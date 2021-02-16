#https://www.vivaolinux.com.br/artigo/Configuracao-simples-Samba-+-LDAP
#https://github.com/gitphill/ldap-alpine

#docker login
#docker build https://github.com/jpmenega/kubernetes.git#main:ldap -t jpmenegatti/ldap:v12
#docker push jpmenegatti/ldap:v12

FROM alpine

ENV ORGANISATION_NAME "UZ Ltda"
ENV SUFFIX "dc=uz,dc=local"
ENV ROOT_USER "admin"
ENV ROOT_PW "Uz2@21TI"
ENV USER_UID "jpmenega"
ENV USER_GIVEN_NAME "Joao Paulo"
ENV USER_SURNAME "Menegatti"
ENV USER_EMAIL "jpmenegatti@hotmail.com"
ENV LDAP_ACCESS_CONTROL "access to * by * read"
ENV LOG_LEVEL "stats"

# Install ldap
RUN apk add --update openldap openldap-back-mdb && \
    rm -rf /var/cache/apk/*

COPY samba.schema /etc/openldap/schema
COPY samba.ldif /etc/openldap/schema
COPY users.ldif /etc/openldap/
COPY organisation.ldif /etc/openldap/ 
COPY docker-entrypoint.sh /


EXPOSE 389 636

VOLUME ["/var/lib/openldap/openldap-data"]

ENTRYPOINT ["/docker-entrypoint.sh"]
