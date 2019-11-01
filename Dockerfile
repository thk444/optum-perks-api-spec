FROM nginx:1.17.5-alpine
LABEL maintainer="Livefront <app-distribution@livefront.com>"

# Configure ssh to be available for Azure.
RUN apk add --no-cache openssh
COPY .docker/azure-sshd-config /etc/ssh/sshd_config
RUN ssh-keygen -A
RUN mkdir -p /var/run/sshd
RUN echo "root:Docker!" | chpasswd

# Set the nginx port to 8080.
RUN sed -i "s/listen\s\+80;/listen 8080;/g" /etc/nginx/conf.d/default.conf

# Give Azure access to sshd and the nginx server.
EXPOSE 2222 8080

COPY .docker/index.html optum-searchrx-api-spec.yml /usr/share/nginx/html/
