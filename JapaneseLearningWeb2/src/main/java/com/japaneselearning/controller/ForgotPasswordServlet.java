package com.japaneselearning.controller;

import com.japaneselearning.dao.UserDAO;
import com.japaneselearning.model.User;
import com.japaneselearning.utils.EmailUtility;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

import java.io.IOException;
import java.util.Random;

@WebServlet("/forgot-password")
public class ForgotPasswordServlet extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        request.getRequestDispatcher("forgot-password.jsp").forward(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        
        String email = request.getParameter("email");
        
        if (email == null || email.trim().isEmpty()) {
            request.setAttribute("error", "Vui lòng nhập email!");
            request.getRequestDispatcher("forgot-password.jsp").forward(request, response);
            return;
        }

        UserDAO dao = new UserDAO();
        User user = dao.findByEmail(email.trim());

        if (user == null) {
            request.setAttribute("error", "Email không tồn tại trong hệ thống!");
            request.getRequestDispatcher("forgot-password.jsp").forward(request, response);
            return;
        }

        // Tạo mã OTP 6 số
        String otp = String.format("%06d", new Random().nextInt(999999));
        
        // Lưu email và OTP vào session
        HttpSession session = request.getSession();
        session.setAttribute("resetEmail", email.trim());
        session.setAttribute("resetOTP", otp);
        
        // Gửi email
        try {
            String subject = "Mã xác thực khôi phục mật khẩu";
            String content = "Chào " + user.getFullName() + ",<br><br>"
                           + "Bạn đã yêu cầu khôi phục mật khẩu. Mã xác thực (OTP) của bạn là: <b><span style='font-size: 24px; color: #dc3545;'>" + otp + "</span></b><br><br>"
                           + "Vui lòng nhập mã này cùng với mật khẩu mới để đặt lại mật khẩu của bạn.<br>"
                           + "Nếu bạn không yêu cầu khôi phục mật khẩu, vui lòng bỏ qua email này.<br><br>"
                           + "Trân trọng,<br>Japanese Learning Team";
            EmailUtility.sendEmail(email.trim(), subject, content);
            
            response.sendRedirect("verify-forgot-otp.jsp");
        } catch (Exception e) {
            e.printStackTrace();
            request.setAttribute("error", "Lỗi khi gửi email xác thực. Vui lòng thử lại sau.");
            request.getRequestDispatcher("forgot-password.jsp").forward(request, response);
        }
    }
}
