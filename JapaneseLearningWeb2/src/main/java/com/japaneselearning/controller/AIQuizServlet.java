package com.japaneselearning.controller;

import com.google.gson.Gson;
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

@WebServlet(name = "AIQuizServlet", urlPatterns = {"/ai-quiz"})
public class AIQuizServlet extends HttpServlet {

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
        int numQuestions = reqBody.has("numQuestions") ? reqBody.get("numQuestions").getAsInt() : 5;
        
        String lessonContent = "";
        
        // Option 1: lessonId provided — load content from file
        if (reqBody.has("lessonId")) {
            int lessonId = reqBody.get("lessonId").getAsInt();
            com.japaneselearning.dao.LessonDAO lessonDAO = new com.japaneselearning.dao.LessonDAO();
            com.japaneselearning.model.Lesson lesson = lessonDAO.getLessonById(lessonId);
            if (lesson != null && lesson.getContentPath() != null) {
                try (InputStream contentStream = getServletContext().getResourceAsStream("/" + lesson.getContentPath())) {
                    if (contentStream != null) {
                        lessonContent = new String(contentStream.readAllBytes(), StandardCharsets.UTF_8);
                    }
                }
            }
            if (lessonContent.isEmpty()) {
                response.setStatus(400);
                response.getWriter().write("{\"error\":\"Không tìm thấy nội dung bài học\"}");
                return;
            }
        }
        // Option 2: lessonContent provided directly
        else if (reqBody.has("lessonContent")) {
            lessonContent = reqBody.get("lessonContent").getAsString();
        }

        // Limit content length to avoid token limits
        if (lessonContent.length() > 4000) {
            lessonContent = lessonContent.substring(0, 4000);
        }

        // Remove HTML tags to get plain text
        String plainText = lessonContent.replaceAll("<[^>]*>", " ")
                                        .replaceAll("\\s+", " ")
                                        .trim();

        // Build prompt
        String prompt = "Bạn là giáo viên tiếng Nhật. Dựa vào nội dung bài học sau, hãy tạo " + numQuestions +
                " câu hỏi trắc nghiệm để kiểm tra kiến thức.\n\n" +
                "NỘI DUNG BÀI HỌC:\n" + plainText + "\n\n" +
                "QUY TẮC BẮT BUỘC:\n" +
                "1. Tạo đúng " + numQuestions + " câu hỏi, mỗi câu 4 lựa chọn\n" +
                "2. Mỗi đáp án phải NGẮN GỌN (1-3 từ), KHÔNG dùng dấu / hoặc liệt kê nhiều nghĩa\n" +
                "3. Trường answer phải COPY NGUYÊN VĂN một phần tử trong mảng options\n" +
                "4. KHÔNG dùng nhãn A, B, C, D\n" +
                "5. CHỈ trả về JSON, không nói gì thêm\n\n" +
                "FORMAT:\n" +
                "[{\"question\":\"câu hỏi\",\"options\":[\"opt1\",\"opt2\",\"opt3\",\"opt4\"],\"answer\":\"opt1\"}]\n\n" +
                "VÍ DỤ ĐÚNG:\n" +
                "{\"question\":\"'食べる' có nghĩa là gì?\",\"options\":[\"Ăn\",\"Uống\",\"Ngủ\",\"Đi\"],\"answer\":\"Ăn\"}\n\n" +
                "VÍ DỤ SAI (KHÔNG LÀM THẾ NÀY):\n" +
                "{\"question\":\"...\",\"options\":[\"Ăn\",\"Uống\",\"Ngủ\",\"Đi\"],\"answer\":\"Ăn / Ăn cơm\"}\n\n" +
                "JSON:";

        try {
            String aiResponse = callGroqAPI(prompt);

            // Extract JSON array from response
            String jsonStr = extractJsonArray(aiResponse);

            // Validate it's valid JSON array
            JsonArray arr = JsonParser.parseString(jsonStr).getAsJsonArray();

            // Validate and fix: ensure answer matches one of the options
            JsonArray validated = validateAndFixQuiz(arr);

            response.getWriter().write(validated.toString());

        } catch (Exception e) {
            e.printStackTrace();
            response.setStatus(500);
            response.getWriter().write("{\"error\":\"Lỗi tạo quiz: " + e.getMessage().replace("\"", "'") + "\"}");
        }
    }

    /**
     * Validate each question: ensure answer exactly matches one option.
     * If not, try partial matching. Drop invalid questions.
     */
    private JsonArray validateAndFixQuiz(JsonArray arr) {
        JsonArray result = new JsonArray();
        for (int i = 0; i < arr.size(); i++) {
            JsonObject q = arr.get(i).getAsJsonObject();
            if (!q.has("question") || !q.has("options") || !q.has("answer")) continue;

            String answer = q.get("answer").getAsString().trim();
            JsonArray options = q.getAsJsonArray("options");

            // Check if answer exactly matches an option
            boolean found = false;
            for (int j = 0; j < options.size(); j++) {
                if (options.get(j).getAsString().trim().equals(answer)) {
                    found = true;
                    break;
                }
            }

            // If not found, try partial matching (answer contains option or vice versa)
            if (!found) {
                String bestMatch = null;
                int bestScore = 0;
                for (int j = 0; j < options.size(); j++) {
                    String opt = options.get(j).getAsString().trim();
                    if (answer.contains(opt) || opt.contains(answer)) {
                        int score = Math.min(answer.length(), opt.length());
                        if (score > bestScore) {
                            bestScore = score;
                            bestMatch = opt;
                        }
                    }
                }
                if (bestMatch != null) {
                    // Fix the answer to match the option
                    q.addProperty("answer", bestMatch);
                    found = true;
                }
            }

            // If still not found, set answer to first option (fallback)
            if (!found) {
                q.addProperty("answer", options.get(0).getAsString());
            }

            result.add(q);
        }
        return result;
    }

    private String callGroqAPI(String prompt) throws IOException {
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
        body.addProperty("max_tokens", 2048);

        JsonArray messages = new JsonArray();
        JsonObject msg = new JsonObject();
        msg.addProperty("role", "user");
        msg.addProperty("content", prompt);
        messages.add(msg);
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

        // Parse response to get content
        JsonObject respObj = JsonParser.parseString(resp.toString()).getAsJsonObject();
        return respObj.getAsJsonArray("choices")
                .get(0).getAsJsonObject()
                .getAsJsonObject("message")
                .get("content").getAsString();
    }

    /**
     * Extract JSON array from AI response (handle cases where AI adds extra text)
     */
    private String extractJsonArray(String text) {
        // Find first [ and last ]
        int start = text.indexOf('[');
        int end = text.lastIndexOf(']');
        if (start >= 0 && end > start) {
            return text.substring(start, end + 1);
        }
        throw new RuntimeException("Không tìm thấy JSON trong response của AI");
    }
}
