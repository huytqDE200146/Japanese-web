<%-- 
    Document   : register
    Created on : Feb 19, 2026
    Author     : ADMIN
--%>

<%@ page contentType="text/html;charset=UTF-8" %>
<!DOCTYPE html>
<html>
<head>
    <title>Japanese Learning - Đăng ký</title>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <link rel="stylesheet" href="css/login-style.css">
    <link href="https://fonts.googleapis.com/css2?family=Noto+Serif+JP:wght@400;700&family=Poppins:wght@300;400;600&display=swap" rel="stylesheet">
</head>
<body>

    <!-- Floating Kana Animation Container -->
    <div class="kana-container" id="kana-container"></div>

    <div class="login-card register-card">
        <div class="welcome-text">
            <h1>登録する</h1> <!-- "Register" -->
            <p>Tạo tài khoản mới</p>
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

        <form action="register" method="post" id="registerForm">
            <div class="input-group">
                <label for="fullName">Họ và tên / 氏名</label>
                <input type="text" id="fullName" name="fullName" required placeholder="Nguyen Van A">
            </div>

            <div class="input-group">
                <label for="email">Email / メール</label>
                <input type="email" id="email" name="email" required placeholder="example@email.com">
            </div>

            <div class="input-group">
                <label for="username">Tên đăng nhập / ユーザー名</label>
                <input type="text" id="username" name="username" required placeholder="example_san" minlength="3">
            </div>

            <div class="input-group">
                <label for="password">Mật khẩu / パスワード</label>
                <div class="password-wrapper">
                    <input type="password" id="password" name="password" required placeholder="••••••••" minlength="6">
                    <button type="button" class="toggle-password" onclick="togglePassword('password', this)" title="Hiện/Ẩn mật khẩu">
                        👁
                    </button>
                </div>
            </div>

            <div class="input-group">
                <label for="confirmPassword">Xác nhận mật khẩu / 確認</label>
                <div class="password-wrapper">
                    <input type="password" id="confirmPassword" name="confirmPassword" required placeholder="••••••••">
                    <button type="button" class="toggle-password" onclick="togglePassword('confirmPassword', this)" title="Hiện/Ẩn mật khẩu">
                        👁
                    </button>
                </div>
            </div>

            <button type="submit" class="btn-login btn-register">
                Đăng ký <span>➔</span>
            </button>
        </form>

        <div class="switch-form">
            Đã có tài khoản? <a href="login">Đăng nhập</a>
        </div>
    </div>

    <script>
        // Floating Japanese Characters (Kana) Effect
        const container = document.getElementById('kana-container');
        const kanaChars = [
            'あ', 'い', 'う', 'え', 'お',
            'か', 'き', 'く', 'け', 'こ',
            'さ', 'し', 'す', 'せ', 'そ',
            'た', 'ち', 'つ', 'て', 'と',
            'ナ', 'ニ', 'ヌ', 'ネ', 'ノ',
            'ハ', 'ヒ', 'フ', 'ヘ', 'ホ',
            'マ', 'ミ', 'ム', 'メ', 'モ',
            'ラ', 'リ', 'ル', 'レ', 'ロ'
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

        // Client-side validation
        document.getElementById('registerForm').addEventListener('submit', function(e) {
            const pw = document.getElementById('password').value;
            const cpw = document.getElementById('confirmPassword').value;
            
            if (pw.length < 6) {
                e.preventDefault();
                alert('Mật khẩu phải có ít nhất 6 ký tự!');
                return;
            }
            
            if (pw !== cpw) {
                e.preventDefault();
                alert('Mật khẩu xác nhận không khớp!');
            }
        });

        // Toggle password visibility
        function togglePassword(inputId, btn) {
            const input = document.getElementById(inputId);
            if (input.type === 'password') {
                input.type = 'text';
                btn.textContent = '🙈';
            } else {
                input.type = 'password';
                btn.textContent = '👁';
            }
        }
    </script>
</body>
</html>
