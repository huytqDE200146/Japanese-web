<%@ page contentType="text/html;charset=UTF-8" %>
<%@ page import="com.japaneselearning.model.User" %>

<%
    User user = (User) session.getAttribute("user");
    if (user == null) {
        response.sendRedirect("login.jsp");
        return;
    }
    Boolean success = (Boolean) request.getAttribute("success");
    String message = (String) request.getAttribute("message");
%>

<!DOCTYPE html>
<html lang="vi">
<head>
    <title>Kết quả thanh toán - Japanese Learning</title>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/css/bootstrap.min.css">
    <link rel="stylesheet" href="css/main-style.css">
    <link href="https://fonts.googleapis.com/css2?family=Noto+Serif+JP:wght@400;700&family=Poppins:wght@300;400;500;600;700&display=swap" rel="stylesheet">
    <style>
        html, body { min-height: 100vh; }
        body { display: flex; flex-direction: column; }
        main { flex: 1; display: flex; align-items: center; justify-content: center; }
        .footer { margin-top: auto; }
        
        .result-card {
            background: var(--glass-bg);
            backdrop-filter: blur(20px);
            border: 1px solid var(--glass-border);
            border-radius: 24px;
            padding: 3rem;
            text-align: center;
            max-width: 500px;
            width: 90%;
        }
        
        .result-icon {
            font-size: 5rem;
            margin-bottom: 1.5rem;
        }
        .result-icon.success { color: #4caf50; }
        .result-icon.error { color: #f44336; }
        
        .result-title {
            font-family: 'Noto Serif JP', serif;
            font-size: 1.8rem;
            margin-bottom: 1rem;
        }
        .result-title.success { color: #4caf50; }
        .result-title.error { color: #f44336; }
        
        .result-message {
            color: rgba(255,255,255,0.8);
            margin-bottom: 2rem;
            line-height: 1.6;
        }
        
        .premium-badge {
            display: inline-flex;
            align-items: center;
            gap: 0.5rem;
            background: linear-gradient(135deg, #ffd700, #ffb700);
            color: #1a1a2e;
            padding: 0.8rem 1.5rem;
            border-radius: 50px;
            font-weight: 600;
            margin-bottom: 2rem;
        }
        
        .btn-action {
            display: inline-block;
            padding: 0.8rem 2rem;
            border-radius: 12px;
            text-decoration: none;
            font-weight: 500;
            transition: all 0.3s ease;
            margin: 0.5rem;
        }
        .btn-primary-custom {
            background: linear-gradient(135deg, #bc002d, #881337);
            color: white;
        }
        .btn-primary-custom:hover {
            transform: translateY(-2px);
            box-shadow: 0 10px 25px rgba(188, 0, 45, 0.3);
            color: white;
        }
        .btn-secondary-custom {
            background: rgba(255,255,255,0.1);
            border: 1px solid rgba(255,255,255,0.2);
            color: white;
        }
        .btn-secondary-custom:hover {
            background: rgba(255,255,255,0.15);
            color: white;
        }
        
        .confetti {
            position: fixed;
            width: 10px;
            height: 10px;
            background: #ffd700;
            animation: confetti 3s ease infinite;
        }
        @keyframes confetti {
            0% { transform: translateY(-100vh) rotate(0deg); opacity: 1; }
            100% { transform: translateY(100vh) rotate(720deg); opacity: 0; }
        }
    </style>
</head>

<body>

<!-- ===== NAVBAR ===== -->
<jsp:include page="components/navbar.jsp">
    <jsp:param name="activePage" value=""/>
</jsp:include>

<main>
    <div class="result-card">
        <% if (success != null && success) { %>
            <!-- Success State -->
            <div class="result-icon success">✓</div>
            <h1 class="result-title success">Thanh toán thành công!</h1>
            <p class="result-message"><%= message != null ? message : "Cảm ơn bạn đã nâng cấp Premium!" %></p>
            
            <div class="premium-badge">
                ⭐ Thành viên Premium
            </div>
            
            <div>
                <a href="lesson" class="btn-action btn-primary-custom">Bắt đầu học ngay</a>
                <a href="home.jsp" class="btn-action btn-secondary-custom">Về trang chủ</a>
            </div>
        <% } else { %>
            <!-- Error/Cancel State -->
            <div class="result-icon error">✕</div>
            <h1 class="result-title error">Thanh toán không thành công</h1>
            <p class="result-message"><%= message != null ? message : "Đã có lỗi xảy ra trong quá trình thanh toán." %></p>
            
            <div>
                <a href="payment" class="btn-action btn-primary-custom">Thử lại</a>
                <a href="home.jsp" class="btn-action btn-secondary-custom">Về trang chủ</a>
            </div>
        <% } %>
    </div>
</main>

<!-- ===== FOOTER ===== -->
<footer class="footer">
    <p>© 2026 <span class="footer-brand">日本語学習</span> - Japanese Learning Platform. All rights reserved.</p>
</footer>

<% if (success != null && success) { %>
<script>
    // Confetti effect
    function createConfetti() {
        const colors = ['#ffd700', '#ff6b6b', '#4ecdc4', '#45b7d1', '#fff'];
        for (let i = 0; i < 50; i++) {
            const confetti = document.createElement('div');
            confetti.className = 'confetti';
            confetti.style.left = Math.random() * 100 + 'vw';
            confetti.style.background = colors[Math.floor(Math.random() * colors.length)];
            confetti.style.animationDelay = Math.random() * 3 + 's';
            confetti.style.animationDuration = (Math.random() * 2 + 2) + 's';
            document.body.appendChild(confetti);
            
            setTimeout(() => confetti.remove(), 5000);
        }
    }
    createConfetti();
</script>
<% } %>

<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/js/bootstrap.bundle.min.js"></script>
</body>
</html>
