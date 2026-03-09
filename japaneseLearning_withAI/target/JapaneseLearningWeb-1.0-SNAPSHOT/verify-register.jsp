<%@ page contentType="text/html;charset=UTF-8" %>
<!DOCTYPE html>
<html>
<head>
    <title>Japanese Learning - Xác Thực Email</title>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <link rel="stylesheet" href="css/login-style.css">
    <link href="https://fonts.googleapis.com/css2?family=Noto+Serif+JP:wght@400;700&family=Poppins:wght@300;400;600&display=swap" rel="stylesheet">
    <style>
        .verify-text {
            text-align: center;
            margin-bottom: 20px;
            color: #ffffff;
            font-size: 16px;
            font-weight: 500;
            line-height: 1.6;
            text-shadow: 1px 1px 4px rgba(0,0,0,0.8);
            background: rgba(0, 0, 0, 0.2);
            padding: 15px;
            border-radius: 8px;
        }
        .verify-text b {
            color: #333;
        }
    </style>
</head>
<body>

    <!-- Floating Kana Animation Container -->
    <div class="kana-container" id="kana-container"></div>

    <div class="login-card">
        <div class="welcome-text">
            <h1>メールを確認してください</h1> <!-- "Please check your email" -->
            <p>Vui lòng kiểm tra email</p>
        </div>

        <div class="verify-text">
            Chúng tôi đã gửi một liên kết xác thực đến email của bạn. <br><br>
            Vui lòng kiểm tra hộp thư đến (bao gồm cả thư rác/spam) và click vào liên kết để hoàn tất đăng ký tài khoản.
        </div>

        <%
            String error = (String) request.getAttribute("error");
            if (error != null) {
        %>
        <div class="alert">
            ⚠ <%= error %>
        </div>
        <%
            }
        %>

        <div style="text-align: center; margin-top: 20px;">
            <a href="login" class="btn-login" style="display: inline-block; text-decoration: none; padding: 12px 20px;">
                Quay lại Đăng nhập
            </a>
        </div>
        <div class="switch-form">
            <a href="register.jsp">Trở về trang đăng ký</a>
        </div>
    </div>

    <script>
        // Floating Japanese Characters (Kana) Effect
        const container = document.getElementById('kana-container');
        const kanaChars = [
            'あ', 'い', 'う', 'え', 'お',
            'か', 'き', 'く', 'け', 'こ',
            'さ', 'し', 'す', 'せ', 'そ',
            'た', 'ち', 'つ', 'て', 'と'
        ];
        const particleCount = 50;

        function createKana() {
            const span = document.createElement('div');
            span.classList.add('kana');
            span.innerText = kanaChars[Math.floor(Math.random() * kanaChars.length)];
            
            const size = Math.random() * 20 + 15 + 'px';
            span.style.fontSize = size;
            span.style.left = Math.random() * 100 + '%';
            
            const duration = Math.random() * 10 + 10 + 's';
            span.style.animationDuration = duration;
            span.style.animationDelay = Math.random() * 5 + 's';
            
            span.style.opacity = Math.random() * 0.5 + 0.1;
            container.appendChild(span);
        }

        for (let i = 0; i < particleCount; i++) {
            createKana();
        }
    </script>
</body>
</html>
