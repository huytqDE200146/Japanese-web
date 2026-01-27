<%@ page contentType="text/html;charset=UTF-8" %>
<%@ page import="java.util.List" %>
<%@ page import="com.japaneselearning.model.Lesson" %>
<%@ page import="com.japaneselearning.model.User" %>

<%
    User user = (User) session.getAttribute("user");
    if (user == null) {
        response.sendRedirect("login.jsp");
        return;
    }
    List<Lesson> lessons = (List<Lesson>) request.getAttribute("lessons");
%>

<!DOCTYPE html>
<html lang="vi">
<head>
    <title>Courses - Japanese Learning</title>
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

    <!-- Page Header -->
    <section class="section-header" style="margin-bottom: 2rem;">
        <h1 class="section-title" style="font-size: 2.2rem;">All Courses / すべてのコース</h1>
    </section>

    <% if (lessons == null || lessons.isEmpty()) { %>
        <!-- Empty State -->
        <div class="empty-state">
            <div class="empty-state-icon">📚</div>
            <h3>No Lessons Available</h3>
            <p>まだレッスンがありません。Check back later for new courses!</p>
        </div>
    <% } else { %>
        <!-- Courses Grid -->
        <div class="courses-grid">
            <% 
                String[] icons = {"あ", "カ", "漢", "文", "語", "読", "書", "聴"};
                String[] gradients = {
                    "linear-gradient(135deg, #4ade80 0%, #16213e 100%)",
                    "linear-gradient(135deg, #22d3ee 0%, #16213e 100%)",
                    "linear-gradient(135deg, #ffd700 0%, #16213e 100%)",
                    "linear-gradient(135deg, #f97316 0%, #16213e 100%)",
                    "linear-gradient(135deg, #bc002d 0%, #16213e 100%)",
                    "linear-gradient(135deg, #a855f7 0%, #16213e 100%)",
                    "linear-gradient(135deg, #ec4899 0%, #16213e 100%)",
                    "linear-gradient(135deg, #14b8a6 0%, #16213e 100%)"
                };
                int index = 0;
                for (Lesson l : lessons) { 
                    String icon = icons[index % icons.length];
                    String gradient = gradients[index % gradients.length];
                    String level = l.getLevel() != null ? l.getLevel().toUpperCase() : "N5";
                    String levelClass = level.toLowerCase().replace(" ", "");
                    index++;
            %>
            <div class="course-card animate-fade-in">
                <div class="course-image" style="background: <%= gradient %>;">
                    <%= icon %>
                    <span class="course-level <%= levelClass %>"><%= level %></span>
                </div>
                <div class="course-content">
                    <h3 class="course-title"><%= l.getName() %></h3>
                    <p class="course-desc">
                        Learn <%= l.getName() %> with interactive exercises and practice materials.
                    </p>
                    <div class="course-meta">
                        <span class="course-lessons">📖 Level: <%= l.getLevel() %></span>
                        <a href="lesson-detail?id=<%= l.getLessonId() %>" class="btn-start">Study →</a>
                    </div>
                </div>
            </div>
            <% } %>
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
