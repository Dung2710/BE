-- Mongo-oriented schema mapping for backend models
-- Documentation contract aligned with Mongoose models.
-- ObjectId values are represented as varchar(24) and embedded structures as jsonb.

CREATE TABLE users (
  id varchar(24) PRIMARY KEY,
  username varchar,
  email varchar NOT NULL,
  "passwordHash" varchar NOT NULL,
  "fullName" varchar,
  phone varchar,
  role varchar NOT NULL DEFAULT 'customer' CHECK (role IN ('customer', 'staff', 'admin')),
  "avatarUrl" varchar,
  "loyaltyPoints" integer NOT NULL DEFAULT 0,
  "membershipTier" varchar NOT NULL DEFAULT 'bronze' CHECK ("membershipTier" IN ('bronze', 'silver', 'gold', 'platinum')),
  "staffDepartment" varchar,
  "staffStartDate" timestamp with time zone,
  "createdAt" timestamp with time zone NOT NULL DEFAULT now(),
  "updatedAt" timestamp with time zone NOT NULL DEFAULT now()
);

CREATE UNIQUE INDEX users_email_unique_idx ON users (email);
CREATE UNIQUE INDEX users_username_unique_not_null_idx ON users (username) WHERE username IS NOT NULL;

CREATE TABLE addresses (
  id varchar(24) PRIMARY KEY,
  "userId" varchar(24) NOT NULL,
  label varchar NOT NULL DEFAULT 'Home',
  "recipientName" varchar NOT NULL,
  phone varchar NOT NULL,
  street varchar NOT NULL,
  city varchar NOT NULL,
  district varchar NOT NULL,
  ward varchar NOT NULL,
  "isDefault" boolean NOT NULL DEFAULT false
);

ALTER TABLE addresses
  ADD CONSTRAINT addresses_userid_fk FOREIGN KEY ("userId") REFERENCES users (id);

CREATE INDEX addresses_userid_isdefault_idx ON addresses ("userId", "isDefault");

CREATE TABLE categories (
  id varchar(24) PRIMARY KEY,
  name varchar NOT NULL,
  slug varchar NOT NULL,
  description text,
  "parentId" varchar(24),
  image varchar,
  "isActive" boolean NOT NULL DEFAULT true,
  "createdAt" timestamp with time zone NOT NULL DEFAULT now(),
  "updatedAt" timestamp with time zone NOT NULL DEFAULT now()
);

ALTER TABLE categories
  ADD CONSTRAINT categories_parentid_fk FOREIGN KEY ("parentId") REFERENCES categories (id);

CREATE UNIQUE INDEX categories_slug_unique_idx ON categories (slug);

CREATE TABLE products (
  id varchar(24) PRIMARY KEY,
  name varchar NOT NULL,
  slug varchar NOT NULL,
  sku varchar NOT NULL,
  "categoryId" varchar(24) NOT NULL,
  price double precision NOT NULL CHECK (price >= 0),
  "originalPrice" double precision CHECK ("originalPrice" >= 0),
  description text,
  attributes jsonb NOT NULL DEFAULT '{}'::jsonb,
  images jsonb NOT NULL DEFAULT '[]'::jsonb,
  "stockQuantity" integer NOT NULL DEFAULT 0 CHECK ("stockQuantity" >= 0),
  "isAvailable" boolean NOT NULL DEFAULT true,
  "metaTitle" varchar,
  "metaDescription" text,
  "averageRating" double precision NOT NULL DEFAULT 0 CHECK ("averageRating" >= 0 AND "averageRating" <= 5),
  "reviewCount" integer NOT NULL DEFAULT 0 CHECK ("reviewCount" >= 0),
  "soldCount" integer NOT NULL DEFAULT 0 CHECK ("soldCount" >= 0),
  "createdAt" timestamp with time zone NOT NULL DEFAULT now(),
  "updatedAt" timestamp with time zone NOT NULL DEFAULT now()
);

ALTER TABLE products
  ADD CONSTRAINT products_categoryid_fk FOREIGN KEY ("categoryId") REFERENCES categories (id);

CREATE UNIQUE INDEX products_slug_unique_idx ON products (slug);
CREATE UNIQUE INDEX products_sku_unique_idx ON products (sku);
CREATE INDEX products_categoryid_isavailable_idx ON products ("categoryId", "isAvailable");

CREATE TABLE inventory_logs (
  id varchar(24) PRIMARY KEY,
  "productId" varchar(24) NOT NULL,
  "variantSku" varchar,
  "changeAmount" integer NOT NULL,
  reason varchar NOT NULL CHECK (reason IN ('import', 'sale', 'return', 'adjustment', 'damage')),
  "performedBy" varchar(24) NOT NULL,
  note text,
  "createdAt" timestamp with time zone NOT NULL DEFAULT now()
);

ALTER TABLE inventory_logs
  ADD CONSTRAINT inventory_logs_productid_fk FOREIGN KEY ("productId") REFERENCES products (id);

ALTER TABLE inventory_logs
  ADD CONSTRAINT inventory_logs_performedby_fk FOREIGN KEY ("performedBy") REFERENCES users (id);

CREATE INDEX inventory_logs_productid_createdat_desc_idx ON inventory_logs ("productId", "createdAt" DESC);

CREATE TABLE carts (
  id varchar(24) PRIMARY KEY,
  "userId" varchar(24) NOT NULL,
  items jsonb NOT NULL DEFAULT '[]'::jsonb,
  "updatedAt" timestamp with time zone NOT NULL DEFAULT now()
);

ALTER TABLE carts
  ADD CONSTRAINT carts_userid_fk FOREIGN KEY ("userId") REFERENCES users (id);

CREATE UNIQUE INDEX carts_userid_unique_idx ON carts ("userId");

CREATE TABLE vouchers (
  id varchar(24) PRIMARY KEY,
  code varchar NOT NULL,
  description text,
  "discountType" varchar NOT NULL CHECK ("discountType" IN ('percentage', 'fixed_amount')),
  "discountValue" double precision NOT NULL CHECK ("discountValue" >= 0),
  "minOrderValue" double precision NOT NULL DEFAULT 0 CHECK ("minOrderValue" >= 0),
  "maxDiscountAmount" double precision CHECK ("maxDiscountAmount" >= 0),
  "startDate" timestamp with time zone NOT NULL,
  "expirationDate" timestamp with time zone NOT NULL,
  "usageLimit" integer NOT NULL CHECK ("usageLimit" >= 0),
  "usedCount" integer NOT NULL DEFAULT 0 CHECK ("usedCount" >= 0),
  "isActive" boolean NOT NULL DEFAULT true,
  "createdAt" timestamp with time zone NOT NULL DEFAULT now(),
  "updatedAt" timestamp with time zone NOT NULL DEFAULT now(),
  CHECK ("expirationDate" >= "startDate")
);

CREATE UNIQUE INDEX vouchers_code_unique_idx ON vouchers (code);

CREATE TABLE orders (
  id varchar(24) PRIMARY KEY,
  "orderCode" varchar NOT NULL,
  "userId" varchar(24) NOT NULL,
  "shippingRecipientName" varchar NOT NULL,
  "shippingPhone" varchar NOT NULL,
  "shippingAddress" text NOT NULL,
  subtotal double precision NOT NULL CHECK (subtotal >= 0),
  "shippingFee" double precision NOT NULL DEFAULT 0 CHECK ("shippingFee" >= 0),
  "discountAmount" double precision NOT NULL DEFAULT 0 CHECK ("discountAmount" >= 0),
  "totalAmount" double precision NOT NULL CHECK ("totalAmount" >= 0),
  "paymentMethod" varchar NOT NULL DEFAULT 'cod' CHECK ("paymentMethod" IN ('cod', 'banking', 'momo', 'vnpay')),
  "paymentStatus" varchar NOT NULL DEFAULT 'pending' CHECK ("paymentStatus" IN ('pending', 'paid', 'failed', 'refunded')),
  "voucherId" varchar(24),
  status varchar NOT NULL DEFAULT 'pending' CHECK (status IN ('pending', 'confirmed', 'preparing', 'shipping', 'delivered', 'cancelled', 'returned')),
  items jsonb NOT NULL DEFAULT '[]'::jsonb,
  "statusHistory" jsonb NOT NULL DEFAULT '[]'::jsonb,
  "createdAt" timestamp with time zone NOT NULL DEFAULT now(),
  "updatedAt" timestamp with time zone NOT NULL DEFAULT now()
);

ALTER TABLE orders
  ADD CONSTRAINT orders_userid_fk FOREIGN KEY ("userId") REFERENCES users (id);

ALTER TABLE orders
  ADD CONSTRAINT orders_voucherid_fk FOREIGN KEY ("voucherId") REFERENCES vouchers (id);

CREATE UNIQUE INDEX orders_ordercode_unique_idx ON orders ("orderCode");
CREATE INDEX orders_userid_createdat_desc_idx ON orders ("userId", "createdAt" DESC);
CREATE INDEX orders_status_createdat_desc_idx ON orders (status, "createdAt" DESC);

CREATE TABLE reviews (
  id varchar(24) PRIMARY KEY,
  "productId" varchar(24) NOT NULL,
  "userId" varchar(24) NOT NULL,
  "orderId" varchar(24) NOT NULL,
  rating integer NOT NULL CHECK (rating >= 1 AND rating <= 5),
  content text,
  images jsonb NOT NULL DEFAULT '[]'::jsonb,
  "isPublished" boolean NOT NULL DEFAULT true,
  "replyContent" text,
  "repliedAt" timestamp with time zone,
  "repliedBy" varchar(24),
  "createdAt" timestamp with time zone NOT NULL DEFAULT now(),
  "updatedAt" timestamp with time zone NOT NULL DEFAULT now()
);

ALTER TABLE reviews
  ADD CONSTRAINT reviews_productid_fk FOREIGN KEY ("productId") REFERENCES products (id);

ALTER TABLE reviews
  ADD CONSTRAINT reviews_userid_fk FOREIGN KEY ("userId") REFERENCES users (id);

ALTER TABLE reviews
  ADD CONSTRAINT reviews_orderid_fk FOREIGN KEY ("orderId") REFERENCES orders (id);

ALTER TABLE reviews
  ADD CONSTRAINT reviews_repliedby_fk FOREIGN KEY ("repliedBy") REFERENCES users (id);

CREATE UNIQUE INDEX reviews_orderid_productid_unique_idx ON reviews ("orderId", "productId");
CREATE INDEX reviews_productid_createdat_desc_idx ON reviews ("productId", "createdAt" DESC);

CREATE TABLE comments (
  id varchar(24) PRIMARY KEY,
  "targetId" varchar(24) NOT NULL,
  "targetModel" varchar NOT NULL CHECK ("targetModel" IN ('product', 'lesson')),
  "userId" varchar(24) NOT NULL,
  content text NOT NULL,
  "parentId" varchar(24),
  "isHidden" boolean NOT NULL DEFAULT false,
  "createdAt" timestamp with time zone NOT NULL DEFAULT now()
);

ALTER TABLE comments
  ADD CONSTRAINT comments_userid_fk FOREIGN KEY ("userId") REFERENCES users (id);

ALTER TABLE comments
  ADD CONSTRAINT comments_parentid_fk FOREIGN KEY ("parentId") REFERENCES comments (id);

CREATE INDEX comments_targetmodel_targetid_createdat_desc_idx
  ON comments ("targetModel", "targetId", "createdAt" DESC);

CREATE TABLE chat_conversations (
  id varchar(24) PRIMARY KEY,
  type varchar NOT NULL DEFAULT 'support',
  "isActive" boolean NOT NULL DEFAULT true,
  "customerId" varchar(24),
  "participantIds" jsonb NOT NULL DEFAULT '[]'::jsonb,
  "createdAt" timestamp with time zone NOT NULL DEFAULT now(),
  "updatedAt" timestamp with time zone NOT NULL DEFAULT now()
);

ALTER TABLE chat_conversations
  ADD CONSTRAINT chat_conversations_customerid_fk FOREIGN KEY ("customerId") REFERENCES users (id);

-- Mongo multikey intent for participantIds + updatedAt DESC is represented by:
-- 1) GIN index for participantIds membership lookup
-- 2) B-Tree index for updatedAt DESC sorting
CREATE INDEX chat_conversations_participantids_gin_idx
  ON chat_conversations USING GIN ("participantIds");

CREATE INDEX chat_conversations_updatedat_desc_idx
  ON chat_conversations ("updatedAt" DESC);

CREATE TABLE chat_messages (
  id varchar(24) PRIMARY KEY,
  "conversationId" varchar(24) NOT NULL,
  "senderId" varchar(24) NOT NULL,
  content text NOT NULL,
  "isRead" boolean NOT NULL DEFAULT false,
  "readBy" jsonb NOT NULL DEFAULT '[]'::jsonb,
  "createdAt" timestamp with time zone NOT NULL DEFAULT now(),
  "updatedAt" timestamp with time zone NOT NULL DEFAULT now()
);

ALTER TABLE chat_messages
  ADD CONSTRAINT chat_messages_conversationid_fk FOREIGN KEY ("conversationId") REFERENCES chat_conversations (id);

ALTER TABLE chat_messages
  ADD CONSTRAINT chat_messages_senderid_fk FOREIGN KEY ("senderId") REFERENCES users (id);

CREATE INDEX chat_messages_conversationid_createdat_desc_idx
  ON chat_messages ("conversationId", "createdAt" DESC);

CREATE TABLE courses (
  id varchar(24) PRIMARY KEY,
  title varchar NOT NULL,
  description text,
  thumbnail varchar,
  "instructorId" varchar(24) NOT NULL,
  "isActive" boolean NOT NULL DEFAULT true,
  "createdAt" timestamp with time zone NOT NULL DEFAULT now(),
  "updatedAt" timestamp with time zone NOT NULL DEFAULT now()
);

ALTER TABLE courses
  ADD CONSTRAINT courses_instructorid_fk FOREIGN KEY ("instructorId") REFERENCES users (id);

CREATE INDEX courses_instructorid_createdat_desc_idx ON courses ("instructorId", "createdAt" DESC);

CREATE TABLE modules (
  id varchar(24) PRIMARY KEY,
  "courseId" varchar(24) NOT NULL,
  title varchar NOT NULL,
  "order" integer NOT NULL DEFAULT 0
);

ALTER TABLE modules
  ADD CONSTRAINT modules_courseid_fk FOREIGN KEY ("courseId") REFERENCES courses (id);

CREATE INDEX modules_courseid_order_idx ON modules ("courseId", "order");

CREATE TABLE lessons (
  id varchar(24) PRIMARY KEY,
  "moduleId" varchar(24) NOT NULL,
  title varchar NOT NULL,
  content text,
  duration integer CHECK (duration IS NULL OR duration > 0),
  "isRequired" boolean NOT NULL DEFAULT true,
  "order" integer NOT NULL DEFAULT 0
);

ALTER TABLE lessons
  ADD CONSTRAINT lessons_moduleid_fk FOREIGN KEY ("moduleId") REFERENCES modules (id);

CREATE INDEX lessons_moduleid_order_idx ON lessons ("moduleId", "order");

CREATE TABLE employee_progress (
  id varchar(24) PRIMARY KEY,
  "userId" varchar(24) NOT NULL,
  "courseId" varchar(24) NOT NULL,
  status varchar NOT NULL DEFAULT 'enrolled' CHECK (status IN ('enrolled', 'in_progress', 'completed')),
  "progressPercentage" double precision NOT NULL DEFAULT 0 CHECK ("progressPercentage" >= 0 AND "progressPercentage" <= 100),
  "enrolledAt" timestamp with time zone NOT NULL DEFAULT now(),
  "completedAt" timestamp with time zone,
  "completedLessonIds" jsonb NOT NULL DEFAULT '[]'::jsonb,
  "createdAt" timestamp with time zone NOT NULL DEFAULT now(),
  "updatedAt" timestamp with time zone NOT NULL DEFAULT now()
);

ALTER TABLE employee_progress
  ADD CONSTRAINT employee_progress_userid_fk FOREIGN KEY ("userId") REFERENCES users (id);

ALTER TABLE employee_progress
  ADD CONSTRAINT employee_progress_courseid_fk FOREIGN KEY ("courseId") REFERENCES courses (id);

CREATE UNIQUE INDEX employee_progress_userid_courseid_unique_idx
  ON employee_progress ("userId", "courseId");
