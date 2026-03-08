<%@ page contentType="text/html;charset=UTF-8" %>
<%@ page import="com.japaneselearning.model.User" %>
<%
    User sessionUser = (User) session.getAttribute("user");
    if (sessionUser == null) {
        response.sendRedirect("login.jsp");
        return;
    }
    boolean isPremium = sessionUser.hasPremiumAccess();
    int userLevelScore = sessionUser.getLevel(); // 5 = N5, 4 = N4, etc.
%>
<!DOCTYPE html>
<html lang="vi">
<head>
    <title>AI Luyện Nói - Japanese Learning</title>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <link href="https://fonts.googleapis.com/css2?family=Noto+Serif+JP:wght@400;700&family=Poppins:wght@300;400;500;600&display=swap" rel="stylesheet">
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">
    
    <style>
        :root {
            --primary: #ff6b81;
            --primary-light: #ff8fa3;
            --secondary: #1a1a2e;
            --secondary-light: #16213e;
            --bg-color: #0f172a;
            --card-bg: rgba(30, 41, 59, 0.7);
            --text-main: #f8fafc;
            --text-muted: #94a3b8;
            --gold: #ffd700;
        }

        * {
            box-sizing: border-box;
            margin: 0;
            padding: 0;
        }

        body {
            font-family: 'Poppins', sans-serif;
            background: linear-gradient(135deg, var(--bg-color), var(--secondary-light));
            color: var(--text-main);
            min-height: 100vh;
        }

        .voice-container {
            max-width: 1000px;
            margin: 40px auto;
            padding: 0 20px;
            display: grid;
            grid-template-columns: 320px 1fr;
            gap: 25px;
        }

        /* ----- SIDEBAR SETTINGS ----- */
        .sidebar {
            background: var(--card-bg);
            backdrop-filter: blur(15px);
            border-radius: 20px;
            border: 1px solid rgba(255, 255, 255, 0.1);
            padding: 25px;
            display: flex;
            flex-direction: column;
            gap: 20px;
            height: fit-content;
        }

        .sidebar-title {
            font-size: 1.2rem;
            font-weight: 600;
            display: flex;
            align-items: center;
            gap: 10px;
            margin-bottom: 5px;
        }

        .form-group {
            display: flex;
            flex-direction: column;
            gap: 8px;
        }

        .form-group label {
            font-size: 0.85rem;
            color: var(--text-muted);
            font-weight: 500;
        }

        .custom-select {
            width: 100%;
            padding: 12px;
            border-radius: 12px;
            background: rgba(15, 23, 42, 0.6);
            border: 1px solid rgba(255, 255, 255, 0.15);
            color: white;
            font-family: 'Poppins', sans-serif;
            font-size: 0.95rem;
            cursor: pointer;
            outline: none;
            transition: border-color 0.3s;
        }

        .custom-select:focus {
            border-color: var(--primary);
        }

        .premium-lock {
            color: var(--gold);
            font-size: 0.8rem;
            margin-left: 5px;
        }
        
        /* Cảnh báo cấp độ */
        .level-warning {
            background: rgba(255, 107, 129, 0.15);
            border-left: 4px solid var(--primary);
            padding: 12px;
            border-radius: 8px;
            font-size: 0.85rem;
            display: none;
            margin-top: 5px;
        }

        .btn-restart {
            margin-top: auto;
            background: rgba(255, 255, 255, 0.1);
            color: white;
            border: none;
            padding: 12px;
            border-radius: 12px;
            cursor: pointer;
            font-weight: 500;
            transition: all 0.3s;
        }
        .btn-restart:hover {
            background: rgba(255, 255, 255, 0.2);
            transform: translateY(-2px);
        }

        /* ----- CHAT AREA ----- */
        .chat-area {
            display: flex;
            flex-direction: column;
            background: var(--card-bg);
            backdrop-filter: blur(15px);
            border-radius: 20px;
            border: 1px solid rgba(255, 255, 255, 0.1);
            height: calc(100vh - 120px);
            overflow: hidden;
            position: relative;
        }

        .chat-header {
            padding: 20px 25px;
            border-bottom: 1px solid rgba(255, 255, 255, 0.1);
            display: flex;
            align-items: center;
            gap: 15px;
        }

        .ai-avatar {
            width: 45px;
            height: 45px;
            border-radius: 50%;
            background: linear-gradient(135deg, var(--primary), var(--primary-light));
            display: flex;
            align-items: center;
            justify-content: center;
            font-size: 1.5rem;
        }

        .header-info h2 {
            font-size: 1.1rem;
            font-weight: 600;
        }

        .header-info p {
            font-size: 0.8rem;
            color: var(--primary-light);
            margin-top: 2px;
        }

        /* Messages */
        .messages-container {
            flex: 1;
            padding: 25px;
            overflow-y: auto;
            display: flex;
            flex-direction: column;
            gap: 20px;
        }
        
        .messages-container::-webkit-scrollbar {
            width: 6px;
        }
        .messages-container::-webkit-scrollbar-thumb {
            background-color: rgba(255,255,255,0.2);
            border-radius: 10px;
        }

        .message {
            max-width: 80%;
            display: flex;
            flex-direction: column;
            opacity: 0;
            transform: translateY(10px);
            animation: fadeIn 0.4s ease forwards;
        }

        @keyframes fadeIn {
            to { opacity: 1; transform: translateY(0); }
        }

        .message-ai {
            align-self: flex-start;
        }

        .message-user {
            align-self: flex-end;
            align-items: flex-end;
        }

        .bubble {
            padding: 15px 20px;
            border-radius: 20px;
            font-size: 1.1rem;
            line-height: 1.5;
            position: relative;
        }

        .message-ai .bubble {
            background: rgba(255, 107, 129, 0.15);
            border: 1px solid rgba(255, 107, 129, 0.3);
            border-bottom-left-radius: 5px;
        }

        .message-user .bubble {
            background: linear-gradient(135deg, var(--secondary), var(--secondary-light));
            border: 1px solid rgba(255, 255, 255, 0.1);
            border-bottom-right-radius: 5px;
        }

        .bubble-japanese {
            font-family: 'Noto Serif JP', serif;
            font-size: 1.4rem;
            margin-bottom: 5px;
        }

        .bubble-sub {
            font-size: 0.85rem;
            color: var(--text-muted);
            border-top: 1px solid rgba(255,255,255,0.1);
            padding-top: 5px;
            margin-top: 5px;
        }

        .bubble-speaker {
            position: absolute;
            top: 50%;
            right: -35px;
            transform: translateY(-50%);
            width: 25px;
            height: 25px;
            border-radius: 50%;
            background: rgba(255,255,255,0.1);
            display: flex;
            align-items: center;
            justify-content: center;
            cursor: pointer;
            color: var(--text-muted);
            font-size: 0.7rem;
            transition: 0.3s;
        }
        .bubble-speaker:hover {
            background: var(--primary);
            color: white;
        }

        /* Nhập liệu Micro */
        .input-area {
            padding: 20px 25px;
            border-top: 1px solid rgba(255, 255, 255, 0.1);
            display: flex;
            flex-direction: column;
            gap: 15px;
            align-items: center;
            background: rgba(15, 23, 42, 0.5);
        }

        .voice-status {
            font-size: 0.85rem;
            color: var(--text-muted);
            height: 20px; /* fixed height để không bị giật UI */
        }

        .mic-button {
            width: 70px;
            height: 70px;
            border-radius: 50%;
            background: linear-gradient(135deg, #1e293b, #0f172a);
            border: 2px solid rgba(255, 255, 255, 0.1);
            color: white;
            font-size: 1.8rem;
            cursor: pointer;
            box-shadow: 0 10px 25px rgba(0,0,0,0.3);
            transition: all 0.3s cubic-bezier(0.175, 0.885, 0.32, 1.275);
            display: flex;
            align-items: center;
            justify-content: center;
            position: relative;
        }

        .mic-button:hover {
            transform: scale(1.05);
            border-color: var(--primary-light);
            color: var(--primary-light);
        }

        .mic-button.recording {
            background: var(--primary);
            border-color: var(--primary);
            color: white;
            animation: pulse 1.5s infinite;
        }

        @keyframes pulse {
            0% { box-shadow: 0 0 0 0 rgba(255, 107, 129, 0.6); }
            70% { box-shadow: 0 0 0 20px rgba(255, 107, 129, 0); }
            100% { box-shadow: 0 0 0 0 rgba(255, 107, 129, 0); }
        }

        /* Fallback text input */
        .text-input-wrapper {
            width: 100%;
            display: flex;
            background: rgba(255, 255, 255, 0.05);
            border-radius: 20px;
            padding: 5px 15px;
            border: 1px solid rgba(255, 255, 255, 0.1);
            transition: 0.3s;
        }
        .text-input-wrapper:focus-within {
            border-color: var(--primary);
            background: rgba(255, 255, 255, 0.1);
        }
        
        .chat-input {
            flex: 1;
            background: transparent;
            border: none;
            color: white;
            padding: 10px;
            font-size: 0.95rem;
            font-family: 'Poppins', sans-serif;
            outline: none;
        }
        
        .chat-input::placeholder {
            color: rgba(255,255,255,0.3);
        }

        .btn-send {
            background: transparent;
            border: none;
            color: var(--primary);
            font-size: 1.2rem;
            cursor: pointer;
            padding: 0 10px;
            transition: 0.3s;
        }
        .btn-send:hover {
            color: var(--primary-light);
            transform: scale(1.1);
        }

        /* Loading Dots */
        .typing-indicator {
            display: none;
            align-self: flex-start;
            background: rgba(255, 255, 255, 0.05);
            padding: 15px 20px;
            border-radius: 20px;
            border-bottom-left-radius: 5px;
            margin-bottom: 20px;
        }
        .dot {
            display: inline-block;
            width: 6px;
            height: 6px;
            background: var(--text-muted);
            border-radius: 50%;
            margin: 0 3px;
            animation: jump 1.4s infinite ease-in-out both;
        }
        .dot:nth-child(1) { animation-delay: -0.32s; }
        .dot:nth-child(2) { animation-delay: -0.16s; }
        @keyframes jump {
            0%, 80%, 100% { transform: scale(0); }
            40% { transform: scale(1); background: var(--primary); }
        }

        /* Responsive */
        @media (max-width: 900px) {
            .voice-container {
                grid-template-columns: 1fr;
                gap: 15px;
                margin: 20px auto;
            }
            .sidebar {
                border-radius: 15px;
            }
            .chat-area {
                height: 60vh;
            }
        }
    </style>
</head>
<body>

    <jsp:include page="components/navbar.jsp">
        <jsp:param name="activePage" value="ai-voice"/>
    </jsp:include>

    <div class="voice-container">
        <!-- Sidebar Setup -->
        <div class="sidebar">
            <h3 class="sidebar-title"><i class="fa-solid fa-gear"></i> Cấu Hình Luyện Nói</h3>
            
            <div class="form-group">
                <label>Trình Độ Của Bạn (JLPT)</label>
                <select id="levelSelect" class="custom-select" onchange="checkLevelAccess()">
                    <option value="N5">Level N5 (Mới bắt đầu)</option>
                    <option value="N4">Level N4 (Trung cấp 1)</option>
                    <option value="N3">Level N3 (Trung cấp 2) <%= !isPremium && userLevelScore > 3 ? "🔒" : "" %></option>
                    <option value="N2">Level N2 (Cao cấp 1) <%= !isPremium && userLevelScore > 2 ? "🔒" : "" %></option>
                    <option value="N1">Level N1 (Cao cấp 2) <%= !isPremium && userLevelScore > 1 ? "🔒" : "" %></option>
                </select>
                <div id="levelWarning" class="level-warning">
                    <i class="fa-solid fa-gem"></i> Bạn cần <a href="premium.jsp" style="color:var(--primary);">Gói Premium</a> để hội thoại thực tế ở level này!
                </div>
            </div>

            <div class="form-group">
                <label>Tình huống nhập vai</label>
                <select id="scenarioSelect" class="custom-select" onchange="resetChat()">
                    <!-- Phụ thuộc level, JS sẽ populate -->
                </select>
            </div>

            <div class="form-group" style="margin-top: 15px;">
                <label>Tốc độ giọng nói AI (<span id="speedValue">1.0</span>x)</label>
                <input type="range" id="voiceSpeed" min="0.5" max="1.5" step="0.1" value="1.0" 
                       style="width: 100%; accent-color: var(--primary);" 
                       oninput="document.getElementById('speedValue').innerText = this.value">
            </div>

            <button class="btn-restart" onclick="startNewSession()">
                <i class="fa-solid fa-rotate-right"></i> Bắt đầu hội thoại mới
            </button>
        </div>

        <!-- Chat Interaction Area -->
        <div class="chat-area">
            <div class="chat-header">
                <div class="ai-avatar"><i class="fa-solid fa-robot" style="color:white; font-size:1.2rem;"></i></div>
                <div class="header-info">
                    <h2 id="currentScenarioTitle">Yukiko - Nhân viên Cửa hàng (N5)</h2>
                    <p>Hãy bấm Mic để đóng vai khách hàng</p>
                </div>
            </div>

            <div class="messages-container" id="chatHistory">
                <!-- Initial AI Greeting will be injected here -->
            </div>
            
            <div class="typing-indicator" id="typingIndicator">
                <div class="dot"></div><div class="dot"></div><div class="dot"></div>
            </div>

            <div class="input-area">
                <div class="voice-status" id="voiceStatus">Sẵn sàng. Bấm vào Micro để nói.</div>
                
                <button class="mic-button" id="micBtn" onclick="toggleRecording()">
                    <i class="fa-solid fa-microphone"></i>
                </button>

                <div class="text-input-wrapper">
                    <input type="text" class="chat-input" id="textInput" placeholder="Hoặc gõ Romaji / Tiếng Nhật vào đây..." onkeypress="handleEnter(event)">
                    <button class="btn-send" onclick="sendTextMessage()">
                        <i class="fa-solid fa-paper-plane"></i>
                    </button>
                </div>
            </div>
        </div>
    </div>

    <script>
        // === Global Variables & Configurations ===
        const isPremium = <%= isPremium %>;
        const userLevelScore = <%= userLevelScore %>; // 5 -> N5, 4 -> N4
        
        let conversationHistory = [];
        let isRecording = false;
        let finalTranscript = ''; // Lưu trữ văn bản ghi âm
        
        // Speech Recognition Setup
        const SpeechRecognition = window.SpeechRecognition || window.webkitSpeechRecognition;
        let recognition = null;
        
        if (SpeechRecognition) {
            recognition = new SpeechRecognition();
            recognition.continuous = true; // Ghi âm liên tục cho đến khi user ngắt
            recognition.interimResults = true; // Cho phép hiển thị kết quả tạm thời
            recognition.lang = 'ja-JP';

            recognition.onstart = function() {
                isRecording = true;
                finalTranscript = '';
                document.getElementById('textInput').value = '';
                document.getElementById('micBtn').classList.add('recording');
                document.getElementById('voiceStatus').innerText = "Đang lắng nghe... Bấm lại Micro để gửi!";
            };

            recognition.onresult = function(event) {
                let interimTranscript = '';
                for (let i = event.resultIndex; i < event.results.length; ++i) {
                    if (event.results[i].isFinal) {
                        finalTranscript += event.results[i][0].transcript;
                    } else {
                        interimTranscript += event.results[i][0].transcript;
                    }
                }
                document.getElementById('textInput').value = finalTranscript + interimTranscript;
            };

            recognition.onerror = function(event) {
                console.error("Speech recognition error", event.error);
                if (event.error !== 'no-speech') {
                    document.getElementById('voiceStatus').innerText = "Lỗi Micro. Vui lòng nói lại hoặc gõ văn bản.";
                }
                stopRecordingUI();
            };

            recognition.onend = function() {
                stopRecordingUI();
                // Chỉ tự động gửi nếu có văn bản
                if (document.getElementById('textInput').value.trim() !== '') {
                    sendTextMessage();
                }
            };
        } else {
            console.warn("Browser does not support Speech Recognition.");
            document.getElementById('voiceStatus').innerText = "Trình duyệt không hỗ trợ Mic. Vui lòng dùng Chrome.";
        }

        // Speech Synthesis Setup
        const synth = window.speechSynthesis;
        let japaneseVoices = [];

        // Trình duyệt cần thời gian tải danh sách giọng nói
        function loadVoices() {
            japaneseVoices = synth.getVoices().filter(voice => voice.lang.includes('ja'));
        }
        loadVoices();
        if (speechSynthesis.onvoiceschanged !== undefined) {
            speechSynthesis.onvoiceschanged = loadVoices;
        }

        // === Logic Control ===

        const scenarios = {
            "N5": [
                {id: "konbini", name: "Cửa hàng tiện lợi (Mua đồ)", intro: "いらっしゃいませ！ (Xin chào quý khách)"},
                {id: "ask_directions", name: "Hỏi đường cơ bản", intro: "はい、どうしましたか？ (Vâng, có chuyện gì vậy?)"},
                {id: "self_intro", name: "Giới thiệu bản thân", intro: "はじめまして、お名前は？ (Rất vui được gặp, bạn tên là gì?)"}
            ],
            "N4": [
                {id: "restaurant", name: "Đặt bàn nhà hàng", intro: "お電話ありがとうございます。レストランさくらでございます。 (Cảm ơn đã gọi, đây là nhà hàng Sakura)"},
                {id: "doctor", name: "Khám bệnh", intro: "今日はどうしましたか？ (Hôm nay bạn thấy thế nào?)"}
            ],
            "N3": [
                {id: "interview", name: "Phỏng vấn Arubaito", intro: "では、面接を始めます。自己紹介をお願いします。 (Vậy chúng ta bắt đầu phỏng vấn nhé. Xin hãy giới thiệu bản thân.)"},
                {id: "complain", name: "Phàn nàn dịch vụ", intro: "申し訳ございません。どのような状況でしょうか？ (Mong quý khách thông cảm, có vấn đề gì xảy ra vậy ạ?)"}
            ],
            "N2": [
                {id: "business_meeting", name: "Họp công ty", intro: "本日の会議を始めましょう。(Chúng ta bắt đầu cuộc họp hôm nay nhé)"}
            ],
            "N1": [
                {id: "debate", name: "Tranh luận xã hội", intro: "その件について、あなたの意見を聞かせてください。(Hãy cho tôi nghe ý kiến của bạn về vấn đề đó)"}
            ]
        };

        function populateScenarios() {
            const level = document.getElementById('levelSelect').value;
            const scenarioSelect = document.getElementById('scenarioSelect');
            scenarioSelect.innerHTML = '';
            
            if (scenarios[level]) {
                scenarios[level].forEach(sc => {
                    const opt = document.createElement('option');
                    opt.value = sc.name;
                    opt.text = sc.name;
                    opt.dataset.intro = sc.intro;
                    scenarioSelect.appendChild(opt);
                });
            }
        }

        function checkLevelAccess() {
            populateScenarios();
            const levelStr = document.getElementById('levelSelect').value;
            const requestedLevelScore = parseInt(levelStr.replace('N', '')); // N5 -> 5
            
            const warning = document.getElementById('levelWarning');
            const micBtn = document.getElementById('micBtn');
            const textInput = document.getElementById('textInput');
            
            // Logic: userLevelScore 5 (N5) is > requestedLevelScore 4 (N4). 
            // So if requested < user && !isPremium -> Block
            if (!isPremium && requestedLevelScore < userLevelScore) {
                warning.style.display = "block";
                micBtn.disabled = true;
                textInput.disabled = true;
                micBtn.style.opacity = 0.5;
            } else {
                warning.style.display = "none";
                micBtn.disabled = false;
                textInput.disabled = false;
                micBtn.style.opacity = 1;
                startNewSession();
            }
        }

        function toggleRecording() {
            if (!recognition) return;
            
            if (isRecording) {
                recognition.stop();
            } else {
                // Cancel any ongoing speaking before listening
                synth.cancel();
                recognition.start();
            }
        }

        function stopRecordingUI() {
            isRecording = false;
            document.getElementById('micBtn').classList.remove('recording');
            document.getElementById('voiceStatus').innerText = "Sẵn sàng. Bấm vào Micro để nói.";
        }

        function handleEnter(e) {
            if(e.key === 'Enter') {
                sendTextMessage();
            }
        }

        function playVoice(japaneseText) {
            if (synth.speaking) {
                synth.cancel();
            }
            if (japaneseText !== "") {
                const utterThis = new SpeechSynthesisUtterance(japaneseText);
                if (japaneseVoices.length > 0) {
                    // Try to pick a female voice for UI consistency if available
                    utterThis.voice = japaneseVoices.find(v => v.name.includes('Female')) || japaneseVoices[0];
                }
                utterThis.lang = 'ja-JP';
                utterThis.rate = parseFloat(document.getElementById('voiceSpeed').value);
                synth.speak(utterThis);
            }
        }

        function appendMessage(role, textData) {
            const chatHistory = document.getElementById('chatHistory');
            const wrapper = document.createElement('div');
            wrapper.className = `message message-${role}`;

            let contentHTML = '';
            if (role === 'ai') {
                contentHTML = `
                    <div class="bubble">
                        <div class="bubble-speaker" onclick="playVoice('\${textData.japanese.replace(/'/g, "\\'")}')" title="Nghe lại">🔊</div>
                        <div class="bubble-japanese">\${textData.japanese || ''}</div>
                        <div class="bubble-sub">\${textData.romaji || ''}</div>
                        <div class="bubble-sub" style="color:#ff8fa3;">\${textData.vietnamese || ''}</div>
                    </div>
                `;
            } else {
                // User message (we only have the raw string they spoke/typed)
                contentHTML = `
                    <div class="bubble">
                        <div class="bubble-japanese" style="font-size:1.1rem;">\${textData}</div>
                    </div>
                `;
            }

            wrapper.innerHTML = contentHTML;
            chatHistory.appendChild(wrapper);
            
            // Cuộn xuống cuối
            chatHistory.scrollTop = chatHistory.scrollHeight;
        }

        async function sendTextMessage() {
            const inputEl = document.getElementById('textInput');
            const message = inputEl.value.trim();
            
            if (!message) return;

            // Xóa ô nhập
            inputEl.value = '';
            
            // Hiển thị message người dùng ngay lập tức
            appendMessage('user', message);
            
            // Lưu vào history nội bộ gửi API
            conversationHistory.push({ role: "user", content: message });
            
            // Hiển thị loading AI
            document.getElementById('typingIndicator').style.display = 'block';
            document.getElementById('chatHistory').scrollTop = document.getElementById('chatHistory').scrollHeight;

            const level = document.getElementById('levelSelect').value;
            const scenario = document.getElementById('scenarioSelect').value;

            try {
                const response = await fetch('ai-voice', {
                    method: 'POST',
                    headers: { 'Content-Type': 'application/json' },
                    body: JSON.stringify({
                        level: level,
                        scenario: scenario,
                        message: message,
                        history: conversationHistory.slice(0, 8) // Giữ max 8 tin nhắn gần nhất để đỡ tốn token
                    })
                });

                document.getElementById('typingIndicator').style.display = 'none';

                if (response.ok) {
                    const data = await response.json();
                    
                    // Add AI response to UI
                    appendMessage('ai', data);
                    
                    // Tự động đọc bằng TTS
                    playVoice(data.japanese);

                    // Add to history for API context
                    // AI requires the pure plain text response back in the history
                    conversationHistory.push({ role: "assistant", content: data.japanese });
                } else {
                    const error = await response.json();
                    if (error.limitReached) {
                        if (confirm(error.error + "\n\nNhấn OK để đến trang Nâng Cấp ngay!")) {
                            window.location.href = "premium.jsp";
                        }
                    } else {
                        alert("Lỗi: " + error.error);
                    }
                }
            } catch (err) {
                console.error(err);
                document.getElementById('typingIndicator').style.display = 'none';
                alert("Đã xảy ra lỗi kết nối tới AI.");
            }
        }

        function resetChat() {
            document.getElementById('chatHistory').innerHTML = '';
            conversationHistory = [];
            
            const level = document.getElementById('levelSelect').value;
            const scenarioSelect = document.getElementById('scenarioSelect');
            const scenarioName = scenarioSelect.options[scenarioSelect.selectedIndex].text;
            const introMsg = scenarioSelect.options[scenarioSelect.selectedIndex].dataset.intro;
            
            document.getElementById('currentScenarioTitle').innerText = `\${scenarioName} (\${level})`;
            
            // Split intro for display
            let parts = introMsg.split(' (');
            let jpn = parts[0];
            let vie = parts.length > 1 ? parts[1].replace(')', '') : '';
            
            const aiFormat = {
                japanese: jpn,
                romaji: "",
                vietnamese: vie
            };

            // Lưu câu đầu của AI vào lịch sử
            conversationHistory.push({ role: "assistant", content: jpn });
            
            setTimeout(() => {
                appendMessage('ai', aiFormat);
                playVoice(jpn);
            }, 500);
        }

        function startNewSession() {
            synth.cancel();
            resetChat();
        }

        // Khởi tạo lần đầu
        document.addEventListener('DOMContentLoaded', () => {
            populateScenarios();
            checkLevelAccess(); // Sẽ gọi startNewSession bên trong nếu pass validation
        });

    </script>
</body>
</html>
