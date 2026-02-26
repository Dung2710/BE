# Poly2026 Backend Base

Starter backend theo kiến trúc MVC thủ tục với:

- TypeScript + path alias
- ExpressJS
- MongoDB + Mongoose
- Redis
- Kafka
- Multer + Cloudinary
- Zod
- Socket.IO
- Nodemailer
- Passport HTTP Bearer (JWT)
- Winston
- ESLint + Prettier
- Jest + Supertest
- Swagger/OpenAPI

## 1. Cài đặt

```bash
npm install
cp .env.example .env
```

## 2. Chạy dự án

```bash
npm run dev
```

Build production:

```bash
npm run build
npm run start
```

## 3. Scripts

- `npm run dev`: chạy local với ts-node-dev
- `npm run build`: compile TypeScript ra `dist/`
- `npm run start`: chạy production build
- `npm run lint`: chạy ESLint
- `npm run lint:fix`: tự sửa lỗi lint có thể fix
- `npm run format`: check format bằng Prettier
- `npm run format:write`: format code
- `npm test`: chạy test
- `npm run test:watch`: chạy test watch mode
- `npm run test:cov`: test coverage

## 4. Kiến trúc thư mục

```text
src/
  config/
  controllers/
  middlewares/
  models/
  routes/
  services/
  sockets/
  types/
  utils/
  validators/
tests/
```

## 5. API base path

- Prefix: `/api/v1`
- Swagger: `/api/v1/docs`

### Endpoint chính

- `GET /api/v1/health`
- `POST /api/v1/auth/register`
- `POST /api/v1/auth/login`
- `POST /api/v1/auth/refresh`
- `POST /api/v1/auth/logout` (Bearer)
- `GET /api/v1/auth/me` (Bearer)
- `POST /api/v1/upload/image` (Bearer)
- `POST /api/v1/mail/test` (Bearer)

## 6. Socket.IO

Auth qua handshake:

- `auth.token = <access_token>`

Events:

- `client:ping` -> `server:pong`
- `room:join`
- `room:message`

## 7. Ghi chú vận hành

- MongoDB là dependency bắt buộc khi boot app chính.
- Redis dùng cho refresh token session. Khi Redis down, refresh/logout trả lỗi.
- Kafka optional qua `KAFKA_ENABLED`.
- Cloudinary/Nodemailer thiếu cấu hình sẽ chỉ làm fail endpoint liên quan, không crash app.
