<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@page import="com.japaneselearning.model.User"%>

<%
    // KIỂM TRA QUYỀN VIP
    User chatUser = (User) session.getAttribute("user");
    boolean isVip = false;
    if (chatUser != null) {
        try { isVip = chatUser.hasPremiumAccess(); } 
        catch (Exception e) { isVip = false; }
    }
%>

<style>
    /* NÚT MỞ CHAT NỔI (LAUNCHER) - Tăng z-index lên 999999 để đè lên Quiz Overlay */
    #chat-launcher {
        position: fixed; bottom: 25px; right: 25px;
        width: 65px; height: 65px; 
        background: linear-gradient(135deg, #bc002d 0%, #881337 100%);
        border-radius: 50%; color: white; text-align: center;
        line-height: 65px; font-size: 32px; cursor: pointer;
        box-shadow: 0 8px 25px rgba(188, 0, 45, 0.4); z-index: 999999;
        transition: all 0.3s cubic-bezier(0.175, 0.885, 0.32, 1.275);
    }
    #chat-launcher:hover { transform: scale(1.1) rotate(-5deg); box-shadow: 0 12px 30px rgba(188, 0, 45, 0.5); }

    /* CỬA SỔ CHAT MAIN - Tăng z-index lên 999999 */
    #chat-window {
        display: none; position: fixed; bottom: 25px; right: 25px;
        width: 380px; height: 550px; 
        background: rgba(255, 255, 255, 0.98); backdrop-filter: blur(20px);
        border-radius: 16px; box-shadow: 0 15px 40px rgba(0,0,0,0.3);
        z-index: 999999; flex-direction: column; overflow: hidden;
        font-family: 'Poppins', 'Noto Serif JP', sans-serif; 
        border: 1px solid rgba(188, 0, 45, 0.15);
        transition: all 0.4s cubic-bezier(0.25, 0.8, 0.25, 1);
        transform-origin: bottom right;
    }
    
    #chat-window.maximized { width: 600px; height: 80vh; max-width: 95vw; }
    #chat-window.minimized { height: 65px !important; bottom: 25px; cursor: pointer; }
    #chat-window.minimized #chat-messages, 
    #chat-window.minimized #input-area,
    #chat-window.minimized #premium-lock-screen { display: none !important; }

    /* HEADER CHAT */
    .chat-header {
        background: linear-gradient(135deg, #bc002d 0%, #881337 100%);
        color: white; padding: 12px 18px; display: flex; 
        justify-content: space-between; align-items: center;
        flex-shrink: 0; transition: background 0.3s;
    }
    #chat-window.minimized .chat-header { border-radius: 16px; }
    
    .header-title-box { display: flex; align-items: center; gap: 10px; }
    .header-avatar { 
        width: 36px; height: 36px; background: white; border-radius: 50%;
        display: flex; align-items: center; justify-content: center; font-size: 20px;
        box-shadow: 0 2px 10px rgba(0,0,0,0.1);
    }
    .header-text { display: flex; flex-direction: column; }
    .header-name { font-weight: 600; font-size: 18px; letter-spacing: 0.5px; }
    .quota-text { font-size: 11px; color: #ffb7c5; font-weight: 500; margin-top: 2px; }

    /* NÚT ĐIỀU KHIỂN WINDOW */
    .window-controls { display: flex; gap: 10px; align-items: center; }
    .ctrl-btn { 
        background: transparent; border: none; color: rgba(255,255,255,0.7); 
        cursor: pointer; font-size: 16px; width: 24px; height: 24px; 
        border-radius: 4px; display: flex; align-items: center; justify-content: center;
        transition: all 0.2s;
    }
    .ctrl-btn:hover { background: rgba(255,255,255,0.2); color: white; }

    /* KHU VỰC TIN NHẮN */
    #chat-messages {
        flex: 1; padding: 20px 15px; overflow-y: auto; background-color: #fdfdfd;
        display: flex; flex-direction: column; gap: 15px; scroll-behavior: smooth;
    }
    #chat-messages::-webkit-scrollbar { width: 6px; }
    #chat-messages::-webkit-scrollbar-thumb { background: rgba(188,0,45,0.2); border-radius: 3px; }

    /* BONG BÓNG CHAT */
    .message { max-width: 85%; padding: 12px 16px; border-radius: 18px; font-size: 17px; line-height: 1.5; word-wrap: break-word; box-shadow: 0 2px 8px rgba(0,0,0,0.04); animation: popIn 0.3s cubic-bezier(0.175, 0.885, 0.32, 1.275); }
    @keyframes popIn { from { opacity: 0; transform: scale(0.9) translateY(10px); } to { opacity: 1; transform: scale(1) translateY(0); } }
    
    .user-msg { 
        align-self: flex-end; color: white; border-bottom-right-radius: 4px;
        background: linear-gradient(135deg, #ff758c 0%, #ff7eb3 100%); 
    }
    .bot-msg { 
        align-self: flex-start; background-color: white; color: #333; 
        border-bottom-left-radius: 4px; border: 1px solid #f0f0f0; 
    }

    /* HIỆU ỨNG THINKING CỦA AI */
    .thinking-box { display: flex; align-items: center; gap: 10px; color: #bc002d; font-weight: 500; font-size: 13.5px; }
    .thinking-dots { display: flex; gap: 4px; margin-top: 2px; }
    .tdot { width: 6px; height: 6px; background: #bc002d; border-radius: 50%; animation: tBounce 1.4s infinite ease-in-out both; }
    .tdot:nth-child(1) { animation-delay: -0.32s; }
    .tdot:nth-child(2) { animation-delay: -0.16s; }
    @keyframes tBounce { 0%, 80%, 100% { transform: scale(0); opacity: 0.4; } 40% { transform: scale(1); opacity: 1; } }
    .thinking-text { background: linear-gradient(90deg, #bc002d, #ff758c, #bc002d); background-size: 200% auto; color: transparent; -webkit-background-clip: text; background-clip: text; animation: gradientText 2s linear infinite; }
    @keyframes gradientText { to { background-position: 200% center; } }

    /* VÙNG NHẬP LIỆU */
    .chat-input-area { padding: 15px; border-top: 1px solid #eee; display: flex; gap: 10px; background: white; align-items: center; }
    #chat-input { flex: 1; padding: 12px 18px; border: 1px solid #e0e0e0; border-radius: 25px; outline: none; transition: 0.3s; font-family: inherit; font-size: 17px; background: #f9f9f9; }
    #chat-input:focus { border-color: #ffb7c5; background: white; box-shadow: 0 0 0 3px rgba(255,183,197,0.3); }
    #chat-input:disabled { background: #f1f1f1; cursor: not-allowed; }
    #send-btn { background: linear-gradient(135deg, #bc002d 0%, #881337 100%); color: white; border: none; width: 44px; height: 44px; border-radius: 50%; cursor: pointer; display: flex; align-items: center; justify-content: center; transition: 0.3s; flex-shrink: 0; box-shadow: 0 4px 10px rgba(188, 0, 45, 0.3); }
    #send-btn:hover:not(:disabled) { transform: translateY(-2px); box-shadow: 0 6px 15px rgba(188, 0, 45, 0.4); }
    #send-btn:disabled { background: #ccc; box-shadow: none; cursor: not-allowed; }
    #send-btn svg { width: 18px; height: 18px; fill: currentColor; margin-left: 3px; }

    /* MÀN HÌNH KHÓA (FREE HẾT LƯỢT) */
    #premium-lock-screen { display: none; flex-direction: column; align-items: center; justify-content: center; flex: 1; text-align: center; padding: 25px; background: rgba(255,255,255,0.9); backdrop-filter: blur(5px); }
    .lock-icon { font-size: 55px; margin-bottom: 15px; animation: floatLock 3s ease-in-out infinite; }
    @keyframes floatLock { 0%, 100% { transform: translateY(0); } 50% { transform: translateY(-10px); } }
    .lock-title { font-size: 18px; font-weight: bold; color: #bc002d; margin-bottom: 8px; }
    .lock-desc { font-size: 13.5px; color: #666; margin-bottom: 25px; line-height: 1.6; }
    .btn-upgrade-premium { background: linear-gradient(135deg, #f6d365 0%, #fda085 100%); color: #fff !important; border: none; padding: 12px 28px; border-radius: 30px; font-weight: bold; text-decoration: none; display: inline-block; box-shadow: 0 6px 15px rgba(253, 160, 133, 0.4); transition: all 0.3s; font-size: 14.5px; }
    .btn-upgrade-premium:hover { transform: translateY(-3px) scale(1.02); box-shadow: 0 8px 20px rgba(253, 160, 133, 0.6); }
</style>

<div id="chat-launcher" onclick="toggleChat()">✨</div>

<div id="chat-window">
    <div class="chat-header" id="chat-header" onclick="restoreFromMinimized(event)">
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
            Konnichiwa! 🌸 Mình là AI Sensei.<br>Mình có thể thấy được bài học hoặc kết quả bài Quiz của bạn. Bạn muốn giải thích câu nào?
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
    const API_URL = "http://127.0.0.1:8000/api/chat/stream"; 
    const IS_VIP = <%= isVip %>;
    const MAX_FREE_CHATS = 5;
    let chatHistory = [];

    document.addEventListener("DOMContentLoaded", checkQuotaAndUpdateUI);

    // ================= WINDOW CONTROLS =================
    function toggleChat(e) {
        if(e) e.stopPropagation();
        const win = document.getElementById("chat-window");
        const launcher = document.getElementById("chat-launcher");
        if (win.style.display === "none" || win.style.display === "") {
            win.style.display = "flex"; win.classList.remove("minimized");
            launcher.style.display = "none";
            if(checkQuotaAndUpdateUI()) document.getElementById("chat-input").focus();
        } else {
            win.style.display = "none"; launcher.style.display = "block";
        }
    }

    function toggleMinimize(e) {
        e.stopPropagation();
        document.getElementById("chat-window").classList.add("minimized");
    }

    function restoreFromMinimized(e) {
        const win = document.getElementById("chat-window");
        if(win.classList.contains("minimized")) {
            win.classList.remove("minimized");
            if(checkQuotaAndUpdateUI()) document.getElementById("chat-input").focus();
        }
    }

    function toggleMaximize(e) {
        e.stopPropagation();
        const win = document.getElementById("chat-window");
        if(win.classList.contains("minimized")) win.classList.remove("minimized");
        win.classList.toggle("maximized");
    }

    // ================= QUOTA LOGIC =================
    function getTodayString() { const d = new Date(); return d.getFullYear() + "-" + (d.getMonth() + 1) + "-" + d.getDate(); }

    function checkQuotaAndUpdateUI() {
        if (IS_VIP) {
            document.getElementById('quota-display').innerText = "👑 Premium Member";
            return true;
        }
        let date = localStorage.getItem('ai_chat_date');
        let count = localStorage.getItem('ai_chat_count');
        let today = getTodayString();

        if (date !== today || count === null) {
            count = MAX_FREE_CHATS;
            localStorage.setItem('ai_chat_date', today);
            localStorage.setItem('ai_chat_count', count);
        }

        count = parseInt(count);
        document.getElementById('quota-display').innerText = `Còn ${count}/${MAX_FREE_CHATS} lượt hôm nay`;

        if (count <= 0) {
            document.getElementById("chat-messages").style.display = "none";
            document.getElementById("premium-lock-screen").style.display = "flex";
            document.getElementById("chat-input").disabled = true;
            document.getElementById("chat-input").placeholder = "Vui lòng nâng cấp VIP...";
            document.getElementById("send-btn").disabled = true;
            return false;
        }
        return true;
    }

    // ================= CHAT LOGIC & EFFECTS =================
    function handleKeyPress(event) { if (event.key === "Enter") sendMessage(); }
    const sleep = ms => new Promise(r => setTimeout(r, ms));

    async function sendMessage() {
        if (!checkQuotaAndUpdateUI()) return;

        const inputField = document.getElementById("chat-input");
        const sendBtn = document.getElementById("send-btn");
        const userText = inputField.value.trim();
        if (!userText) return;

        if (!IS_VIP) {
            let count = parseInt(localStorage.getItem('ai_chat_count'));
            localStorage.setItem('ai_chat_count', count - 1);
            checkQuotaAndUpdateUI();
        }

        addMessage(userText, 'user');
        inputField.value = ""; inputField.disabled = true; sendBtn.disabled = true;

        // HIỆU ỨNG THINKING
        const thinkingId = "think-" + Date.now();
        const thinkingHTML = `
            <div class="thinking-box">
                <span id="${thinkingId}-text" class="thinking-text">Đang phân tích câu hỏi</span>
                <div class="thinking-dots"><div class="tdot"></div><div class="tdot"></div><div class="tdot"></div></div>
            </div>`;
        const thinkingBubble = addMessage(thinkingHTML, 'bot');
        const textSpan = document.getElementById(`${thinkingId}-text`);

        const states = ["Đang quét dữ liệu màn hình...", "Đang lục tìm trí nhớ...", "Đang đối chiếu đáp án..."];
        let stateIdx = 0;
        const stateInterval = setInterval(() => {
            if(textSpan) textSpan.innerText = states[stateIdx];
            stateIdx = (stateIdx + 1) % states.length;
        }, 1200);

        // ==============================================================
        // LẤY CONTEXT THÔNG MINH (ĐỌC BÀI HỌC HOẶC KẾT QUẢ QUIZ)
        // ==============================================================
        let pageContext = "Người dùng đang ở trang: " + document.title; 
        
        // CÁCH 1: Tìm xem có Popup Quiz nào đang được hiển thị không (display: block)
        const activeQuizOverlay = document.querySelector('.quiz-overlay[style*="display: block"]');
        
        if (activeQuizOverlay) {
            // Lấy nội dung text trong cái Quiz đó (chứa các câu hỏi, câu làm sai, đáp án đúng)
            pageContext = "Nội dung bài Quiz và Kết quả người dùng đang xem:\n" + activeQuizOverlay.innerText.substring(0, 3000);
        } else {
            // CÁCH 2: Nếu không mở Quiz, tìm vùng bài học bình thường
            const readableArea = document.getElementById("ai-readable-context");
            if (readableArea) {
                pageContext = "Tài liệu bài học người dùng đang xem: \n" + readableArea.innerText.substring(0, 3000);
            }
        }
        
        const payload = { message: userText, context: pageContext, history: chatHistory };

        try {
            const response = await fetch(API_URL, {
                method: "POST", headers: { "Content-Type": "application/json" },
                body: JSON.stringify(payload)
            });

            if (!response.ok) throw new Error("Lỗi API");

            clearInterval(stateInterval);
            if(textSpan) {
                textSpan.innerText = "Đã tìm thấy câu trả lời! ✨";
                textSpan.style.color = "#28a745"; 
                document.querySelector('.thinking-dots').style.display = 'none';
            }
            await sleep(600); 
            thinkingBubble.remove(); 

            const reader = response.body.getReader();
            const decoder = new TextDecoder("utf-8");
            
            const botMessageDiv = addMessage("", 'bot');
            let currentBotText = ""; 

            while (true) {
                const { done, value } = await reader.read();
                if (done) break;

                const chunk = decoder.decode(value, { stream: true });
                const lines = chunk.split('\n');
                
                for (let line of lines) {
                    if (line.startsWith('data: ')) {
                        currentBotText += line.substring(6); 
                        botMessageDiv.innerHTML = currentBotText.replace(/\n/g, '<br>');
                        scrollToBottom();
                    }
                }
            }

            chatHistory.push({ role: "user", content: userText });
            chatHistory.push({ role: "model", content: currentBotText });

        } catch (error) {
            clearInterval(stateInterval);
            thinkingBubble.remove();
            addMessage("❌ AI Sensei đang bảo trì. Vui lòng thử lại sau nhé!", 'bot');
            if (!IS_VIP) {
                let count = parseInt(localStorage.getItem('ai_chat_count'));
                localStorage.setItem('ai_chat_count', count + 1);
                checkQuotaAndUpdateUI();
            }
        } finally {
            if (IS_VIP || parseInt(localStorage.getItem('ai_chat_count')) > 0) {
                inputField.disabled = false; sendBtn.disabled = false; inputField.focus();
            }
        }
    }

    function addMessage(htmlContent, sender) {
        const msgDiv = document.createElement("div");
        msgDiv.className = "message " + (sender === 'user' ? "user-msg" : "bot-msg");
        msgDiv.innerHTML = htmlContent; 
        document.getElementById("chat-messages").appendChild(msgDiv);
        scrollToBottom();
        return msgDiv; 
    }

    function scrollToBottom() {
        const box = document.getElementById("chat-messages");
        box.scrollTop = box.scrollHeight;
    }
</script>