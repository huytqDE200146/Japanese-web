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

CREATE TABLE course (
    course_id INT IDENTITY(1,1) PRIMARY KEY,
    course_name NVARCHAR(100),
    description NVARCHAR(MAX),
    level NVARCHAR(10),
    status NVARCHAR(20),
    created_at DATETIME DEFAULT GETDATE()
);

GO

CREATE TABLE lesson (
    lesson_id INT IDENTITY(1,1) PRIMARY KEY,
    course_id INT,
    title NVARCHAR(100),
    description NVARCHAR(MAX),
    order_index INT,
    CONSTRAINT fk_lesson_course
        FOREIGN KEY (course_id) REFERENCES course(course_id)
);
GO

INSERT INTO course (course_name, description, level, status)
VALUES
('Japanese N5', 'Basic Japanese for beginners', 'N5', 'active'),
('Japanese N4', 'Elementary Japanese course', 'N4', 'active');
GO

INSERT INTO lesson (course_id, title, description, order_index)
VALUES
(1, 'Hiragana Basics', 'Learn basic Hiragana characters', 1),
(1, 'Katakana Basics', 'Learn basic Katakana characters', 2),
(1, 'Basic Greetings', 'Common Japanese greetings', 3);
GO

INSERT INTO lesson (course_id, title, description, order_index)
VALUES
(2, 'Te-form Introduction', 'Learn how to use te-form verbs', 1),
(2, 'Past Tense Verbs', 'Learn past tense verb forms', 2);
GO

SELECT * FROM course;

SELECT l.lesson_id, l.title, c.course_name
FROM lesson l
JOIN course c ON l.course_id = c.course_id
ORDER BY c.course_id, l.order_index;


