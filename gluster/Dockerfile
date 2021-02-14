#docker login
#docker build https://github.com/jpmenega/kubernetes.git#main:gluster -t jpmenegatti/fssupport:v2
#docker push jpmenegatti/fssupport:v2

FROM nginx AS fssupport
COPY 99-initFolders.sh /docker-entrypoint.d
RUN chmod +x /docker-entrypoint.d/99-initFolders.sh
