package com.japaneselearning.controller;

import com.japaneselearning.dao.UserDAO;
import com.japaneselearning.model.User;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

import java.io.IOException;

@WebServlet("/verify-register")
public class VerifyRegisterServlet extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        
        String token = request.getParameter("token");
        
        if (token != null && !token.trim().isEmpty()) {
            User user = com.japaneselearning.utils.TokenStore.getInstance().getUser(token);
            
            if (user != null) {
                UserDAO dao = new UserDAO();
                boolean success;
                
                if (user.getGoogleId() != null && !user.getGoogleId().isEmpty()) {
                    // Đăng ký cho người dùng Google
                    User registeredUser = dao.registerGoogleUser(user.getGoogleId(), user.getEmail(), user.getFullName());
                    success = (registeredUser != null);
                } else {
                    // Đăng ký bình thường
                    success = dao.register(user);
                }

                if (success) {
                    com.japaneselearning.utils.TokenStore.getInstance().removeUser(token);
                    request.setAttribute("success", "Xác thực thành công! Vui lòng đăng nhập.");
                    request.getRequestDispatcher("login.jsp").forward(request, response);
                } else {
                    request.setAttribute("error", "Đăng ký vào database thất bại. Vui lòng thử lại!");
                    request.getRequestDispatcher("login.jsp").forward(request, response);
                }
            } else {
                request.setAttribute("error", "Link xác thực không hợp lệ hoặc đã hết hạn!");
                request.getRequestDispatcher("login.jsp").forward(request, response);
            }
        } else {
            // Nếu không có token, hiển thị trang thông báo yêu cầu kiểm tra email
            request.getRequestDispatcher("verify-register.jsp").forward(request, response);
        }
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        doGet(request, response);
    }
}
