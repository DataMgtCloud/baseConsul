FROM datamgtcloud/baseos

# data directory
RUN mkdir -p /opt/datamgt/config/srv/consul

# Build user, group, and home dir for services
RUN \
  mkdir -p /etc/service/consul && \
  mkdir /home/svc && \
  groupadd -g 616 svc && \
  useradd -u 616 -g svc -d /home/svc -s /sbin/nologin -c "Service user" svc && \
  chown -R svc:svc /home/svc

# Download Consul
RUN \
  mkdir -p /opt/datamgt/bin/ && \
  curl -s https://releases.hashicorp.com/consul/0.6.4/consul_0.6.4_linux_amd64.zip -o consul.zip && \
  unzip consul.zip && \
  rm consul.zip && \
  mv consul /opt/datamgt/bin/

# expose Consul client agent ports
EXPOSE 8301 8301/udp
