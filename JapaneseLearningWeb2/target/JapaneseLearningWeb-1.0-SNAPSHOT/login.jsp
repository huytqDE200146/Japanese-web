<%-- 
    Document   : login
    Created on : Jan 21, 2026, 7:03:04 PM
    Author     : ADMIN
--%>

<%@ page contentType="text/html;charset=UTF-8" %>
<!DOCTYPE html>
<html>
<head>
    <title>Japanese Learning - Login</title>
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
            <h1>日本語を学ぼう</h1> <!-- "Let's learn Japanese" -->
            <p>Welcome to Japanese Learning</p>
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

        <form action="login" method="post">
            <div class="input-group">
                <label for="username">Username / ユーザー名</label>
                <input type="text" id="username" name="username" required placeholder="example_san">
            </div>

            <div class="input-group">
                <label for="password">Password / パスワード</label>
                <input type="password" id="password" name="password" required placeholder="••••••••">
            </div>

            <button type="submit" class="btn-login">
                Login <span>➔</span>
            </button>
        </form>
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
            
            // Randomize position, size, and animation
            const size = Math.random() * 20 + 15 + 'px'; // 15px to 35px
            span.style.fontSize = size;
            span.style.left = Math.random() * 100 + '%';
            
            const duration = Math.random() * 10 + 10 + 's'; // 10s to 20s (slower floating)
            span.style.animationDuration = duration;
            span.style.animationDelay = Math.random() * 5 + 's';
            
            // Random opacity for depth
            span.style.opacity = Math.random() * 0.5 + 0.1;

            container.appendChild(span);

            // Remove after animation (cleanup) to prevent overflow if we were generating continuously, 
            // but here we generate a fixed set. For a continuous stream loop, we'd need a different approach.
            // Since CSS loops infinitely, we just keep them.
        }

        for (let i = 0; i < particleCount; i++) {
            createKana();
        }
    </script>
</body>
</html>