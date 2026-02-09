package com.japaneselearning.controller;

import com.japaneselearning.dao.PaymentDAO;
import com.japaneselearning.dao.UserDAO;
import com.japaneselearning.model.Payment;
import com.japaneselearning.model.User;
import com.japaneselearning.service.PayOSService;
import vn.payos.type.CheckoutResponseData;
import vn.payos.type.PaymentLinkData;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

import java.io.IOException;

@WebServlet(name = "PaymentServlet", urlPatterns = {"/createPayment", "/paymentSuccess", "/paymentCancel"})
public class PaymentServlet extends HttpServlet {
    
    private PayOSService payOSService;
    private PaymentDAO paymentDAO;
    private UserDAO userDAO;
    
    @Override
    public void init() throws ServletException {
        payOSService = PayOSService.getInstance();
        paymentDAO = new PaymentDAO();
        userDAO = new UserDAO();
    }
    
    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        
        String path = request.getServletPath();
        HttpSession session = request.getSession();
        User user = (User) session.getAttribute("user");
        
        // Require login
        if (user == null) {
            response.sendRedirect("login.jsp");
            return;
        }
        
        switch (path) {
            case "/paymentSuccess":
                handlePaymentSuccess(request, response, user);
                break;
            case "/paymentCancel":
                handlePaymentCancel(request, response);
                break;
            default:
                response.sendRedirect("home.jsp");
        }
    }
    
    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        
        String path = request.getServletPath();
        HttpSession session = request.getSession();
        User user = (User) session.getAttribute("user");
        
        if (user == null) {
            response.sendRedirect("login.jsp");
            return;
        }
        
        if ("/createPayment".equals(path)) {
            createPayment(request, response, user);
        }
    }
    
    /**
     * Hiển thị trang Premium
     */
    private void showPremiumPage(HttpServletRequest request, HttpServletResponse response, User user) 
            throws ServletException, IOException {
        
        // Refresh user data để lấy Premium status mới nhất
        User refreshedUser = userDAO.getUserById(user.getId());
        if (refreshedUser != null) {
            request.getSession().setAttribute("user", refreshedUser);
        }
        
        // Use redirect instead of forward to avoid path issues
        response.sendRedirect(request.getContextPath() + "/premium.jsp");
    }
    
    /**
     * Tạo thanh toán mới
     */
    private void createPayment(HttpServletRequest request, HttpServletResponse response, User user) 
            throws IOException {
        
        try {
            // Lấy gói từ request (mặc định gói 1 tháng)
            String planParam = request.getParameter("plan");
            int amount;
            int days;
            String description;
            
            switch (planParam != null ? planParam : "1month") {
                case "3months":
                    amount = 249000;
                    days = 90;
                    description = "Premium 3 Thang";
                    break;
                case "1year":
                    amount = 799000;
                    days = 365;
                    description = "Premium 1 Nam";
                    break;
                default: // 1month
                    amount = 99000;
                    days = 30;
                    description = "Premium 1 Thang";
            }
            
            // Generate unique order code
            long orderCode = PayOSService.generateOrderCode();
            
            // Tạo payment link từ PayOS - dùng method trả về URL trực tiếp
            String checkoutUrl = payOSService.createPaymentLinkUrl(orderCode, amount, description);
            
            if (checkoutUrl == null) {
                request.getSession().setAttribute("error", "Không thể tạo link thanh toán. Vui lòng thử lại.");
                response.sendRedirect("premium.jsp");
                return;
            }
            
            // Lưu payment record vào DB
            Payment payment = new Payment(user.getId(), orderCode, amount, description);
            payment.setCheckoutUrl(checkoutUrl);
            paymentDAO.createPayment(payment);
            
            // Lưu orderCode vào session để verify sau
            request.getSession().setAttribute("pendingOrderCode", orderCode);
            request.getSession().setAttribute("pendingDays", days);
            
            // Redirect đến trang thanh toán PayOS
            response.sendRedirect(checkoutUrl);
            
        } catch (Exception e) {
            e.printStackTrace();
            request.getSession().setAttribute("error", "Lỗi hệ thống: " + e.getMessage());
            response.sendRedirect("premium.jsp");
        }
    }
    
    /**
     * Xử lý callback thành công từ PayOS
     */
    private void handlePaymentSuccess(HttpServletRequest request, HttpServletResponse response, User user) 
            throws ServletException, IOException {
        
        try {
            // Lấy orderCode từ query params
            String orderCodeParam = request.getParameter("orderCode");
            
            if (orderCodeParam == null) {
                request.setAttribute("error", "Không tìm thấy mã đơn hàng");
                request.getRequestDispatcher("/payment-result.jsp").forward(request, response);
                return;
            }
            
            long orderCode = Long.parseLong(orderCodeParam);
            
            // Verify với PayOS
            PaymentLinkData paymentInfo = payOSService.getPaymentInfo(orderCode);
            
            if (paymentInfo != null && "PAID".equals(paymentInfo.getStatus())) {
                // Lấy payment từ DB
                Payment payment = paymentDAO.getPaymentByOrderCode(orderCode);
                
                if (payment != null && !payment.isPaid()) {
                    // Cập nhật payment status
                    paymentDAO.updatePaymentStatus(orderCode, Payment.STATUS_PAID, "PayOS");
                    
                    // Xác định số ngày Premium
                    int days = 30; // default
                    Integer pendingDays = (Integer) request.getSession().getAttribute("pendingDays");
                    if (pendingDays != null) {
                        days = pendingDays;
                    }
                    
                    // Nâng cấp user lên Premium
                    userDAO.upgradeToPremium(user.getId(), days);
                    
                    // Refresh session user
                    User updatedUser = userDAO.getUserById(user.getId());
                    request.getSession().setAttribute("user", updatedUser);
                    
                    // Clear pending data
                    request.getSession().removeAttribute("pendingOrderCode");
                    request.getSession().removeAttribute("pendingDays");
                }
                
                request.setAttribute("success", true);
                request.setAttribute("message", "Thanh toán thành công! Bạn đã được nâng cấp lên Premium.");
            } else {
                request.setAttribute("success", false);
                request.setAttribute("message", "Thanh toán chưa hoàn tất. Vui lòng kiểm tra lại.");
            }
            
        } catch (Exception e) {
            e.printStackTrace();
            request.setAttribute("success", false);
            request.setAttribute("message", "Lỗi xử lý thanh toán: " + e.getMessage());
        }
        
        request.getRequestDispatcher("/payment-result.jsp").forward(request, response);
    }
    
    /**
     * Xử lý callback hủy từ PayOS
     */
    private void handlePaymentCancel(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        
        String orderCodeParam = request.getParameter("orderCode");
        
        if (orderCodeParam != null) {
            try {
                long orderCode = Long.parseLong(orderCodeParam);
                paymentDAO.updatePaymentStatus(orderCode, Payment.STATUS_CANCELLED, null);
            } catch (Exception e) {
                e.printStackTrace();
            }
        }
        
        request.setAttribute("success", false);
        request.setAttribute("message", "Bạn đã hủy thanh toán.");
        request.getRequestDispatcher("/payment-result.jsp").forward(request, response);
    }
}
