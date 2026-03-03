package com.japaneselearning.controller;

import com.japaneselearning.dao.UserDAO;
import com.japaneselearning.model.User;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.Cookie;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

import java.io.IOException;

@WebServlet("/login")
public class LoginServlet extends HttpServlet {

    private static final int COOKIE_MAX_AGE = 7 * 24 * 60 * 60; // 7 ngày

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        // Nếu đã có session → redirect về home
        HttpSession session = request.getSession(false);
        if (session != null && session.getAttribute("user") != null) {
            response.sendRedirect("home.jsp");
            return;
        }

        // Kiểm tra cookie "remember me" → tự động đăng nhập
        String savedUsername = null;
        String savedPassword = null;

        Cookie[] cookies = request.getCookies();
        if (cookies != null) {
            for (Cookie c : cookies) {
                if ("rememberUser".equals(c.getName())) {
                    savedUsername = c.getValue();
                }
                if ("rememberPass".equals(c.getName())) {
                    savedPassword = c.getValue();
                }
            }
        }

        if (savedUsername != null && savedPassword != null) {
            UserDAO dao = new UserDAO();
            User user = dao.login(savedUsername, savedPassword);

            if (user != null) {
                session = request.getSession();
                session.setAttribute("user", user);

                if ("ADMIN".equals(user.getRole())) {
                    response.sendRedirect("admin/home.jsp");
                } else {
                    response.sendRedirect("home.jsp");
                }
                return;
            }
        }

        request.getRequestDispatcher("login.jsp").forward(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        String username = request.getParameter("username");
        String password = request.getParameter("password");
        String remember = request.getParameter("remember");

        UserDAO dao = new UserDAO();
        User user = dao.login(username, password);

        if (user != null) {
            HttpSession session = request.getSession();
            session.setAttribute("user", user);

            // Lưu cookie nếu tick "Ghi nhớ đăng nhập"
            if ("on".equals(remember)) {
                Cookie userCookie = new Cookie("rememberUser", username);
                userCookie.setMaxAge(COOKIE_MAX_AGE);
                userCookie.setPath("/");
                response.addCookie(userCookie);

                Cookie passCookie = new Cookie("rememberPass", password);
                passCookie.setMaxAge(COOKIE_MAX_AGE);
                passCookie.setPath("/");
                response.addCookie(passCookie);
            }

            // Phân quyền
            if ("ADMIN".equals(user.getRole())) {
                response.sendRedirect("admin/home.jsp");
            } else {
                response.sendRedirect("home.jsp");
            }
        } else {
            request.setAttribute("error", "Sai tài khoản hoặc mật khẩu!");
            request.getRequestDispatcher("login.jsp").forward(request, response);
        }
    }
}