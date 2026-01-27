<%@ page contentType="text/html;charset=UTF-8" %>
<%@ page import="com.japaneselearning.model.Lesson" %>
<%@ page import="com.japaneselearning.model.User" %>

<%
    User user = (User) session.getAttribute("user");
    if (user == null) {
        response.sendRedirect("login.jsp");
        return;
    }
    Lesson lesson = (Lesson) request.getAttribute("lesson");
    String content = (String) request.getAttribute("lessonContent");
%>

<!DOCTYPE html>
<html lang="vi">
<head>
    <title><%= lesson != null ? lesson.getName() : "Lesson" %> - Japanese Learning</title>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/css/bootstrap.min.css">
    <link rel="stylesheet" href="css/main-style.css">
    <link href="https://fonts.googleapis.com/css2?family=Noto+Serif+JP:wght@400;700&family=Poppins:wght@300;400;500;600;700&display=swap" rel="stylesheet">
</head>

<body>

<!-- ===== NAVBAR ===== -->
<nav class="navbar navbar-expand-lg">
    <div class="container-fluid">
        <a class="navbar-brand" href="home.jsp">日本語学習</a>

        <button class="navbar-toggler" type="button" data-bs-toggle="collapse" data-bs-target="#navbarNav">
            <span class="navbar-toggler-icon"></span>
        </button>

        <div class="collapse navbar-collapse" id="navbarNav">
            <ul class="navbar-nav me-auto mb-2 mb-lg-0">
                <li class="nav-item">
                    <a class="nav-link" href="home.jsp">🏠 Home</a>
                </li>
                <li class="nav-item">
                    <a class="nav-link active" href="lessons">📚 Courses</a>
                </li>
                <li class="nav-item">
                    <a class="nav-link" href="quiz.jsp">✍️ Quiz</a>
                </li>
                <li class="nav-item">
                    <a class="nav-link" href="process.jsp">📊 Progress</a>
                </li>
                <li class="nav-item">
                    <a class="nav-link" href="ai-chat.jsp">🤖 AI Chat</a>
                </li>
            </ul>

            <span class="navbar-text me-3">
                こんにちは、<strong><%= user.getFullName() %></strong> さん
            </span>

            <a href="logout" class="btn-logout">Logout</a>
        </div>
    </div>
</nav>

<!-- ===== MAIN CONTENT ===== -->
<main class="main-container">

    <!-- Breadcrumb -->
    <nav aria-label="breadcrumb" style="margin-bottom: 1.5rem;">
        <ol class="breadcrumb" style="background: transparent; padding: 0;">
            <li class="breadcrumb-item"><a href="home.jsp" style="color: var(--sakura-pink);">Home</a></li>
            <li class="breadcrumb-item"><a href="lessons" style="color: var(--sakura-pink);">Courses</a></li>
            <li class="breadcrumb-item active" style="color: var(--muted-text);"><%= lesson != null ? lesson.getName() : "Lesson" %></li>
        </ol>
    </nav>

    <% if (lesson != null) { %>
    <!-- Lesson Header -->
    <div class="lesson-header animate-fade-in">
        <h1><%= lesson.getName() %></h1>
        <span class="level-badge">Level: <%= lesson.getLevel() %></span>
    </div>

    <!-- Lesson Content -->
    <div class="lesson-content-wrapper animate-fade-in">
        <div class="lesson-content">
            <% if (content != null && !content.isEmpty()) { %>
                <%= content %>
            <% } else { %>
                <div class="empty-state" style="padding: 2rem;">
                    <div class="empty-state-icon">📄</div>
                    <h3>Content Coming Soon</h3>
                    <p>このレッスンの内容は準備中です。This lesson content is being prepared.</p>
                </div>
            <% } %>
        </div>
    </div>

    <!-- Navigation Buttons -->
    <div style="display: flex; justify-content: space-between; margin-top: 2rem;">
        <a href="lessons" class="btn-start" style="background: var(--card-bg); border: 1px solid var(--primary-red);">
            ← Back to Courses
        </a>
        <button class="btn-start" onclick="alert('Lesson Completed!')">
            Mark as Complete ✓
        </button>
    </div>

    <% } else { %>
    <!-- Lesson Not Found -->
    <div class="empty-state">
        <div class="empty-state-icon">❌</div>
        <h3>Lesson Not Found</h3>
        <p>レッスンが見つかりません。The requested lesson could not be found.</p>
        <a href="lessons" class="btn-start" style="display: inline-block; margin-top: 1rem;">← Back to Courses</a>
    </div>
    <% } %>

</main>

<!-- ===== FOOTER ===== -->
<footer class="footer">
    <p>© 2026 <span class="footer-brand">日本語学習</span> - Japanese Learning Platform. All rights reserved.</p>
</footer>

<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/js/bootstrap.bundle.min.js"></script>
</body>
</html>
