<%@ page contentType="text/html;charset=UTF-8" %>
<%
    String resetEmail = (String) session.getAttribute("resetEmail");
    Boolean isOtpVerified = (Boolean) session.getAttribute("isOtpVerified");
    if (resetEmail == null || isOtpVerified == null || !isOtpVerified) {
        response.sendRedirect("forgot-password");
        return;
    }
%>
<!DOCTYPE html>
<html>
<head>
    <title>Japanese Learning - Đặt Lại Mật Khẩu</title>
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
</head>
<body>

    <div class="kana-container" id="kana-container"></div>

    <div class="login-card" style="margin-top: 40px; margin-bottom: 40px;">
        <div class="welcome-text">
            <h1>パスワードの再設定</h1> <!-- "Reset Password" -->
            <p>Đặt lại mật khẩu</p>
        </div>

        <form action="reset-password" method="post" id="resetForm">
            <div class="input-group">
                <label for="newPassword">Mật khẩu mới</label>
                <div class="password-wrapper">
                    <input type="password" id="newPassword" name="newPassword" required placeholder="••••••••" minlength="8">
                    <button type="button" class="toggle-password" onclick="togglePassword('newPassword', this)">🙉</button>
                </div>
                
                <div class="password-reqs">
                    <div class="reqs-title">YÊU CẦU BẢO MẬT</div>
                    <div class="reqs-grid">
                        <div class="req-item" id="req-length"><span class="req-icon"></span> Ít nhất 8 ký tự</div>
                        <div class="req-item" id="req-number"><span class="req-icon"></span> Ít nhất 1 số</div>
                        <div class="req-item" id="req-lower"><span class="req-icon"></span> Chứa chữ thường (a-z)</div>
                        <div class="req-item" id="req-upper"><span class="req-icon"></span> Chứa chữ hoa (A-Z)</div>
                    </div>
                </div>
            </div>

            <div class="input-group">
                <label for="confirmPassword">Xác nhận mật khẩu</label>
                <div class="password-wrapper">
                    <input type="password" id="confirmPassword" name="confirmPassword" required placeholder="••••••••">
                    <button type="button" class="toggle-password" onclick="togglePassword('confirmPassword', this)">🙉</button>
                </div>
            </div>

            <button type="submit" class="btn-login btn-register">
                Đổi mật khẩu <span>➔</span>
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

        // Password validation logic
        const passwordInput = document.getElementById('newPassword');
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
        document.getElementById('resetForm').addEventListener('submit', function(e) {
            const pw = passwordInput.value;
            const cpw = document.getElementById('confirmPassword').value;
            
            if (pw.length < 8 || !/\d/.test(pw) || !/[a-z]/.test(pw) || !/[A-Z]/.test(pw)) {
                e.preventDefault();
                alert('Mật khẩu chưa đáp ứng đủ yêu cầu bảo mật!');
                return;
            }
            if (pw !== cpw) {
                e.preventDefault();
                alert('Mật khẩu xác nhận không khớp!');
            }
        });

        function togglePassword(inputId, btn) {
            const input = document.getElementById(inputId);
            if (input.type === 'password') {
                input.type = 'text';
                btn.textContent = '🙈';
            } else {
                input.type = 'password';
                btn.textContent = '🙉';
            }
        }
    </script>
</body>
</html>
