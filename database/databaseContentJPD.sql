-- 1. Tạo database
CREATE DATABASE japanese_web;
GO

-- 2. Dùng database
USE japanese_web;
GO

-- 3. Tạo bảng users (ĐÚNG SQL SERVER)
CREATE TABLE users (
    id INT IDENTITY(1,1) PRIMARY KEY,
    username VARCHAR(50) NOT NULL UNIQUE,
    password VARCHAR(255) NOT NULL,
    email VARCHAR(100),
    full_name VARCHAR(100),
    role VARCHAR(20) DEFAULT 'USER',
    status VARCHAR(20) DEFAULT 'ACTIVE',
    created_at DATETIME DEFAULT GETDATE()
);
GO

-- 4. Insert dữ liệu mẫu
INSERT INTO users (username, password, email, full_name, role, status)
VALUES
('huy01', '123456', 'huy01@gmail.com', 'Tran Quoc Huy', 'USER', 'ACTIVE'),
('linh02', '123456', 'linh02@gmail.com', 'Nguyen Thi Linh', 'USER', 'ACTIVE'),
('nam03', '123456', 'nam03@gmail.com', 'Le Van Nam', 'USER', 'ACTIVE');
GO

INSERT INTO users (username, password, email, full_name, role, status)
VALUES
('testban', '123456', 'testban@gmail.com', 'User Bi Khoa', 'USER', 'BAN');
GO

-- 5. Kiểm tra
SELECT id, username, role, status, created_at FROM users;
GO

-- Lesson database
USE japanese_web;
GO

CREATE TABLE lesson (
    lesson_id INT IDENTITY(1,1) PRIMARY KEY,
    name NVARCHAR(200) NOT NULL,
    level NVARCHAR(10) NOT NULL,    
    description NVARCHAR(MAX),
    content_path NVARCHAR(255) NOT NULL, -- đường dẫn file HTML
    created_at DATETIME DEFAULT GETDATE()
);
GO

INSERT INTO lesson (name, level, description, content_path)
VALUES
(N'Hiragana cơ bản', 'N5',
 N'Học bảng chữ cái Hiragana cơ bản',
 N'lessons/n5/hiragana.html'),

(N'Katakana cơ bản', 'N5',
 N'Học bảng chữ cái Katakana',
 N'lessons/n5/katakana.html'),

(N'Giới thiệu bản thân', 'N5',
 N'Cách tự giới thiệu bằng tiếng Nhật',
 N'lessons/n4/self_introduction.html');


