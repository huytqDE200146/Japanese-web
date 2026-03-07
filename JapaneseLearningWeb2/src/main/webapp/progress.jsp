<%@ page contentType="text/html;charset=UTF-8" %>

<!DOCTYPE html>
<html lang="vi">
<head>
    <title>Progress - Japanese Learning</title>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">

    <link rel="stylesheet"
          href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/css/bootstrap.min.css">
    <link rel="stylesheet" href="css/main-style.css">
</head>

<body>

<jsp:include page="components/navbar.jsp">
    <jsp:param name="activePage" value="progress"/>
</jsp:include>

<main class="main-container">

    <!-- HERO -->
    <section class="hero-section">
        <h1 class="hero-title">
            学習 <span>Progress</span>
        </h1>
        <p class="hero-subtitle">
            Theo dõi hành trình chinh phục JLPT của bạn
        </p>
        <p class="hero-japanese">継続は力なり</p>
    </section>

    <!-- STATS -->
    <div class="stats-row mt-4">

        <div class="stat-card">
            <div class="stat-icon">📘</div>
            <div class="stat-info">
                <h3>${completedCount}</h3>
                <p>Bài đã hoàn thành</p>
            </div>
        </div>

        <div class="stat-card">
            <div class="stat-icon">📚</div>
            <div class="stat-info">
                <h3>${totalCount}</h3>
                <p>Tổng số bài</p>
            </div>
        </div>

        <div class="stat-card">
            <div class="stat-icon">📊</div>
            <div class="stat-info">
                <h3>${percent}%</h3>
                <p>Tiến độ hoàn thành</p>
            </div>
        </div>

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
</body>
</html>