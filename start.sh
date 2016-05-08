#!/bin/bash
echo "Start the consul container"

export DEFAULT_CONFIG_DIR="-config-dir /etc/consul.d"
export CONSUL_OPTIONS="$CONSUL_OPTIONS $DEFAULT_CONFIG_DIR"

start_consul_agent(){
  GOMAXPROCS=2 exec /opt/datamgt/home/bin/consul agent $CONSUL_OPTIONS
}

scan_file(){
  if [[ -f $1 ]]
  then
    while read -r line
    do
      if [[ $line == *\"server* ]] && [[ $line == *true* ]] ;
      then
        echo Config file = $1 has server flag set. Consul agent will be started...
        start_consul_agent
      fi
    done < $1
  fi
}

scan_folder(){
  FILES=$1/*
  for f in $FILES
  do
    if [ ! -z "$f" ]
    then
      scan_file $f
    fi
  done
}

if [ ! -z "$CONSUL_PORT_8500_TCP_ADDR" ]
then
  export CONSUL_OPTIONS="$CONSUL_OPTIONS -join $CONSUL_PORT_8500_TCP_ADDR"
fi

# Drop existing peers because Docker reassigns new IP addresses for each container start
if [ -f /opt/datamgt/config/srv/consul/raft/peers.json ]
then
  rm /opt/datamgt/config/srv/consul/raft/peers.json
fi

# scan consul_options for config-file, config-dir, and config-server entries
IFS=' ' read -a array <<< $CONSUL_OPTIONS
for index in "${!array[@]}"
do
  if [[ -config-file == ${array[index]} ]] ;
  then
    scan_file ${array[index+1]}
  elif [[ -server == ${array[index]} ]] ;
  then
    echo CONSUL_OPTIONS contains -server flag. Consul agent will be started...
    start_consul_agent
  elif [[ -config-dir == ${array[index]} ]] ;
  then
    scan_folder ${array[index+1]}
  fi
done

# if server still not set, only start if consul_port_8500_tcp_addr is
if [ ! -z "$CONSUL_PORT_8500_TCP_ADDR" ] ;
then
  # create /etc/mtab if it doesn't exist (for CF Diego)
  [ ! -e /etc/mtab -a -e /proc/mounts ] && ln -s /proc/mounts /etc/mtab
  echo CONSUL_PORT_8500_TCP_ADDR has been set. Consul agent will be started...
  start_consul_agent
fi
