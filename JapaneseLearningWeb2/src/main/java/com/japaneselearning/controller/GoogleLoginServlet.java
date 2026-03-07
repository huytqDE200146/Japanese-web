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

                        String subject = "Xác nhận đăng ký tài khoản qua Google";
                        String content = "Chào " + fullName + ",<br><br>"
                                       + "Cảm ơn bạn đã đăng nhập qua Google tại Japanese Learning.<br>"
                                       + "Để hoàn tất việc tạo tài khoản, vui lòng click vào đường link bên dưới:<br><br>"
                                       + "<a href='" + verifyLink + "' style='display:inline-block;padding:10px 20px;color:#fff;background-color:#007bff;text-decoration:none;border-radius:5px;'>Hoàn Tất Đăng Ký</a><br><br>"
                                       + "Hoặc bạn cũng có thể copy link này vào trình duyệt: <br>" + verifyLink + "<br><br>"
                                       + "Trân trọng,<br>Japanese Learning Team";
                        
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
