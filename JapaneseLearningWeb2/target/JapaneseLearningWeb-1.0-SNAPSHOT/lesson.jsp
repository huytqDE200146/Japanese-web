<%@ page contentType="text/html;charset=UTF-8" %>
<%@ page import="java.util.List" %>
<%@ page import="java.util.Map" %>
<%@ page import="com.japaneselearning.model.Lesson" %>
<%@ page import="com.japaneselearning.model.User" %>

<%
    User user = (User) session.getAttribute("user");
    if (user == null) {
        response.sendRedirect("login.jsp");
        return;
    }
    Map<String, List<Lesson>> groupedLessons = (Map<String, List<Lesson>>) request.getAttribute("groupedLessons");
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
    <style>
        /* Sticky Footer */
        html, body {
            min-height: 100vh;
        }
        body {
            display: flex;
            flex-direction: column;
        }
        main {
            flex: 1;
        }
        .footer {
            margin-top: auto;
        }
        
        /* Page Hero */
        .page-hero {
            background: linear-gradient(135deg, rgba(188, 0, 45, 0.9) 0%, rgba(26, 26, 46, 0.95) 100%),
                        url('https://images.unsplash.com/photo-1480796927426-f609979314bd?w=1200') center/cover;
            border-radius: 20px;
            padding: 3rem 2rem;
            margin-bottom: 2.5rem;
            text-align: center;
            position: relative;
            overflow: hidden;
        }
        .page-hero::before {
            content: '学';
            position: absolute;
            right: 30px;
            top: 50%;
            transform: translateY(-50%);
            font-size: 8rem;
            opacity: 0.1;
            font-family: 'Noto Serif JP', serif;
        }
        .page-hero h1 {
            font-family: 'Noto Serif JP', serif;
            font-size: 2.5rem;
            margin-bottom: 0.5rem;
        }
        .page-hero p {
            color: rgba(255,255,255,0.8);
            font-size: 1.1rem;
        }
        
        /* Quick Stats */
        .quick-stats {
            display: flex;
            justify-content: center;
            gap: 2rem;
            margin-top: 1.5rem;
            flex-wrap: wrap;
        }
        .quick-stat {
            display: flex;
            align-items: center;
            gap: 0.5rem;
            background: rgba(255,255,255,0.15);
            padding: 0.5rem 1rem;
            border-radius: 25px;
            font-size: 0.9rem;
        }
        .quick-stat-icon {
            font-size: 1.2rem;
        }

        /* Category Grid */
        .category-grid {
            display: grid;
            grid-template-columns: repeat(3, 1fr);
            gap: 1.5rem;
            margin-bottom: 2rem;
            align-items: start;
        }
        @media (max-width: 1200px) {
            .category-grid {
                grid-template-columns: repeat(2, 1fr);
            }
        }
        @media (max-width: 768px) {
            .category-grid {
                grid-template-columns: 1fr;
            }
        }
        
        /* Category Card */
        .category-card {
            background: linear-gradient(145deg, rgba(30, 30, 50, 0.9) 0%, rgba(20, 20, 35, 0.95) 100%);
            backdrop-filter: blur(20px);
            border: 1px solid rgba(255, 255, 255, 0.08);
            border-radius: 20px;
            overflow: hidden;
            transition: all 0.3s cubic-bezier(0.4, 0, 0.2, 1);
            display: flex;
            flex-direction: column;
        }
        .category-card:hover {
            transform: translateY(-8px);
            box-shadow: 0 20px 50px rgba(188, 0, 45, 0.25);
            border-color: rgba(255, 183, 197, 0.3);
        }
        
        .category-card-header {
            padding: 1.25rem 1.5rem;
            display: flex;
            align-items: center;
            gap: 1rem;
            background: linear-gradient(135deg, rgba(255,255,255,0.05) 0%, transparent 100%);
            border-bottom: 1px solid rgba(255,255,255,0.06);
            cursor: pointer;
            transition: background 0.2s ease;
        }
        .category-card-header:hover {
            background: rgba(255,255,255,0.08);
        }
        .category-icon-box {
            width: 48px;
            height: 48px;
            border-radius: 12px;
            display: flex;
            align-items: center;
            justify-content: center;
            font-size: 1.6rem;
            flex-shrink: 0;
            box-shadow: 0 4px 15px rgba(0,0,0,0.3);
        }
        .category-info {
            flex-grow: 1;
            min-width: 0;
        }
        .category-info h3 {
            font-family: 'Noto Serif JP', serif;
            font-size: 1rem;
            margin: 0 0 0.2rem 0;
            color: white;
            font-weight: 600;
            white-space: nowrap;
            overflow: hidden;
            text-overflow: ellipsis;
        }
        .category-meta {
            display: flex;
            gap: 0.75rem;
            font-size: 0.75rem;
            color: rgba(255,255,255,0.5);
        }
        .toggle-icon {
            font-size: 1rem;
            transition: transform 0.3s ease;
            color: rgba(255,255,255,0.4);
            flex-shrink: 0;
        }
        .category-card.collapsed .toggle-icon {
            transform: rotate(-90deg);
        }
        
        /* Lessons List */
        .lessons-container {
            padding: 0.75rem;
            max-height: 280px;
            overflow-y: auto;
            flex-grow: 1;
        }
        .lessons-container::-webkit-scrollbar {
            width: 4px;
        }
        .lessons-container::-webkit-scrollbar-track {
            background: rgba(255,255,255,0.03);
            border-radius: 2px;
        }
        .lessons-container::-webkit-scrollbar-thumb {
            background: linear-gradient(180deg, #bc002d, #881337);
            border-radius: 2px;
        }
        
        .lesson-row {
            display: flex;
            align-items: center;
            padding: 0.6rem 0.8rem;
            background: rgba(255,255,255,0.02);
            border: 1px solid rgba(255,255,255,0.04);
            border-radius: 10px;
            margin-bottom: 0.4rem;
            transition: all 0.25s cubic-bezier(0.4, 0, 0.2, 1);
            gap: 0.75rem;
        }
        .lesson-row:hover {
            background: rgba(188, 0, 45, 0.12);
            border-color: rgba(188, 0, 45, 0.25);
            transform: translateX(4px);
        }
        .lesson-row:last-child {
            margin-bottom: 0;
        }
        
        .lesson-number {
            width: 26px;
            height: 26px;
            border-radius: 7px;
            background: linear-gradient(135deg, #bc002d 0%, #881337 100%);
            display: flex;
            align-items: center;
            justify-content: center;
            font-weight: 700;
            font-size: 0.7rem;
            flex-shrink: 0;
            box-shadow: 0 2px 6px rgba(188, 0, 45, 0.4);
        }
        .lesson-info {
            flex-grow: 1;
            min-width: 0;
        }
        .lesson-name {
            font-weight: 500;
            color: white;
            font-size: 0.85rem;
            white-space: nowrap;
            overflow: hidden;
            text-overflow: ellipsis;
            line-height: 1.3;
        }
        .lesson-desc {
            font-size: 0.7rem;
            color: rgba(255,255,255,0.45);
            margin-top: 1px;
        }
        .lesson-action {
            flex-shrink: 0;
        }
        .btn-lesson {
            background: transparent;
            border: 1px solid rgba(255, 183, 197, 0.4);
            color: #ffb7c5;
            padding: 0.3rem 0.8rem;
            border-radius: 16px;
            font-size: 0.7rem;
            font-weight: 500;
            text-decoration: none;
            transition: all 0.25s ease;
            display: inline-flex;
            align-items: center;
            gap: 0.25rem;
        }
        .btn-lesson:hover {
            background: var(--primary-red);
            border-color: var(--primary-red);
            color: white;
        }

        /* Gradient backgrounds for categories */
        .gradient-hiragana { background: linear-gradient(135deg, #4ade80 0%, #16a34a 100%); }
        .gradient-katakana { background: linear-gradient(135deg, #22d3ee 0%, #0891b2 100%); }
        .gradient-vocab { background: linear-gradient(135deg, #fbbf24 0%, #d97706 100%); }
        .gradient-grammar { background: linear-gradient(135deg, #f472b6 0%, #db2777 100%); }
        .gradient-kanji { background: linear-gradient(135deg, #bc002d 0%, #881337 100%); }
        .gradient-default { background: linear-gradient(135deg, #a855f7 0%, #7c3aed 100%); }

        /* Filter Bar */
        .filter-bar {
            display: flex;
            gap: 0.8rem;
            margin-bottom: 1.5rem;
            flex-wrap: wrap;
        }
        .filter-btn {
            background: var(--glass-bg);
            border: 1px solid var(--glass-border);
            color: var(--light-text);
            padding: 0.5rem 1.2rem;
            border-radius: 25px;
            font-size: 0.85rem;
            cursor: pointer;
            transition: all 0.2s ease;
        }
        .filter-btn:hover, .filter-btn.active {
            background: var(--primary-red);
            border-color: var(--primary-red);
            color: white;
        }
    </style>
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
                <li class="nav-item"><a class="nav-link" href="home.jsp">🏠 Home</a></li>
                <li class="nav-item"><a class="nav-link active" href="lessons">📚 Courses</a></li>
                <li class="nav-item"><a class="nav-link" href="quiz.jsp">✍️ Quiz</a></li>
                <li class="nav-item"><a class="nav-link" href="process.jsp">📊 Progress</a></li>
                <li class="nav-item"><a class="nav-link" href="ai-chat.jsp">🤖 AI Chat</a></li>
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

    <!-- Page Hero -->
    <section class="page-hero animate-fade-in">
        <h1>📚 Khoá Học / コース</h1>
        <p>Khám phá toàn bộ bài học tiếng Nhật từ cơ bản đến nâng cao</p>
        <div class="quick-stats">
            <div class="quick-stat">
                <span class="quick-stat-icon">📖</span>
                <span><%= groupedLessons != null ? groupedLessons.values().stream().mapToInt(List::size).sum() : 0 %> bài học</span>
            </div>
            <div class="quick-stat">
                <span class="quick-stat-icon">📂</span>
                <span><%= groupedLessons != null ? groupedLessons.size() : 0 %> chủ đề</span>
            </div>
            <div class="quick-stat">
                <span class="quick-stat-icon">🎯</span>
                <span>JLPT N5</span>
            </div>
        </div>
    </section>

    <% if (groupedLessons == null || groupedLessons.isEmpty()) { %>
        <div class="empty-state">
            <div class="empty-state-icon">📚</div>
            <h3>Chưa có bài học nào</h3>
            <p>まだレッスンがありません。Hãy quay lại sau!</p>
        </div>
    <% } else { 
        // Define icons and gradients for each category
        java.util.Map<String, String> categoryIcons = new java.util.LinkedHashMap<>();
        categoryIcons.put("Hiragana cơ bản", "あ");
        categoryIcons.put("Katakana cơ bản", "カ");
        categoryIcons.put("Từ Vựng & Kanji", "語");
        categoryIcons.put("Ngữ pháp cơ bản", "文");
        categoryIcons.put("Kanji", "漢");
        
        java.util.Map<String, String> categoryGradients = new java.util.LinkedHashMap<>();
        categoryGradients.put("Hiragana cơ bản", "gradient-hiragana");
        categoryGradients.put("Katakana cơ bản", "gradient-katakana");
        categoryGradients.put("Từ Vựng & Kanji", "gradient-vocab");
        categoryGradients.put("Ngữ pháp cơ bản", "gradient-grammar");
        categoryGradients.put("Kanji", "gradient-kanji");
        
        int catIndex = 0;
    %>

    <!-- Category Grid -->
    <div class="category-grid">
        <% for (Map.Entry<String, List<Lesson>> entry : groupedLessons.entrySet()) {
            String category = entry.getKey();
            List<Lesson> lessons = entry.getValue();
            String icon = categoryIcons.getOrDefault(category, "📖");
            String gradient = categoryGradients.getOrDefault(category, "gradient-default");
            catIndex++;
        %>
        <div class="category-card animate-fade-in" id="cat-<%= catIndex %>">
            <div class="category-card-header" onclick="toggleCategory(<%= catIndex %>)">
                <div class="category-icon-box <%= gradient %>"><%= icon %></div>
                <div class="category-info">
                    <h3><%= category %></h3>
                    <div class="category-meta">
                        <span>📚 <%= lessons.size() %> bài học</span>
                        <span>🎯 N5</span>
                    </div>
                </div>
                <span class="toggle-icon">▼</span>
            </div>
            <div class="lessons-container" id="lessons-<%= catIndex %>">
                <% int lessonNum = 0; for (Lesson l : lessons) { lessonNum++; %>
                <div class="lesson-row">
                    <div class="lesson-number"><%= lessonNum %></div>
                    <div class="lesson-info">
                        <div class="lesson-name"><%= l.getDescription() %></div>
                        <div class="lesson-desc"><%= l.getLevel() %></div>
                    </div>
                    <div class="lesson-action">
                        <a href="lesson-detail?id=<%= l.getLessonId() %>" class="btn-lesson">
                            Học <span>→</span>
                        </a>
                    </div>
                </div>
                <% } %>
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
<script>
    function toggleCategory(id) {
        const card = document.getElementById('cat-' + id);
        const container = document.getElementById('lessons-' + id);
        
        card.classList.toggle('collapsed');
        
        if (card.classList.contains('collapsed')) {
            container.style.maxHeight = '0';
            container.style.padding = '0 1rem';
            container.style.overflow = 'hidden';
        } else {
            container.style.maxHeight = '400px';
            container.style.padding = '1rem';
            container.style.overflow = 'auto';
        }
    }
</script>
</body>
</html>
