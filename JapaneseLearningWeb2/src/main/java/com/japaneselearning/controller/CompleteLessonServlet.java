package com.japaneselearning.controller;

import com.japaneselearning.dao.LessonDAO;
import com.japaneselearning.dao.ProgressDAO;
import com.japaneselearning.dao.UserDAO;
import com.japaneselearning.model.Progress;
import com.japaneselearning.model.User;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;
import java.io.IOException;

@WebServlet("/complete-lesson")
public class CompleteLessonServlet extends HttpServlet {

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        HttpSession session = request.getSession(false);
        if (session == null || session.getAttribute("user") == null) {
            response.sendRedirect("login.jsp");
            return;
        }

        User user = (User) session.getAttribute("user");
        int userId = user.getId();
        int lessonId = 0;

        try {
            lessonId = Integer.parseInt(request.getParameter("lessonId"));
            System.out.println("DEBUG - Nhận lessonId: " + lessonId);
        } catch (Exception e) {
            System.out.println("DEBUG - Lỗi parse lessonId");
            response.sendRedirect("lessons");
            return;
        }

        LessonDAO lessonDAO = new LessonDAO();
        ProgressDAO progressDAO = new ProgressDAO();

        boolean inserted = lessonDAO.markLessonCompleted(userId, lessonId);
        System.out.println("DEBUG - Kết quả insert: " + inserted);

        if (inserted) {
            Progress progress = progressDAO.getProgressByUserId(userId);
            if (progress != null) {
                progress.setTotalLessons(progress.getTotalLessons() + 1);
                progressDAO.calculateStreak(progress);
                progressDAO.updateProgress(progress);
            }

            int currentLevel = user.getLevel(); 
            if (currentLevel > 1) { 
                String levelStr = "N" + currentLevel; 
                int completedInLevel = progressDAO.countCompletedLessonsByLevel(userId, levelStr);
                int totalInLevel = progressDAO.countTotalLessonsByLevel(levelStr);

                System.out.println("DEBUG - Level Target: " + levelStr + " | Đã học: " + completedInLevel + " / Tổng: " + totalInLevel);

                if (totalInLevel > 0 && completedInLevel >= totalInLevel) {
                    int newLevel = currentLevel - 1; 
                    UserDAO userDAO = new UserDAO();
                    
                    if (userDAO.updateUserLevel(userId, newLevel)) {
                        user.setLevel(newLevel); 
                        session.setAttribute("user", user);
                        session.setAttribute("levelUpMessage", "🎉 Chúc mừng! Bạn đã hoàn thành " + levelStr + " và mở khóa cấp độ N" + newLevel + "!");
                        System.out.println("DEBUG - Đã thăng cấp thành công lên N" + newLevel);
                    }
                }
            }
        }

        response.sendRedirect("lessons");
    }
}