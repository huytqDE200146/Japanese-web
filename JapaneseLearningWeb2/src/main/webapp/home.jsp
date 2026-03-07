<%@ page contentType="text/html;charset=UTF-8" %>
<%@ page import="com.japaneselearning.model.User" %>

<%
    User user = (User) session.getAttribute("user");
    boolean isGuest = (user == null);
    
    // Get first letter for avatar
    String avatarLetter = "U";
    if (!isGuest && user.getFullName() != null && !user.getFullName().isEmpty()) {
        avatarLetter = user.getFullName().substring(0, 1).toUpperCase();
    }
%>

<!DOCTYPE html>
<html lang="vi">
<head>
    <title>Home - Japanese Learning</title>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <meta name="description" content="Learn Japanese online with interactive lessons, quizzes, and AI chat support.">
    <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/css/bootstrap.min.css">
    <link rel="stylesheet" href="css/main-style.css">
    <link href="https://fonts.googleapis.com/css2?family=Noto+Serif+JP:wght@400;700&family=Poppins:wght@300;400;500;600;700&display=swap" rel="stylesheet">
</head>

<body>

<!-- ===== NAVBAR (Component) ===== -->
<jsp:include page="components/navbar.jsp">
    <jsp:param name="activePage" value="home" />
</jsp:include>

<!-- ===== MAIN CONTENT ===== -->
<main class="main-container">

    <!-- Hero Section -->
    <section class="hero-section animate-fade-in">
        <h1 class="hero-title">Welcome to <span>Japanese Learning</span></h1>
        <p class="hero-subtitle">
            Start your journey to master Japanese language with our interactive lessons, 
            comprehensive quizzes, and AI-powered conversation practice.
        </p>
        <p class="hero-japanese">日本語の世界へようこそ！</p>
    </section>

    <!-- Stats Row -->
    <div class="stats-row">
        <div class="stat-card animate-fade-in animate-delay-1">
            <div class="stat-icon">📖</div>
            <div class="stat-info">
                <h3>50+</h3>
                <p>Lessons Available</p>
            </div>
        </div>
        <div class="stat-card animate-fade-in animate-delay-2">
            <div class="stat-icon">✍️</div>
            <div class="stat-info">
                <h3>200+</h3>
                <p>Practice Questions</p>
            </div>
        </div>
        <div class="stat-card animate-fade-in animate-delay-3">
            <div class="stat-icon">🎯</div>
            <div class="stat-info">
                <h3>N5-N1</h3>
                <p>All JLPT Levels</p>
            </div>
        </div>
        <div class="stat-card animate-fade-in animate-delay-4">
            <div class="stat-icon">🤖</div>
            <div class="stat-info">
                <h3>AI</h3>
                <p>Chat Support</p>
            </div>
        </div>
    </div>

    <!-- Featured Courses Section -->
    <section class="animate-fade-in">
        <div class="section-header">
            <h2 class="section-title">Featured Courses</h2>
            <a href="lessons" class="view-all-btn">View All →</a>
        </div>

        <div class="courses-grid">
            <!-- Course Card 1 -->
            <div class="course-card">
                <div class="course-image" style="background: linear-gradient(135deg, #4ade80 0%, #16213e 100%);">
                    あ
                    <span class="course-level n5">N5</span>
                </div>
                <div class="course-content">
                    <h3 class="course-title">Hiragana Basics</h3>
                    <p class="course-desc">Master the fundamental Japanese writing system with interactive exercises.</p>
                    <div class="course-meta">
                        <span class="course-lessons">📚 12 lessons</span>
                        <a href="<%= isGuest ? "login" : "lessons" %>" class="btn-start">Start</a>
                    </div>
                </div>
            </div>

            <!-- Course Card 2 -->
            <div class="course-card">
                <div class="course-image" style="background: linear-gradient(135deg, #22d3ee 0%, #16213e 100%);">
                    カ
                    <span class="course-level n4">N4</span>
                </div>
                <div class="course-content">
                    <h3 class="course-title">Katakana Complete</h3>
                    <p class="course-desc">Learn Katakana for foreign words and modern Japanese vocabulary.</p>
                    <div class="course-meta">
                        <span class="course-lessons">📚 10 lessons</span>
                        <a href="<%= isGuest ? "login" : "lessons" %>" class="btn-start">Start</a>
                    </div>
                </div>
            </div>

            <!-- Course Card 3 -->
            <div class="course-card">
                <div class="course-image" style="background: linear-gradient(135deg, #ffd700 0%, #16213e 100%);">
                    漢
                    <span class="course-level n3">N3</span>
                </div>
                <div class="course-content">
                    <h3 class="course-title">Kanji Essentials</h3>
                    <p class="course-desc">Essential Kanji characters for everyday communication and reading.</p>
                    <div class="course-meta">
                        <span class="course-lessons">📚 25 lessons</span>
                        <a href="<%= isGuest ? "login" : "lessons" %>" class="btn-start">Start</a>
                    </div>
                </div>
            </div>
        </div>
    </section>

    <!-- Call to Action for Guests OR User Profile -->
    <% if (isGuest) { %>
    <section class="animate-fade-in" style="margin-top: 4rem;">
        <div class="user-card" style="text-align: center; padding: 4rem 2rem; background: linear-gradient(145deg, rgba(188, 0, 45, 0.15), rgba(20, 20, 35, 0.95)); border: 1px solid rgba(255, 183, 197, 0.2);">
            <h2 style="font-family: 'Noto Serif JP', serif; font-size: 2rem; color: white; margin-bottom: 1rem;">Start Learning Japanese Today!</h2>
            <p style="color: rgba(255,255,255,0.7); margin-bottom: 2rem; max-width: 600px; margin-left: auto; margin-right: auto;">
                Unlock all interactive lessons, JLPT quizzes, AI chat features, and track your progress. 
                Register a free account to begin your journey.
            </p>
            <div style="display: flex; gap: 1rem; justify-content: center;">
                <a href="register.jsp" class="btn-start" style="padding: 0.8rem 2.5rem; font-size: 1.1rem; background: var(--gradient-primary);">Sign Up Now</a>
                <a href="login.jsp" class="btn-start" style="padding: 0.8rem 2.5rem; font-size: 1.1rem; background: rgba(255,255,255,0.1); border: 1px solid rgba(255,255,255,0.2); color: white;">Log In</a>
            </div>
        </div>
    </section>
    <% } else { %>
    <!-- User Profile Section -->
    <section class="animate-fade-in">
        <div class="section-header">
            <h2 class="section-title">Your Profile</h2>
        </div>

        <div class="user-card">
            <div class="user-card-header">
                <div class="user-avatar"><%= avatarLetter %></div>
                <div class="user-info">
                    <h2><%= user.getFullName() %></h2>
                    <p>@<%= user.getUsername() %> • Member</p>
                </div>
            </div>
            <div class="user-details">
                <div class="detail-item">
                    <span class="detail-label">Email</span>
                    <span class="detail-value"><%= user.getEmail() %></span>
                </div>
                <div class="detail-item">
                    <span class="detail-label">Role</span>
                    <span class="detail-value"><%= user.getRole() %></span>
                </div>
                <div class="detail-item">
                    <span class="detail-label">Status</span>
                    <span class="detail-value" style="color: #4ade80;"><%= user.getStatus() %></span>
                </div>
                <div class="detail-item">
                    <span class="detail-label">Current Level</span>
                    <span class="detail-value">JLPT N<%= user.getLevel() > 0 ? user.getLevel() : "未設定" %></span>
                </div>
            </div>
        </div>
    </section>
    <% } %>

</main>

<!-- ===== FOOTER ===== -->
<footer class="footer">
    <p>© 2026 <span class="footer-brand">日本語学習</span> - Japanese Learning Platform. All rights reserved.</p>
</footer>

<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/js/bootstrap.bundle.min.js"></script>
</body>
</html>
