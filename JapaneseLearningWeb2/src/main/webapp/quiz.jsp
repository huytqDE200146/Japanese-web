<%@ page contentType="text/html;charset=UTF-8" %>
<%@ page import="java.util.List, java.util.Map" %>
<%@ page import="com.japaneselearning.model.Lesson" %>
<%@ page import="com.japaneselearning.model.User" %>
<%
    User user = (User) session.getAttribute("user");
    if (user == null) {
        response.sendRedirect("login.jsp");
        return;
    }
    Map<String, List<Lesson>> groupedLessons = (Map<String, List<Lesson>>) request.getAttribute("groupedLessons");
    
    // If accessed directly (not via servlet), redirect
    if (groupedLessons == null) {
        response.sendRedirect(request.getContextPath() + "/quiz");
        return;
    }
    
    String userLevelStr = user.getLevel() > 0 ? "N" + user.getLevel() : "";

    
    // Category icons & gradients for base names
    java.util.Map<String, String> catIcons = new java.util.LinkedHashMap<>();
    catIcons.put("Hiragana", "あ");
    catIcons.put("Katakana", "カ");
    catIcons.put("Từ Vựng", "語");
    catIcons.put("Ngữ pháp", "文");
    catIcons.put("Kanji", "漢");
    
    java.util.Map<String, String> catGrads = new java.util.LinkedHashMap<>();
    catGrads.put("Hiragana", "grad-hiragana");
    catGrads.put("Katakana", "grad-katakana");
    catGrads.put("Từ Vựng", "grad-vocab");
    catGrads.put("Ngữ pháp", "grad-grammar");
    catGrads.put("Kanji", "grad-kanji");
%>
<!DOCTYPE html>
<html lang="vi">
<head>
    <title>Quiz - Japanese Learning</title>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/css/bootstrap.min.css">
    <link rel="stylesheet" href="css/main-style.css">
    <link href="https://fonts.googleapis.com/css2?family=Noto+Serif+JP:wght@400;700&family=Poppins:wght@300;400;500;600;700&display=swap" rel="stylesheet">
    <style>
        html, body { min-height: 100vh; }
        body { display: flex; flex-direction: column; }
        main { flex: 1; }
        .footer { margin-top: auto; }

        .quiz-hero {
            background: linear-gradient(135deg, rgba(188, 0, 45, 0.9) 0%, rgba(26, 26, 46, 0.95) 100%),
                        url('https://images.unsplash.com/photo-1492571350019-22de08371fd3?w=1200') center/cover;
            border-radius: 20px; padding: 3rem 2rem; margin-bottom: 2.5rem; text-align: center;
            position: relative; overflow: hidden;
        }
        .quiz-hero::before { content: '試'; position: absolute; right: 30px; top: 50%; transform: translateY(-50%); font-size: 8rem; opacity: 0.1; font-family: 'Noto Serif JP', serif; }
        .quiz-hero h1 { font-family: 'Noto Serif JP', serif; font-size: 2.5rem; margin-bottom: 0.5rem; }
        .quiz-hero p { color: rgba(255,255,255,0.8); font-size: 1.1rem; }

        /* ===== TABS ===== */
        .quiz-tabs { display: flex; gap: 0.5rem; margin-bottom: 2rem; flex-wrap: wrap; }
        .quiz-tab {
            padding: 0.7rem 1.5rem; border-radius: 25px; border: 1px solid var(--glass-border);
            background: var(--glass-bg); color: var(--light-text); cursor: pointer;
            font-weight: 500; font-size: 0.95rem; transition: all 0.3s ease;
        }
        .quiz-tab:hover { background: rgba(255,255,255,0.1); }
        .quiz-tab.active { background: var(--gradient-primary); border-color: transparent; color: white; }

        /* ===== CATEGORY CARDS ===== */
        .category-grid { display: grid; grid-template-columns: repeat(auto-fill, minmax(280px, 1fr)); gap: 1.5rem; margin-bottom: 2rem; }
        .cat-card {
            background: var(--glass-bg); backdrop-filter: blur(20px); border: 1px solid var(--glass-border);
            border-radius: 20px; padding: 2rem; text-align: center; cursor: pointer;
            transition: all 0.4s cubic-bezier(0.4, 0, 0.2, 1); position: relative; overflow: hidden;
        }
        .cat-card:hover { transform: translateY(-10px) scale(1.03); box-shadow: 0 20px 50px rgba(188, 0, 45, 0.3); border-color: rgba(255, 183, 197, 0.4); background: rgba(255, 255, 255, 0.12); }
        .cat-card::before { content: ''; position: absolute; top: 0; left: -100%; width: 100%; height: 100%; background: linear-gradient(90deg, transparent, rgba(255,255,255,0.1), transparent); transition: 0.6s; }
        .cat-card:hover::before { left: 100%; }
        .cat-icon { width: 80px; height: 80px; border-radius: 20px; display: flex; align-items: center; justify-content: center; font-size: 2.5rem; margin: 0 auto 1rem; box-shadow: 0 8px 25px rgba(0,0,0,0.3); }
        .cat-card h3 { font-family: 'Noto Serif JP', serif; font-size: 1.2rem; margin-bottom: 0.5rem; color: white; }
        .cat-card p { color: var(--muted-text); font-size: 0.85rem; }
        .cat-count { display: inline-block; background: rgba(255,255,255,0.1); padding: 0.25rem 0.75rem; border-radius: 20px; font-size: 0.75rem; color: var(--sakura-pink); margin-top: 0.5rem; }
        .grad-hiragana { background: linear-gradient(135deg, #4ade80, #16a34a); }
        .grad-katakana { background: linear-gradient(135deg, #22d3ee, #0891b2); }
        .grad-vocab { background: linear-gradient(135deg, #fbbf24, #d97706); }
        .grad-grammar { background: linear-gradient(135deg, #f472b6, #db2777); }
        .grad-kanji { background: linear-gradient(135deg, #bc002d, #881337); }
        .grad-default { background: linear-gradient(135deg, #a855f7, #7c3aed); }

        /* ===== AI QUIZ LESSON LIST ===== */
        .section-title-quiz { font-family: 'Noto Serif JP', serif; font-size: 1.5rem; margin-bottom: 1.5rem; display: flex; align-items: center; gap: 0.5rem; }
        .section-title-quiz::before { content: ''; width: 4px; height: 28px; background: var(--primary-red); border-radius: 2px; }
        .lesson-category-card {
            background: var(--glass-bg); backdrop-filter: blur(20px); border: 1px solid var(--glass-border);
            border-radius: 16px; overflow: hidden; margin-bottom: 1.5rem;
        }
        .lesson-cat-header {
            padding: 1rem 1.5rem; display: flex; align-items: center; gap: 1rem;
            background: linear-gradient(135deg, rgba(255,255,255,0.05), transparent);
            border-bottom: 1px solid rgba(255,255,255,0.06); cursor: pointer; transition: background 0.2s;
        }
        .lesson-cat-header:hover { background: rgba(255,255,255,0.08); }
        .lesson-cat-icon { width: 44px; height: 44px; border-radius: 10px; display: flex; align-items: center; justify-content: center; font-size: 1.4rem; flex-shrink: 0; }
        .lesson-cat-info h4 { font-family: 'Noto Serif JP', serif; font-size: 1rem; margin: 0 0 0.15rem 0; color: white; }
        .lesson-cat-info span { font-size: 0.75rem; color: var(--muted-text); }
        .lesson-cat-toggle { color: rgba(255,255,255,0.4); font-size: 1rem; transition: transform 0.3s; margin-left: auto; }
        .lesson-category-card.collapsed .lesson-cat-toggle { transform: rotate(-90deg); }
        .lesson-list { padding: 0.5rem; max-height: 500px; overflow-y: auto; transition: max-height 0.4s, padding 0.4s; }
        .lesson-category-card.collapsed .lesson-list { max-height: 0; padding: 0 0.5rem; overflow: hidden; }
        .lesson-quiz-item {
            display: flex; align-items: center; gap: 1rem; padding: 0.7rem 1rem;
            background: rgba(255,255,255,0.02); border: 1px solid rgba(255,255,255,0.04);
            border-radius: 10px; margin-bottom: 0.4rem; transition: all 0.2s;
        }
        .lesson-quiz-item:hover { background: rgba(188, 0, 45, 0.12); border-color: rgba(188, 0, 45, 0.25); }
        .lesson-quiz-num { width: 28px; height: 28px; border-radius: 8px; background: var(--gradient-primary); display: flex; align-items: center; justify-content: center; font-weight: 700; font-size: 0.7rem; flex-shrink: 0; }
        .lesson-quiz-name { flex: 1; font-size: 0.85rem; color: white; min-width: 0; overflow: hidden; text-overflow: ellipsis; white-space: nowrap; }
        .btn-gen-quiz {
            background: transparent; border: 1px solid rgba(255,183,197,0.4); color: #ffb7c5;
            padding: 0.3rem 0.9rem; border-radius: 16px; font-size: 0.7rem; font-weight: 500;
            cursor: pointer; transition: all 0.25s; display: inline-flex; align-items: center; gap: 0.3rem; white-space: nowrap;
        }
        .btn-gen-quiz:hover { background: var(--primary-red); border-color: var(--primary-red); color: white; }

        /* ===== QUIZ INTERFACE (shared) ===== */
        .quiz-overlay { display: none; position: fixed; inset: 0; background: rgba(0,0,0,0.85); backdrop-filter: blur(10px); z-index: 9999; overflow-y: auto; padding: 2rem; }
        .quiz-modal { max-width: 750px; margin: 0 auto; }
        @keyframes spin { from{transform:rotate(0deg)} to{transform:rotate(360deg)} }
        .q-num-btn { background:rgba(255,255,255,0.05); border:2px solid rgba(255,255,255,0.15); color:white; padding:0.6rem 1.5rem; border-radius:12px; cursor:pointer; font-size:1rem; transition:all 0.3s; }
        .q-num-btn:hover { border-color:var(--sakura-pink); background:rgba(255,255,255,0.1); }
        .q-num-btn.active { background:rgba(188,0,45,0.3); border-color:var(--primary-red); color:var(--sakura-pink); }
        .q-opt-btn { background:rgba(255,255,255,0.05); border:2px solid rgba(255,255,255,0.15); border-radius:14px; padding:1rem; color:white; font-size:1rem; cursor:pointer; transition:all 0.3s; text-align:left; }
        .q-opt-btn:hover:not(.disabled) { background:rgba(255,255,255,0.1); border-color:var(--sakura-pink); transform:translateY(-2px); }
        .q-opt-btn.correct { background:rgba(74,222,128,0.2); border-color:#4ade80; color:#4ade80; }
        .q-opt-btn.wrong { background:rgba(248,113,113,0.2); border-color:#f87171; color:#f87171; }
        .q-opt-btn.disabled { cursor:default; opacity:0.6; }
        .q-opt-btn.show-correct { border-color:#4ade80; background:rgba(74,222,128,0.1); }
        .glass-card { background:var(--glass-bg); backdrop-filter:blur(20px); border:1px solid var(--glass-border); border-radius:16px; padding:2rem; }

        /* ===== STATIC QUIZ (existing) ===== */
        .options-grid { display: grid; grid-template-columns: 1fr 1fr; gap: 1rem; }
        @media (max-width: 576px) { .options-grid { grid-template-columns: 1fr; } }
        .option-btn { background:rgba(255,255,255,0.05); border:2px solid rgba(255,255,255,0.15); border-radius:14px; padding:1rem 1.5rem; color:white; font-size:1.1rem; cursor:pointer; transition:all 0.3s; }
        .option-btn:hover:not(.disabled) { background:rgba(255,255,255,0.1); border-color:var(--sakura-pink); transform:translateY(-3px); }
        .option-btn.correct { background:rgba(74,222,128,0.2); border-color:#4ade80; color:#4ade80; }
        .option-btn.wrong { background:rgba(248,113,113,0.2); border-color:#f87171; color:#f87171; }
        .option-btn.disabled { cursor:default; opacity:0.6; }
        .option-btn.show-correct { border-color:#4ade80; background:rgba(74,222,128,0.1); }
        
        /* ===== FILTER BAR ===== */
        .filter-bar {
            display: flex; gap: 0.8rem; margin-bottom: 1.5rem; flex-wrap: wrap;
        }
        .filter-btn {
            background: var(--glass-bg); border: 1px solid var(--glass-border);
            color: var(--light-text); padding: 0.5rem 1.2rem; border-radius: 25px;
            font-size: 0.85rem; cursor: pointer; transition: all 0.2s ease;
        }
        .filter-btn:hover, .filter-btn.active {
            background: var(--primary-red); border-color: var(--primary-red); color: white;
        }

        /* ===== AI CATEGORY GRID (3 Columns) ===== */
        .ai-category-grid {
            display: grid;
            grid-template-columns: repeat(3, 1fr);
            gap: 1.5rem;
            align-items: start; /* Prevents stretching other cards in the row when one expands */
        }
        @media (max-width: 1024px) { .ai-category-grid { grid-template-columns: repeat(2, 1fr); } }
        @media (max-width: 768px) { .ai-category-grid { grid-template-columns: 1fr; } }
    </style>
</head>
<body>

<jsp:include page="components/navbar.jsp">
    <jsp:param name="activePage" value="quiz" />
</jsp:include>

<main class="main-container">
    <!-- Hero -->
    <section class="quiz-hero animate-fade-in">
        <h1>✍️ Quiz / クイズ</h1>
        <p>Kiểm tra kiến thức tiếng Nhật qua các bài quiz thú vị</p>
    </section>

    <!-- Tabs -->
    <div class="quiz-tabs">
        <button class="quiz-tab active" onclick="switchTab('practice')">📝 Luyện tập theo chủ đề</button>
        <button class="quiz-tab" onclick="switchTab('ai')">🤖 Quiz AI từ bài học</button>
    </div>

    <!-- ============ TAB 1: PRACTICE QUIZ ============ -->
    <div id="tabPractice">
        <h2 class="section-title-quiz">Chọn chủ đề luyện tập</h2>
        <div class="category-grid">
            <div class="cat-card animate-fade-in" onclick="startStaticQuiz('hiragana')">
                <div class="cat-icon grad-hiragana">あ</div>
                <h3>Hiragana</h3>
                <p>Đọc chữ Hiragana và chọn cách phát âm đúng</p>
                <span class="cat-count">15 câu hỏi</span>
            </div>
            <div class="cat-card animate-fade-in" onclick="startStaticQuiz('katakana')">
                <div class="cat-icon grad-katakana">カ</div>
                <h3>Katakana</h3>
                <p>Đọc chữ Katakana và chọn cách phát âm đúng</p>
                <span class="cat-count">15 câu hỏi</span>
            </div>
            <div class="cat-card animate-fade-in" onclick="startStaticQuiz('vocabulary')">
                <div class="cat-icon grad-vocab">語</div>
                <h3>Từ Vựng</h3>
                <p>Chọn nghĩa đúng của từ vựng tiếng Nhật</p>
                <span class="cat-count">15 câu hỏi</span>
            </div>
            <div class="cat-card animate-fade-in" onclick="startStaticQuiz('grammar')">
                <div class="cat-icon grad-grammar">文</div>
                <h3>Ngữ Pháp</h3>
                <p>Điền từ đúng vào chỗ trống trong câu</p>
                <span class="cat-count">15 câu hỏi</span>
            </div>
            <div class="cat-card animate-fade-in" onclick="startStaticQuiz('kanji')">
                <div class="cat-icon grad-kanji">漢</div>
                <h3>Kanji</h3>
                <p>Nhận biết cách đọc và nghĩa của Kanji</p>
                <span class="cat-count">15 câu hỏi</span>
            </div>
        </div>
    </div>

    <!-- ============ TAB 2: AI QUIZ FROM LESSONS ============ -->
    <div id="tabAi" style="display:none;">
        <h2 class="section-title-quiz">🤖 Chọn bài học để AI tạo Quiz</h2>
        <p style="color:var(--muted-text);margin-bottom:1.5rem;">AI sẽ đọc nội dung bài học và tự động tạo câu hỏi trắc nghiệm. Bạn có thể chọn số câu hỏi (5/10/15).</p>

        <!-- Level Filter Bar -->
        <div class="filter-bar animate-fade-in" style="margin-bottom: 2rem;">
            <button class="filter-btn<%= "N5".equals(userLevelStr) ? " active" : "" %>" data-filter="N5" onclick="filterQuizLevel('N5', this)">N5<%= "N5".equals(userLevelStr) ? " ✓" : "" %></button>
            <button class="filter-btn<%= "N4".equals(userLevelStr) ? " active" : "" %>" data-filter="N4" onclick="filterQuizLevel('N4', this)">N4<%= "N4".equals(userLevelStr) ? " ✓" : "" %></button>
            <button class="filter-btn<%= "N3".equals(userLevelStr) ? " active" : "" %>" data-filter="N3" onclick="filterQuizLevel('N3', this)">N3<%= "N3".equals(userLevelStr) ? " ✓" : "" %></button>
            <button class="filter-btn<%= "N2".equals(userLevelStr) ? " active" : "" %>" data-filter="N2" onclick="filterQuizLevel('N2', this)">N2<%= "N2".equals(userLevelStr) ? " ✓" : "" %></button>
            <button class="filter-btn<%= "N1".equals(userLevelStr) ? " active" : "" %>" data-filter="N1" onclick="filterQuizLevel('N1', this)">N1<%= "N1".equals(userLevelStr) ? " ✓" : "" %></button>
        </div>

        <% if (groupedLessons != null && !groupedLessons.isEmpty()) {
            int catIdx = 0;
        %>
        <div class="ai-category-grid" id="aiCategoryGrid">
            <% for (Map.Entry<String, List<Lesson>> entry : groupedLessons.entrySet()) {
                String category = entry.getKey();
                List<Lesson> lessons = entry.getValue();
                String icon = "📖";
                String grad = "grad-default";
                for (Map.Entry<String, String> iconEntry : catIcons.entrySet()) {
                    if (category.contains(iconEntry.getKey())) {
                        icon = iconEntry.getValue();
                        grad = catGrads.getOrDefault(iconEntry.getKey(), "grad-default");
                        break;
                    }
                }
                catIdx++;
                String catLevel = lessons.get(0).getLevel();
                boolean isUserLevel = catLevel.equals(userLevelStr);
        %>
        <div class="lesson-category-card collapsed<%= isUserLevel ? " user-level-highlight" : "" %>" id="aiCat-<%= catIdx %>" data-level="<%= catLevel %>"
             <% if (isUserLevel) { %>style="border-color: rgba(255, 183, 197, 0.4); box-shadow: 0 0 20px rgba(188, 0, 45, 0.15);"<% } %>>
            <div class="lesson-cat-header" onclick="document.getElementById('aiCat-<%= catIdx %>').classList.toggle('collapsed')">
                <div class="lesson-cat-icon <%= grad %>"><%= icon %></div>
                <div class="lesson-cat-info" style="flex-grow: 1;">
                    <h4><%= category %></h4>
                    <span>📚 <%= lessons.size() %> bài học | 🎯 <%= catLevel %></span>
                </div>
                <% if (isUserLevel) { %>
                <span style="background: linear-gradient(135deg, #bc002d, #881337); color: white; font-size: 0.65rem; padding: 0.2rem 0.6rem; border-radius: 12px; font-weight: 600; white-space: nowrap; margin-right: 1rem;">⭐ Your Level</span>
                <% } %>
                <span class="lesson-cat-toggle" style="margin-left: 0;">▼</span>
            </div>
            <div class="lesson-list">
                <% int lNum = 0; for (Lesson l : lessons) { lNum++; %>
                <div class="lesson-quiz-item">
                    <div class="lesson-quiz-num"><%= lNum %></div>
                    <div class="lesson-quiz-name"><%= l.getDescription() %></div>
                    <%
                        String lessonLevelStr = l.getLevel();
                        int lessonLevel = Integer.parseInt(lessonLevelStr.substring(1));
                        int userLevel = user.getLevel();
                        boolean isPremium = user.hasPremiumAccess();
                    %>
                    <% if (isPremium || lessonLevel == userLevel) { %>
                    <button class="btn-gen-quiz" onclick="openAiQuizModal(<%= l.getLessonId() %>, '<%= l.getDescription().replace("'", "\\'") %>')">
                        🤖 Tạo Quiz
                    </button>
                    <% } else { %>
                    <button class="btn-gen-quiz" style="opacity: 0.4; cursor: not-allowed;" title="Nâng cấp Premium để mở khóa nội dung này">
                        🔒 Yêu cầu N<%= userLevel %> / Premium
                    </button>
                    <% } %>
                </div>
                <% } %>
            </div>
        </div>
        <%  } %>
        </div> <!-- End ai-category-grid -->
        <% } else { %>
        <div style="text-align:center;padding:3rem;color:var(--muted-text);">
            <div style="font-size:3rem;margin-bottom:1rem;">📚</div>
            <p>Chưa có bài học nào.</p>
        </div>
        <% } %>
    </div>
</main>

<!-- ===== AI QUIZ OVERLAY ===== -->
<div id="aiQuizOverlay" class="quiz-overlay">
<div class="quiz-modal">
    <!-- Config -->
    <div id="aiConfig" class="glass-card" style="text-align:center;">
        <h2 style="font-family:'Noto Serif JP',serif;margin-bottom:0.5rem;">🤖 Tạo Quiz AI</h2>
        <p id="aiLessonName" style="color:var(--muted-text);margin-bottom:1.5rem;"></p>
        <div style="margin-bottom:1.5rem;">
            <label style="display:block;margin-bottom:0.5rem;color:var(--sakura-pink);font-weight:600;">Số câu hỏi</label>
            <div style="display:flex;gap:1rem;justify-content:center;">
                <button class="q-num-btn active" onclick="selectNum(this,5)">5 câu</button>
                <button class="q-num-btn" onclick="selectNum(this,10)">10 câu</button>
                <button class="q-num-btn" onclick="selectNum(this,15)">15 câu</button>
            </div>
        </div>
        <button onclick="generateAiQuiz()" style="background:var(--gradient-primary);color:white;border:none;padding:0.8rem 2.5rem;border-radius:30px;font-size:1.1rem;font-weight:600;cursor:pointer;">✨ Tạo Quiz</button>
        <br><button onclick="closeOverlay()" style="background:transparent;border:1px solid rgba(255,255,255,0.2);color:white;padding:0.5rem 1.5rem;border-radius:20px;margin-top:1rem;cursor:pointer;">✕ Đóng</button>
    </div>
    <!-- Loading -->
    <div id="aiLoading" style="display:none;text-align:center;padding:3rem;">
        <div style="font-size:3rem;animation:spin 1s linear infinite;display:inline-block;">🔄</div>
        <p style="margin-top:1rem;color:var(--sakura-pink);font-size:1.1rem;">AI đang tạo quiz...</p>
        <p style="color:var(--muted-text);font-size:0.85rem;">Vui lòng đợi 5-10 giây</p>
    </div>
    <!-- Quiz Play -->
    <div id="aiPlay" style="display:none;">
        <div style="display:flex;justify-content:space-between;align-items:center;margin-bottom:1rem;">
            <span style="font-family:'Noto Serif JP',serif;color:var(--sakura-pink);font-size:1rem;">🤖 Quiz AI</span>
            <span id="aiTimer" style="font-size:1.3rem;font-weight:700;color:white;">0:00</span>
        </div>
        <div style="height:8px;background:rgba(255,255,255,0.1);border-radius:4px;margin-bottom:0.5rem;overflow:hidden;">
            <div id="aiProgress" style="height:100%;background:linear-gradient(90deg,#4ade80,#16a34a);border-radius:4px;transition:width 0.5s;width:0%;"></div>
        </div>
        <div id="aiCounter" style="color:var(--muted-text);font-size:0.85rem;margin-bottom:1.5rem;"></div>
        <div class="glass-card" style="text-align:center;">
            <div id="aiQText" style="font-family:'Noto Serif JP',serif;font-size:1.4rem;color:white;margin-bottom:1.5rem;"></div>
            <div id="aiOpts" style="display:grid;grid-template-columns:1fr 1fr;gap:1rem;"></div>
            <div id="aiFeedback" style="margin-top:1.5rem;font-size:1.1rem;font-weight:600;min-height:1.5rem;"></div>
        </div>
    </div>
    <!-- Results -->
    <div id="aiResult" style="display:none;">
        <div class="glass-card" style="text-align:center;">
            <div id="aiScoreNum" style="font-size:4rem;font-weight:700;background:linear-gradient(135deg,#4ade80,#fbbf24);-webkit-background-clip:text;-webkit-text-fill-color:transparent;background-clip:text;">0%</div>
            <div id="aiGrade" style="font-family:'Noto Serif JP',serif;font-size:1.3rem;margin-bottom:1.5rem;"></div>
            <div style="display:flex;justify-content:center;gap:2rem;margin-bottom:1.5rem;">
                <div style="text-align:center;"><span id="aiCorrectN" style="font-size:2rem;font-weight:700;color:#4ade80;display:block;">0</span><span style="font-size:0.8rem;color:var(--muted-text);">Đúng</span></div>
                <div style="text-align:center;"><span id="aiWrongN" style="font-size:2rem;font-weight:700;color:#f87171;display:block;">0</span><span style="font-size:0.8rem;color:var(--muted-text);">Sai</span></div>
                <div style="text-align:center;"><span id="aiTimeN" style="font-size:2rem;font-weight:700;color:#fbbf24;display:block;">0:00</span><span style="font-size:0.8rem;color:var(--muted-text);">Thời gian</span></div>
            </div>
            <div style="display:flex;justify-content:center;gap:1rem;flex-wrap:wrap;">
                <button onclick="generateAiQuiz()" style="background:var(--gradient-primary);color:white;border:none;padding:0.7rem 2rem;border-radius:30px;font-weight:600;cursor:pointer;">🔄 Tạo quiz mới</button>
                <button onclick="closeOverlay()" style="background:rgba(255,255,255,0.1);border:1px solid rgba(255,255,255,0.2);color:white;padding:0.7rem 2rem;border-radius:30px;font-weight:600;cursor:pointer;">✕ Đóng</button>
            </div>
            <div id="aiWrongList" style="margin-top:1.5rem;text-align:left;"></div>
        </div>
    </div>
</div>
</div>

<!-- ===== STATIC QUIZ OVERLAY ===== -->
<div id="staticOverlay" class="quiz-overlay">
<div class="quiz-modal">
    <div style="display:flex;justify-content:space-between;align-items:center;margin-bottom:1rem;">
        <span id="sCatLabel" style="font-family:'Noto Serif JP',serif;color:var(--sakura-pink);font-size:1rem;"></span>
        <span id="sTimer" style="font-size:1.3rem;font-weight:700;color:white;">0:00</span>
    </div>
    <div style="height:8px;background:rgba(255,255,255,0.1);border-radius:4px;margin-bottom:0.5rem;overflow:hidden;">
        <div id="sProgress" style="height:100%;background:linear-gradient(90deg,#4ade80,#16a34a);border-radius:4px;transition:width 0.5s;width:0%;"></div>
    </div>
    <div id="sCounter" style="color:var(--muted-text);font-size:0.85rem;margin-bottom:1.5rem;"></div>

    <!-- Question -->
    <div id="sQuestion" class="glass-card" style="text-align:center;">
        <div id="sQText" style="font-family:'Noto Serif JP',serif;font-size:2.5rem;color:white;margin-bottom:0.5rem;"></div>
        <div id="sQSub" style="color:var(--muted-text);font-size:1rem;margin-bottom:2rem;"></div>
        <div id="sOpts" class="options-grid"></div>
        <div id="sFeedback" style="margin-top:1.5rem;font-size:1.1rem;font-weight:600;min-height:1.5rem;"></div>
    </div>

    <!-- Results -->
    <div id="sResult" style="display:none;">
        <div class="glass-card" style="text-align:center;">
            <div id="sScoreNum" style="font-size:5rem;font-weight:700;background:linear-gradient(135deg,#4ade80,#fbbf24);-webkit-background-clip:text;-webkit-text-fill-color:transparent;background-clip:text;">0%</div>
            <div id="sGrade" style="font-family:'Noto Serif JP',serif;font-size:1.5rem;margin-bottom:1.5rem;"></div>
            <div style="display:flex;justify-content:center;gap:2rem;margin-bottom:2rem;">
                <div style="text-align:center;"><span id="sCorrectN" style="font-size:2rem;font-weight:700;color:#4ade80;display:block;">0</span><span style="font-size:0.8rem;color:var(--muted-text);">Đúng</span></div>
                <div style="text-align:center;"><span id="sWrongN" style="font-size:2rem;font-weight:700;color:#f87171;display:block;">0</span><span style="font-size:0.8rem;color:var(--muted-text);">Sai</span></div>
                <div style="text-align:center;"><span id="sTimeN" style="font-size:2rem;font-weight:700;color:#fbbf24;display:block;">0:00</span><span style="font-size:0.8rem;color:var(--muted-text);">Thời gian</span></div>
            </div>
            <div style="display:flex;justify-content:center;gap:1rem;flex-wrap:wrap;">
                <button onclick="retryStaticQuiz()" style="background:var(--gradient-primary);color:white;border:none;padding:0.8rem 2rem;border-radius:30px;font-weight:600;cursor:pointer;">🔄 Làm lại</button>
                <button onclick="closeOverlay()" style="background:rgba(255,255,255,0.1);border:1px solid rgba(255,255,255,0.2);color:white;padding:0.8rem 2rem;border-radius:30px;font-weight:600;cursor:pointer;">📚 Quay lại</button>
            </div>
            <div id="sWrongList" style="margin-top:2rem;text-align:left;"></div>
        </div>
    </div>
</div>
</div>

<footer class="footer">
    <p>&copy; 2026 <span class="footer-brand">日本語学習</span> - Japanese Learning Platform. All rights reserved.</p>
</footer>

<script>
// ==================== TAB SWITCHING ====================
function switchTab(tab) {
    document.querySelectorAll('.quiz-tab').forEach((t,i) => { t.classList.toggle('active', (tab==='practice'?i===0:i===1)); });
    document.getElementById('tabPractice').style.display = tab==='practice'?'block':'none';
    document.getElementById('tabAi').style.display = tab==='ai'?'block':'none';
}

function closeOverlay() {
    document.getElementById('aiQuizOverlay').style.display='none';
    document.getElementById('staticOverlay').style.display='none';
    document.body.style.overflow='';
    clearInterval(aiTimerInt); clearInterval(sTimerInt);
}

// ==================== STATIC QUIZ DATA ====================
const quizData = {
    hiragana: { label:"Hiragana", prompt:"Chọn cách đọc đúng", questions:[
        {q:"あ",a:"a",opts:["a","i","u","e"]},{q:"い",a:"i",opts:["e","i","o","u"]},{q:"う",a:"u",opts:["a","u","o","e"]},
        {q:"え",a:"e",opts:["i","a","e","u"]},{q:"お",a:"o",opts:["o","a","u","e"]},{q:"か",a:"ka",opts:["ka","ki","ku","ke"]},
        {q:"き",a:"ki",opts:["ka","ke","ki","ko"]},{q:"く",a:"ku",opts:["ko","ku","ka","ki"]},{q:"け",a:"ke",opts:["ki","ka","ke","ku"]},
        {q:"こ",a:"ko",opts:["ku","ke","ko","ka"]},{q:"さ",a:"sa",opts:["sa","shi","su","se"]},{q:"し",a:"shi",opts:["sa","su","shi","so"]},
        {q:"す",a:"su",opts:["shi","su","se","so"]},{q:"せ",a:"se",opts:["sa","se","su","so"]},{q:"そ",a:"so",opts:["se","so","sa","shi"]}
    ]},
    katakana: { label:"Katakana", prompt:"Chọn cách đọc đúng", questions:[
        {q:"ア",a:"a",opts:["a","i","u","e"]},{q:"イ",a:"i",opts:["e","i","o","u"]},{q:"ウ",a:"u",opts:["a","u","o","e"]},
        {q:"エ",a:"e",opts:["i","a","e","u"]},{q:"オ",a:"o",opts:["o","a","u","e"]},{q:"カ",a:"ka",opts:["ka","ki","ku","ke"]},
        {q:"キ",a:"ki",opts:["ka","ke","ki","ko"]},{q:"ク",a:"ku",opts:["ko","ku","ka","ki"]},{q:"ケ",a:"ke",opts:["ki","ka","ke","ku"]},
        {q:"コ",a:"ko",opts:["ku","ke","ko","ka"]},{q:"サ",a:"sa",opts:["sa","shi","su","se"]},{q:"シ",a:"shi",opts:["sa","su","shi","so"]},
        {q:"ス",a:"su",opts:["shi","su","se","so"]},{q:"セ",a:"se",opts:["sa","se","su","so"]},{q:"ソ",a:"so",opts:["se","so","sa","shi"]}
    ]},
    vocabulary: { label:"Từ Vựng", prompt:"Chọn nghĩa đúng", questions:[
        {q:"食べる (たべる)",a:"Ăn",opts:["Uống","Ăn","Ngủ","Đi"]},{q:"飲む (のむ)",a:"Uống",opts:["Ăn","Uống","Đọc","Viết"]},
        {q:"見る (みる)",a:"Nhìn/Xem",opts:["Nghe","Nói","Nhìn/Xem","Đọc"]},{q:"聞く (きく)",a:"Nghe",opts:["Nhìn","Nghe","Nói","Viết"]},
        {q:"話す (はなす)",a:"Nói",opts:["Nghe","Đọc","Nói","Viết"]},{q:"読む (よむ)",a:"Đọc",opts:["Viết","Đọc","Nghe","Nói"]},
        {q:"書く (かく)",a:"Viết",opts:["Đọc","Vẽ","Viết","Nói"]},{q:"行く (いく)",a:"Đi",opts:["Đến","Về","Đi","Chạy"]},
        {q:"来る (くる)",a:"Đến",opts:["Đi","Đến","Về","Ra"]},{q:"帰る (かえる)",a:"Về nhà",opts:["Đi","Đến","Về nhà","Ra ngoài"]},
        {q:"寝る (ねる)",a:"Ngủ",opts:["Thức","Ngủ","Ăn","Nghỉ"]},{q:"起きる (おきる)",a:"Thức dậy",opts:["Ngủ","Thức dậy","Nằm","Ngồi"]},
        {q:"買う (かう)",a:"Mua",opts:["Bán","Mua","Trả","Đổi"]},{q:"学校 (がっこう)",a:"Trường học",opts:["Nhà","Trường học","Công ty","Bệnh viện"]},
        {q:"先生 (せんせい)",a:"Giáo viên",opts:["Học sinh","Bác sĩ","Giáo viên","Nhân viên"]}
    ]},
    grammar: { label:"Ngữ Pháp", prompt:"Điền từ đúng vào chỗ trống", questions:[
        {q:"わたし___学生です。",a:"は",opts:["は","が","を","に"]},{q:"これ___本です。",a:"は",opts:["を","は","に","で"]},
        {q:"学校___行きます。",a:"に",opts:["を","は","に","で"]},{q:"ごはん___食べます。",a:"を",opts:["は","が","を","に"]},
        {q:"日本語___勉強します。",a:"を",opts:["は","を","に","で"]},{q:"友達___会います。",a:"に",opts:["を","に","は","で"]},
        {q:"バス___乗ります。",a:"に",opts:["を","で","に","は"]},{q:"図書館___勉強します。",a:"で",opts:["に","を","で","は"]},
        {q:"昨日テレビ___見ました。",a:"を",opts:["は","を","が","に"]},{q:"東京___住んでいます。",a:"に",opts:["で","に","を","は"]},
        {q:"毎日7時___起きます。",a:"に",opts:["は","で","に","を"]},{q:"コーヒー___紅茶、どちらが好きですか。",a:"と",opts:["と","や","も","か"]},
        {q:"田中さん___日本人です。",a:"は",opts:["は","が","も","の"]},{q:"これは誰___かばんですか。",a:"の",opts:["が","の","は","を"]},
        {q:"映画___好きです。",a:"が",opts:["は","を","が","に"]}
    ]},
    kanji: { label:"Kanji", prompt:"Chọn nghĩa hoặc cách đọc đúng", questions:[
        {q:"日",a:"Ngày / Mặt trời",opts:["Ngày / Mặt trời","Tháng","Năm","Sao"]},{q:"月",a:"Tháng / Mặt trăng",opts:["Ngày","Tháng / Mặt trăng","Năm","Tuần"]},
        {q:"火",a:"Lửa",opts:["Nước","Lửa","Đất","Gió"]},{q:"水",a:"Nước",opts:["Lửa","Gió","Nước","Đất"]},
        {q:"木",a:"Cây / Gỗ",opts:["Hoa","Cỏ","Lá","Cây / Gỗ"]},{q:"金",a:"Vàng / Tiền",opts:["Bạc","Đồng","Vàng / Tiền","Sắt"]},
        {q:"土",a:"Đất",opts:["Đá","Đất","Cát","Bùn"]},{q:"山",a:"Núi",opts:["Sông","Biển","Núi","Đồng"]},
        {q:"川",a:"Sông",opts:["Núi","Sông","Hồ","Biển"]},{q:"大",a:"Lớn / To",opts:["Nhỏ","Lớn / To","Dài","Ngắn"]},
        {q:"小",a:"Nhỏ / Bé",opts:["Lớn","Cao","Nhỏ / Bé","Thấp"]},{q:"人",a:"Người",opts:["Con","Người","Vật","Chim"]},
        {q:"口",a:"Miệng",opts:["Mắt","Tai","Mũi","Miệng"]},{q:"目",a:"Mắt",opts:["Mắt","Tai","Mũi","Miệng"]},
        {q:"手",a:"Tay",opts:["Chân","Tay","Đầu","Vai"]}
    ]}
};

// ==================== STATIC QUIZ ENGINE ====================
let sCat=null, sQs=[], sIdx=0, sScore=0, sWrongs=[], sTimerInt=null, sSec=0, sAns=false;
const SQ_COUNT = 10;
function shuffle(a){const b=[...a];for(let i=b.length-1;i>0;i--){const j=Math.floor(Math.random()*(i+1));[b[i],b[j]]=[b[j],b[i]];}return b;}

function startStaticQuiz(cat) {
    sCat=cat; const d=quizData[cat];
    sQs=shuffle(d.questions).slice(0,SQ_COUNT).map(q=>({...q,opts:shuffle(q.opts)}));
    sIdx=0; sScore=0; sWrongs=[]; sSec=0; sAns=false;
    document.getElementById('staticOverlay').style.display='block';
    document.body.style.overflow='hidden';
    document.getElementById('sCatLabel').textContent=d.label;
    document.getElementById('sQuestion').style.display='block';
    document.getElementById('sResult').style.display='none';
    clearInterval(sTimerInt);
    sTimerInt=setInterval(()=>{sSec++;const m=Math.floor(sSec/60),s=sSec%60;document.getElementById('sTimer').textContent=m+':'+(s<10?'0':'')+s;},1000);
    showSQ();
}
function retryStaticQuiz(){startStaticQuiz(sCat);}
function showSQ(){
    sAns=false; const q=sQs[sIdx],t=sQs.length;
    document.getElementById('sQText').textContent=q.q;
    document.getElementById('sQSub').textContent=quizData[sCat].prompt;
    document.getElementById('sCounter').textContent='Câu '+(sIdx+1)+' / '+t;
    document.getElementById('sProgress').style.width=((sIdx/t)*100)+'%';
    document.getElementById('sFeedback').textContent='';
    const g=document.getElementById('sOpts'); g.innerHTML='';
    q.opts.forEach(o=>{const b=document.createElement('button');b.className='option-btn';b.textContent=o;b.onclick=()=>selectSA(b,o,q.a);g.appendChild(b);});
}
function selectSA(btn,sel,cor){
    if(sAns)return; sAns=true;
    document.querySelectorAll('#sOpts .option-btn').forEach(b=>b.classList.add('disabled'));
    if(sel===cor){btn.classList.add('correct');sScore++;document.getElementById('sFeedback').innerHTML='<span style="color:#4ade80">✅ Chính xác!</span>';}
    else{btn.classList.add('wrong');sWrongs.push({q:sQs[sIdx].q,y:sel,c:cor});document.getElementById('sFeedback').innerHTML='<span style="color:#f87171">❌ Sai! Đáp án: '+cor+'</span>';
    document.querySelectorAll('#sOpts .option-btn').forEach(b=>{if(b.textContent===cor)b.classList.add('show-correct');});}
    setTimeout(()=>{sIdx++;if(sIdx<sQs.length)showSQ();else showSR();},1500);
}
function showSR(){
    clearInterval(sTimerInt);
    document.getElementById('sQuestion').style.display='none';
    document.getElementById('sResult').style.display='block';
    const t=sQs.length,p=Math.round((sScore/t)*100),m=Math.floor(sSec/60),s=sSec%60;
    document.getElementById('sScoreNum').textContent=p+'%';
    document.getElementById('sCorrectN').textContent=sScore;
    document.getElementById('sWrongN').textContent=t-sScore;
    document.getElementById('sTimeN').textContent=m+':'+(s<10?'0':'')+s;
    let g='';if(p===100)g='🏆 Hoàn hảo! すごい!';else if(p>=80)g='🌸 Giỏi lắm!';else if(p>=60)g='📖 Khá tốt!';else if(p>=40)g='💪 Cần cố gắng!';else g='📚 Hãy ôn tập lại!';
    document.getElementById('sGrade').textContent=g;
    const wd=document.getElementById('sWrongList');
    if(sWrongs.length>0){let h='<h4 style="font-family:\'Noto Serif JP\',serif;color:var(--sakura-pink);margin-bottom:1rem;">📝 Xem lại câu sai</h4>';
    sWrongs.forEach(w=>{h+='<div style="background:rgba(248,113,113,0.08);border:1px solid rgba(248,113,113,0.2);border-radius:12px;padding:1rem;margin-bottom:0.75rem;"><div style="font-weight:600;color:white;margin-bottom:0.3rem;">'+w.q+'</div><div style="color:#f87171;font-size:0.9rem;">❌ Bạn chọn: '+w.y+'</div><div style="color:#4ade80;font-size:0.9rem;">✅ Đáp án: '+w.c+'</div></div>';});
    wd.innerHTML=h;}else{wd.innerHTML='<p style="text-align:center;color:#4ade80;margin-top:1rem;">🎉 Đúng tất cả!</p>';}
}

// ==================== AI QUIZ ENGINE ====================
let aiLessonId=null, aiNumQ=5, aiQs=[], aiIdx=0, aiScore=0, aiWrongs=[], aiTimerInt=null, aiSec=0, aiAns=false;

function selectNum(btn,n){aiNumQ=n;document.querySelectorAll('.q-num-btn').forEach(b=>b.classList.remove('active'));btn.classList.add('active');}

function openAiQuizModal(lessonId, name){
    aiLessonId=lessonId;
    document.getElementById('aiLessonName').textContent='Bài: '+name;
    document.getElementById('aiQuizOverlay').style.display='block';
    document.getElementById('aiConfig').style.display='block';
    document.getElementById('aiLoading').style.display='none';
    document.getElementById('aiPlay').style.display='none';
    document.getElementById('aiResult').style.display='none';
    document.body.style.overflow='hidden';
}

async function generateAiQuiz(){
    document.getElementById('aiConfig').style.display='none';
    document.getElementById('aiResult').style.display='none';
    document.getElementById('aiPlay').style.display='none';
    document.getElementById('aiLoading').style.display='block';
    try{
        const resp=await fetch('<%= request.getContextPath() %>/ai-quiz',{method:'POST',headers:{'Content-Type':'application/json'},body:JSON.stringify({lessonId:aiLessonId,numQuestions:aiNumQ})});
        if(!resp.ok){const e=await resp.json();throw new Error(e.error||'Server error');}
        aiQs=await resp.json(); aiIdx=0; aiScore=0; aiWrongs=[]; aiSec=0; aiAns=false;
        document.getElementById('aiLoading').style.display='none';
        document.getElementById('aiPlay').style.display='block';
        clearInterval(aiTimerInt);
        aiTimerInt=setInterval(()=>{aiSec++;const m=Math.floor(aiSec/60),s=aiSec%60;document.getElementById('aiTimer').textContent=m+':'+(s<10?'0':'')+s;},1000);
        showAIQ();
    }catch(e){document.getElementById('aiLoading').style.display='none';document.getElementById('aiConfig').style.display='block';alert('Lỗi tạo quiz: '+e.message);}
}

function showAIQ(){
    aiAns=false;const q=aiQs[aiIdx],t=aiQs.length;
    document.getElementById('aiQText').textContent=q.question;
    document.getElementById('aiCounter').textContent='Câu '+(aiIdx+1)+' / '+t;
    document.getElementById('aiProgress').style.width=((aiIdx/t)*100)+'%';
    document.getElementById('aiFeedback').textContent='';document.getElementById('aiFeedback').style.color='';
    const g=document.getElementById('aiOpts');g.innerHTML='';
    q.options.forEach(o=>{const b=document.createElement('button');b.className='q-opt-btn';b.textContent=o;b.onclick=()=>selectAIA(b,o,q.answer);g.appendChild(b);});
}
function selectAIA(btn,sel,cor){
    if(aiAns)return;aiAns=true;
    document.querySelectorAll('.q-opt-btn').forEach(b=>b.classList.add('disabled'));
    if(sel===cor){btn.classList.add('correct');aiScore++;document.getElementById('aiFeedback').textContent='✅ Chính xác!';document.getElementById('aiFeedback').style.color='#4ade80';}
    else{btn.classList.add('wrong');aiWrongs.push({q:aiQs[aiIdx].question,y:sel,c:cor});document.getElementById('aiFeedback').textContent='❌ Sai! Đáp án: '+cor;document.getElementById('aiFeedback').style.color='#f87171';
    document.querySelectorAll('.q-opt-btn').forEach(b=>{if(b.textContent===cor)b.classList.add('show-correct');});}
    setTimeout(()=>{aiIdx++;if(aiIdx<aiQs.length)showAIQ();else showAIR();},1500);
}
function showAIR(){
    clearInterval(aiTimerInt);
    document.getElementById('aiPlay').style.display='none';
    document.getElementById('aiResult').style.display='block';
    const t=aiQs.length,p=Math.round((aiScore/t)*100),m=Math.floor(aiSec/60),s=aiSec%60;
    document.getElementById('aiScoreNum').textContent=p+'%';
    document.getElementById('aiCorrectN').textContent=aiScore;
    document.getElementById('aiWrongN').textContent=t-aiScore;
    document.getElementById('aiTimeN').textContent=m+':'+(s<10?'0':'')+s;
    let g='';if(p===100)g='🏆 Hoàn hảo! すごい!';else if(p>=80)g='🌸 Giỏi lắm!';else if(p>=60)g='📖 Khá tốt!';else if(p>=40)g='💪 Cần cố gắng!';else g='📚 Hãy ôn tập lại!';
    document.getElementById('aiGrade').textContent=g;
    const wd=document.getElementById('aiWrongList');
    if(aiWrongs.length>0){let h='<h4 style="font-family:\'Noto Serif JP\',serif;color:var(--sakura-pink);margin-bottom:1rem;">📝 Xem lại câu sai</h4>';
    aiWrongs.forEach(w=>{h+='<div style="background:rgba(248,113,113,0.08);border:1px solid rgba(248,113,113,0.2);border-radius:12px;padding:1rem;margin-bottom:0.75rem;"><div style="font-weight:600;color:white;margin-bottom:0.3rem;">'+w.q+'</div><div style="color:#f87171;font-size:0.9rem;">❌ Bạn chọn: '+w.y+'</div><div style="color:#4ade80;font-size:0.9rem;">✅ Đáp án: '+w.c+'</div></div>';});
    wd.innerHTML=h;}else{wd.innerHTML='<p style="text-align:center;color:#4ade80;margin-top:1rem;">🎉 Đúng tất cả!</p>';}
}

// ==================== FILTER AI QUIZ LEVEL ====================
function filterQuizLevel(level, btn) {
    // Update active button
    document.querySelectorAll('.filter-btn').forEach(b => b.classList.remove('active'));
    btn.classList.add('active');

    // Filter cards
    const cards = document.querySelectorAll('.lesson-category-card');
    cards.forEach(card => {
        const cardLevel = card.getAttribute('data-level');
        if (cardLevel === level) {
            card.style.display = '';
            // Make sure they stay collapsed when switching tabs
            card.classList.add('collapsed');
        } else {
            card.style.display = 'none';
        }
    });
}

document.addEventListener('DOMContentLoaded', function() {
    const userLevel = '<%= userLevelStr %>';
    if (userLevel) {
        const btn = document.querySelector('.filter-btn[data-filter="' + userLevel + '"]');
        if (btn) filterQuizLevel(userLevel, btn);
    }
});
</script>
<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/js/bootstrap.bundle.min.js"></script>
</body>
</html>
