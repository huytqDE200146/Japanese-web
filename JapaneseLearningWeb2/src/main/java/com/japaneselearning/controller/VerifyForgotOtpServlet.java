package com.japaneselearning.controller;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

import java.io.IOException;

@WebServlet("/verify-forgot-otp")
public class VerifyForgotOtpServlet extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        request.getRequestDispatcher("verify-forgot-otp.jsp").forward(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        
        String otpInput = request.getParameter("otp");
        
        HttpSession session = request.getSession();
        String sessionEmail = (String) session.getAttribute("resetEmail");
        String sessionOtp = (String) session.getAttribute("resetOTP");

        if (sessionEmail == null || sessionOtp == null) {
            request.setAttribute("error", "Phiên khôi phục đã hết hạn. Vui lòng yêu cầu lại!");
            request.getRequestDispatcher("forgot-password.jsp").forward(request, response);
            return;
        }

        if (otpInput != null && otpInput.trim().equals(sessionOtp)) {
            // OTP is correct. Set a flag in session to indicate OTP is verified.
            session.setAttribute("isOtpVerified", true);
            response.sendRedirect("reset-password.jsp");
        } else {
            request.setAttribute("error", "Mã xác thực không đúng!");
            request.getRequestDispatcher("verify-forgot-otp.jsp").forward(request, response);
        }
    }
}
