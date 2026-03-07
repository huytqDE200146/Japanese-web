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
<<<<<<< HEAD
=======
    <style>
        /* ===== Password Requirements ===== */
        .password-reqs {
            background: rgba(240, 244, 248, 0.95);
            border-radius: 12px;
            padding: 16px;
            margin-top: 12px;
            font-size: 0.85rem;
            color: #8392a5;
            text-align: left;
            box-shadow: inset 0 2px 4px rgba(0,0,0,0.05);
        }
        .reqs-title {
            font-weight: 600;
            margin-bottom: 12px;
            font-size: 0.8rem;
            letter-spacing: 0.5px;
            color: #9ba6b5;
            text-transform: uppercase;
        }
        .reqs-grid {
            display: grid;
            grid-template-columns: 1fr 1fr;
            gap: 10px;
        }
        .req-item {
            display: flex;
            align-items: center;
            gap: 8px;
            transition: color 0.3s ease;
        }
        .req-icon {
            display: inline-block;
            width: 14px;
            height: 14px;
            border-radius: 50%;
            background-color: #d1d9e6;
            transition: background-color 0.3s ease;
            position: relative;
        }
        .req-item.valid {
            color: #10b981; /* green */
        }
        .req-item.valid .req-icon {
            background-color: #10b981;
        }
        .req-item.valid .req-icon::after {
            content: '';
            position: absolute;
            left: 4.5px;
            top: 2.5px;
            width: 3.5px;
            height: 6px;
            border: solid white;
            border-width: 0 2px 2px 0;
            transform: rotate(45deg);
        }
    </style>
>>>>>>> f88f49bbc623c4dcecf2fbf29b3238f8f6b4161b
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
<<<<<<< HEAD
                    <input type="password" id="password" name="password" required placeholder="••••••••" minlength="6">
=======
                    <input type="password" id="password" name="password" required placeholder="••••••••" minlength="8">
>>>>>>> f88f49bbc623c4dcecf2fbf29b3238f8f6b4161b
                    <button type="button" class="toggle-password" onclick="togglePassword('password', this)" title="Hiện/Ẩn mật khẩu">
                        👁
                    </button>
                </div>
<<<<<<< HEAD
=======
                
                <div class="password-reqs">
                    <div class="reqs-title">YÊU CẦU BẢO MẬT</div>
                    <div class="reqs-grid">
                        <div class="req-item" id="req-length"><span class="req-icon"></span> Ít nhất 8 ký tự</div>
                        <div class="req-item" id="req-number"><span class="req-icon"></span> Ít nhất 1 số</div>
                        <div class="req-item" id="req-lower"><span class="req-icon"></span> Chứa chữ thường (a-z)</div>
                        <div class="req-item" id="req-upper"><span class="req-icon"></span> Chứa chữ hoa (A-Z)</div>
                    </div>
                </div>
>>>>>>> f88f49bbc623c4dcecf2fbf29b3238f8f6b4161b
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

<<<<<<< HEAD
        // Client-side validation
        document.getElementById('registerForm').addEventListener('submit', function(e) {
            const pw = document.getElementById('password').value;
            const cpw = document.getElementById('confirmPassword').value;
            
            if (pw.length < 6) {
                e.preventDefault();
                alert('Mật khẩu phải có ít nhất 6 ký tự!');
=======
        // Password validation logic
        const passwordInput = document.getElementById('password');
        const reqLength = document.getElementById('req-length');
        const reqNumber = document.getElementById('req-number');
        const reqLower = document.getElementById('req-lower');
        const reqUpper = document.getElementById('req-upper');

        passwordInput.addEventListener('input', function() {
            const val = this.value;
            toggleValid(reqLength, val.length >= 8);
            toggleValid(reqNumber, /\d/.test(val));
            toggleValid(reqLower, /[a-z]/.test(val));
            toggleValid(reqUpper, /[A-Z]/.test(val));
        });

        function toggleValid(element, isValid) {
            if (isValid) {
                element.classList.add('valid');
            } else {
                element.classList.remove('valid');
            }
        }

        // Client-side validation
        document.getElementById('registerForm').addEventListener('submit', function(e) {
            const pw = passwordInput.value;
            const cpw = document.getElementById('confirmPassword').value;
            
            if (pw.length < 8 || !/\d/.test(pw) || !/[a-z]/.test(pw) || !/[A-Z]/.test(pw)) {
                e.preventDefault();
                alert('Mật khẩu chưa đáp ứng đủ yêu cầu bảo mật!');
>>>>>>> f88f49bbc623c4dcecf2fbf29b3238f8f6b4161b
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
