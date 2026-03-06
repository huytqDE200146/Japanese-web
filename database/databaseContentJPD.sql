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
    level INT NOT NULL DEFAULT 5,
    role VARCHAR(20) DEFAULT 'USER',
    status VARCHAR(20) DEFAULT 'ACTIVE',
    created_at DATETIME DEFAULT GETDATE(),
    is_premium BIT DEFAULT 0,
    premium_until DATETIME NULL,
    google_id VARCHAR(255) NULL
);
GO

-- Dữ liệu mẫu users
INSERT INTO users (username, password, email, full_name, level, role, status) VALUES
('huy01',       '123456', 'huy01@gmail.com',     'Tran Quoc Huy', 1,  'ADMIN', 'ACTIVE'),
('linh02',      '123456', 'linh02@gmail.com',     'Nguyen Thi Linh', 2, 'USER', 'ACTIVE'),
('nam03',       '123456', 'nam03@gmail.com',      'Le Van Nam', 5,     'USER', 'ACTIVE'),
('nhaphuong22', '123456', 'nhaphuong@gmail.com',   'Le Nha Phuong', 1,  'ADMIN', 'ACTIVE'),
('testban',     '123456', 'testban@gmail.com',     'User Bi Khoa', 3,   'USER', 'BAN');
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

(N'Từ Vựng & Kanji', 'N4', N'Bài 1', N'lessons/n4/voca1_n4.html'),
(N'Từ Vựng & Kanji', 'N4', N'Bài 2', N'lessons/n4/voca2_n4.html'),
(N'Từ Vựng & Kanji', 'N4', N'Bài 3', N'lessons/n4/voca3_n4.html'),
(N'Từ Vựng & Kanji', 'N4', N'Bài 4', N'lessons/n4/voca4_n4.html'),
(N'Từ Vựng & Kanji', 'N4', N'Bài 5', N'lessons/n4/voca5_n4.html'),
(N'Từ Vựng & Kanji', 'N4', N'Bài 6', N'lessons/n4/voca6_n4.html'),

(N'Từ Vựng & Kanji', 'N3', N'Bài 1', N'lessons/n3/n3_voca_1.html'),
(N'Từ Vựng & Kanji', 'N3', N'Bài 2', N'lessons/n3/n3_voca_2.html'),
(N'Từ Vựng & Kanji', 'N3', N'Bài 3', N'lessons/n3/n3_voca_3.html'),
(N'Từ Vựng & Kanji', 'N3', N'Bài 4', N'lessons/n3/n3_voca_4.html'),
(N'Từ Vựng & Kanji', 'N3', N'Bài 5', N'lessons/n3/n3_voca_5.html'),
(N'Từ Vựng & Kanji', 'N3', N'Bài 6', N'lessons/n3/n3_voca_6.html'),

(N'Từ Vựng & Kanji', 'N2', N'Bài 1', N'lessons/n2/n2_voca_1.html'),
(N'Từ Vựng & Kanji', 'N2', N'Bài 2', N'lessons/n2/n2_voca_2.html'),
(N'Từ Vựng & Kanji', 'N2', N'Bài 3', N'lessons/n2/n2_voca_3.html'),
(N'Từ Vựng & Kanji', 'N2', N'Bài 4', N'lessons/n2/n2_voca_4.html'),
(N'Từ Vựng & Kanji', 'N2', N'Bài 5', N'lessons/n2/n2_voca_5.html'),
(N'Từ Vựng & Kanji', 'N2', N'Bài 6', N'lessons/n2/n2_voca_6.html'),

(N'Từ Vựng & Kanji', 'N1', N'Bài 1', N'lessons/n1/n1_voca_1.html'),
(N'Từ Vựng & Kanji', 'N1', N'Bài 2', N'lessons/n1/n1_voca_2.html'),
(N'Từ Vựng & Kanji', 'N1', N'Bài 3', N'lessons/n1/n1_voca_3.html'),
(N'Từ Vựng & Kanji', 'N1', N'Bài 4', N'lessons/n1/n1_voca_4.html'),
(N'Từ Vựng & Kanji', 'N1', N'Bài 5', N'lessons/n1/n1_voca_5.html'),
(N'Từ Vựng & Kanji', 'N1', N'Bài 6', N'lessons/n1/n1_voca_6.html'),

-- Ngữ pháp
(N'Ngữ pháp', 'N5', N'Bài 1', N'lessons/n5/basic_grammar1.html'),
(N'Ngữ pháp', 'N5', N'Bài 2', N'lessons/n5/basic_grammar2.html'),
(N'Ngữ pháp', 'N5', N'Bài 3', N'lessons/n5/basic_grammar3.html'),
(N'Ngữ pháp', 'N5', N'Bài 4', N'lessons/n5/basic_grammar4.html'),
(N'Ngữ pháp', 'N5', N'Bài 5', N'lessons/n5/basic_grammar5.html'),
(N'Ngữ pháp', 'N5', N'Bài 6', N'lessons/n5/basic_grammar6.html'),
(N'Ngữ pháp', 'N5', N'Bài 7', N'lessons/n5/basic_grammar7.html'),

(N'Ngữ pháp', 'N4', N'Bài 1', N'lessons/n4/gam1_n4.html'),
(N'Ngữ pháp', 'N4', N'Bài 2', N'lessons/n4/gam2_n4.html'),
(N'Ngữ pháp', 'N4', N'Bài 3', N'lessons/n4/gam3_n4.html'),
(N'Ngữ pháp', 'N4', N'Bài 4', N'lessons/n4/gam4_n4.html'),
(N'Ngữ pháp', 'N4', N'Bài 5', N'lessons/n4/gam5_n4.html'),
(N'Ngữ pháp', 'N4', N'Bài 6', N'lessons/n4/gam6_n4.html'),

(N'Ngữ pháp', 'N3', N'Bài 1', N'lessons/n3/n3_gam_1.html'),
(N'Ngữ pháp', 'N3', N'Bài 2', N'lessons/n3/n3_gam_2.html'),
(N'Ngữ pháp', 'N3', N'Bài 3', N'lessons/n3/n3_gam_3.html'),
(N'Ngữ pháp', 'N3', N'Bài 4', N'lessons/n3/n3_gam_4.html'),
(N'Ngữ pháp', 'N3', N'Bài 5', N'lessons/n3/n3_gam_5.html'),
(N'Ngữ pháp', 'N3', N'Bài 6', N'lessons/n3/n3_gam_6.html'),

(N'Ngữ pháp', 'N2', N'Bài 1', N'lessons/n2/n2_gam_1.html'),
(N'Ngữ pháp', 'N2', N'Bài 2', N'lessons/n2/n2_gam_2.html'),
(N'Ngữ pháp', 'N2', N'Bài 3', N'lessons/n2/n2_gam_3.html'),
(N'Ngữ pháp', 'N2', N'Bài 4', N'lessons/n2/n2_gam_4.html'),
(N'Ngữ pháp', 'N2', N'Bài 5', N'lessons/n2/n2_gam_5.html'),
(N'Ngữ pháp', 'N2', N'Bài 6', N'lessons/n2/n2_gam_6.html'),

(N'Ngữ pháp', 'N1', N'Bài 1', N'lessons/n1/n1_gam_1.html'),
(N'Ngữ pháp', 'N1', N'Bài 2', N'lessons/n1/n1_gam_2.html'),
(N'Ngữ pháp', 'N1', N'Bài 3', N'lessons/n1/n1_gam_3.html'),
(N'Ngữ pháp', 'N1', N'Bài 4', N'lessons/n1/n1_gam_4.html'),
(N'Ngữ pháp', 'N1', N'Bài 5', N'lessons/n1/n1_gam_5.html'),
(N'Ngữ pháp', 'N1', N'Bài 6', N'lessons/n1/n1_gam_6.html'),



-- Kanji
(N'Kanji', 'N5', N'Bài 1', N'lessons/n5/Kanji1.html'),
(N'Kanji', 'N5', N'Bài 2', N'lessons/n5/Kanji2.html'),
(N'Kanji', 'N5', N'Bài 3', N'lessons/n5/Kanji3.html'),
(N'Kanji', 'N5', N'Bài 4', N'lessons/n5/Kanji4.html'),
(N'Kanji', 'N5', N'Bài 5', N'lessons/n5/Kanji5.html'),
(N'Kanji', 'N5', N'Bài 6', N'lessons/n5/Kanji6.html'),
(N'Kanji', 'N5', N'Bài 7', N'lessons/n5/Kanji7.html'),

(N'Kanji', 'N4', N'Bài 1', N'lessons/n4/kanji1_n4.html'),
(N'Kanji', 'N4', N'Bài 2', N'lessons/n4/kanji2_n4.html'),
(N'Kanji', 'N4', N'Bài 3', N'lessons/n4/kanji3_n4.html'),
(N'Kanji', 'N4', N'Bài 4', N'lessons/n4/kanji4_n4.html'),
(N'Kanji', 'N4', N'Bài 5', N'lessons/n4/kanji5_n4.html'),
(N'Kanji', 'N4', N'Bài 6', N'lessons/n4/kanji6_n4.html'),

(N'Kanji', 'N3', N'Bài 1', N'lessons/n3/n3_kanji_1.html'),
(N'Kanji', 'N3', N'Bài 2', N'lessons/n3/n3_kanji_2.html'),
(N'Kanji', 'N3', N'Bài 3', N'lessons/n3/n3_kanji_3.html'),
(N'Kanji', 'N3', N'Bài 4', N'lessons/n3/n3_kanji_4.html'),
(N'Kanji', 'N3', N'Bài 5', N'lessons/n3/n3_kanji_5.html'),
(N'Kanji', 'N3', N'Bài 6', N'lessons/n3/n3_kanji_6.html'),

(N'Kanji', 'N2', N'Bài 1', N'lessons/n2/n2_kanji_1.html'),
(N'Kanji', 'N2', N'Bài 2', N'lessons/n2/n2_kanji_2.html'),
(N'Kanji', 'N2', N'Bài 3', N'lessons/n2/n2_kanji_3.html'),
(N'Kanji', 'N2', N'Bài 4', N'lessons/n2/n2_kanji_4.html'),
(N'Kanji', 'N2', N'Bài 5', N'lessons/n2/n2_kanji_5.html'),
(N'Kanji', 'N2', N'Bài 6', N'lessons/n2/n2_kanji_6.html'),

(N'Kanji', 'N1', N'Bài 1', N'lessons/n1/n1_kanji_1.html'),
(N'Kanji', 'N1', N'Bài 2', N'lessons/n1/n1_kanji_2.html'),
(N'Kanji', 'N1', N'Bài 3', N'lessons/n1/n1_kanji_3.html'),
(N'Kanji', 'N1', N'Bài 4', N'lessons/n1/n1_kanji_4.html'),
(N'Kanji', 'N1', N'Bài 5', N'lessons/n1/n1_kanji_5.html'),
(N'Kanji', 'N1', N'Bài 6', N'lessons/n1/n1_kanji_6.html');
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


-- =============================================
-- 3. BẢNG LESSON
-- =============================================
CREATE TABLE progress (
    id INT IDENTITY PRIMARY KEY,
    user_id INT NOT NULL,
    lesson_id INT NOT NULL,
    completed BIT DEFAULT 0,
    completed_at DATETIME NULL,
    CONSTRAINT uq_user_lesson UNIQUE (user_id, lesson_id)
);
GO

CREATE TABLE user_progress (
    user_id INT PRIMARY KEY,
    streak INT DEFAULT 0,
    longest_streak INT DEFAULT 0,
    total_lessons INT DEFAULT 0,
    total_quizzes INT DEFAULT 0,
    last_study_date DATE,
    FOREIGN KEY (user_id) REFERENCES users(id)
);

CREATE TABLE lesson_progress (
    id INT IDENTITY(1,1) PRIMARY KEY,
    user_id INT NOT NULL,
    lesson_id INT NOT NULL,
    completed BIT DEFAULT 0,
    completed_date DATE,

    CONSTRAINT UQ_lesson_progress_user_lesson UNIQUE (user_id, lesson_id),

    CONSTRAINT FK_lesson_progress_user 
        FOREIGN KEY (user_id) REFERENCES users(id),

    CONSTRAINT FK_lesson_progress_lesson 
        FOREIGN KEY (lesson_id) REFERENCES lesson(lesson_id)
);