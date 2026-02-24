package com.japaneselearning.controller;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.Cookie;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

import java.io.IOException;

@WebServlet("/logout")
public class LogoutServlet extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        // 1. Hủy session
        HttpSession session = request.getSession(false);
        if (session != null) {
            session.invalidate();
        }

        // 2. Xóa cookie "remember me"
        Cookie userCookie = new Cookie("rememberUser", "");
        userCookie.setMaxAge(0); // Xóa ngay
        userCookie.setPath("/");
        response.addCookie(userCookie);

        Cookie passCookie = new Cookie("rememberPass", "");
        passCookie.setMaxAge(0);
        passCookie.setPath("/");
        response.addCookie(passCookie);

        // 3. Redirect về trang login
        response.sendRedirect("login");
    }
}
