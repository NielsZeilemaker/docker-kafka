#!/bin/bash

if [ ! -z "$ENABLE_KERBEROS" ]; then
  # Start Kerberos keytab creation
  echo "Starting keytab creation..."
  /usr/bin/configureKerberosClient.sh
  returnedValue=$?
  if [ $returnedValue -eq 0 ]
  then
    echo "Krb5 configuration has been started!"
  else
    echo "Krb5 configuration has failed to start with code $returnedValue."
    return $returnedValue
  fi
fi

# Start Zookeeper.
echo "Starting Zookeeper..."
/usr/bin/start-zookeeper.sh &

# Start Kafka topic creation in the background
/usr/bin/create-kafka-topics.sh &

# Start Kafka on master node.
echo "Starting kafka..."
exec /usr/bin/start-kafka.sh