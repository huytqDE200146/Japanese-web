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

@WebServlet("/profile")
public class ProfileServlet extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        HttpSession session = request.getSession(false);
        if (session == null || session.getAttribute("user") == null) {
            response.sendRedirect("login");
            return;
        }

        // Refresh user data from DB
        User sessionUser = (User) session.getAttribute("user");
        UserDAO dao = new UserDAO();
        User user = dao.getUserById(sessionUser.getId());

        if (user != null) {
            session.setAttribute("user", user);
            request.setAttribute("profileUser", user);
        }

        request.getRequestDispatcher("profile.jsp").forward(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        HttpSession session = request.getSession(false);
        if (session == null || session.getAttribute("user") == null) {
            response.sendRedirect("login");
            return;
        }

        User sessionUser = (User) session.getAttribute("user");
        String fullName = request.getParameter("fullName");
        String email = request.getParameter("email");
        String password = request.getParameter("password");
        String confirmPassword = request.getParameter("confirmPassword");

        // Validate
        if (fullName == null || fullName.trim().isEmpty() ||
            email == null || email.trim().isEmpty()) {
            request.setAttribute("error", "Họ tên và Email không được để trống!");
            request.setAttribute("profileUser", sessionUser);
            request.getRequestDispatcher("profile.jsp").forward(request, response);
            return;
        }

        // Password validation (only if changing)
        if (password != null && !password.trim().isEmpty()) {
            if (password.length() < 6) {
                request.setAttribute("error", "Mật khẩu mới phải có ít nhất 6 ký tự!");
                request.setAttribute("profileUser", sessionUser);
                request.getRequestDispatcher("profile.jsp").forward(request, response);
                return;
            }
            if (!password.equals(confirmPassword)) {
                request.setAttribute("error", "Mật khẩu xác nhận không khớp!");
                request.setAttribute("profileUser", sessionUser);
                request.getRequestDispatcher("profile.jsp").forward(request, response);
                return;
            }
        }

        UserDAO dao = new UserDAO();
        boolean success = dao.updateProfile(
            sessionUser.getId(),
            fullName.trim(),
            email.trim(),
            (password != null && !password.trim().isEmpty()) ? password : null
        );

        if (success) {
            // Refresh session user
            User updatedUser = dao.getUserById(sessionUser.getId());
            session.setAttribute("user", updatedUser);
            request.setAttribute("profileUser", updatedUser);
            request.setAttribute("success", "Cập nhật thông tin thành công!");
        } else {
            request.setAttribute("profileUser", sessionUser);
            request.setAttribute("error", "Cập nhật thất bại. Vui lòng thử lại!");
        }

        request.getRequestDispatcher("profile.jsp").forward(request, response);
    }
}
