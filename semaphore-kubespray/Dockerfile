# Build from Debian based python image
FROM python:3.10.12-slim-bullseye

# Set default environment variables 
ENV SEMAPHORE_DB_USER=semaphore
ENV SEMAPHORE_DB_PASS=semaphore
ENV SEMAPHORE_DB_HOST=mysql
ENV SEMAPHORE_DB_PORT=3306
ENV SEMAPHORE_DB_DIALECT=mysql
ENV SEMAPHORE_DB=semaphore
ENV SEMAPHORE_PLAYBOOK_PATH=/tmp/semaphore/
ENV SEMAPHORE_ADMIN_PASSWORD=changeme
ENV SEMAPHORE_ADMIN_NAME=admin
ENV SEMAPHORE_ADMIN_EMAIL=admin@localhost
ENV SEMAPHORE_ADMIN=admin
ENV SEMAPHORE_ACCESS_KEY_ENCRYPTION=gs72mPntFATGJs9qK0pQ0rKtfidlexiMjYCH9gWKhTU=

# Install required packages
RUN apt-get -y update && apt-get -y install git wget gettext
# Install Ansible
RUN git clone https://github.com/kubernetes-sigs/kubespray /tmp/kubespray
RUN cd /tmp/kubespray && pip install -U -r requirements.txt
# Download and install semaphore
RUN cd /tmp && wget https://github.com/ansible-semaphore/semaphore/releases/\
download/v2.8.90/semaphore_2.8.90_linux_amd64.deb 
RUN dpkg -i /tmp/semaphore_2.8.90_linux_amd64.deb 
# Copy semaphore config
COPY config_template.json /semaphore/config_template.json
COPY entrypoint.sh /semaphore/entrypoint.sh
RUN chmod +x /semaphore/entrypoint.sh

# Clean up
RUN rm -rf /tmp/kubespray && rm -rf /tmp/semaphore_2.8.90_linux_amd64.deb 
# Startup process
ENTRYPOINT ["/semaphore/entrypoint.sh"]
