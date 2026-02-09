-- =============================================
-- PayOS Payment Integration - Database Schema
-- =============================================

USE japanese_web;
GO

-- 1. Add Premium columns to users table
ALTER TABLE users ADD is_premium BIT DEFAULT 0;
ALTER TABLE users ADD premium_until DATETIME NULL;
GO

-- 2. Create payments table
CREATE TABLE payments (
    payment_id INT IDENTITY(1,1) PRIMARY KEY,
    user_id INT NOT NULL,
    order_code BIGINT UNIQUE NOT NULL,
    amount INT NOT NULL,
    description NVARCHAR(255),
    status VARCHAR(20) DEFAULT 'PENDING', -- PENDING, PAID, CANCELLED, EXPIRED
    payment_method VARCHAR(50),
    checkout_url NVARCHAR(500),
    created_at DATETIME DEFAULT GETDATE(),
    paid_at DATETIME NULL,
    FOREIGN KEY (user_id) REFERENCES users(id)
);
GO

-- 3. Create index for faster lookup
CREATE INDEX idx_payments_order_code ON payments(order_code);
CREATE INDEX idx_payments_user_id ON payments(user_id);
GO

-- 4. Premium subscription plans (optional - for future use)
CREATE TABLE subscription_plans (
    plan_id INT IDENTITY(1,1) PRIMARY KEY,
    name NVARCHAR(100) NOT NULL,
    price INT NOT NULL, -- in VND
    duration_days INT NOT NULL,
    description NVARCHAR(500),
    is_active BIT DEFAULT 1
);
GO

-- Insert default Premium plan
INSERT INTO subscription_plans (name, price, duration_days, description)
VALUES 
(N'Premium 1 Tháng', 99000, 30, N'Truy cập tất cả bài học N5-N1, AI Chat không giới hạn'),
(N'Premium 3 Tháng', 249000, 90, N'Tiết kiệm 16% so với gói 1 tháng'),
(N'Premium 1 Năm', 799000, 365, N'Tiết kiệm 33% so với gói 1 tháng');
GO
