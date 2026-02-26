import Redis from 'ioredis';

import { env } from '@config/env';
import { logger } from '@config/logger';

let redisClient: Redis | null = null;
let redisReady = false;

export const initRedis = async () => {
  redisClient = new Redis(env.REDIS_URL, {
    lazyConnect: true,
    keyPrefix: `${env.REDIS_KEY_PREFIX}:`
  });

  redisClient.on('ready', () => {
    redisReady = true;
    logger.info('Redis connected');
  });

  redisClient.on('error', (error) => {
    redisReady = false;
    logger.error(`Redis error: ${error.message}`);
  });

  redisClient.on('end', () => {
    redisReady = false;
    logger.warn('Redis connection closed');
  });

  try {
    await redisClient.connect();
  } catch (error) {
    redisReady = false;
    logger.warn(`Redis unavailable: ${(error as Error).message}`);
  }
};

export const closeRedis = async () => {
  if (!redisClient) {
    return;
  }

  await redisClient.quit();
  redisReady = false;
};

export const getRedisClient = () => redisClient;

export const isRedisReady = () => redisReady;

export const getRedisHealth = () => (redisReady ? 'up' : 'down');
