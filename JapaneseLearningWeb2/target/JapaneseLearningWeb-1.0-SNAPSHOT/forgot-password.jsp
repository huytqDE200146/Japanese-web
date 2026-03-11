<%@ page contentType="text/html;charset=UTF-8" %>
<!DOCTYPE html>
<html>
<head>
    <title>Japanese Learning - Quên Mật Khẩu</title>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <link rel="stylesheet" href="css/login-style.css">
    <link href="https://fonts.googleapis.com/css2?family=Noto+Serif+JP:wght@400;700&family=Poppins:wght@300;400;600&display=swap" rel="stylesheet">
</head>
<body>

    <!-- Floating Kana Animation Container -->
    <div class="kana-container" id="kana-container"></div>

    <div class="login-card">
        <div class="welcome-text">
            <h1>パスワードを忘れた</h1> <!-- "Forgot Password" -->
            <p>Khôi phục mật khẩu</p>
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

        <form action="forgot-password" method="post">
            <div class="input-group">
                <label for="email">Nhập email tài khoản của bạn</label>
                <input type="email" id="email" name="email" required placeholder="example@email.com">
            </div>

            <button type="submit" class="btn-login btn-register">
                Gửi mã xác nhận <span>➔</span>
            </button>
        </form>

        <div class="switch-form">
            <a href="login.jsp">Quay lại Đăng nhập</a>
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
