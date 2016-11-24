FROM jwilder/nginx-proxy
MAINTAINER Mikko Piuhola

# Create some temporary directory
# to run the startup scripts from
WORKDIR /cert-app
ADD . /cert-app/
RUN chmod +x /cert-app/start.sh

CMD /cert-app/start.sh
