FROM datamgtcloud/baseos

#executables
RUN mkdir -p /opt/datamgt/bin/

# data directory
RUN mkdir -p /opt/datamgt/config/srv/consul

RUN \
  curl -s https://releases.hashicorp.com/consul/0.6.4/consul_0.6.4_linux_amd64.zip -o consul.zip && \
  unzip consul.zip && \
  rm consul.zip && \
  mv consul /opt/datamgt/bin/


# Set up consul as a runit service
COPY config-consul.json /etc/consul.d/
COPY start.sh /usr/runit/consul/run.sh
RUN \
  mkdir -p /etc/service/consul && \
  ln -s /usr/runit/consul/run.sh /etc/service/consul/run

# Build user, group, and home dir for services
RUN \
  mkdir /home/svc && \
  groupadd -g 616 svc && \
  useradd -u 616 -g svc -d /home/svc -s /sbin/nologin -c "Service user" svc && \
  chown -R svc:svc /home/svc

# expose Consul client agent ports
EXPOSE 8301 8301/udp

ADD boot.sh /sbin/boot
CMD ["/sbin/boot"]
