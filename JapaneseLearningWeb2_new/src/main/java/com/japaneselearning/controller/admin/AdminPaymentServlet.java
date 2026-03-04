package com.japaneselearning.controller.admin;

import com.japaneselearning.dao.PaymentDAO;
import com.japaneselearning.model.Payment;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import java.io.IOException;
import java.util.List;

@WebServlet(name = "AdminPaymentServlet", urlPatterns = {"/admin/payments"})
public class AdminPaymentServlet extends HttpServlet {

    private PaymentDAO paymentDAO = new PaymentDAO();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        
        List<Payment> paymentList = paymentDAO.getAllPayments();
        request.setAttribute("paymentList", paymentList);
        request.getRequestDispatcher("/admin/payments.jsp").forward(request, response);
    }
}
