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
            String subject = "Yêu cầu khôi phục mật khẩu - Japanese Learning";
            String content = "<div style='font-family: Arial, sans-serif; max-width: 600px; margin: 0 auto; padding: 20px; background-color: #f4f7f6; border-radius: 10px;'>"
                           + "<div style='background-color: #ffffff; padding: 40px; border-radius: 8px; box-shadow: 0 4px 6px rgba(0,0,0,0.05); text-align: center;'>"
                           + "<h2 style='color: #2c3e50; margin-top: 0; margin-bottom: 20px;'>Mã xác nhận quên mật khẩu</h2>"
                           + "<p style='color: #555555; font-size: 16px; line-height: 1.6; margin-bottom: 30px; text-align: left;'>"
                           + "Chào <b>" + user.getFullName() + "</b>,<br><br>"
                           + "Chúng tôi nhận được yêu cầu khôi phục mật khẩu cho tài khoản của bạn tại <b>Japanese Learning</b>. Dưới đây là mã OTP của bạn:"
                           + "</p>"
                           + "<div style='background-color: #f8f9fa; border: 1px dashed #ced4da; border-radius: 8px; padding: 20px; margin: 30px 0;'>"
                           + "<span style='font-size: 36px; font-weight: bold; color: #dc3545; letter-spacing: 8px;'>" + otp + "</span>"
                           + "</div>"
                           + "<p style='color: #555555; font-size: 15px; margin-top: 30px; margin-bottom: 0; text-align: left;'>"
                           + "Vui lòng nhập mã này vào trang xác thực để lấy lại quyền truy cập thẻ."
                           + "</p>"
                           + "</div>"
                           + "<div style='text-align: center; margin-top: 20px; color: #999999; font-size: 12px;'>"
                           + "Nếu bạn không hề gửi yêu cầu này, vui lòng bỏ qua email và kiểm tra lại bảo mật tài khoản.<br><br>"
                           + "&copy; 2026 Japanese Learning Team. All rights reserved."
                           + "</div>"
                           + "</div>";
            EmailUtility.sendEmail(email.trim(), subject, content);
            
            response.sendRedirect("verify-forgot-otp.jsp");
        } catch (Exception e) {
            e.printStackTrace();
            request.setAttribute("error", "Lỗi khi gửi email xác thực. Vui lòng thử lại sau.");
            request.getRequestDispatcher("forgot-password.jsp").forward(request, response);
        }
    }
}
