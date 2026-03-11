<%@ page contentType="text/html;charset=UTF-8" %>
<%@ page import="com.japaneselearning.model.User" %>

<%
    User user = (User) session.getAttribute("user");
    if (user == null) {
        response.sendRedirect("login.jsp");
        return;
    }
    boolean isPremium = user.hasPremiumAccess();
    String error = (String) session.getAttribute("error");
    session.removeAttribute("error");
%>

<!DOCTYPE html>
<html lang="vi">
<head>
    <title>Premium - Japanese Learning</title>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/css/bootstrap.min.css">
    <link rel="stylesheet" href="css/main-style.css">
    <link href="https://fonts.googleapis.com/css2?family=Noto+Serif+JP:wght@400;700&family=Poppins:wght@300;400;500;600;700&display=swap" rel="stylesheet">
    <style>
        /* Sticky Footer */
        html, body { min-height: 100vh; }
        body { display: flex; flex-direction: column; }
        main { flex: 1; }
        .footer { margin-top: auto; }
        
        /* Hero Section */
        .premium-hero {
            background: linear-gradient(135deg, rgba(212, 175, 55, 0.9) 0%, rgba(26, 26, 46, 0.95) 100%),
                        url('https://images.unsplash.com/photo-1492571350019-22de08371fd3?w=1200') center/cover;
            border-radius: 24px;
            padding: 4rem 2rem;
            text-align: center;
            margin-bottom: 3rem;
            position: relative;
            overflow: hidden;
        }
        .premium-hero::before {
            content: '★';
            position: absolute;
            right: 50px;
            top: 50%;
            transform: translateY(-50%);
            font-size: 10rem;
            opacity: 0.1;
        }
        .premium-hero h1 {
            font-family: 'Noto Serif JP', serif;
            font-size: 3rem;
            margin-bottom: 1rem;
            background: linear-gradient(135deg, #ffd700, #ffed4a);
            -webkit-background-clip: text;
            -webkit-text-fill-color: transparent;
            background-clip: text;
        }
        .premium-hero p {
            color: rgba(255,255,255,0.9);
            font-size: 1.2rem;
            max-width: 600px;
            margin: 0 auto;
        }
        
        /* Status Badge */
        .premium-status {
            display: inline-flex;
            align-items: center;
            gap: 0.5rem;
            padding: 0.5rem 1.5rem;
            border-radius: 50px;
            margin-top: 1.5rem;
            font-weight: 600;
        }
        .premium-status.active {
            background: linear-gradient(135deg, #ffd700, #ffb700);
            color: #1a1a2e;
        }
        .premium-status.inactive {
            background: rgba(255,255,255,0.2);
            color: white;
        }
        
        /* Pricing Cards */
        .pricing-grid {
            display: grid;
            grid-template-columns: repeat(3, 1fr);
            gap: 2rem;
            margin-bottom: 3rem;
        }
        @media (max-width: 992px) {
            .pricing-grid { grid-template-columns: 1fr; }
        }
        
        .pricing-card {
            background: var(--glass-bg);
            backdrop-filter: blur(20px);
            border: 2px solid var(--glass-border);
            border-radius: 20px;
            padding: 2rem;
            text-align: center;
            transition: all 0.3s ease;
            position: relative;
        }
        .pricing-card:hover {
            transform: translateY(-10px);
            border-color: rgba(255, 215, 0, 0.5);
            box-shadow: 0 20px 50px rgba(255, 215, 0, 0.2);
        }
        .pricing-card.featured {
            border-color: #ffd700;
            background: linear-gradient(180deg, rgba(255, 215, 0, 0.1) 0%, rgba(26, 26, 46, 0.9) 100%);
        }
        .pricing-card.featured::before {
            content: 'Phổ biến';
            position: absolute;
            top: -12px;
            left: 50%;
            transform: translateX(-50%);
            background: linear-gradient(135deg, #ffd700, #ffb700);
            color: #1a1a2e;
            padding: 0.3rem 1rem;
            border-radius: 20px;
            font-size: 0.8rem;
            font-weight: 600;
        }
        
        .pricing-name {
            font-size: 1.3rem;
            font-weight: 600;
            margin-bottom: 0.5rem;
            color: white;
        }
        .pricing-price {
            font-size: 2.5rem;
            font-weight: 700;
            color: #ffd700;
            margin: 1rem 0;
        }
        .pricing-price span {
            font-size: 1rem;
            color: var(--muted-text);
        }
        .pricing-save {
            background: rgba(76, 175, 80, 0.2);
            color: #4caf50;
            padding: 0.3rem 0.8rem;
            border-radius: 20px;
            font-size: 0.85rem;
            margin-bottom: 1.5rem;
            display: inline-block;
        }
        
        .pricing-features {
            list-style: none;
            padding: 0;
            margin: 1.5rem 0;
            text-align: left;
        }
        .pricing-features li {
            padding: 0.5rem 0;
            color: rgba(255,255,255,0.8);
            display: flex;
            align-items: center;
            gap: 0.5rem;
        }
        .pricing-features li::before {
            content: '✓';
            color: #4caf50;
            font-weight: bold;
        }
        
        .btn-premium {
            width: 100%;
            padding: 1rem;
            border: none;
            border-radius: 12px;
            font-size: 1rem;
            font-weight: 600;
            cursor: pointer;
            transition: all 0.3s ease;
        }
        .btn-premium.primary {
            background: linear-gradient(135deg, #ffd700, #ffb700);
            color: #1a1a2e;
        }
        .btn-premium.primary:hover {
            transform: scale(1.02);
            box-shadow: 0 10px 30px rgba(255, 215, 0, 0.3);
        }
        .btn-premium.secondary {
            background: rgba(255,255,255,0.1);
            color: white;
            border: 1px solid rgba(255,255,255,0.2);
        }
        .btn-premium:disabled {
            opacity: 0.5;
            cursor: not-allowed;
        }
        
        /* Features Section */
        .features-section {
            background: var(--glass-bg);
            border-radius: 20px;
            padding: 3rem;
            margin-bottom: 2rem;
        }
        .features-section h2 {
            text-align: center;
            margin-bottom: 2rem;
            font-family: 'Noto Serif JP', serif;
        }
        .features-grid {
            display: grid;
            grid-template-columns: repeat(4, 1fr);
            gap: 1.5rem;
        }
        @media (max-width: 992px) {
            .features-grid { grid-template-columns: repeat(2, 1fr); }
        }
        .feature-item {
            text-align: center;
            padding: 1.5rem;
        }
        .feature-icon {
            font-size: 2.5rem;
            margin-bottom: 1rem;
        }
        .feature-title {
            font-weight: 600;
            margin-bottom: 0.5rem;
        }
        .feature-desc {
            color: var(--muted-text);
            font-size: 0.9rem;
        }
        
        /* Alert */
        .alert-premium {
            background: rgba(244, 67, 54, 0.2);
            border: 1px solid rgba(244, 67, 54, 0.5);
            color: #ff6b6b;
            padding: 1rem;
            border-radius: 10px;
            margin-bottom: 2rem;
        }
    </style>
</head>

<body>

<!-- ===== NAVBAR (Component) ===== -->
<jsp:include page="components/navbar.jsp">
    <jsp:param name="activePage" value="premium" />
</jsp:include>

<main class="container py-4">
    
    <% if (error != null) { %>
    <div class="alert-premium">⚠️ <%= error %></div>
    <% } %>
    
    <!-- Hero Section -->
    <div class="premium-hero">
        <h1>⭐ Nâng cấp Premium</h1>
        <p>Mở khóa toàn bộ nội dung học từ N5 đến N1, AI Chat không giới hạn và nhiều tính năng độc quyền khác!</p>
        
        <% if (isPremium) { %>
        <div class="premium-status active">
            ✓ Bạn đang là thành viên Premium
            <% if (user.getPremiumUntil() != null) { %>
            (đến <%= new java.text.SimpleDateFormat("dd/MM/yyyy").format(user.getPremiumUntil()) %>)
            <% } %>
        </div>
        <% } else { %>
        <div class="premium-status inactive">Bạn chưa có gói Premium</div>
        <% } %>
    </div>
    
    <!-- Pricing Cards -->
    <div class="pricing-grid">
        <!-- 1 Month -->
        <div class="pricing-card">
            <div class="pricing-name">Premium 1 Tháng</div>
            <div class="pricing-price">99.000đ <span>/tháng</span></div>
            <ul class="pricing-features">
                <li>Truy cập toàn bộ bài học N5-N1</li>
                <li>AI Chat không giới hạn</li>
                <li>Quiz nâng cao</li>
                <li>Không quảng cáo</li>
            </ul>
            <form action="createPayment" method="post">
                <input type="hidden" name="plan" value="1month">
                <button type="submit" class="btn-premium secondary" <%= isPremium ? "disabled" : "" %>>
                    <%= isPremium ? "Đang sử dụng" : "Mua ngay" %>
                </button>
            </form>
        </div>
        
        <!-- 3 Months - Featured -->
        <div class="pricing-card featured">
            <div class="pricing-name">Premium 3 Tháng</div>
            <div class="pricing-price">249.000đ</div>
            <div class="pricing-save">Tiết kiệm 16%</div>
            <ul class="pricing-features">
                <li>Tất cả tính năng 1 tháng</li>
                <li>Hỗ trợ ưu tiên</li>
                <li>Tài liệu PDF độc quyền</li>
                <li>Lịch học cá nhân hóa</li>
            </ul>
            <form action="createPayment" method="post">
                <input type="hidden" name="plan" value="3months">
                <button type="submit" class="btn-premium primary">
                    <%= isPremium ? "Gia hạn thêm" : "Mua ngay" %>
                </button>
            </form>
        </div>
        
        <!-- 1 Year -->
        <div class="pricing-card">
            <div class="pricing-name">Premium 1 Năm</div>
            <div class="pricing-price">799.000đ</div>
            <div class="pricing-save">Tiết kiệm 33%</div>
            <ul class="pricing-features">
                <li>Tất cả tính năng 3 tháng</li>
                <li>Chứng chỉ hoàn thành</li>
                <li>Mentoring 1-1 (2 buổi)</li>
                <li>Cập nhật nội dung trọn đời</li>
            </ul>
            <form action="createPayment" method="post">
                <input type="hidden" name="plan" value="1year">
                <button type="submit" class="btn-premium secondary">
                    <%= isPremium ? "Gia hạn thêm" : "Mua ngay" %>
                </button>
            </form>
        </div>
    </div>
    
    <!-- Features Section -->
    <div class="features-section">
        <h2>Tại sao chọn Premium?</h2>
        <div class="features-grid">
            <div class="feature-item">
                <div class="feature-icon">📚</div>
                <div class="feature-title">500+ Bài học</div>
                <div class="feature-desc">Từ N5 đến N1, được biên soạn bởi giáo viên bản xứ</div>
            </div>
            <div class="feature-item">
                <div class="feature-icon">🤖</div>
                <div class="feature-title">AI Chat</div>
                <div class="feature-desc">Luyện hội thoại với AI thông minh 24/7</div>
            </div>
            <div class="feature-item">
                <div class="feature-icon">🎯</div>
                <div class="feature-title">Quiz thông minh</div>
                <div class="feature-desc">Đề thi mô phỏng JLPT thực tế</div>
            </div>
            <div class="feature-item">
                <div class="feature-icon">📈</div>
                <div class="feature-title">Theo dõi tiến độ</div>
                <div class="feature-desc">Dashboard chi tiết về quá trình học</div>
            </div>
        </div>
    </div>
    
</main>

<!-- ===== FOOTER ===== -->
<footer class="footer">
    <p>© 2026 <span class="footer-brand">日本語学習</span> - Japanese Learning Platform. All rights reserved.</p>
</footer>

<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/js/bootstrap.bundle.min.js"></script>
</body>
</html>
