<%@ page contentType="text/html;charset=UTF-8" %>
<%@ page import="com.japaneselearning.model.User" %>

<%
    User user = (User) session.getAttribute("user");
    if (user == null) {
        response.sendRedirect("login");
        return;
    }
%>

<!DOCTYPE html>
<html>
<head>
    <title>Learning Progress</title>
    <link rel="stylesheet" href="css/style.css">
</head>

<body>

<div class="main-container">

    <!-- ===== HERO SECTION ===== -->
    <div class="hero-section animate-fade-in">
        <h1 class="hero-title">
            学習 <span>Progress</span>
        </h1>
        <p class="hero-subtitle">
            Theo dõi hành trình chinh phục JLPT của bạn
        </p>
        <div class="hero-japanese">
            継続は力なり
        </div>
    </div>



    <!-- ===== STATS ROW ===== -->
    <div class="stats-row animate-fade-in animate-delay-2">

        <!-- Completed Lessons -->
        <div class="stat-card">
            <div class="stat-icon">📘</div>
            <div class="stat-info">
                <h3>${completed}</h3>
                <p>Bài đã hoàn thành</p>
            </div>
        </div>

        <!-- Total Lessons -->
        <div class="stat-card">
            <div class="stat-icon">📚</div>
            <div class="stat-info">
                <h3>${total}</h3>
                <p>Tổng số bài</p>
            </div>
        </div>

        <!-- Progress Percent -->
        <div class="stat-card">
            <div class="stat-icon">🔥</div>
            <div class="stat-info">
                <h3>${percent}%</h3>
                <p>Tiến độ hoàn thành</p>
            </div>
        </div>

    </div>

    <!-- ===== PROGRESS BAR SECTION ===== -->
    <div class="user-card animate-fade-in animate-delay-3">

        <div class="section-header">
            <h2 class="section-title">Lesson Progress</h2>
        </div>

        <div style="background: rgba(255,255,255,0.1);
                    border-radius: 20px;
                    overflow: hidden;
                    height: 25px;
                    margin-top: 1rem;">

            <div style="
                width: ${percent}%;
                height: 100%;
                background: var(--gradient-primary);
                display:flex;
                align-items:center;
                justify-content:center;
                font-weight:600;
                transition: width 0.8s ease;
            ">
                ${percent}%
            </div>

        </div>

        <p style="margin-top:1rem; color: var(--muted-text);">
            Hoàn thành toàn bộ lesson để mở khóa cấp độ tiếp theo.
        </p>

    </div>

</div>

</body>
</html>