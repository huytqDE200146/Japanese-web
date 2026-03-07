<%@ page contentType="text/html;charset=UTF-8" %>
<<<<<<< HEAD

<!DOCTYPE html>
<html lang="vi">
<head>
    <title>Progress - Japanese Learning</title>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">

    <link rel="stylesheet"
          href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/css/bootstrap.min.css">
    <link rel="stylesheet" href="css/main-style.css">
=======
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
>>>>>>> f88f49bbc623c4dcecf2fbf29b3238f8f6b4161b
</head>

<body>

<<<<<<< HEAD
<jsp:include page="components/navbar.jsp">
    <jsp:param name="activePage" value="progress"/>
</jsp:include>

<main class="main-container">

    <!-- HERO -->
    <section class="hero-section">
=======
<div class="main-container">

    <!-- ===== HERO SECTION ===== -->
    <div class="hero-section animate-fade-in">
>>>>>>> f88f49bbc623c4dcecf2fbf29b3238f8f6b4161b
        <h1 class="hero-title">
            学習 <span>Progress</span>
        </h1>
        <p class="hero-subtitle">
            Theo dõi hành trình chinh phục JLPT của bạn
        </p>
<<<<<<< HEAD
        <p class="hero-japanese">継続は力なり</p>
    </section>

    <!-- STATS -->
    <div class="stats-row mt-4">

        <div class="stat-card">
            <div class="stat-icon">📘</div>
            <div class="stat-info">
                <h3>${completedCount}</h3>
=======
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
>>>>>>> f88f49bbc623c4dcecf2fbf29b3238f8f6b4161b
                <p>Bài đã hoàn thành</p>
            </div>
        </div>

<<<<<<< HEAD
        <div class="stat-card">
            <div class="stat-icon">📚</div>
            <div class="stat-info">
                <h3>${totalCount}</h3>
=======
        <!-- Total Lessons -->
        <div class="stat-card">
            <div class="stat-icon">📚</div>
            <div class="stat-info">
                <h3>${total}</h3>
>>>>>>> f88f49bbc623c4dcecf2fbf29b3238f8f6b4161b
                <p>Tổng số bài</p>
            </div>
        </div>

<<<<<<< HEAD
        <div class="stat-card">
            <div class="stat-icon">📊</div>
=======
        <!-- Progress Percent -->
        <div class="stat-card">
            <div class="stat-icon">🔥</div>
>>>>>>> f88f49bbc623c4dcecf2fbf29b3238f8f6b4161b
            <div class="stat-info">
                <h3>${percent}%</h3>
                <p>Tiến độ hoàn thành</p>
            </div>
        </div>

<<<<<<< HEAD
        <div class="stat-card">
            <div class="stat-icon">🔥</div>
            <div class="stat-info">
                <h3>${streak}</h3>
                <p>Streak hiện tại</p>
            </div>
        </div>

    </div>

    <!-- LESSON PROGRESS -->
    <section class="mt-5">
        <div class="section-header">
            <h2 class="section-title">Lesson Completion</h2>
        </div>

        <div class="progress-card">

            <div class="progress-header">
                <div>
                    <h3 class="progress-level">
                        ${percent}%
                    </h3>
                    <p class="progress-sub">
                        Hoàn thành toàn bộ lesson <strong>${currentLevelStr}</strong> để mở khóa cấp độ tiếp theo.
                    </p>
                </div>
            </div>

            <div class="progress-bar-wrapper">
                <div class="progress-bar-fill"
                     style="width: ${percent}%;"></div>
            </div>

        </div>
    </section>

    <!-- STREAK SECTION -->
    <section class="mt-5">
        <div class="section-header">
            <h2 class="section-title">Study Streak</h2>
        </div>

        <div class="progress-card text-center">

            <h3 class="display-6">
                🔥 ${streak} ngày liên tiếp
            </h3>

            <p class="progress-sub">
                Kỷ lục cao nhất:
                <strong>${longestStreak}</strong> ngày
            </p>

            <p class="mt-3 text-white">
                Học mỗi ngày để giữ lửa và tiến gần hơn đến JLPT N1!
            </p>

        </div>
    </section>

</main>

<footer class="footer mt-5">
    <p>© 2026 <span class="footer-brand">日本語学習</span> - Japanese Learning Platform.</p>
</footer>

<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/js/bootstrap.bundle.min.js"></script>
=======
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

>>>>>>> f88f49bbc623c4dcecf2fbf29b3238f8f6b4161b
</body>
</html>