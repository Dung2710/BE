import { Kafka, logLevel, type Consumer, type Producer } from 'kafkajs';

import { env } from '@config/env';
import { logger } from '@config/logger';

let kafka: Kafka | null = null;
let producer: Producer | null = null;
let consumer: Consumer | null = null;
let kafkaReady = false;

export const initKafka = async () => {
  if (!env.kafkaEnabled) {
    logger.info('Kafka disabled by env');
    return;
  }

  kafka = new Kafka({
    clientId: env.KAFKA_CLIENT_ID,
    brokers: env.kafkaBrokers,
    logLevel: logLevel.NOTHING
  });

  producer = kafka.producer();
  consumer = kafka.consumer({ groupId: env.KAFKA_GROUP_ID });

  try {
    await producer.connect();
    await consumer.connect();
    kafkaReady = true;
    logger.info('Kafka connected');
  } catch (error) {
    kafkaReady = false;
    logger.error(`Kafka unavailable: ${(error as Error).message}`);
  }
};

export const closeKafka = async () => {
  if (!env.kafkaEnabled) {
    return;
  }

  await producer?.disconnect();
  await consumer?.disconnect();
  kafkaReady = false;
};

export const getKafkaProducer = () => producer;

export const getKafkaConsumer = () => consumer;

export const isKafkaReady = () => kafkaReady;

export const getKafkaHealth = () => {
  if (!env.kafkaEnabled) {
    return 'disabled';
  }

  return kafkaReady ? 'up' : 'down';
};
