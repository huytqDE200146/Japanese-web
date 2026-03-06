package com.japaneselearning.controller.admin;

import com.japaneselearning.dao.LessonDAO;
import com.japaneselearning.dao.PaymentDAO;
import com.japaneselearning.dao.UserDAO;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import java.io.IOException;

@WebServlet(name = "AdminDashboardServlet", urlPatterns = {"/admin/dashboard"})
public class AdminDashboardServlet extends HttpServlet {

    private UserDAO userDAO = new UserDAO();
    private LessonDAO lessonDAO = new LessonDAO();
    private PaymentDAO paymentDAO = new PaymentDAO();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        
        request.setAttribute("totalUsers", userDAO.getTotalUsers());
        request.setAttribute("totalLessons", lessonDAO.getTotalLessons());
        request.setAttribute("totalRevenue", paymentDAO.getTotalPaymentsAmount());
        
        // Monthly revenue for chart
        java.util.LinkedHashMap<String, Long> monthlyRevenue = paymentDAO.getMonthlyRevenue();
        StringBuilder labels = new StringBuilder("[");
        StringBuilder values = new StringBuilder("[");
        boolean first = true;
        for (java.util.Map.Entry<String, Long> entry : monthlyRevenue.entrySet()) {
            if (!first) { labels.append(","); values.append(","); }
            labels.append("\"").append(entry.getKey()).append("\"");
            values.append(entry.getValue());
            first = false;
        }
        labels.append("]");
        values.append("]");
        request.setAttribute("chartLabels", labels.toString());
        request.setAttribute("chartValues", values.toString());
        
        request.getRequestDispatcher("/admin/home.jsp").forward(request, response);
    }
}
