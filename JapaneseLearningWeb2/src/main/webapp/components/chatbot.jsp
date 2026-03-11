<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@page import="com.japaneselearning.model.User"%>

<%
    // =================================================================
    // LỚP BẢO VỆ CẤP SERVER: CHỐNG NHÚNG FILE NHIỀU LẦN (SINGLETON)
    // Nếu chatbot đã được nạp 1 lần ở Navbar, nó sẽ bỏ qua các lần nhúng sau
    // =================================================================
    if (request.getAttribute("CHATBOT_ALREADY_LOADED") == null) {
        request.setAttribute("CHATBOT_ALREADY_LOADED", true);

        User chatUser = (User) session.getAttribute("user");
        boolean isVip = false;
        if (chatUser != null) {
            try {
                isVip = chatUser.hasPremiumAccess();
            } catch (Exception e) {
                isVip = false;
            }
        }
%>

<style>
    /* CSS GIAO DIỆN (Đã tối ưu) */
    #chat-launcher {
        position: fixed;
        bottom: 25px;
        right: 25px;
        width: 65px;
        height: 65px;
        background: linear-gradient(135deg, #bc002d 0%, #881337 100%);
        border-radius: 50%;
        color: white;
        text-align: center;
        line-height: 65px;
        font-size: 32px;
        cursor: pointer;
        box-shadow: 0 8px 25px rgba(188, 0, 45, 0.4);
        z-index: 999999;
        transition: all 0.3s cubic-bezier(0.175, 0.885, 0.32, 1.275);
    }
    #chat-launcher:hover {
        transform: scale(1.1) rotate(-5deg);
        box-shadow: 0 12px 30px rgba(188, 0, 45, 0.5);
    }
    #chat-window {
        display: none;
        position: fixed;
        bottom: 25px;
        right: 25px;
        width: 380px;
        height: 550px;
        background: rgba(255, 255, 255, 0.98);
        backdrop-filter: blur(20px);
        border-radius: 16px;
        box-shadow: 0 15px 40px rgba(0,0,0,0.3);
        z-index: 999999;
        flex-direction: column;
        overflow: hidden;
        font-family: 'Poppins', 'Noto Serif JP', sans-serif;
        border: 1px solid rgba(188, 0, 45, 0.15);
        transition: all 0.4s cubic-bezier(0.25, 0.8, 0.25, 1);
        transform-origin: bottom right;
    }
    #chat-window.maximized {
        width: 600px;
        height: 80vh;
        max-width: 95vw;
    }
    #chat-window.minimized {
        height: 65px !important;
        bottom: 25px;
        cursor: pointer;
    }
    #chat-window.minimized #chat-messages, #chat-window.minimized #input-area, #chat-window.minimized #premium-lock-screen {
        display: none !important;
    }
    #chat-window .chat-header {
        background: linear-gradient(135deg, #bc002d 0%, #881337 100%);
        color: white;
        padding: 12px 18px;
        display: flex;
        justify-content: space-between;
        align-items: center;
        flex-shrink: 0;
        transition: background 0.3s;
    }
    #chat-window.minimized .chat-header {
        border-radius: 16px;
    }
    .header-title-box {
        display: flex;
        align-items: center;
        gap: 10px;
    }
    .header-avatar {
        width: 36px;
        height: 36px;
        background: white;
        border-radius: 50%;
        display: flex;
        align-items: center;
        justify-content: center;
        font-size: 20px;
        box-shadow: 0 2px 10px rgba(0,0,0,0.1);
    }
    .header-text {
        display: flex;
        flex-direction: column;
    }
    .header-name {
        font-weight: 600;
        font-size: 16px;
        letter-spacing: 0.5px;
    }
    .quota-text {
        font-size: 11.5px;
        color: #ffb7c5;
        font-weight: 500;
        margin-top: 2px;
    }
    .window-controls {
        display: flex;
        gap: 10px;
        align-items: center;
    }
    .ctrl-btn {
        background: transparent;
        border: none;
        color: rgba(255,255,255,0.7);
        cursor: pointer;
        font-size: 16px;
        width: 24px;
        height: 24px;
        border-radius: 4px;
        display: flex;
        align-items: center;
        justify-content: center;
        transition: all 0.2s;
    }
    .ctrl-btn:hover {
        background: rgba(255,255,255,0.2);
        color: white;
    }
    #chat-messages {
        flex: 1;
        padding: 20px 15px;
        overflow-y: auto;
        background-color: #fdfdfd;
        display: flex;
        flex-direction: column;
        gap: 15px;
        scroll-behavior: smooth;
    }
    #chat-messages::-webkit-scrollbar {
        width: 6px;
    }
    #chat-messages::-webkit-scrollbar-thumb {
        background: rgba(188,0,45,0.2);
        border-radius: 3px;
    }
    #chat-messages .message {
        max-width: 88%;
        padding: 12px 16px;
        border-radius: 18px;
        font-size: 14.5px;
        line-height: 1.6;
        word-wrap: break-word;
        box-shadow: 0 2px 8px rgba(0,0,0,0.04);
        animation: popIn 0.3s cubic-bezier(0.175, 0.885, 0.32, 1.275);
    }
    @keyframes popIn {
        from {
            opacity: 0;
            transform: scale(0.9) translateY(10px);
        }
        to {
            opacity: 1;
            transform: scale(1) translateY(0);
        }
    }
    #chat-messages .user-msg {
        align-self: flex-end;
        color: white;
        border-bottom-right-radius: 4px;
        background: linear-gradient(135deg, #ff758c 0%, #ff7eb3 100%);
    }
    #chat-messages .bot-msg {
        align-self: flex-start;
        background-color: white;
        color: #2c3e50;
        border-bottom-left-radius: 4px;
        border: 1px solid #eaeaea;
    }
    #chat-messages .bot-msg strong {
        color: #bc002d;
        font-weight: 700;
    }
    .thinking-box {
        display: flex;
        align-items: center;
        gap: 8px;
        color: #bc002d;
        font-weight: 500;
        font-size: 14px;
    }
    .thinking-dots {
        display: flex;
        gap: 4px;
        margin-top: 2px;
    }
    .tdot {
        width: 6px;
        height: 6px;
        background: #bc002d;
        border-radius: 50%;
        animation: tBounce 1.4s infinite ease-in-out both;
    }
    .tdot:nth-child(1) {
        animation-delay: -0.32s;
    }
    .tdot:nth-child(2) {
        animation-delay: -0.16s;
    }
    @keyframes tBounce {
        0%, 80%, 100% {
            transform: scale(0);
            opacity: 0.4;
        }
        40% {
            transform: scale(1);
            opacity: 1;
        }
    }
    .chat-input-area {
        padding: 15px;
        border-top: 1px solid #eee;
        display: flex;
        gap: 10px;
        background: white;
        align-items: center;
    }
    #chat-input {
        flex: 1;
        padding: 12px 18px;
        border: 1px solid #e0e0e0;
        border-radius: 25px;
        outline: none;
        transition: 0.3s;
        font-family: inherit;
        font-size: 14.5px;
        background: #f9f9f9;
    }
    #chat-input:focus {
        border-color: #ffb7c5;
        background: white;
        box-shadow: 0 0 0 3px rgba(255,183,197,0.3);
    }
    #chat-input:disabled {
        background: #f1f1f1;
        cursor: not-allowed;
    }
    #send-btn {
        background: linear-gradient(135deg, #bc002d 0%, #881337 100%);
        color: white;
        border: none;
        width: 44px;
        height: 44px;
        border-radius: 50%;
        cursor: pointer;
        display: flex;
        align-items: center;
        justify-content: center;
        transition: 0.3s;
        flex-shrink: 0;
        box-shadow: 0 4px 10px rgba(188, 0, 45, 0.3);
    }
    #send-btn:hover:not(:disabled) {
        transform: translateY(-2px);
        box-shadow: 0 6px 15px rgba(188, 0, 45, 0.4);
    }
    #send-btn:disabled {
        background: #ccc;
        box-shadow: none;
        cursor: not-allowed;
    }
    #send-btn svg {
        width: 18px;
        height: 18px;
        fill: currentColor;
        margin-left: 3px;
    }
    #premium-lock-screen {
        display: none;
        flex-direction: column;
        align-items: center;
        justify-content: center;
        flex: 1;
        text-align: center;
        padding: 25px;
        background: rgba(255,255,255,0.9);
        backdrop-filter: blur(5px);
    }
    .lock-icon {
        font-size: 55px;
        margin-bottom: 15px;
        animation: floatLock 3s ease-in-out infinite;
    }
    @keyframes floatLock {
        0%, 100% {
            transform: translateY(0);
        }
        50% {
            transform: translateY(-10px);
        }
    }
    .lock-title {
        font-size: 18px;
        font-weight: bold;
        color: #bc002d;
        margin-bottom: 8px;
    }
    .lock-desc {
        font-size: 14px;
        color: #666;
        margin-bottom: 25px;
        line-height: 1.6;
    }
    .btn-upgrade-premium {
        background: linear-gradient(135deg, #f6d365 0%, #fda085 100%);
        color: #fff !important;
        border: none;
        padding: 12px 28px;
        border-radius: 30px;
        font-weight: bold;
        text-decoration: none;
        display: inline-block;
        box-shadow: 0 6px 15px rgba(253, 160, 133, 0.4);
        transition: all 0.3s;
        font-size: 14.5px;
    }
    .btn-upgrade-premium:hover {
        transform: translateY(-3px) scale(1.02);
        box-shadow: 0 8px 20px rgba(253, 160, 133, 0.6);
    }
</style>

<div id="chat-launcher" onclick="toggleChat()">✨</div>

<div id="chat-window">
    <div class="chat-header" id="chat-header" onclick="restoreFromMinimized()">
        <div class="header-title-box">
            <div class="header-avatar">🤖</div>
            <div class="header-text">
                <span class="header-name">AI Sensei</span>
                <span class="quota-text" id="quota-display">Đang tải dữ liệu...</span>
            </div>
        </div>
        <div class="window-controls">
            <button class="ctrl-btn" onclick="toggleMinimize(event)" title="Thu nhỏ">_</button>
            <button class="ctrl-btn" onclick="toggleMaximize(event)" title="Phóng to">□</button>
            <button class="ctrl-btn" onclick="toggleChat(event)" title="Đóng">×</button>
        </div>
    </div>

    <div id="chat-messages">
        <div class="message bot-msg">
            Konnichiwa! 🌸 Mình là AI Sensei.<br>Mình có thể đọc được bài học hoặc kết quả bài Quiz của bạn. Bạn có chỗ nào chưa hiểu không?
        </div>
    </div>

    <div id="premium-lock-screen">
        <div class="lock-icon">🔒</div>
        <div class="lock-title">Đã hết lượt Free hôm nay!</div>
        <div class="lock-desc">Nâng cấp tài khoản Premium để mở khóa sức mạnh AI không giới hạn, hỗ trợ học tập 24/7.</div>
        <a href="premium.jsp" class="btn-upgrade-premium">👑 Mở Khóa Premium Ngay</a>
    </div>

    <div class="chat-input-area" id="input-area">
        <input type="text" id="chat-input" placeholder="Hỏi AI Sensei..." onkeypress="handleKeyPress(event)">
        <button id="send-btn" onclick="sendMessage()">
            <svg viewBox="0 0 24 24"><path d="M2.01 21L23 12 2.01 3 2 10l15 2-15 2z"></path></svg>
        </button>
    </div>
</div>

<script>
    var API_URL = "http://127.0.0.1:8000/api/chat/stream";
    var IS_VIP = <%= isVip%>;
    var MAX_FREE_CHATS = 5;
    window.chatHistory = window.chatHistory || [];

    function getTodayString() {
        var d = new Date();
        return d.getFullYear() + "-" + (d.getMonth() + 1) + "-" + d.getDate();
    }

    function checkQuotaAndUpdateUI() {
        try {
            var quotaEl = document.getElementById('quota-display');
            if (!quotaEl)
                return true;

            if (IS_VIP) {
                quotaEl.innerText = "👑 Premium Member";
                return true;
            }

            var date = localStorage.getItem('ai_chat_date');
            var count = localStorage.getItem('ai_chat_count');
            var today = getTodayString();

            if (date !== today || count === null || isNaN(parseInt(count))) {
                count = MAX_FREE_CHATS;
                localStorage.setItem('ai_chat_date', today);
                localStorage.setItem('ai_chat_count', count);
            }

            count = parseInt(count);
            quotaEl.innerText = "Còn " + count + "/" + MAX_FREE_CHATS + " lượt hôm nay";

            if (count <= 0) {
                document.getElementById("chat-messages").style.display = "none";
                document.getElementById("premium-lock-screen").style.display = "flex";
                document.getElementById("chat-input").disabled = true;
                document.getElementById("chat-input").placeholder = "Vui lòng nâng cấp VIP...";
                document.getElementById("send-btn").disabled = true;
                return false;
            }
            return true;

        } catch (error) {
            var el = document.getElementById('quota-display');
            if (el)
                el.innerText = "Còn 5/5 lượt (Ẩn danh)";
            return true;
        }
    }

    function toggleChat(e) {
        if (e)
            e.stopPropagation();
        var win = document.getElementById("chat-window");
        var launcher = document.getElementById("chat-launcher");
        if (win.style.display === "none" || win.style.display === "") {
            win.style.display = "flex";
            win.classList.remove("minimized");
            if (launcher)
                launcher.style.display = "none";
            if (checkQuotaAndUpdateUI()) {
                var inp = document.getElementById("chat-input");
                if (inp)
                    inp.focus();
            }
        } else {
            win.style.display = "none";
            if (launcher)
                launcher.style.display = "block";
        }
    }
    function toggleMinimize(e) {
        if (e)
            e.stopPropagation();
        document.getElementById("chat-window").classList.add("minimized");
    }
    function restoreFromMinimized() {
        var win = document.getElementById("chat-window");
        if (win.classList.contains("minimized")) {
            win.classList.remove("minimized");
            if (checkQuotaAndUpdateUI())
                document.getElementById("chat-input").focus();
        }
    }
    function toggleMaximize(e) {
        if (e)
            e.stopPropagation();
        var win = document.getElementById("chat-window");
        win.classList.remove("minimized");
        win.classList.toggle("maximized");
    }

    function formatMarkdown(text) {
        var html = text;
        html = html.replace(/\*\*(.*?)\*\*/g, '<strong>$1</strong>');
        html = html.replace(/^(\d+\.)\s+(.*)$/gm, '<div style="margin-top: 10px; margin-bottom: 5px;"><strong>$1</strong> $2</div>');
        html = html.replace(/^(?:-|\*)\s+(.*)$/gm, '<div style="margin-left: 15px; margin-bottom: 5px;">• $1</div>');
        html = html.replace(/\n/g, '<br>');
        html = html.replace(/<\/div><br>/g, '</div>');
        html = html.replace(/<br><div/g, '<div');
        return html;
    }

    function scrollToBottom() {
        var box = document.getElementById("chat-messages");
        if (box)
            box.scrollTop = box.scrollHeight;
    }

    function addMessage(htmlContent, sender) {
        var msgDiv = document.createElement("div");
        msgDiv.className = "message " + (sender === 'user' ? "user-msg" : "bot-msg");
        msgDiv.innerHTML = htmlContent;
        document.getElementById("chat-messages").appendChild(msgDiv);
        scrollToBottom();
        return msgDiv;
    }

    function handleKeyPress(event) {
        if (event.key === "Enter")
            sendMessage();
    }

    async function sendMessage() {
        if (!checkQuotaAndUpdateUI())
            return;

        var inputField = document.getElementById("chat-input");
        var sendBtn = document.getElementById("send-btn");
        var userText = inputField.value.trim();
        if (!userText)
            return;

        if (!IS_VIP) {
            try {
                var count = parseInt(localStorage.getItem('ai_chat_count'));
                if (!isNaN(count))
                    localStorage.setItem('ai_chat_count', count - 1);
            } catch (e) {
            }
            checkQuotaAndUpdateUI();
        }

        addMessage(userText, 'user');
        inputField.value = "";
        inputField.disabled = true;
        sendBtn.disabled = true;

        var thinkingId = "think-" + Date.now();
        var thinkingHTML = '<div class="thinking-box" id="' + thinkingId + '"><span>Đang thu thập dữ liệu...</span><div class="thinking-dots"><div class="tdot"></div><div class="tdot"></div><div class="tdot"></div></div></div>';
        var thinkingBubble = addMessage(thinkingHTML, 'bot');

        var pageContext = "Người dùng đang ở trang: " + document.title;
        var activeQuizOverlay = document.querySelector('.quiz-overlay[style*="display: block"]');
        if (activeQuizOverlay) {
            pageContext = "Nội dung bài Quiz và Kết quả người dùng đang xem:\n" + activeQuizOverlay.innerText.substring(0, 3000);
        } else {
            var readableArea = document.getElementById("ai-readable-context");
            if (readableArea)
                pageContext = "Tài liệu bài học người dùng đang xem: \n" + readableArea.innerText.substring(0, 3000);
        }

        var payload = {message: userText, context: pageContext, history: window.chatHistory};

        try {
            var response = await fetch(API_URL, {
                method: "POST", headers: {"Content-Type": "application/json"},
                body: JSON.stringify(payload)
            });

            if (!response.ok)
                throw new Error("Lỗi API");

            var reader = response.body.getReader();
            var decoder = new TextDecoder("utf-8");

            var isFirstChunk = true;
            var currentBotText = "";
            var botMessageDiv = null;

            while (true) {
                var streamData = await reader.read();
                var done = streamData.done;
                var value = streamData.value;

                if (done)
                    break;

                if (isFirstChunk) {
                    thinkingBubble.remove();
                    botMessageDiv = addMessage("", 'bot');
                    isFirstChunk = false;
                }

                var chunk = decoder.decode(value, {stream: true});
                var messages = chunk.split('\n\n');

                for (var i = 0; i < messages.length; i++) {
                    var msg = messages[i];
                    if (msg.startsWith('data: ')) {
                        var text = msg.substring(6);
                        if (text.trim() === '[DONE]')
                            continue;
                        text = text.replace(/\\n/g, '\n');
                        currentBotText += text;
                    }
                }

                botMessageDiv.innerHTML = formatMarkdown(currentBotText);
                scrollToBottom();
            }

            window.chatHistory.push({role: "user", content: userText});
            window.chatHistory.push({role: "model", content: currentBotText});

        } catch (error) {
            thinkingBubble.remove();
            addMessage("❌ Server AI chưa phản hồi. Vui lòng thử lại.", 'bot');
            if (!IS_VIP) {
                try {
                    var count = parseInt(localStorage.getItem('ai_chat_count'));
                    if (!isNaN(count))
                        localStorage.setItem('ai_chat_count', count + 1);
                } catch (e) {
                }
                checkQuotaAndUpdateUI();
            }
        } finally {
            inputField.disabled = false;
            sendBtn.disabled = false;
            inputField.focus();
        }
    }

    // Khởi chạy khi load xong
    checkQuotaAndUpdateUI();
</script>

<%
    } // KẾT THÚC LỚP BẢO VỆ SINGLETON
%>