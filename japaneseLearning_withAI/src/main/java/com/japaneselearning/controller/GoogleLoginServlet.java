package com.japaneselearning.controller;

import com.japaneselearning.dao.UserDAO;
import com.japaneselearning.model.User;
import com.google.api.client.googleapis.auth.oauth2.GoogleIdToken;
import com.google.api.client.googleapis.auth.oauth2.GoogleIdTokenVerifier;
import com.google.api.client.http.javanet.NetHttpTransport;
import com.google.api.client.json.gson.GsonFactory;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

import java.io.IOException;
import java.util.Collections;

@WebServlet("/google-login")
public class GoogleLoginServlet extends HttpServlet {

    private static final String GOOGLE_CLIENT_ID = "912023989681-0fehc1j8pvssrm274qgetn523c92aik9.apps.googleusercontent.com";

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        String credential = request.getParameter("credential");

        if (credential == null || credential.isEmpty()) {
            request.setAttribute("error", "Không nhận được thông tin từ Google!");
            request.getRequestDispatcher("login.jsp").forward(request, response);
            return;
        }

        try {
            // Verify Google ID Token
            GoogleIdTokenVerifier verifier = new GoogleIdTokenVerifier.Builder(
                    new NetHttpTransport(), GsonFactory.getDefaultInstance())
                    .setAudience(Collections.singletonList(GOOGLE_CLIENT_ID))
                    .build();

            GoogleIdToken idToken = verifier.verify(credential);

            if (idToken != null) {
                GoogleIdToken.Payload payload = idToken.getPayload();

                String googleId = payload.getSubject(); // Google unique ID
                String email = payload.getEmail();
                String fullName = (String) payload.get("name");

                UserDAO dao = new UserDAO();

                // Tìm user theo Google ID
                User user = dao.findByGoogleId(googleId);

                if (user == null) {
                    // Chưa có tài khoản → Tạo token gửi xác thực thay vì đăng ký luôn
                    user = new User();
                    // Dùng email làm username tạm (loại bỏ @...)
                    user.setUsername(email.split("@")[0]);
                    user.setEmail(email);
                    user.setFullName(fullName);
                    user.setGoogleId(googleId);
                    user.setPassword(""); // Không cần password cho Google login

                    // Generate Token
                    String token = java.util.UUID.randomUUID().toString();
                    com.japaneselearning.utils.TokenStore.getInstance().storeUser(token, user);

                    // Send email
                    try {
                        String scheme = request.getScheme(); 
                        String serverName = request.getServerName();
                        int serverPort = request.getServerPort();
                        String contextPath = request.getContextPath();
                        String appBaseUrl = scheme + "://" + serverName + ":" + serverPort + contextPath;
                        String verifyLink = appBaseUrl + "/verify-register?token=" + token;

                        String subject = "Xác nhận đăng ký tài khoản Google - Japanese Learning";
                        String content = "<div style='font-family: Arial, sans-serif; max-width: 600px; margin: 0 auto; padding: 20px; background-color: #f4f7f6; border-radius: 10px;'>"
                                       + "<div style='background-color: #ffffff; padding: 40px; border-radius: 8px; box-shadow: 0 4px 6px rgba(0,0,0,0.05); text-align: center;'>"
                                       + "<h2 style='color: #2c3e50; margin-top: 0; margin-bottom: 20px;'>Hoàn tất đăng nhập qua Google</h2>"
                                       + "<p style='color: #555555; font-size: 16px; line-height: 1.6; margin-bottom: 30px; text-align: left;'>"
                                       + "Chào <b>" + fullName + "</b>,<br><br>"
                                       + "Cảm ơn bạn đã lựa chọn đăng nhập qua Google tại <b>Japanese Learning</b>. Để hoàn tất việc khởi tạo tài khoản, vui lòng xác nhận email bằng cách nhấn vào nút bên dưới:"
                                       + "</p>"
                                       + "<a href='" + verifyLink + "' style='display: inline-block; padding: 14px 30px; color: #ffffff; background-color: #ea4335; text-decoration: none; border-radius: 6px; font-weight: bold; font-size: 16px; letter-spacing: 0.5px; transition: background-color 0.3s;'>HOÀN TẤT ĐĂNG KÝ</a>"
                                       + "<p style='color: #888888; font-size: 13px; margin-top: 30px; margin-bottom: 0; text-align: left;'>"
                                       + "Nếu nút trên không hoạt động, bạn có thể copy và dán đường dẫn này vào trình duyệt:<br>"
                                       + "<a href='" + verifyLink + "' style='color: #007bff; text-decoration: underline; word-break: break-all;'>" + verifyLink + "</a>"
                                       + "</p>"
                                       + "</div>"
                                       + "<div style='text-align: center; margin-top: 20px; color: #999999; font-size: 12px;'>"
                                       + "Nếu bạn không cố gắng đăng nhập, xin vui lòng bỏ qua email này.<br><br>"
                                       + "&copy; 2026 Japanese Learning Team. All rights reserved."
                                       + "</div>"
                                       + "</div>";
                        
                        com.japaneselearning.utils.EmailUtility.sendEmail(email, subject, content);
                        
                        response.sendRedirect("verify-register.jsp");
                        return;
                    } catch (Exception e) {
                        e.printStackTrace();
                        com.japaneselearning.utils.TokenStore.getInstance().removeUser(token);
                        request.setAttribute("error", "Lỗi khi gửi email xác thực. Vui lòng thử lại sau.");
                        request.getRequestDispatcher("login.jsp").forward(request, response);
                        return;
                    }
                }

                if (user != null) {
                    HttpSession session = request.getSession();
                    session.setAttribute("user", user);

                    // Phân quyền
                    if ("ADMIN".equals(user.getRole())) {
                        response.sendRedirect("admin/home.jsp");
                    } else if (user.getLevel() == 0) {
                        response.sendRedirect("select-level");
                    } else {
                        response.sendRedirect("home.jsp");
                    }
                } else {
                    request.setAttribute("error", "Không thể tạo tài khoản. Vui lòng thử lại!");
                    request.getRequestDispatcher("login.jsp").forward(request, response);
                }
            } else {
                request.setAttribute("error", "Token Google không hợp lệ!");
                request.getRequestDispatcher("login.jsp").forward(request, response);
            }
        } catch (Exception e) {
            e.printStackTrace();
            request.setAttribute("error", "Lỗi xác thực Google: " + e.getMessage());
            request.getRequestDispatcher("login.jsp").forward(request, response);
        }
    }
}