package com.japaneselearning.controller;

import com.google.gson.JsonArray;
import com.google.gson.JsonObject;
import com.google.gson.JsonParser;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import com.japaneselearning.model.User;

import java.io.*;
import java.net.HttpURLConnection;
import java.net.URL;
import java.nio.charset.StandardCharsets;

@WebServlet(name = "AIVoiceServlet", urlPatterns = {"/ai-voice"})
public class AIVoiceServlet extends HttpServlet {

    private static final String GROQ_API_KEY = "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";
    private static final String GROQ_API_URL = "https://api.groq.com/openai/v1/chat/completions";

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        response.setContentType("application/json");
        response.setCharacterEncoding("UTF-8");

        // Check login
        HttpSession session = request.getSession();
        User user = (User) session.getAttribute("user");
        if (user == null) {
            response.setStatus(401);
            response.getWriter().write("{\"error\":\"Chưa đăng nhập\"}");
            return;
        }

        // Read request body
        StringBuilder sb = new StringBuilder();
        try (BufferedReader reader = request.getReader()) {
            String line;
            while ((line = reader.readLine()) != null) {
                sb.append(line);
            }
        }

        JsonObject reqBody = JsonParser.parseString(sb.toString()).getAsJsonObject();
        
        String userMessage = reqBody.has("message") ? reqBody.get("message").getAsString() : "";
        String level = reqBody.has("level") ? reqBody.get("level").getAsString() : "N5";
        String scenario = reqBody.has("scenario") ? reqBody.get("scenario").getAsString() : "General";
        JsonArray history = reqBody.has("history") ? reqBody.getAsJsonArray("history") : new JsonArray();

        // Level Validation Logic
        boolean isPremium = user.hasPremiumAccess();
        int userLevel = user.getLevel();
        int requestedLevel = Integer.parseInt(level.replace("N", ""));
        
        if (!isPremium && requestedLevel < userLevel) { // e.g. User is N5 (5), requests N4 (4)
            response.setStatus(403);
            response.getWriter().write("{\"error\":\"Bạn cần nâng cấp Premium để giao tiếp ở trình độ N" + requestedLevel + "\"}");
            return;
        }

        // Usage limit logic for free users
        if (!isPremium) {
            Integer usageCount = (Integer) session.getAttribute("aiVoiceUsageCount");
            if (usageCount == null) {
                usageCount = 0;
            }
            if (usageCount >= 5) {
                response.setStatus(403);
                response.getWriter().write("{\"error\":\"Bạn đã hết 5 lượt dùng thử AI Voice hôm nay. Nâng cấp Premium ngay để luyện nói thả ga bảo vệ mượt mà nhé!\", \"limitReached\": true}");
                return;
            }
            session.setAttribute("aiVoiceUsageCount", usageCount + 1);
        }

        // Build System Prompt
        String systemPrompt = "Bạn là AI đóng vai một người Nhật trong tình huống giao tiếp thực tế. " +
                "Hiện tại bạn đang ở trong tình huống: [" + scenario + "]. " +
                "Người dùng đang học tiếng Nhật ở trình độ " + level + ". " +
                "YÊU CẦU BẮT BUỘC:\n" +
                "1. CHỈ SỬ DỤNG TỪ VỰNG và ngữ pháp trình độ " + level + " hoặc thấp hơn.\n" +
                "2. LUÔN BẮT ĐẦU CÂU TRẢ LỜI BẰNG CÁCH NHẮC LẠI NỘI DUNG NGƯỜI DÙNG VỪA NÓI để xác nhận, sau đó mới đưa ra câu trả lời của bạn.\n" +
                "3. TUYỆT ĐỐI CHỈ DÙNG TIẾNG NHẬT (Hiragana, Katakana, Kanji) cho phần 'japanese'. Không bao giờ được dùng tiếng Hàn (Korean), tiếng Trung hay ngôn ngữ khác.\n" +
                "4. Đóng đúng vai trò của mình trong tình huống này. Đừng gọi người dùng là 'Ông/Bà Quốc gia' (Không dùng Betonamu-san) nếu họ nói họ đến từ đâu.\n" +
                "5. LUÔN CHỦ ĐỘNG ĐẶT CÂU HỎI tiếp theo ở cuối câu trả lời để duy trì hội thoại, CÂU HỎI PHẢI XOAY QUANH CHỦ ĐỀ [" + scenario + "].\n" +
                "6. BẮT BUỘC TRẢ VỀ ĐÚNG ĐỊNH DẠNG JSON. KHÔNG ĐƯỢC CHÈN THÊM BẤT KỲ VĂN BẢN NÀO BÊN NGOÀI KHỐI JSON.\n\n" +
                "ĐỊNH DẠNG JSON MẪU:\n" +
                "{\"japanese\": \"(Nhắc lại ý người dùng) そうですか、ベトナムですね。(Câu hỏi tiếp) どんな映画が好きですか？\", \"romaji\": \"Sou desu ka, Betonamu desu ne. Donna eiga ga suki desu ka?\", \"vietnamese\": \"Vậy à, bạn đến từ Việt Nam nhỉ. Bạn thích thể loại phim nào?\"}";

        try {
            String aiResponse = callGroqAPI(systemPrompt, userMessage, history);
            
            // Lấy chuỗi JSON từ AI trả về.
            int start = aiResponse.indexOf('{');
            int end = aiResponse.lastIndexOf('}');
            if (start >= 0 && end > start) {
                String cleanJsonStr = aiResponse.substring(start, end + 1);
                response.getWriter().write(cleanJsonStr);
            } else {
                 response.getWriter().write("{\"japanese\": \"" + aiResponse.replaceAll("\"", "'") + "\", \"romaji\": \"\", \"vietnamese\": \"\"}");
            }

        } catch (Exception e) {
            e.printStackTrace();
            response.setStatus(500);
            response.getWriter().write("{\"error\":\"Lỗi kết nối AI: " + e.getMessage().replace("\"", "'") + "\"}");
        }
    }

    private String callGroqAPI(String systemPrompt, String userMessage, JsonArray history) throws IOException {
        URL url = new URL(GROQ_API_URL);
        HttpURLConnection conn = (HttpURLConnection) url.openConnection();
        conn.setRequestMethod("POST");
        conn.setRequestProperty("Content-Type", "application/json");
        conn.setRequestProperty("Authorization", "Bearer " + GROQ_API_KEY);
        conn.setDoOutput(true);
        conn.setConnectTimeout(30000);
        conn.setReadTimeout(60000);

        JsonObject body = new JsonObject();
        body.addProperty("model", "llama-3.3-70b-versatile");
        body.addProperty("temperature", 0.7);
        body.addProperty("max_tokens", 500);

        JsonObject responseFormat = new JsonObject();
        responseFormat.addProperty("type", "json_object");
        body.add("response_format", responseFormat);

        JsonArray messages = new JsonArray();
        
        // 1. Add System prompt
        JsonObject sysMsg = new JsonObject();
        sysMsg.addProperty("role", "system");
        sysMsg.addProperty("content", systemPrompt);
        messages.add(sysMsg);
        
        // 2. Add History
        if (history != null) {
            for (int i = 0; i < history.size(); i++) {
                messages.add(history.get(i).getAsJsonObject());
            }
        }
        
        // 3. Add Current User Message
        JsonObject currentMsg = new JsonObject();
        currentMsg.addProperty("role", "user");
        currentMsg.addProperty("content", userMessage);
        messages.add(currentMsg);

        body.add("messages", messages);

        try (OutputStream os = conn.getOutputStream()) {
            os.write(body.toString().getBytes(StandardCharsets.UTF_8));
        }

        int status = conn.getResponseCode();
        InputStream is = (status >= 200 && status < 300) ? conn.getInputStream() : conn.getErrorStream();

        StringBuilder resp = new StringBuilder();
        try (BufferedReader br = new BufferedReader(new InputStreamReader(is, StandardCharsets.UTF_8))) {
            String line;
            while ((line = br.readLine()) != null) {
                resp.append(line);
            }
        }

        if (status < 200 || status >= 300) {
            throw new IOException("Groq API error " + status + ": " + resp.toString());
        }

        JsonObject respObj = JsonParser.parseString(resp.toString()).getAsJsonObject();
        return respObj.getAsJsonArray("choices")
                .get(0).getAsJsonObject()
                .getAsJsonObject("message")
                .get("content").getAsString();
    }
}
