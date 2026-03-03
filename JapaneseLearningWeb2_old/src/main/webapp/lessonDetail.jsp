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
    
    // Navigation data
    Integer prevId = (Integer) request.getAttribute("prevLessonId");
    Integer nextId = (Integer) request.getAttribute("nextLessonId");
    Lesson prevLesson = (Lesson) request.getAttribute("prevLesson");
    Lesson nextLesson = (Lesson) request.getAttribute("nextLesson");
%>

<!DOCTYPE html>
<html lang="vi">
<head>
    <title><%= lesson != null ? lesson.getDescription() : "Lesson" %> - Japanese Learning</title>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/css/bootstrap.min.css">
    <link rel="stylesheet" href="css/main-style.css">
    <link href="https://fonts.googleapis.com/css2?family=Noto+Serif+JP:wght@400;700&family=Poppins:wght@300;400;500;600;700&display=swap" rel="stylesheet">
    <style>
        /* Page Layout */
        .lesson-page {
            display: grid;
            grid-template-columns: 1fr 280px;
            gap: 2rem;
            align-items: start;
        }
        
        @media (max-width: 992px) {
            .lesson-page {
                grid-template-columns: 1fr;
            }
            .lesson-sidebar {
                order: -1;
            }
        }

        /* Breadcrumb Enhanced */
        .breadcrumb-nav {
            background: var(--glass-bg);
            backdrop-filter: blur(15px);
            padding: 0.8rem 1.2rem;
            border-radius: 12px;
            margin-bottom: 1.5rem;
            border: 1px solid var(--glass-border);
        }
        .breadcrumb-nav ol {
            margin: 0;
            padding: 0;
            list-style: none;
            display: flex;
            flex-wrap: wrap;
            gap: 0.5rem;
            font-size: 0.9rem;
        }
        .breadcrumb-nav li::after {
            content: '›';
            margin-left: 0.5rem;
            color: var(--muted-text);
        }
        .breadcrumb-nav li:last-child::after {
            display: none;
        }
        .breadcrumb-nav a {
            color: var(--sakura-pink);
            text-decoration: none;
        }
        .breadcrumb-nav a:hover {
            text-decoration: underline;
        }

        /* Lesson Header Enhanced */
        .lesson-hero {
            background: linear-gradient(135deg, rgba(188, 0, 45, 0.85) 0%, rgba(26, 26, 46, 0.95) 100%);
            border-radius: 16px;
            padding: 2rem;
            margin-bottom: 2rem;
            position: relative;
            overflow: hidden;
        }
        .lesson-hero::before {
            content: '📖';
            position: absolute;
            right: 20px;
            top: 50%;
            transform: translateY(-50%);
            font-size: 6rem;
            opacity: 0.15;
        }
        .lesson-hero h1 {
            font-family: 'Noto Serif JP', serif;
            font-size: 1.8rem;
            margin-bottom: 1rem;
            position: relative;
            z-index: 1;
        }
        .lesson-meta {
            display: flex;
            gap: 1rem;
            flex-wrap: wrap;
            position: relative;
            z-index: 1;
        }
        .meta-badge {
            background: rgba(255,255,255,0.15);
            padding: 0.4rem 1rem;
            border-radius: 20px;
            font-size: 0.85rem;
            display: flex;
            align-items: center;
            gap: 0.4rem;
        }

        /* Content Area */
        .lesson-content-area {
            background: var(--glass-bg);
            backdrop-filter: blur(20px);
            border: 1px solid var(--glass-border);
            border-radius: 16px;
            padding: 2rem;
            margin-bottom: 2rem;
        }
        
        /* Override embedded content styles - Comprehensive Dark Theme */
        .lesson-content-area,
        .lesson-content-area * {
            background-color: transparent !important;
        }
        .lesson-content-area {
            font-family: 'Poppins', 'Noto Serif JP', sans-serif !important;
            line-height: 1.8 !important;
        }
        /* Override all body, div, table backgrounds */
        .lesson-content-area body,
        .lesson-content-area div,
        .lesson-content-area .container,
        .lesson-content-area .lesson-container {
            width: 100% !important;
            padding: 0 !important;
            margin: 0 !important;
            background: transparent !important;
            background-color: transparent !important;
        }
        .lesson-content-area .lesson,
        .lesson-content-area .lesson-section {
            background: rgba(255,255,255,0.05) !important;
            backdrop-filter: blur(10px) !important;
            border: 1px solid rgba(255,255,255,0.1) !important;
            padding: 1.5rem 2rem !important;
            border-radius: 16px !important;
            margin-bottom: 1.5rem !important;
            box-shadow: none !important;
        }
        .lesson-content-area h1, 
        .lesson-content-area h2 {
            font-family: 'Noto Serif JP', serif !important;
            color: var(--sakura-pink) !important;
            border-bottom: 2px solid rgba(188, 0, 45, 0.3) !important;
            padding-bottom: 0.5rem !important;
        }
        .lesson-content-area h3 {
            color: white !important;
            font-size: 1.1rem !important;
        }
        .lesson-content-area p, 
        .lesson-content-area div,
        .lesson-content-area li,
        .lesson-content-area ul {
            color: var(--light-text) !important;
        }
        
        /* Example and Structure boxes */
        .lesson-content-area .example,
        .lesson-content-area .example-box {
            background: rgba(188, 0, 45, 0.15) !important;
            border-left: 4px solid var(--primary-red) !important;
            border-radius: 0 12px 12px 0 !important;
            padding: 1rem 1.5rem !important;
            margin: 1rem 0 !important;
        }
        .lesson-content-area .structure,
        .lesson-content-area .grammar-structure {
            background: linear-gradient(135deg, rgba(188, 0, 45, 0.2) 0%, rgba(255, 183, 197, 0.1) 100%) !important;
            border: 1px solid rgba(255, 183, 197, 0.3) !important;
            border-radius: 12px !important;
            padding: 1rem 1.5rem !important;
            color: white !important;
            font-family: 'Noto Serif JP', serif !important;
            font-size: 1.2rem !important;
        }
        .lesson-content-area .note,
        .lesson-content-area .note-box {
            background: rgba(255, 215, 0, 0.1) !important;
            border-left: 4px solid var(--accent-gold) !important;
            border-radius: 0 12px 12px 0 !important;
            padding: 0.8rem 1.2rem !important;
            color: var(--accent-gold) !important;
            margin: 1rem 0 !important;
        }
        
        /* Tables - Dark Theme */
        .lesson-content-area table {
            width: 100% !important;
            border-collapse: separate !important;
            border-spacing: 0 !important;
            margin: 1rem 0 !important;
            border-radius: 12px !important;
            overflow: hidden !important;
            background: rgba(255,255,255,0.03) !important;
        }
        .lesson-content-area table th {
            background: linear-gradient(135deg, #bc002d 0%, #881337 100%) !important;
            color: white !important;
            padding: 0.8rem 1rem !important;
            text-align: left !important;
            font-weight: 600 !important;
            border: none !important;
        }
        .lesson-content-area table td {
            padding: 0.8rem 1rem !important;
            border-bottom: 1px solid rgba(255,255,255,0.05) !important;
            border-left: none !important;
            border-right: none !important;
            color: var(--light-text) !important;
            background: transparent !important;
        }
        .lesson-content-area table tr:hover td {
            background: rgba(255,255,255,0.08) !important;
        }
        .lesson-content-area table tr:nth-child(even) td {
            background: rgba(255,255,255,0.03) !important;
        }
        .lesson-content-area .jp,
        .lesson-content-area .jp-word {
            font-family: 'Noto Serif JP', serif !important;
            font-size: 1.1rem !important;
            font-weight: 500 !important;
            color: white !important;
        }
        
        /* Special table classes from old HTML */
        .lesson-content-area .table2,
        .lesson-content-area .table3 {
            border: none !important;
        }
        .lesson-content-area .td2,
        .lesson-content-area .td3 {
            border: 1px solid rgba(255,255,255,0.1) !important;
            background: rgba(255,255,255,0.03) !important;
            color: var(--light-text) !important;
        }
        .lesson-content-area .td3 {
            color: var(--sakura-pink) !important;
        }
        
        /* Section divider */
        .lesson-content-area hr,
        .lesson-content-area .section-divider {
            border: none !important;
            height: 1px !important;
            background: linear-gradient(90deg, transparent, rgba(255, 183, 197, 0.3), transparent) !important;
            margin: 2rem 0 !important;
        }
        
        /* Vocab table specific */
        .lesson-content-area .vocab-table tbody tr:hover {
            background: rgba(255,255,255,0.08) !important;
        }
        
        /* Particle highlights */
        .lesson-content-area .particle,
        .lesson-content-area span[style*="color:red"],
        .lesson-content-area span[style*="color: red"] {
            color: #ff4d6d !important;
            font-weight: bold !important;
        }
        .lesson-content-area span[style*="color:blue"],
        .lesson-content-area span[style*="color: blue"] {
            color: #60a5fa !important;
        }
        
        /* Translation text */
        .lesson-content-area .translation {
            color: #a0a0a0 !important;
            font-size: 0.95rem !important;
        }
        .lesson-content-area .japanese {
            font-family: 'Noto Serif JP', serif !important;
            font-size: 1.1rem !important;
            color: white !important;
        }

        /* Sidebar */
        .lesson-sidebar {
            position: sticky;
            top: 100px;
        }
        .sidebar-card {
            background: var(--glass-bg);
            backdrop-filter: blur(20px);
            border: 1px solid var(--glass-border);
            border-radius: 16px;
            padding: 1.5rem;
            margin-bottom: 1rem;
        }
        .sidebar-title {
            font-family: 'Noto Serif JP', serif;
            font-size: 1rem;
            margin-bottom: 1rem;
            padding-bottom: 0.8rem;
            border-bottom: 1px solid rgba(255,255,255,0.1);
            display: flex;
            align-items: center;
            gap: 0.5rem;
        }

        /* Navigation Buttons */
        .nav-buttons {
            display: flex;
            flex-direction: column;
            gap: 0.8rem;
        }
        .nav-btn-sidebar {
            display: flex;
            align-items: center;
            gap: 0.8rem;
            padding: 0.8rem 1rem;
            background: rgba(255,255,255,0.05);
            border: 1px solid var(--glass-border);
            border-radius: 10px;
            text-decoration: none;
            transition: all 0.2s ease;
            overflow: hidden;
        }
        .nav-btn-sidebar:hover {
            background: rgba(188, 0, 45, 0.2);
            border-color: var(--sakura-pink);
            transform: translateX(3px);
        }
        .nav-btn-icon {
            width: 36px;
            height: 36px;
            background: var(--gradient-primary);
            border-radius: 8px;
            display: flex;
            align-items: center;
            justify-content: center;
            font-size: 1rem;
            flex-shrink: 0;
        }
        .nav-btn-text {
            flex: 1;
            min-width: 0;
            overflow: hidden;
        }
        .nav-btn-label {
            font-size: 0.7rem;
            color: var(--muted-text);
            text-transform: uppercase;
            letter-spacing: 0.5px;
            display: block;
        }
        .nav-btn-title {
            font-size: 0.85rem;
            color: white;
            white-space: nowrap;
            overflow: hidden;
            text-overflow: ellipsis;
            display: block;
        }

        /* Quick Links */
        .quick-links {
            display: grid;
            grid-template-columns: 1fr 1fr;
            gap: 0.5rem;
        }
        .quick-link {
            display: flex;
            flex-direction: column;
            align-items: center;
            padding: 1rem 0.5rem;
            background: rgba(255,255,255,0.03);
            border-radius: 10px;
            text-decoration: none;
            transition: all 0.2s ease;
            text-align: center;
        }
        .quick-link:hover {
            background: rgba(255,255,255,0.08);
        }
        .quick-link-icon {
            font-size: 1.5rem;
            margin-bottom: 0.3rem;
        }
        .quick-link-text {
            font-size: 0.75rem;
            color: var(--muted-text);
        }

        /* Bottom Navigation (Mobile) */
        .bottom-nav {
            display: none;
            position: fixed;
            bottom: 0;
            left: 0;
            right: 0;
            background: rgba(26, 26, 46, 0.95);
            backdrop-filter: blur(20px);
            padding: 1rem;
            border-top: 1px solid var(--glass-border);
            z-index: 100;
        }
        @media (max-width: 992px) {
            .bottom-nav {
                display: flex;
                gap: 0.8rem;
            }
            .lesson-sidebar {
                position: relative;
                top: 0;
            }
            main.main-container {
                padding-bottom: 100px;
            }
        }
        .bottom-nav a {
            flex: 1;
            padding: 0.8rem;
            background: var(--glass-bg);
            border: 1px solid var(--glass-border);
            border-radius: 10px;
            text-decoration: none;
            text-align: center;
            font-size: 0.85rem;
            color: white;
            transition: all 0.2s ease;
        }
        .bottom-nav a:hover {
            background: var(--primary-red);
            border-color: var(--primary-red);
        }
        .bottom-nav a.primary {
            background: var(--gradient-primary);
            border: none;
        }
    </style>
</head>

<body>

<!-- ===== NAVBAR ===== -->
<jsp:include page="components/navbar.jsp">
    <jsp:param name="activePage" value="courses"/>
</jsp:include>

<!-- ===== MAIN CONTENT ===== -->
<main class="main-container">

    <% if (lesson != null) { %>
    
    <!-- Breadcrumb -->
    <nav class="breadcrumb-nav animate-fade-in">
        <ol>
            <li><a href="home.jsp">🏠 Home</a></li>
            <li><a href="lessons">📚 Courses</a></li>
            <li><a href="lessons"><%= lesson.getName() %></a></li>
            <li style="color: var(--muted-text);"><%= lesson.getDescription() %></li>
        </ol>
    </nav>

    <div class="lesson-page">
        <!-- Main Content Area -->
        <div class="lesson-main">
            <!-- Lesson Hero -->
            <div class="lesson-hero animate-fade-in">
                <h1><%= lesson.getDescription() %></h1>
                <div class="lesson-meta">
                    <span class="meta-badge">📚 <%= lesson.getName() %></span>
                    <span class="meta-badge">🎯 Level: <%= lesson.getLevel() %></span>
                    <span class="meta-badge">⏱️ ~15 phút</span>
                </div>
            </div>

            <!-- Lesson Content -->
            <div class="lesson-content-area animate-fade-in">
                <% if (content != null && !content.isEmpty()) { %>
                    <%= content %>
                <% } else { %>
                    <div class="empty-state" style="padding: 2rem;">
                        <div class="empty-state-icon">📄</div>
                        <h3>Nội dung đang được chuẩn bị</h3>
                        <p>このレッスンの内容は準備中です。Vui lòng quay lại sau!</p>
                    </div>
                <% } %>
            </div>
        </div>

        <!-- Sidebar -->
        <aside class="lesson-sidebar">
            <!-- Navigation Card -->
            <div class="sidebar-card animate-fade-in">
                <h3 class="sidebar-title">📖 Điều hướng bài học</h3>
                <div class="nav-buttons">
                    <% if (prevLesson != null) { %>
                    <a href="lesson-detail?id=<%= prevId %>" class="nav-btn-sidebar">
                        <span class="nav-btn-icon">←</span>
                        <span class="nav-btn-text">
                            <span class="nav-btn-label">Bài trước</span>
                            <span class="nav-btn-title"><%= prevLesson.getDescription() %></span>
                        </span>
                    </a>
                    <% } %>
                    
                    <a href="lessons" class="nav-btn-sidebar">
                        <span class="nav-btn-icon">📋</span>
                        <span class="nav-btn-text">
                            <span class="nav-btn-label">Xem tất cả</span>
                            <span class="nav-btn-title">Danh sách bài học</span>
                        </span>
                    </a>
                    
                    <% if (nextLesson != null) { %>
                    <a href="lesson-detail?id=<%= nextId %>" class="nav-btn-sidebar">
                        <span class="nav-btn-icon">→</span>
                        <span class="nav-btn-text">
                            <span class="nav-btn-label">Bài tiếp theo</span>
                            <span class="nav-btn-title"><%= nextLesson.getDescription() %></span>
                        </span>
                    </a>
                    <% } else { %>
                    <a href="lessons" class="nav-btn-sidebar" style="border-color: var(--success-green);">
                        <span class="nav-btn-icon" style="background: linear-gradient(135deg, #4ade80, #16a34a);">🎉</span>
                        <span class="nav-btn-text">
                            <span class="nav-btn-label">Hoàn thành!</span>
                            <span class="nav-btn-title">Quay về danh sách</span>
                        </span>
                    </a>
                    <% } %>
                </div>
            </div>

            <!-- Quick Links -->
            <div class="sidebar-card animate-fade-in">
                <h3 class="sidebar-title">⚡ Liên kết nhanh</h3>
                <div class="quick-links">
                    <a href="quiz.jsp" class="quick-link">
                        <span class="quick-link-icon">✍️</span>
                        <span class="quick-link-text">Làm Quiz</span>
                    </a>
                    <a href="ai-chat.jsp" class="quick-link">
                        <span class="quick-link-icon">🤖</span>
                        <span class="quick-link-text">Hỏi AI</span>
                    </a>
                    <a href="process.jsp" class="quick-link">
                        <span class="quick-link-icon">📊</span>
                        <span class="quick-link-text">Tiến độ</span>
                    </a>
                    <a href="home.jsp" class="quick-link">
                        <span class="quick-link-icon">🏠</span>
                        <span class="quick-link-text">Trang chủ</span>
                    </a>
                </div>
            </div>
        </aside>
    </div>

    <% } else { %>
    <!-- Lesson Not Found -->
    <div class="empty-state animate-fade-in" style="margin-top: 4rem;">
        <div class="empty-state-icon">❌</div>
        <h3>Không tìm thấy bài học</h3>
        <p>レッスンが見つかりません。Bài học này không tồn tại.</p>
        <a href="lessons" class="btn-start" style="display: inline-block; margin-top: 1rem;">← Quay về danh sách</a>
    </div>
    <% } %>

</main>

<!-- Bottom Navigation (Mobile) -->
<% if (lesson != null) { %>
<div class="bottom-nav">
    <% if (prevLesson != null) { %>
    <a href="lesson-detail?id=<%= prevId %>">← Bài trước</a>
    <% } else { %>
    <a href="lessons">← Danh sách</a>
    <% } %>
    
    <% if (nextLesson != null) { %>
    <a href="lesson-detail?id=<%= nextId %>" class="primary">Bài tiếp →</a>
    <% } else { %>
    <a href="lessons" class="primary">🎉 Hoàn thành</a>
    <% } %>
</div>
<% } %>

<!-- ===== FOOTER ===== -->
<footer class="footer">
    <p>© 2026 <span class="footer-brand">日本語学習</span> - Japanese Learning Platform. All rights reserved.</p>
</footer>

<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/js/bootstrap.bundle.min.js"></script>
</body>
</html>
