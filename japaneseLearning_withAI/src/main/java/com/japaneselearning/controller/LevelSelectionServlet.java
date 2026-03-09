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

@WebServlet("/select-level")
public class LevelSelectionServlet extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        HttpSession session = request.getSession(false);
        if (session == null || session.getAttribute("user") == null) {
            response.sendRedirect("login.jsp");
            return;
        }

        request.getRequestDispatcher("select-level.jsp").forward(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        HttpSession session = request.getSession(false);
        if (session == null || session.getAttribute("user") == null) {
            response.sendRedirect("login.jsp");
            return;
        }

        User user = (User) session.getAttribute("user");
        String levelParam = request.getParameter("level");

        if (levelParam != null && !levelParam.isEmpty()) {
            try {
                int level = Integer.parseInt(levelParam);
                // Validate level (1-5 for N1-N5)
                if (level >= 1 && level <= 5) {
                    UserDAO dao = new UserDAO();
                    boolean updated = dao.updateUserLevel(user.getId(), level);

                    if (updated) {
                        user.setLevel(level);
                        session.setAttribute("user", user);
                    }
                }
            } catch (NumberFormatException e) {
                e.printStackTrace();
            }
        }

        response.sendRedirect("home.jsp");
    }
}
