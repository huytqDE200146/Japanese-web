<%@ page contentType="text/html;charset=UTF-8" %>
<%
    String resetEmail = (String) session.getAttribute("resetEmail");
    if (resetEmail == null) {
        response.sendRedirect("forgot-password");
        return;
    }
%>
<!DOCTYPE html>
<html>
<head>
    <title>Japanese Learning - Xác Thực OTP</title>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <link rel="stylesheet" href="css/login-style.css">
    <link href="https://fonts.googleapis.com/css2?family=Noto+Serif+JP:wght@400;700&family=Poppins:wght@300;400;600&display=swap" rel="stylesheet">
    <style>
        .verify-text {
            text-align: center;
            margin-bottom: 20px;
            color: #555;
            font-size: 14px;
        }
        .verify-text b {
            color: #333;
        }
    </style>
</head>
<body>

    <div class="kana-container" id="kana-container"></div>

    <div class="login-card" style="margin-top: 40px; margin-bottom: 40px;">
        <div class="welcome-text">
            <h1>認証</h1> <!-- "Verification" -->
            <p>Xác thực mã OTP</p>
        </div>

        <div class="verify-text">
            Mã xác thực 6 số đã được gửi tới email:<br>
            <b><%= resetEmail %></b>
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

        <form action="verify-forgot-otp" method="post" id="verifyOtpForm">
            <div class="input-group">
                <label for="otp">Mã xác thực (OTP)</label>
                <input type="text" id="otp" name="otp" required placeholder="Nhập mã 6 chữ số" pattern="\d{6}">
            </div>

            <button type="submit" class="btn-login btn-register">
                Tiếp tục <span>➔</span>
            </button>
        </form>
    </div>

    <script>
        // Floating Japanese Characters (Kana) Effect
        const container = document.getElementById('kana-container');
        const kanaChars = ['あ', 'い', 'う', 'え', 'お', 'か', 'き', 'く', 'け', 'こ'];
        const particleCount = 20;

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
        for (let i = 0; i < particleCount; i++) { createKana(); }
    </script>
</body>
</html>
