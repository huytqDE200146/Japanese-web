package com.japaneselearning.controller.admin;

import com.japaneselearning.dao.PaymentDAO;
import com.japaneselearning.dao.UserDAO;
import com.japaneselearning.model.Payment;
import com.japaneselearning.model.User;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import java.io.IOException;
import java.util.List;

@WebServlet(name = "AdminUserServlet", urlPatterns = {"/admin/users"})
public class AdminUserServlet extends HttpServlet {

    private UserDAO userDAO = new UserDAO();
    private PaymentDAO paymentDAO = new PaymentDAO();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        
        List<User> userList = userDAO.getAllUsers();
        request.setAttribute("userList", userList);
        request.getRequestDispatcher("/admin/users.jsp").forward(request, response);
    }
    
    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        
        String action = request.getParameter("action");
        if (action == null) {
            response.sendRedirect(request.getContextPath() + "/admin/users");
            return;
        }

        try {
            int userId = Integer.parseInt(request.getParameter("userId"));
            
            if ("updateRole".equals(action)) {
                String role = request.getParameter("role");
                if ("ADMIN".equals(role) || "USER".equals(role)) {
                    userDAO.updateUserRole(userId, role);
                    request.getSession().setAttribute("msgSuccess", "Cập nhật quyền thành công!");
                }
            } else if ("updateStatus".equals(action)) {
                String status = request.getParameter("status");
                if ("ACTIVE".equals(status) || "BAN".equals(status)) {
                    userDAO.updateUserStatus(userId, status);
                    request.getSession().setAttribute("msgSuccess", "Cập nhật trạng thái thành công!");
                }
            } else if ("togglePremium".equals(action)) {
                String premiumValue = request.getParameter("premium");
                if ("true".equals(premiumValue)) {
                    int days = 30;
                    try { days = Integer.parseInt(request.getParameter("days")); } catch (Exception ignored) {}
                    
                    // Tính amount dựa trên số ngày (giống pricing ở PaymentServlet)
                    int amount;
                    String description;
                    switch (days) {
                        case 90:
                            amount = 249000;
                            description = "Premium 3 Thang (Admin)";
                            break;
                        case 180:
                            amount = 499000;
                            description = "Premium 6 Thang (Admin)";
                            break;
                        case 365:
                            amount = 799000;
                            description = "Premium 1 Nam (Admin)";
                            break;
                        default:
                            amount = 99000;
                            description = "Premium 1 Thang (Admin)";
                    }
                    
                    // Cấp premium
                    userDAO.updatePremiumStatus(userId, true, days);
                    
                    // Tạo payment record đã PAID (tính vào doanh thu)
                    paymentDAO.createPaidPayment(userId, amount, description, "Admin");
                    
                    request.getSession().setAttribute("msgSuccess", "Đã cấp Premium thành công!");
                } else {
                    userDAO.updatePremiumStatus(userId, false, 0);
                    request.getSession().setAttribute("msgSuccess", "Đã huỷ Premium thành công!");
                }
            } else if ("deleteUser".equals(action)) {
                // Không cho xoá chính mình
                User currentUser = (User) request.getSession().getAttribute("user");
                if (currentUser != null && currentUser.getId() == userId) {
                    request.getSession().setAttribute("msgError", "Không thể xoá tài khoản của chính bạn!");
                } else {
                    if (userDAO.deleteUser(userId)) {
                        request.getSession().setAttribute("msgSuccess", "Đã xoá user thành công!");
                    } else {
                        request.getSession().setAttribute("msgError", "Xoá user thất bại!");
                    }
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
            request.getSession().setAttribute("msgError", "Có lỗi xảy ra: " + e.getMessage());
        }

        response.sendRedirect(request.getContextPath() + "/admin/users");
    }
}
