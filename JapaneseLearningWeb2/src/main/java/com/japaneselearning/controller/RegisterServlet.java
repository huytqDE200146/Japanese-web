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

        // Validate
        if (username == null || username.trim().isEmpty() ||
            password == null || password.trim().isEmpty() ||
            email == null || email.trim().isEmpty() ||
            fullName == null || fullName.trim().isEmpty()) {
            request.setAttribute("error", "Vui lòng điền đầy đủ thông tin!");
            request.getRequestDispatcher("register.jsp").forward(request, response);
            return;
        }

        if (password.length() < 8 || !password.matches(".*\\d.*") || !password.matches(".*[a-z].*") || !password.matches(".*[A-Z].*")) {
            request.setAttribute("error", "Mật khẩu chưa đáp ứng yêu cầu bảo mật!");
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
        
        // Generate Token
        String token = java.util.UUID.randomUUID().toString();
        
        // Save to TokenStore
        com.japaneselearning.utils.TokenStore.getInstance().storeUser(token, user);
        
        // Send email
        try {
            // Dựng URL tuyệt đối cho website dựa theo request hiện tại
            String scheme = request.getScheme(); 
            String serverName = request.getServerName();
            int serverPort = request.getServerPort();
            String contextPath = request.getContextPath();
            String appBaseUrl = scheme + "://" + serverName + ":" + serverPort + contextPath;
            String verifyLink = appBaseUrl + "/verify-register?token=" + token;

            String subject = "Xác nhận đăng ký tài khoản";
            String content = "Chào " + user.getFullName() + ",<br><br>"
                           + "Cảm ơn bạn đã đăng ký tài khoản tại Japanese Learning.<br>"
                           + "Vui lòng click vào đường link bên dưới để xác thực email và kích hoạt tài khoản của bạn:<br><br>"
                           + "<a href='" + verifyLink + "' style='display:inline-block;padding:10px 20px;color:#fff;background-color:#007bff;text-decoration:none;border-radius:5px;'>Xác Thực Tài Khoản</a><br><br>"
                           + "Hoặc bạn cũng có thể copy link này vào trình duyệt: <br>" + verifyLink + "<br><br>"
                           + "Trân trọng,<br>Japanese Learning Team";
            com.japaneselearning.utils.EmailUtility.sendEmail(user.getEmail(), subject, content);
            
            // Xóa session OTP cũ nếu có
            jakarta.servlet.http.HttpSession session = request.getSession();
            session.removeAttribute("registerUser");
            session.removeAttribute("registerOTP");

            response.sendRedirect("verify-register.jsp");
        } catch (Exception e) {
            e.printStackTrace();
            // Xóa token nếu gửi mail lỗi
            com.japaneselearning.utils.TokenStore.getInstance().removeUser(token);
            request.setAttribute("error", "Lỗi khi gửi email xác thực. Vui lòng kiểm tra lại email hoặc thử lại sau.");
            request.getRequestDispatcher("register.jsp").forward(request, response);
        }
    }
}
