<%@ page contentType="text/html;charset=UTF-8" %>
<%@ page import="com.japaneselearning.model.User" %>
<%
    // Get user from session (parent page should have already validated)
    User navUser = (User) session.getAttribute("user");
    String currentPage = request.getParameter("activePage");
    if (currentPage == null) currentPage = "";
    
    // Avatar letter
    String navAvatarLetter = "U";
    String navUserName = "User";
    boolean navIsPremium = false;
    
    if (navUser != null) {
        navUserName = navUser.getFullName() != null ? navUser.getFullName() : "User";
        navAvatarLetter = navUserName.length() > 0 ? navUserName.substring(0, 1).toUpperCase() : "U";
        navIsPremium = navUser.hasPremiumAccess();
    }
%>

<!-- ===== ENHANCED NAVBAR ===== -->
<nav class="navbar-main">
    <div class="navbar-container">
        <!-- Logo -->
        <a href="home.jsp" class="navbar-logo">
            <span class="logo-icon">🎌</span>
            <span class="logo-text">日本語学習</span>
        </a>
        
        <!-- Mobile Toggle -->
        <button class="navbar-toggle" id="navbarToggle" aria-label="Toggle navigation">
            <span class="toggle-bar"></span>
            <span class="toggle-bar"></span>
            <span class="toggle-bar"></span>
        </button>
        
        <!-- Navigation Links -->
        <div class="navbar-menu" id="navbarMenu">
            <ul class="navbar-links">
                <li>
                    <a href="home.jsp" class="nav-link <%= "home".equals(currentPage) ? "active" : "" %>">
                        <span class="nav-icon">🏠</span>
                        <span class="nav-text">Home</span>
                    </a>
                </li>
                <li>
                    <a href="lessons" class="nav-link <%= "courses".equals(currentPage) ? "active" : "" %>">
                        <span class="nav-icon">📚</span>
                        <span class="nav-text">Courses</span>
                    </a>
                </li>
                <li>
                    <a href="quiz.jsp" class="nav-link <%= "quiz".equals(currentPage) ? "active" : "" %>">
                        <span class="nav-icon">✍️</span>
                        <span class="nav-text">Quiz</span>
                    </a>
                </li>
                <li>
                    <a href="process.jsp" class="nav-link <%= "progress".equals(currentPage) ? "active" : "" %>">
                        <span class="nav-icon">📊</span>
                        <span class="nav-text">Progress</span>
                    </a>
                </li>
                <li>
                    <a href="ai-chat.jsp" class="nav-link <%= "ai-chat".equals(currentPage) ? "active" : "" %>">
                        <span class="nav-icon">🤖</span>
                        <span class="nav-text">AI Chat</span>
                    </a>
                </li>
            </ul>
            
            <!-- Right Section -->
            <div class="navbar-right">
                <!-- Premium Button -->
                <a href="premium.jsp" class="premium-btn <%= navIsPremium ? "is-premium" : "" %>">
                    <% if (navIsPremium) { %>
                        <span class="premium-icon">👑</span>
                        <span class="premium-text">Premium</span>
                    <% } else { %>
                        <span class="premium-icon">⭐</span>
                        <span class="premium-text">Nâng cấp</span>
                    <% } %>
                </a>
                
                <!-- User Profile -->
                <div class="user-profile">
                    <div class="user-avatar <%= navIsPremium ? "premium" : "" %>">
                        <span class="avatar-letter"><%= navAvatarLetter %></span>
                        <% if (navIsPremium) { %>
                            <span class="crown-badge">👑</span>
                        <% } %>
                    </div>
                    <div class="user-info">
                        <span class="user-name"><%= navUserName %></span>
                        <span class="user-role"><%= navIsPremium ? "Premium Member" : "Free Member" %></span>
                    </div>
                </div>
                
                <!-- Logout Button -->
                <a href="logout" class="logout-btn" title="Đăng xuất">
                    <span class="logout-icon">🚪</span>
                </a>
            </div>
        </div>
    </div>
</nav>

<style>
/* ===== ENHANCED NAVBAR STYLES ===== */
.navbar-main {
    position: fixed;
    top: 0;
    left: 0;
    right: 0;
    z-index: 1000;
    background: linear-gradient(135deg, rgba(26, 26, 46, 0.95) 0%, rgba(22, 33, 62, 0.98) 100%);
    backdrop-filter: blur(20px);
    -webkit-backdrop-filter: blur(20px);
    border-bottom: 1px solid rgba(255, 255, 255, 0.1);
    box-shadow: 0 4px 30px rgba(0, 0, 0, 0.3);
}

.navbar-container {
    max-width: 1400px;
    margin: 0 auto;
    padding: 0 2rem;
    display: flex;
    align-items: center;
    justify-content: space-between;
    height: 70px;
}

/* Logo */
.navbar-logo {
    display: flex;
    align-items: center;
    gap: 0.75rem;
    text-decoration: none;
    transition: transform 0.3s ease;
}
.navbar-logo:hover {
    transform: scale(1.02);
}
.logo-icon {
    font-size: 1.8rem;
    animation: float 3s ease-in-out infinite;
}
@keyframes float {
    0%, 100% { transform: translateY(0); }
    50% { transform: translateY(-3px); }
}
.logo-text {
    font-family: 'Noto Serif JP', serif;
    font-size: 1.4rem;
    font-weight: 700;
    background: linear-gradient(135deg, #ff6b6b 0%, #ee5a5a 50%, #ffd700 100%);
    -webkit-background-clip: text;
    -webkit-text-fill-color: transparent;
    background-clip: text;
}

/* Mobile Toggle */
.navbar-toggle {
    display: none;
    flex-direction: column;
    gap: 5px;
    padding: 10px;
    background: transparent;
    border: none;
    cursor: pointer;
}
.toggle-bar {
    width: 25px;
    height: 3px;
    background: white;
    border-radius: 3px;
    transition: all 0.3s ease;
}

/* Navigation Menu */
.navbar-menu {
    display: flex;
    align-items: center;
    flex: 1;
    justify-content: space-between;
    margin-left: 3rem;
}

.navbar-links {
    display: flex;
    align-items: center;
    gap: 0.5rem;
    list-style: none;
    padding: 0;
    margin: 0;
}

/* Nav Links */
.nav-link {
    display: flex;
    align-items: center;
    gap: 0.5rem;
    padding: 0.6rem 1rem;
    border-radius: 12px;
    text-decoration: none;
    color: rgba(255, 255, 255, 0.7);
    font-weight: 500;
    font-size: 0.9rem;
    transition: all 0.3s cubic-bezier(0.4, 0, 0.2, 1);
    position: relative;
    overflow: hidden;
}
.nav-link::before {
    content: '';
    position: absolute;
    top: 0;
    left: 0;
    right: 0;
    bottom: 0;
    background: linear-gradient(135deg, rgba(255, 107, 107, 0.15), rgba(238, 90, 90, 0.1));
    opacity: 0;
    transition: opacity 0.3s ease;
    border-radius: 12px;
}
.nav-link:hover {
    color: white;
    transform: translateY(-2px);
}
.nav-link:hover::before {
    opacity: 1;
}
.nav-link.active {
    color: white;
    background: linear-gradient(135deg, rgba(255, 107, 107, 0.25), rgba(238, 90, 90, 0.15));
    border: 1px solid rgba(255, 107, 107, 0.3);
}
.nav-icon {
    font-size: 1.1rem;
}

/* Right Section */
.navbar-right {
    display: flex;
    align-items: center;
    gap: 1rem;
}

/* Premium Button */
.premium-btn {
    display: flex;
    align-items: center;
    gap: 0.5rem;
    padding: 0.6rem 1.2rem;
    border-radius: 25px;
    text-decoration: none;
    font-weight: 600;
    font-size: 0.85rem;
    transition: all 0.3s ease;
    background: linear-gradient(135deg, rgba(255, 215, 0, 0.15), rgba(255, 183, 0, 0.1));
    border: 1px solid rgba(255, 215, 0, 0.3);
    color: #ffd700;
}
.premium-btn:hover {
    background: linear-gradient(135deg, rgba(255, 215, 0, 0.25), rgba(255, 183, 0, 0.2));
    transform: translateY(-2px);
    box-shadow: 0 5px 20px rgba(255, 215, 0, 0.25);
    color: #ffd700;
}
.premium-btn.is-premium {
    background: linear-gradient(135deg, #ffd700, #ffb700);
    color: #1a1a2e;
    border: none;
    animation: premiumGlow 2s ease-in-out infinite;
}
@keyframes premiumGlow {
    0%, 100% { box-shadow: 0 0 10px rgba(255, 215, 0, 0.3); }
    50% { box-shadow: 0 0 25px rgba(255, 215, 0, 0.5); }
}
.premium-icon {
    font-size: 1rem;
}

/* User Profile */
.user-profile {
    display: flex;
    align-items: center;
    gap: 0.75rem;
    padding: 0.4rem 0.8rem;
    border-radius: 30px;
    background: rgba(255, 255, 255, 0.05);
    border: 1px solid rgba(255, 255, 255, 0.1);
    transition: all 0.3s ease;
}
.user-profile:hover {
    background: rgba(255, 255, 255, 0.1);
    border-color: rgba(255, 255, 255, 0.2);
}

.user-avatar {
    position: relative;
    width: 40px;
    height: 40px;
    border-radius: 50%;
    background: linear-gradient(135deg, #ff6b6b, #ee5a5a);
    display: flex;
    align-items: center;
    justify-content: center;
}
.user-avatar.premium {
    background: linear-gradient(135deg, #ffd700, #ffb700);
}
.user-avatar.premium::before {
    content: '';
    position: absolute;
    inset: -3px;
    border-radius: 50%;
    background: conic-gradient(from 0deg, #ffd700, #ff9500, #ffd700, #ffed4a, #ffd700);
    z-index: -1;
    animation: rotateBorder 3s linear infinite;
}
@keyframes rotateBorder {
    to { transform: rotate(360deg); }
}
.avatar-letter {
    font-size: 1.1rem;
    font-weight: 700;
    color: white;
}
.user-avatar.premium .avatar-letter {
    color: #1a1a2e;
}
.crown-badge {
    position: absolute;
    top: -8px;
    right: -5px;
    font-size: 0.75rem;
    animation: bounce 1.5s ease-in-out infinite;
}
@keyframes bounce {
    0%, 100% { transform: translateY(0); }
    50% { transform: translateY(-3px); }
}

.user-info {
    display: flex;
    flex-direction: column;
}
.user-name {
    font-size: 0.9rem;
    font-weight: 600;
    color: white;
    line-height: 1.2;
}
.user-role {
    font-size: 0.7rem;
    color: rgba(255, 255, 255, 0.5);
}

/* Logout Button */
.logout-btn {
    display: flex;
    align-items: center;
    justify-content: center;
    width: 40px;
    height: 40px;
    border-radius: 12px;
    background: rgba(244, 67, 54, 0.1);
    border: 1px solid rgba(244, 67, 54, 0.3);
    text-decoration: none;
    transition: all 0.3s ease;
}
.logout-btn:hover {
    background: rgba(244, 67, 54, 0.2);
    transform: translateY(-2px);
    box-shadow: 0 5px 15px rgba(244, 67, 54, 0.2);
}
.logout-icon {
    font-size: 1.1rem;
}

/* Mobile Responsive */
@media (max-width: 1024px) {
    .navbar-container {
        padding: 0 1rem;
    }
    .navbar-toggle {
        display: flex;
    }
    .navbar-menu {
        position: fixed;
        top: 70px;
        left: 0;
        right: 0;
        bottom: 0;
        background: rgba(26, 26, 46, 0.98);
        backdrop-filter: blur(20px);
        flex-direction: column;
        padding: 2rem;
        margin-left: 0;
        transform: translateX(-100%);
        transition: transform 0.3s ease;
    }
    .navbar-menu.active {
        transform: translateX(0);
    }
    .navbar-links {
        flex-direction: column;
        width: 100%;
        gap: 0.5rem;
    }
    .navbar-links li {
        width: 100%;
    }
    .nav-link {
        width: 100%;
        padding: 1rem;
        justify-content: flex-start;
    }
    .navbar-right {
        flex-direction: column;
        width: 100%;
        margin-top: 2rem;
        padding-top: 2rem;
        border-top: 1px solid rgba(255, 255, 255, 0.1);
    }
    .premium-btn {
        width: 100%;
        justify-content: center;
        padding: 1rem;
    }
    .user-profile {
        width: 100%;
        justify-content: center;
        padding: 1rem;
    }
    .user-info {
        display: none;
    }
    .logout-btn {
        width: 100%;
        border-radius: 12px;
        height: auto;
        padding: 1rem;
    }
}

/* Add padding to body for fixed navbar */
body {
    padding-top: 70px;
}
</style>

<script>
// Mobile menu toggle
document.addEventListener('DOMContentLoaded', function() {
    const toggle = document.getElementById('navbarToggle');
    const menu = document.getElementById('navbarMenu');
    
    if (toggle && menu) {
        toggle.addEventListener('click', function() {
            menu.classList.toggle('active');
            toggle.classList.toggle('active');
        });
    }
});
</script>
