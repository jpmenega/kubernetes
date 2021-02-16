#!/bin/sh
# docker entrypoint script
# configures and starts LDAP

# test for ldaps configuration
LDAPS=true
if [ -z "$KEY_FILE" ] || [ -z "$CERT_FILE" ] || [ -z "$CA_FILE" ]; then
  LDAPS=false
fi

if [ "$LDAPS" = true ]; then

  # ensure certificates exist
  RETRY=0
  MAX_RETRIES=3
  until [ -f "$KEY_FILE" ] && [ -f "$CERT_FILE" ] && [ -f "$CA_FILE" ] || [ "$RETRY" -eq "$MAX_RETRIES" ]; do
    RETRY=$((RETRY+1))
    echo "Cannot find certificates. Retry ($RETRY/$MAX_RETRIES) ..."
    sleep 1
  done

  # exit if no certificates were found after maximum retries
  if [ "$RETRY" -eq "$MAX_RETRIES" ]; then
    echo "Cannot start ldap, the following certificates do not exist"
    echo " CA_FILE:   $CA_FILE"
    echo " KEY_FILE:  $KEY_FILE"
    echo " CERT_FILE: $CERT_FILE"
    exit 1
  fi

fi

# replace variables in slapd.conf
SLAPD_CONF="/etc/openldap/slapd.conf"

sed '/^include/a include         /etc/openldap/schema/cosine.schema\n' "$SLAPD_CONF"
sed '/^cosine/a include         /etc/openldap/schema/inetorgperson.schema' "$SLAPD_CONF"

# uncomment back_mdb module configurations
sed -i '/modulepath/s/^# //g' "$SLAPD_CONF"
sed -i '/back_mdb.la/s/^# //g' "$SLAPD_CONF"
sed -i "s~back_mdb.la~back_mdb~g" "$SLAPD_CONF"

mkdir /var/lib/openldap/run
#sed -i "/pidfile/c\pidfile        /run/openldap/slapd.pid" "$SLAPD_CONF"
#sed -i "/argsfile/c\argsfile        /run/openldap/slapd.argsfile" "$SLAPD_CONF"

if [ "$LDAPS" = true ]; then
  sed -i "s~%CA_FILE%~$CA_FILE~g" "$SLAPD_CONF"
  sed -i "s~%KEY_FILE%~$KEY_FILE~g" "$SLAPD_CONF"
  sed -i "s~%CERT_FILE%~$CERT_FILE~g" "$SLAPD_CONF"
  if [ -n "$TLS_VERIFY_CLIENT" ]; then
    sed -i "/TLSVerifyClient/ s/demand/$TLS_VERIFY_CLIENT/" "$SLAPD_CONF"
  fi
else
  # comment out TLS configuration
  sed -i "s~TLSCACertificateFile~#&~" "$SLAPD_CONF"
  sed -i "s~TLSCertificateKeyFile~#&~" "$SLAPD_CONF"
  sed -i "s~TLSCertificateFile~#&~" "$SLAPD_CONF"
  sed -i "s~TLSVerifyClient~#&~" "$SLAPD_CONF"
fi

#sed -i "s~%ROOT_USER%~$ROOT_USER~g" "$SLAPD_CONF"
#sed -i "s~%SUFFIX%~$SUFFIX~g" "$SLAPD_CONF"
#sed -i "/EVERYTHING/c\$LDAP_ACCESS_CONTROL" "$SLAPD_CONF"
echo "access to * by * read" >> "$SLAPD_CONF"
sed -i "/suffix/c\suffix        $SUFFIX" "$SLAPD_CONF"
sed -i "/Manager/c\rootdn        cn=$ROOT_USER,$SUFFIX" "$SLAPD_CONF"
#sed -i "s~%ACCESS_CONTROL%~$ACCESS_CONTROL~g" "$SLAPD_CONF"

# encrypt root password before replacing
ROOT_PW=$(slappasswd -s "$ROOT_PW")
sed -i "s~secret~$ROOT_PW~g" "$SLAPD_CONF"

# replace variables in organisation configuration
ORG_CONF="/etc/openldap/organisation.ldif"
sed -i "s~%SUFFIX%~$SUFFIX~g" "$ORG_CONF"
sed -i "s~%ORGANISATION_NAME%~$ORGANISATION_NAME~g" "$ORG_CONF"

# replace variables in user configuration
USER_CONF="/etc/openldap/users.ldif"
sed -i "s~%SUFFIX%~$SUFFIX~g" "$USER_CONF"
sed -i "s~%USER_UID%~$USER_UID~g" "$USER_CONF"
sed -i "s~%USER_GIVEN_NAME%~$USER_GIVEN_NAME~g" "$USER_CONF"
sed -i "s~%USER_SURNAME%~$USER_SURNAME~g" "$USER_CONF"
if [ -z "$USER_PW" ]; then USER_PW="password"; fi
sed -i "s~%USER_PW%~$USER_PW~g" "$USER_CONF"
sed -i "s~%USER_EMAIL%~$USER_EMAIL~g" "$USER_CONF"

# add organisation and users to ldap (order is important)
slapadd -l "$ORG_CONF"
slapadd -l "$USER_CONF"

# add any scripts in ldif
for l in /ldif/*; do
  case "$l" in
    *.ldif)  echo "ENTRYPOINT: adding $l";
            slapadd -l $l
            ;;
    *)      echo "ENTRYPOINT: ignoring $l" ;;
  esac
done

echo "==========================="
cat $SLAPD_CONF
echo "==========================="
echo $SUFFIX
echo $LDAP_ACCESS_CONTROL
ls -lah /var/lib/openldap/run/
echo "xxxx"
ls -lah /run/openldap/
echo "==========================="

if [ "$LDAPS" = true ]; then
  echo "Starting LDAPS"
  slapd -d "$LOG_LEVEL" -h "ldaps:///"
else
  echo "Starting LDAP"
  slapd -d "$LOG_LEVEL" -h "ldap:///"
fi

# run command passed to docker run
exec "$@"
