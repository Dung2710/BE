import dotenv from 'dotenv';
import { z } from 'zod';

dotenv.config({ quiet: true });

const envSchema = z.object({
  NODE_ENV: z.enum(['development', 'test', 'production']).default('development'),
  APP_NAME: z.string().default('poly2026-be'),
  PORT: z.coerce.number().default(8080),
  API_PREFIX: z.string().default('/api/v1'),
  LOG_LEVEL: z.string().default('info'),
  CORS_ORIGIN: z.string().default('*'),
  RATE_LIMIT_WINDOW_MS: z.coerce.number().default(15 * 60 * 1000),
  RATE_LIMIT_MAX_REQUESTS: z.coerce.number().default(200),

  PAGINATION_DEFAULT_PAGE: z.coerce.number().default(1),
  PAGINATION_DEFAULT_LIMIT: z.coerce.number().default(20),
  PAGINATION_MAX_LIMIT: z.coerce.number().default(100),

  MONGODB_URI: z.string().default('mongodb://127.0.0.1:27017/poly2026'),
  MONGODB_REQUIRE_REPLICA_SET: z.string().default('false'),

  JWT_ACCESS_SECRET: z.string().default('dev-access-secret-change-me'),
  JWT_REFRESH_SECRET: z.string().default('dev-refresh-secret-change-me'),
  JWT_ACCESS_EXPIRES_IN: z.string().default('15m'),
  JWT_REFRESH_EXPIRES_IN: z.string().default('7d'),

  REDIS_URL: z.string().default('redis://127.0.0.1:6379'),
  REDIS_KEY_PREFIX: z.string().default('poly2026'),

  KAFKA_ENABLED: z.string().default('false'),
  KAFKA_CLIENT_ID: z.string().default('poly2026-be'),
  KAFKA_BROKERS: z.string().default('127.0.0.1:9092'),
  KAFKA_GROUP_ID: z.string().default('poly2026-be-group'),
  KAFKA_TOPIC_EVENTS: z.string().default('poly2026.events'),

  CLOUDINARY_CLOUD_NAME: z.string().optional(),
  CLOUDINARY_API_KEY: z.string().optional(),
  CLOUDINARY_API_SECRET: z.string().optional(),

  SMTP_HOST: z.string().optional(),
  SMTP_PORT: z.coerce.number().optional(),
  SMTP_USER: z.string().optional(),
  SMTP_PASS: z.string().optional(),
  SMTP_FROM: z.string().optional()
});

const parsedEnv = envSchema.parse(process.env);

const parseOrigins = (value: string) => {
  if (value.trim() === '*') {
    return '*';
  }

  return value
    .split(',')
    .map((origin) => origin.trim())
    .filter(Boolean);
};

export const env = {
  ...parsedEnv,
  corsOriginList: parseOrigins(parsedEnv.CORS_ORIGIN),
  kafkaEnabled: parsedEnv.KAFKA_ENABLED === 'true',
  kafkaBrokers: parsedEnv.KAFKA_BROKERS.split(',')
    .map((broker) => broker.trim())
    .filter(Boolean),
  mongoRequireReplicaSet: parsedEnv.MONGODB_REQUIRE_REPLICA_SET === 'true',
  isProduction: parsedEnv.NODE_ENV === 'production',
  isDevelopment: parsedEnv.NODE_ENV === 'development',
  isTest: parsedEnv.NODE_ENV === 'test'
};
