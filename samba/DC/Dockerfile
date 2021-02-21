#docker login
#docker build https://github.com/jpmenega/kubernetes.git#main:samba -t jpmenegatti/samba:v9
#docker build . --privileged -t jpmenegatti/sambadc:v1
#docker push jpmenegatti/samba:v9

FROM ubuntu:xenial

# Install samba
RUN apt-get -y update && \
    #echo "adc1" > /etc/hostname && \
    #hostname -F /etc/hostname && \
    #rm /etc/hostname && \
    export DEBIAN_FRONTEND=noninteractive && \
    apt-get -y install samba krb5-user krb5-config winbind libpam-winbind libnss-winbind && \
    fileConf="/etc/krb5.conf" && \
    echo "[libdefaults]" > $fileConf && \
    echo "        default_realm = UZ.COM.BR" >> $fileConf && \
    echo "        fcc-mit-ticketflags = true" >> $fileConf && \
    echo "[realms]" >> $fileConf && \
    echo "        UZ.COM.BR = {" >> $fileConf && \
    echo "                kdc = uz.com.br" >> $fileConf && \
    echo "                admin_server = uz.com.br" >> $fileConf && \
    echo "        }" >> $fileConf && \
    mv /etc/samba/smb.conf /etc/samba/smb.conf.initial 
    #samba-tool domain provision --server-role=dc --use-rfc2307 --dns-backend=SAMBA_INTERNAL --realm=UZ.COM.BR --domain=UZ --adminpass=Uz2@21TI

#COPY samba.sh /usr/bin/

EXPOSE 137/udp 138/udp 139 445

#VOLUME ["/etc/hostname"]

#HEALTHCHECK --interval=60s --timeout=15s \
#            CMD smbclient -L \\localhost -U % -m SMB3

ENTRYPOINT ["/bin/bash", "-c", "while true; do echo waiting; sleep 1000; done"]
