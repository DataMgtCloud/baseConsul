FROM ubuntu

RUN \
  apt-get update && \
  apt-get -y install runit curl iputils-ping dnsutils netcat unzip && \
  apt-get -y autoremove && \
  apt-get clean

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

# expose Consul client agent ports
EXPOSE 8301 8301/udp

ADD boot.sh /sbin/boot
CMD ["/sbin/boot"]
