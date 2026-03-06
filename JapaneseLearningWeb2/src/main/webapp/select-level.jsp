<%@ page contentType="text/html;charset=UTF-8" %>
<%@ page import="com.japaneselearning.model.User" %>

<%
    User user = (User) session.getAttribute("user");
    if (user == null) {
        response.sendRedirect("login.jsp");
        return;
    }
%>

<!DOCTYPE html>
<html lang="vi">
<head>
    <title>Chọn Level - Japanese Learning</title>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/css/bootstrap.min.css">
    <link rel="stylesheet" href="css/main-style.css">
    <link href="https://fonts.googleapis.com/css2?family=Noto+Serif+JP:wght@400;700&family=Poppins:wght@300;400;500;600;700&display=swap" rel="stylesheet">
    <style>
        body {
            min-height: 100vh;
            display: flex;
            align-items: center;
            justify-content: center;
            padding: 2rem;
        }

        .level-container {
            max-width: 800px;
            width: 100%;
            text-align: center;
        }

        .level-header {
            margin-bottom: 2.5rem;
        }
        .level-header h1 {
            font-family: 'Noto Serif JP', serif;
            font-size: 2.5rem;
            margin-bottom: 0.5rem;
            background: linear-gradient(135deg, #ffb7c5, #ffffff);
            -webkit-background-clip: text;
            -webkit-text-fill-color: transparent;
            background-clip: text;
        }
        .level-header p {
            color: rgba(255,255,255,0.6);
            font-size: 1.1rem;
        }
        .level-header .welcome-name {
            color: var(--sakura-pink);
            font-weight: 600;
        }

        .level-grid {
            display: grid;
            grid-template-columns: repeat(auto-fit, minmax(220px, 1fr));
            gap: 1.2rem;
            margin-bottom: 2rem;
        }

        .level-card {
            background: linear-gradient(145deg, rgba(30, 30, 50, 0.9), rgba(20, 20, 35, 0.95));
            border: 2px solid rgba(255, 255, 255, 0.08);
            border-radius: 20px;
            padding: 1.8rem 1.2rem;
            cursor: pointer;
            transition: all 0.35s cubic-bezier(0.4, 0, 0.2, 1);
            position: relative;
            overflow: hidden;
        }
        .level-card::before {
            content: '';
            position: absolute;
            inset: 0;
            background: linear-gradient(135deg, transparent 40%, rgba(188, 0, 45, 0.08));
            opacity: 0;
            transition: opacity 0.3s;
        }
        .level-card:hover {
            transform: translateY(-6px);
            border-color: rgba(255, 183, 197, 0.4);
            box-shadow: 0 15px 40px rgba(188, 0, 45, 0.2);
        }
        .level-card:hover::before {
            opacity: 1;
        }
        .level-card.selected {
            border-color: var(--primary-red);
            box-shadow: 0 0 30px rgba(188, 0, 45, 0.35);
            background: linear-gradient(145deg, rgba(188, 0, 45, 0.15), rgba(20, 20, 35, 0.95));
        }
        .level-card.selected::after {
            content: '✓';
            position: absolute;
            top: 12px;
            right: 14px;
            width: 28px;
            height: 28px;
            background: var(--primary-red);
            border-radius: 50%;
            display: flex;
            align-items: center;
            justify-content: center;
            font-size: 0.85rem;
            font-weight: 700;
            color: white;
        }

        .level-badge {
            display: inline-flex;
            align-items: center;
            justify-content: center;
            width: 60px;
            height: 60px;
            border-radius: 16px;
            font-size: 1.4rem;
            font-weight: 800;
            margin-bottom: 1rem;
            color: white;
            box-shadow: 0 4px 15px rgba(0,0,0,0.3);
        }
        .level-n5 .level-badge { background: linear-gradient(135deg, #4ade80, #16a34a); }
        .level-n4 .level-badge { background: linear-gradient(135deg, #22d3ee, #0891b2); }
        .level-n3 .level-badge { background: linear-gradient(135deg, #fbbf24, #d97706); }
        .level-n2 .level-badge { background: linear-gradient(135deg, #f472b6, #db2777); }
        .level-n1 .level-badge { background: linear-gradient(135deg, #bc002d, #881337); }

        .level-name {
            font-family: 'Noto Serif JP', serif;
            font-size: 1.3rem;
            font-weight: 700;
            color: white;
            margin-bottom: 0.4rem;
        }
        .level-jp {
            font-family: 'Noto Serif JP', serif;
            font-size: 0.9rem;
            color: var(--sakura-pink);
            margin-bottom: 0.5rem;
        }
        .level-desc {
            font-size: 0.8rem;
            color: rgba(255,255,255,0.5);
            line-height: 1.4;
        }

        .btn-confirm {
            background: linear-gradient(135deg, #bc002d, #881337);
            color: white;
            border: none;
            padding: 0.9rem 3rem;
            border-radius: 30px;
            font-size: 1.15rem;
            font-weight: 600;
            cursor: pointer;
            transition: all 0.3s ease;
            opacity: 0.5;
            pointer-events: none;
        }
        .btn-confirm.active {
            opacity: 1;
            pointer-events: all;
        }
        .btn-confirm.active:hover {
            transform: translateY(-2px);
            box-shadow: 0 8px 25px rgba(188, 0, 45, 0.4);
        }

        .skip-link {
            display: block;
            margin-top: 1rem;
            color: rgba(255,255,255,0.4);
            font-size: 0.85rem;
            text-decoration: none;
            transition: color 0.2s;
        }
        .skip-link:hover {
            color: rgba(255,255,255,0.7);
        }

        @media (max-width: 768px) {
            .level-grid {
                grid-template-columns: 1fr 1fr;
            }
            .level-header h1 {
                font-size: 1.8rem;
            }
        }
        @media (max-width: 480px) {
            .level-grid {
                grid-template-columns: 1fr;
            }
        }
    </style>
</head>

<body>

<div class="level-container">
    <div class="level-header animate-fade-in">
        <h1>🎌 Chọn Level Của Bạn</h1>
        <p>Xin chào <span class="welcome-name"><%= user.getFullName() %></span>! Bạn đang ở trình độ nào?</p>
    </div>

    <form id="levelForm" action="select-level" method="post">
        <input type="hidden" name="level" id="levelInput" value="">

        <div class="level-grid">
            <div class="level-card level-n5 animate-fade-in" onclick="selectLevel(this, 5)" style="animation-delay: 0.1s;">
                <div class="level-badge">N5</div>
                <div class="level-name">JLPT N5</div>
                <div class="level-jp">初級 - Sơ cấp</div>
                <div class="level-desc">Hiragana, Katakana, từ vựng & ngữ pháp cơ bản</div>
            </div>

            <div class="level-card level-n4 animate-fade-in" onclick="selectLevel(this, 4)" style="animation-delay: 0.2s;">
                <div class="level-badge">N4</div>
                <div class="level-name">JLPT N4</div>
                <div class="level-jp">初中級 - Sơ trung cấp</div>
                <div class="level-desc">Ngữ pháp nâng cao, Kanji cơ bản, hội thoại</div>
            </div>

            <div class="level-card level-n3 animate-fade-in" onclick="selectLevel(this, 3)" style="animation-delay: 0.3s;">
                <div class="level-badge">N3</div>
                <div class="level-name">JLPT N3</div>
                <div class="level-jp">中級 - Trung cấp</div>
                <div class="level-desc">Đọc hiểu, Kanji trung cấp, giao tiếp tự nhiên</div>
            </div>

            <div class="level-card level-n2 animate-fade-in" onclick="selectLevel(this, 2)" style="animation-delay: 0.4s;">
                <div class="level-badge">N2</div>
                <div class="level-name">JLPT N2</div>
                <div class="level-jp">上級 - Cao cấp</div>
                <div class="level-desc">Ngữ pháp phức tạp, đọc báo, viết luận</div>
            </div>

            <div class="level-card level-n1 animate-fade-in" onclick="selectLevel(this, 1)" style="animation-delay: 0.5s;">
                <div class="level-badge">N1</div>
                <div class="level-name">JLPT N1</div>
                <div class="level-jp">最上級 - Thành thạo</div>
                <div class="level-desc">Trình độ cao nhất, đọc hiểu chuyên sâu</div>
            </div>
        </div>

        <button type="submit" class="btn-confirm" id="btnConfirm">🚀 Bắt đầu học</button>
    </form>
</div>

<script>
    function selectLevel(card, level) {
        // Remove selected from all
        document.querySelectorAll('.level-card').forEach(c => c.classList.remove('selected'));
        // Select this card
        card.classList.add('selected');
        // Set hidden input
        document.getElementById('levelInput').value = level;
        // Enable button
        document.getElementById('btnConfirm').classList.add('active');
    }
</script>

</body>
</html>
