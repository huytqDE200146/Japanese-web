<%-- 
    Document   : profile
    Created on : Feb 19, 2026
    Author     : ADMIN
--%>

<%@ page contentType="text/html;charset=UTF-8" %>
<%@ page import="com.japaneselearning.model.User" %>
<%
    User user = (User) session.getAttribute("user");
    if (user == null) {
        response.sendRedirect("login");
        return;
    }
    User profileUser = (User) request.getAttribute("profileUser");
    if (profileUser == null) profileUser = user;
    
    String avatarLetter = profileUser.getFullName() != null && profileUser.getFullName().length() > 0 
        ? profileUser.getFullName().substring(0, 1).toUpperCase() : "U";
    boolean isPremium = profileUser.hasPremiumAccess();
    boolean isGoogleUser = profileUser.getGoogleId() != null && !profileUser.getGoogleId().isEmpty();
%>

<!DOCTYPE html>
<html lang="vi">
<head>
    <title>Hồ sơ cá nhân - Japanese Learning</title>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/css/bootstrap.min.css">
    <link rel="stylesheet" href="css/main-style.css">
    <link href="https://fonts.googleapis.com/css2?family=Noto+Serif+JP:wght@400;700&family=Poppins:wght@300;400;500;600;700&display=swap" rel="stylesheet">
    <style>
        .profile-container {
            max-width: 800px;
            margin: 2rem auto;
            padding: 0 1rem;
        }
        
        /* Profile Header */
        .profile-header {
            background: linear-gradient(135deg, rgba(188, 0, 45, 0.85) 0%, rgba(26, 26, 46, 0.95) 100%);
            border-radius: 20px;
            padding: 2.5rem;
            text-align: center;
            margin-bottom: 2rem;
            position: relative;
            overflow: hidden;
        }
        .profile-header::before {
            content: '';
            position: absolute;
            top: 0; left: 0; right: 0; bottom: 0;
            background: radial-gradient(circle at 30% 50%, rgba(255,255,255,0.08) 0%, transparent 60%);
        }
        
        .profile-avatar {
            width: 100px;
            height: 100px;
            border-radius: 50%;
            background: linear-gradient(135deg, #ff6b6b, #ee5a5a);
            display: flex;
            align-items: center;
            justify-content: center;
            font-size: 2.5rem;
            font-weight: 700;
            color: white;
            margin: 0 auto 1rem;
            position: relative;
            z-index: 1;
            border: 4px solid rgba(255,255,255,0.2);
        }
        .profile-avatar.premium {
            background: linear-gradient(135deg, #ffd700, #ffb700);
            color: #1a1a2e;
            box-shadow: 0 0 30px rgba(255, 215, 0, 0.3);
        }
        
        .profile-name {
            font-family: 'Noto Serif JP', serif;
            font-size: 1.6rem;
            font-weight: 700;
            color: white;
            margin-bottom: 0.3rem;
            position: relative;
            z-index: 1;
        }
        .profile-status {
            display: inline-flex;
            align-items: center;
            gap: 0.4rem;
            padding: 0.3rem 1rem;
            border-radius: 20px;
            font-size: 0.85rem;
            font-weight: 600;
            position: relative;
            z-index: 1;
        }
        .profile-status.premium {
            background: linear-gradient(135deg, #ffd700, #ffb700);
            color: #1a1a2e;
        }
        .profile-status.free {
            background: rgba(255,255,255,0.15);
            color: rgba(255,255,255,0.8);
        }
        .profile-joined {
            color: rgba(255,255,255,0.5);
            font-size: 0.8rem;
            margin-top: 0.8rem;
            position: relative;
            z-index: 1;
        }
        
        /* Profile Form Card */
        .profile-card {
            background: var(--glass-bg);
            backdrop-filter: blur(20px);
            border: 1px solid var(--glass-border);
            border-radius: 20px;
            padding: 2rem;
            margin-bottom: 1.5rem;
        }
        .card-title {
            font-family: 'Noto Serif JP', serif;
            font-size: 1.2rem;
            margin-bottom: 1.5rem;
            padding-bottom: 0.8rem;
            border-bottom: 1px solid rgba(255,255,255,0.1);
            display: flex;
            align-items: center;
            gap: 0.6rem;
        }
        
        .form-group {
            margin-bottom: 1.2rem;
        }
        .form-group label {
            display: block;
            color: rgba(255,255,255,0.7);
            font-size: 0.85rem;
            margin-bottom: 0.4rem;
            font-weight: 500;
        }
        .form-group input {
            width: 100%;
            padding: 0.8rem 1rem;
            background: rgba(255,255,255,0.06);
            border: 1px solid rgba(255,255,255,0.12);
            border-radius: 12px;
            color: white;
            font-size: 0.95rem;
            transition: all 0.3s ease;
        }
        .form-group input:focus {
            outline: none;
            border-color: var(--sakura-pink);
            background: rgba(255,255,255,0.1);
            box-shadow: 0 0 0 3px rgba(188, 0, 45, 0.15);
        }
        .form-group input:disabled {
            opacity: 0.5;
            cursor: not-allowed;
        }
        .form-group .form-hint {
            font-size: 0.75rem;
            color: rgba(255,255,255,0.4);
            margin-top: 0.3rem;
        }
        
        /* Info Row (read-only) */
        .info-row {
            display: flex;
            justify-content: space-between;
            align-items: center;
            padding: 0.8rem 0;
            border-bottom: 1px solid rgba(255,255,255,0.06);
        }
        .info-row:last-child { border-bottom: none; }
        .info-label {
            color: rgba(255,255,255,0.5);
            font-size: 0.85rem;
        }
        .info-value {
            color: white;
            font-weight: 500;
        }
        
        /* Buttons */
        .btn-save {
            width: 100%;
            padding: 0.9rem;
            background: linear-gradient(135deg, #bc002d, #881337);
            color: white;
            border: none;
            border-radius: 12px;
            font-size: 1rem;
            font-weight: 600;
            cursor: pointer;
            transition: all 0.3s ease;
        }
        .btn-save:hover {
            transform: translateY(-2px);
            box-shadow: 0 10px 30px rgba(188, 0, 45, 0.3);
        }
        
        /* Alerts */
        .profile-alert {
            padding: 0.8rem 1.2rem;
            border-radius: 12px;
            margin-bottom: 1.5rem;
            font-size: 0.9rem;
            font-weight: 500;
        }
        .profile-alert.success {
            background: rgba(76, 175, 80, 0.15);
            border: 1px solid rgba(76, 175, 80, 0.3);
            color: #66bb6a;
        }
        .profile-alert.error {
            background: rgba(244, 67, 54, 0.15);
            border: 1px solid rgba(244, 67, 54, 0.3);
            color: #ef5350;
        }

        /* Password toggle */
        .password-wrapper {
            position: relative;
        }
        .password-wrapper input {
            padding-right: 48px;
        }
        .toggle-pw {
            position: absolute;
            right: 10px;
            top: 50%;
            transform: translateY(-50%);
            background: none;
            border: none;
            font-size: 1.1rem;
            cursor: pointer;
            opacity: 0.5;
            transition: opacity 0.2s;
        }
        .toggle-pw:hover { opacity: 1; }
    </style>
</head>

<body>

<!-- Navbar -->
<jsp:include page="components/navbar.jsp">
    <jsp:param name="activePage" value=""/>
</jsp:include>

<main class="main-container">
    <div class="profile-container">

        <%
            String error = (String) request.getAttribute("error");
            String success = (String) request.getAttribute("success");
            if (error != null) {
        %>
        <div class="profile-alert error">⚠ <%= error %></div>
        <% } if (success != null) { %>
        <div class="profile-alert success">✅ <%= success %></div>
        <% } %>

        <!-- Profile Header -->
        <div class="profile-header animate-fade-in">
            <div class="profile-avatar <%= isPremium ? "premium" : "" %>">
                <%= avatarLetter %>
            </div>
            <div class="profile-name"><%= profileUser.getFullName() %></div>
            <div class="profile-status <%= isPremium ? "premium" : "free" %>">
                <%= isPremium ? "👑 Premium Member" : "Free Member" %>
            </div>
            <div class="profile-joined">
                🗓️ Tham gia: <%= profileUser.getCreatedAt() != null ? new java.text.SimpleDateFormat("dd/MM/yyyy").format(profileUser.getCreatedAt()) : "N/A" %>
            </div>
        </div>

        <!-- Account Info (Read-only) -->
        <div class="profile-card animate-fade-in">
            <h2 class="card-title">📋 Thông tin tài khoản</h2>
            <div class="info-row">
                <span class="info-label">Tên đăng nhập</span>
                <span class="info-value"><%= profileUser.getUsername() %></span>
            </div>
            <div class="info-row">
                <span class="info-label">Vai trò</span>
                <span class="info-value"><%= profileUser.getRole() %></span>
            </div>
            <div class="info-row">
                <span class="info-label">Trạng thái</span>
                <span class="info-value" style="color: #4caf50;"><%= profileUser.getStatus() %></span>
            </div>
            <% if (isGoogleUser) { %>
            <div class="info-row">
                <span class="info-label">Liên kết Google</span>
                <span class="info-value" style="color: #4285f4;">✅ Đã liên kết</span>
            </div>
            <% } %>
            <% if (isPremium && profileUser.getPremiumUntil() != null) { %>
            <div class="info-row">
                <span class="info-label">Premium hết hạn</span>
                <span class="info-value" style="color: #ffd700;"><%= new java.text.SimpleDateFormat("dd/MM/yyyy HH:mm").format(profileUser.getPremiumUntil()) %></span>
            </div>
            <% } %>
        </div>

        <!-- Editable Profile -->
        <div class="profile-card animate-fade-in">
            <h2 class="card-title">✏️ Chỉnh sửa hồ sơ</h2>
            <form action="profile" method="post">
                <div class="form-group">
                    <label>Họ và tên / 氏名</label>
                    <input type="text" name="fullName" value="<%= profileUser.getFullName() != null ? profileUser.getFullName() : "" %>" required>
                </div>

                <div class="form-group">
                    <label>Email / メール</label>
                    <input type="email" name="email" value="<%= profileUser.getEmail() != null ? profileUser.getEmail() : "" %>" required>
                </div>

                <% if (!isGoogleUser) { %>
                <div class="form-group">
                    <label>Mật khẩu mới / 新パスワード</label>
                    <div class="password-wrapper">
                        <input type="password" name="password" id="newPassword" placeholder="Để trống nếu không đổi" minlength="6">
                        <button type="button" class="toggle-pw" onclick="togglePw('newPassword', this)">🙉</button>
                    </div>
                    <div class="form-hint">Tối thiểu 6 ký tự. Để trống nếu không muốn thay đổi.</div>
                </div>

                <div class="form-group">
                    <label>Xác nhận mật khẩu / 確認</label>
                    <div class="password-wrapper">
                        <input type="password" name="confirmPassword" id="confirmPassword" placeholder="Nhập lại mật khẩu mới">
                        <button type="button" class="toggle-pw" onclick="togglePw('confirmPassword', this)">🙉</button>
                    </div>
                </div>
                <% } %>

                <button type="submit" class="btn-save">💾 Lưu thay đổi</button>
            </form>
        </div>

    </div>
</main>

<!-- Footer -->
<footer class="footer">
    <p>© 2026 <span class="footer-brand">日本語学習</span> - Japanese Learning Platform. All rights reserved.</p>
</footer>

<script>
function togglePw(inputId, btn) {
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

<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/js/bootstrap.bundle.min.js"></script>
</body>
</html>
