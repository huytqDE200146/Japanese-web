package com.japaneselearning.controller;

import com.japaneselearning.dao.UserDAO;
import com.japaneselearning.model.User;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import java.io.IOException;

@WebServlet("/register")
public class RegisterServlet extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        request.getRequestDispatcher("register.jsp").forward(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        String username = request.getParameter("username");
        String password = request.getParameter("password");
        String confirmPassword = request.getParameter("confirmPassword");
        String email = request.getParameter("email");
        String fullName = request.getParameter("fullName");

        // Validate đầu vào
        if (username == null || username.trim().isEmpty() ||
            password == null || password.trim().isEmpty() ||
            email == null || email.trim().isEmpty() ||
            fullName == null || fullName.trim().isEmpty()) {
            request.setAttribute("error", "Vui lòng điền đầy đủ thông tin!");
            request.getRequestDispatcher("register.jsp").forward(request, response);
            return;
        }

        // Logic bảo mật mật khẩu (Yêu cầu 8 ký tự, có số, chữ hoa, chữ thường)
        if (password.length() < 8 || !password.matches(".*\\d.*") || !password.matches(".*[a-z].*") || !password.matches(".*[A-Z].*")) {
            request.setAttribute("error", "Mật khẩu chưa đáp ứng yêu cầu bảo mật (tối thiểu 8 ký tự, gồm chữ hoa, chữ thường và số)!");
            request.getRequestDispatcher("register.jsp").forward(request, response);
            return;
        }

        if (!password.equals(confirmPassword)) {
            request.setAttribute("error", "Mật khẩu xác nhận không khớp!");
            request.getRequestDispatcher("register.jsp").forward(request, response);
            return;
        }

        UserDAO dao = new UserDAO();

        if (dao.isUsernameExist(username.trim())) {
            request.setAttribute("error", "Tên đăng nhập đã tồn tại!");
            request.getRequestDispatcher("register.jsp").forward(request, response);
            return;
        }

        if (dao.isEmailExist(email.trim())) {
            request.setAttribute("error", "Email đã được sử dụng!");
            request.getRequestDispatcher("register.jsp").forward(request, response);
            return;
        }

        User user = new User(username.trim(), password, email.trim(), fullName.trim());
        
        // Tạo Token để xác thực qua email
        String token = java.util.UUID.randomUUID().toString();
        
        // Lưu thông tin tạm thời vào TokenStore
        com.japaneselearning.utils.TokenStore.getInstance().storeUser(token, user);
        
        try {
            // Dựng link xác thực hỗ trợ Reverse Proxy (như Render)
            String contextPath = request.getContextPath();
            String appBaseUrl;
            
            String forwardedHost = request.getHeader("X-Forwarded-Host");
            if (forwardedHost != null) {
                // Đang chạy sau reverse proxy (Render) → luôn dùng https, không thêm port
                appBaseUrl = "https://" + forwardedHost + contextPath;
            } else {
                // Chạy local
                String scheme = request.getScheme();
                int serverPort = request.getServerPort();
                String serverName = request.getServerName();
                if (("http".equals(scheme) && serverPort == 80) || ("https".equals(scheme) && serverPort == 443)) {
                    appBaseUrl = scheme + "://" + serverName + contextPath;
                } else {
                    appBaseUrl = scheme + "://" + serverName + ":" + serverPort + contextPath;
                }
            }
            
            String verifyLink = appBaseUrl + "/verify-register?token=" + token;

            String subject = "Xác nhận đăng ký tài khoản - Japanese Learning";
            String content = "<div style='font-family: Arial, sans-serif; max-width: 600px; margin: 0 auto; padding: 20px; background-color: #f4f7f6; border-radius: 10px;'>"
                           + "<div style='background-color: #ffffff; padding: 40px; border-radius: 8px; box-shadow: 0 4px 6px rgba(0,0,0,0.05); text-align: center;'>"
                           + "<h2 style='color: #2c3e50; margin-top: 0; margin-bottom: 20px;'>Xác nhận tài khoản của bạn</h2>"
                           + "<p style='color: #555555; font-size: 16px; line-height: 1.6; margin-bottom: 30px; text-align: left;'>"
                           + "Chào <b>" + user.getFullName() + "</b>,<br><br>"
                           + "Cảm ơn bạn đã tham gia khóa học tại <b>Japanese Learning</b>. Để hoàn tất quá trình đăng ký, vui lòng xác nhận địa chỉ email của bạn bằng cách nhấn vào nút bên dưới:"
                           + "</p>"
                           + "<a href='" + verifyLink + "' style='display: inline-block; padding: 14px 30px; color: #ffffff; background-color: #007bff; text-decoration: none; border-radius: 6px; font-weight: bold; font-size: 16px; letter-spacing: 0.5px; transition: background-color 0.3s;'>XÁC THỰC EMAIL</a>"
                           + "<p style='color: #888888; font-size: 13px; margin-top: 30px; margin-bottom: 0; text-align: left;'>"
                           + "Nếu nút trên không hoạt động, bạn có thể copy và dán đường dẫn này vào trình duyệt:<br>"
                           + "<a href='" + verifyLink + "' style='color: #007bff; text-decoration: underline; word-break: break-all;'>" + verifyLink + "</a>"
                           + "</p>"
                           + "</div>"
                           + "<div style='text-align: center; margin-top: 20px; color: #999999; font-size: 12px;'>"
                           + "Nếu bạn không thực hiện yêu cầu này, vui lòng bỏ qua email này.<br><br>"
                           + "&copy; 2026 Japanese Learning Team. All rights reserved."
                           + "</div>"
                           + "</div>";
            
            com.japaneselearning.utils.EmailUtility.sendEmail(user.getEmail(), subject, content);
            
            // Xóa session OTP cũ nếu có để dọn dẹp
            jakarta.servlet.http.HttpSession session = request.getSession();
            session.removeAttribute("registerUser");
            session.removeAttribute("registerOTP");

            response.sendRedirect("verify-register.jsp");
        } catch (Exception e) {
            e.printStackTrace();
            com.japaneselearning.utils.TokenStore.getInstance().removeUser(token);
            request.setAttribute("error", "Lỗi khi gửi email xác thực. Vui lòng thử lại sau.");
            request.getRequestDispatcher("register.jsp").forward(request, response);
        }
    }
}