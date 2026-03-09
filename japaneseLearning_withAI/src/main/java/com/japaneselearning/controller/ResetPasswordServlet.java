package com.japaneselearning.controller;

import com.japaneselearning.dao.UserDAO;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

import java.io.IOException;

@WebServlet("/reset-password")
public class ResetPasswordServlet extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        request.getRequestDispatcher("reset-password.jsp").forward(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        
        String newPassword = request.getParameter("newPassword");
        
        HttpSession session = request.getSession();
        String sessionEmail = (String) session.getAttribute("resetEmail");
        Boolean isOtpVerified = (Boolean) session.getAttribute("isOtpVerified");

        if (sessionEmail == null || isOtpVerified == null || !isOtpVerified) {
            request.setAttribute("error", "Phiên khôi phục không hợp lệ hoặc đã hết hạn!");
            request.getRequestDispatcher("forgot-password.jsp").forward(request, response);
            return;
        }

        UserDAO dao = new UserDAO();
        boolean success = dao.updatePasswordByEmail(sessionEmail, newPassword);

        if (success) {
            session.removeAttribute("resetEmail");
            session.removeAttribute("resetOTP");
            session.removeAttribute("isOtpVerified");
            request.setAttribute("success", "Đổi mật khẩu thành công! Vui lòng đăng nhập bằng mật khẩu mới.");
            request.getRequestDispatcher("login.jsp").forward(request, response);
        } else {
            request.setAttribute("error", "Đổi mật khẩu thất bại. Vui lòng thử lại!");
            request.getRequestDispatcher("reset-password.jsp").forward(request, response);
        }
    }
}
