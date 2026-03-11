<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<%@taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt"%>

<jsp:include page="header.jsp" />

<div class="container-fluid">
    <div class="row align-items-center mb-4">
        <div class="col">
            <h2 class="h3 mb-0">Payments History</h2>
        </div>
    </div>

    <div class="card shadow-sm border-0">
        <div class="card-body">
            <div class="table-responsive">
                <table class="table table-hover table-bordered align-middle">
                    <thead class="table-light">
                        <tr>
                            <th>Payment ID</th>
                            <th>Order Code</th>
                            <th>User ID</th>
                            <th>Amount (VND)</th>
                            <th>Description</th>
                            <th>Method</th>
                            <th>Status</th>
                            <th>Created At</th>
                            <th>Paid At</th>
                        </tr>
                    </thead>
                    <tbody>
                        <c:forEach var="p" items="${paymentList}">
                            <tr>
                                <td>${p.paymentId}</td>
                                <td><span class="font-monospace">${p.orderCode}</span></td>
                                <td>${p.userId}</td>
                                <td class="text-end fw-bold">
                                    <fmt:formatNumber value="${p.amount}" pattern="#,###"/> ₫
                                </td>
                                <td>${p.description}</td>
                                <td>${p.paymentMethod}</td>
                                <td>
                                    <c:choose>
                                        <c:when test="${p.status == 'PAID'}">
                                            <span class="badge bg-success">PAID</span>
                                        </c:when>
                                        <c:when test="${p.status == 'PENDING'}">
                                            <span class="badge bg-warning text-dark">PENDING</span>
                                        </c:when>
                                        <c:otherwise>
                                            <span class="badge bg-secondary">${p.status}</span>
                                        </c:otherwise>
                                    </c:choose>
                                </td>
                                <td><fmt:formatDate value="${p.createdAt}" pattern="dd/MM/yyyy HH:mm"/></td>
                                <td>
                                    <c:if test="${not empty p.paidAt}">
                                        <fmt:formatDate value="${p.paidAt}" pattern="dd/MM/yyyy HH:mm"/>
                                    </c:if>
                                </td>
                            </tr>
                        </c:forEach>
                        <c:if test="${empty paymentList}">
                            <tr>
                                <td colspan="9" class="text-center py-4">No payments found.</td>
                            </tr>
                        </c:if>
                    </tbody>
                </table>
            </div>
        </div>
    </div>
</div>

<jsp:include page="footer.jsp" />
