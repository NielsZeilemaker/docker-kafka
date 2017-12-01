#!/bin/sh

# Start Topic creation
echo "Starting topic creation..."
# Wait for kafka broker to be available
while [ $(echo dump | nc ${HOSTNAME} 2181 | grep brokers) == "" ]
do
  echo "Waiting for Kafka Broker to be available in zookeeper"
  sleep 10
done

until echo exit | nc --send-only ${HOSTNAME} 9092;
do 
  echo "Waiting for Kafka Broker to be really available"
  sleep 10
done

# Run KafkaTopics to create the topics if they don't exist yet
if [[ -n $KAFKA_CREATE_TOPICS ]]; then
  for TOPIC in ${KAFKA_CREATE_TOPICS//,/ }; do
    echo "creating topic: $TOPIC"
    TOPIC_CONFIG=(${TOPIC//:/ })
    if [ ${TOPIC_CONFIG[3]} ]; then
      $KAFKA_HOME/bin/kafka-topics.sh --create --if-not-exists --zookeeper ${HOSTNAME}:2181 --replication-factor ${TOPIC_CONFIG[2]} --partitions ${TOPIC_CONFIG[1]} --topic "${TOPIC_CONFIG[0]}" --config cleanup.policy="${TOPIC_CONFIG[3]}"
    else
      $KAFKA_HOME/bin/kafka-topics.sh --create --if-not-exists --zookeeper ${HOSTNAME}:2181 --replication-factor ${TOPIC_CONFIG[2]} --partitions ${TOPIC_CONFIG[1]} --topic "${TOPIC_CONFIG[0]}"
    fi
  done
fi