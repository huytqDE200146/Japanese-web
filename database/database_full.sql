-- =============================================
-- Japanese Learning Web - Full Database Schema
-- SQL Server (MSSQL)
-- Generated: 2026-02-19
-- =============================================

-- ===== 1. TẠO DATABASE =====
CREATE DATABASE japanese_web;
GO

USE japanese_web;
GO


-- =============================================
-- 2. BẢNG USERS
-- =============================================
CREATE TABLE users (
    id INT IDENTITY(1,1) PRIMARY KEY,
    username VARCHAR(50) NOT NULL UNIQUE,
    password VARCHAR(255) NOT NULL,
    email VARCHAR(100),
    full_name VARCHAR(100),
    role VARCHAR(20) DEFAULT 'USER',
    status VARCHAR(20) DEFAULT 'ACTIVE',
    created_at DATETIME DEFAULT GETDATE(),
    is_premium BIT DEFAULT 0,
    premium_until DATETIME NULL,
    google_id VARCHAR(255) NULL
);
GO

-- Dữ liệu mẫu users
INSERT INTO users (username, password, email, full_name, role, status) VALUES
('huy01',       '123456', 'huy01@gmail.com',     'Tran Quoc Huy',   'USER', 'ACTIVE'),
('linh02',      '123456', 'linh02@gmail.com',     'Nguyen Thi Linh', 'USER', 'ACTIVE'),
('nam03',       '123456', 'nam03@gmail.com',      'Le Van Nam',      'USER', 'ACTIVE'),
('nhaphuong22', '123456', 'nhaphuong@gmail.com',   'Le Nha Phuong',   'USER', 'ACTIVE'),
('testban',     '123456', 'testban@gmail.com',     'User Bi Khoa',    'USER', 'BAN');
GO


-- =============================================
-- 3. BẢNG LESSON
-- =============================================
CREATE TABLE lesson (
    lesson_id INT IDENTITY(1,1) PRIMARY KEY,
    name NVARCHAR(200) NOT NULL,
    level NVARCHAR(10) NOT NULL,
    description NVARCHAR(MAX),
    content_path NVARCHAR(255) NOT NULL,
    created_at DATETIME DEFAULT GETDATE()
);
GO

-- Dữ liệu mẫu lessons
INSERT INTO lesson (name, level, description, content_path) VALUES
-- Hiragana
(N'Hiragana cơ bản', 'N5', N'Học bảng chữ cái Hiragana cơ bản', N'lessons/n5/hiragana.html'),

-- Katakana
(N'Katakana cơ bản', 'N5', N'Học bảng chữ cái Katakana', N'lessons/n5/katakana.html'),

-- Từ Vựng & Kanji
(N'Từ Vựng & Kanji', 'N5', N'Bài 1', N'lessons/n5/vocabulary1.html'),
(N'Từ Vựng & Kanji', 'N5', N'Bài 2', N'lessons/n5/vocabulary2.html'),
(N'Từ Vựng & Kanji', 'N5', N'Bài 3', N'lessons/n5/vocabulary3.html'),
(N'Từ Vựng & Kanji', 'N5', N'Bài 4', N'lessons/n5/vocabulary4.html'),
(N'Từ Vựng & Kanji', 'N5', N'Bài 5', N'lessons/n5/vocabulary5.html'),
(N'Từ Vựng & Kanji', 'N5', N'Bài 6', N'lessons/n5/vocabulary6.html'),
(N'Từ Vựng & Kanji', 'N5', N'Bài 7', N'lessons/n5/vocabulary7.html'),
(N'Từ Vựng & Kanji', 'N5', N'Thời gian/Sinh hoạt hằng ngày - Lịch trình/Hoạt động - Mỗi ngày', N'lessons/n5/vocabulary3.html'),
(N'Từ Vựng & Kanji', 'N5', N'Thời gian/Sinh hoạt hằng ngày - Lịch trình/Hoạt động - Mỗi ngày', N'lessons/n5/vocabulary3.html'),

-- Ngữ pháp cơ bản
(N'Ngữ pháp cơ bản', 'N5', N'Bài 1', N'lessons/n5/basic_grammar1.html'),
(N'Ngữ pháp cơ bản', 'N5', N'Bài 2', N'lessons/n5/basic_grammar2.html'),
(N'Ngữ pháp cơ bản', 'N5', N'Bài 3', N'lessons/n5/basic_grammar3.html'),
(N'Ngữ pháp cơ bản', 'N5', N'Bài 4', N'lessons/n5/basic_grammar4.html'),
(N'Ngữ pháp cơ bản', 'N5', N'Bài 5', N'lessons/n5/basic_grammar5.html'),
(N'Ngữ pháp cơ bản', 'N5', N'Bài 6', N'lessons/n5/basic_grammar6.html'),
(N'Ngữ pháp cơ bản', 'N5', N'Bài 7', N'lessons/n5/basic_grammar7.html'),

-- Kanji
(N'Kanji', 'N5', N'Bài 1', N'lessons/n5/Kanji1.html'),
(N'Kanji', 'N5', N'Bài 2', N'lessons/n5/Kanji2.html'),
(N'Kanji', 'N5', N'Bài 3', N'lessons/n5/Kanji3.html'),
(N'Kanji', 'N5', N'Bài 4', N'lessons/n5/Kanji4.html'),
(N'Kanji', 'N5', N'Bài 5', N'lessons/n5/Kanji5.html'),
(N'Kanji', 'N5', N'Bài 6', N'lessons/n5/Kanji6.html'),
(N'Kanji', 'N5', N'Bài 7', N'lessons/n5/Kanji7.html');
GO


-- =============================================
-- 4. BẢNG PAYMENTS (PayOS Integration)
-- =============================================
CREATE TABLE payments (
    payment_id INT IDENTITY(1,1) PRIMARY KEY,
    user_id INT NOT NULL,
    order_code BIGINT UNIQUE NOT NULL,
    amount INT NOT NULL,
    description NVARCHAR(255),
    status VARCHAR(20) DEFAULT 'PENDING',   -- PENDING, PAID, CANCELLED, EXPIRED
    payment_method VARCHAR(50),
    checkout_url NVARCHAR(500),
    created_at DATETIME DEFAULT GETDATE(),
    paid_at DATETIME NULL,
    FOREIGN KEY (user_id) REFERENCES users(id)
);
GO

-- Indexes
CREATE INDEX idx_payments_order_code ON payments(order_code);
CREATE INDEX idx_payments_user_id ON payments(user_id);
GO


-- =============================================
-- 5. BẢNG SUBSCRIPTION PLANS
-- =============================================
CREATE TABLE subscription_plans (
    plan_id INT IDENTITY(1,1) PRIMARY KEY,
    name NVARCHAR(100) NOT NULL,
    price INT NOT NULL,             -- VND
    duration_days INT NOT NULL,
    description NVARCHAR(500),
    is_active BIT DEFAULT 1
);
GO

-- Dữ liệu mẫu subscription plans
INSERT INTO subscription_plans (name, price, duration_days, description) VALUES
(N'Premium 1 Tháng',  99000,  30,  N'Truy cập tất cả bài học N5-N1, AI Chat không giới hạn'),
(N'Premium 3 Tháng',  249000, 90,  N'Tiết kiệm 16% so với gói 1 tháng'),
(N'Premium 1 Năm',    799000, 365, N'Tiết kiệm 33% so với gói 1 tháng');
GO


-- =============================================
-- KIỂM TRA
-- =============================================
SELECT id, username, role, status, is_premium, created_at FROM users;
SELECT lesson_id, name, level, description FROM lesson;
SELECT * FROM subscription_plans;
GO
