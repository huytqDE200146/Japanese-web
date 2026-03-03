<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<%@taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt"%>

<%-- Nếu truy cập trực tiếp (không qua servlet), redirect sang /admin/dashboard --%>
<%
    if (request.getAttribute("chartLabels") == null) {
        response.sendRedirect(request.getContextPath() + "/admin/dashboard");
        return;
    }
%>

<jsp:include page="header.jsp" />

<div class="container-fluid">
    <div class="row mb-4">
        <div class="col-12">
            <h2>Dashboard Overview</h2>
            <p class="text-muted">Welcome to the Japanese Learning Platform administration panel.</p>
        </div>
    </div>

    <!-- Statistics Cards -->
    <div class="row g-4 mb-4">
        <!-- Total Users -->
        <div class="col-12 col-md-4">
            <div class="card border-0 shadow-sm h-100">
                <div class="card-body d-flex align-items-center">
                    <div class="flex-shrink-0 me-3">
                        <div class="bg-primary bg-opacity-10 p-3 rounded">
                            <i class="fa-solid fa-users fa-2x text-primary"></i>
                        </div>
                    </div>
                    <div class="flex-grow-1">
                        <h6 class="text-muted mb-1">Total Users</h6>
                        <h3 class="mb-0 fw-bold">${totalUsers}</h3>
                    </div>
                </div>
            </div>
        </div>

        <!-- Total Lessons -->
        <div class="col-12 col-md-4">
            <div class="card border-0 shadow-sm h-100">
                <div class="card-body d-flex align-items-center">
                    <div class="flex-shrink-0 me-3">
                        <div class="bg-success bg-opacity-10 p-3 rounded">
                            <i class="fa-solid fa-book-open fa-2x text-success"></i>
                        </div>
                    </div>
                    <div class="flex-grow-1">
                        <h6 class="text-muted mb-1">Total Lessons</h6>
                        <h3 class="mb-0 fw-bold">${totalLessons}</h3>
                    </div>
                </div>
            </div>
        </div>

        <!-- Total Revenue -->
        <div class="col-12 col-md-4">
            <div class="card border-0 shadow-sm h-100">
                <div class="card-body d-flex align-items-center">
                    <div class="flex-shrink-0 me-3">
                        <div class="bg-warning bg-opacity-10 p-3 rounded">
                            <i class="fa-solid fa-coins fa-2x text-warning"></i>
                        </div>
                    </div>
                    <div class="flex-grow-1">
                        <h6 class="text-muted mb-1">Total Premium Revenue</h6>
                        <h3 class="mb-0 fw-bold">
                            <fmt:formatNumber value="${totalRevenue}" pattern="#,###"/> ₫
                        </h3>
                    </div>
                </div>
            </div>
        </div>
    </div>

    <div class="row">
        <div class="col-12 col-lg-8">
            <div class="card border-0 shadow-sm">
                <div class="card-header bg-white py-3">
                    <h5 class="card-title mb-0 fw-bold"><i class="fa-solid fa-chart-bar text-primary me-2"></i>Doanh thu theo tháng</h5>
                </div>
                <div class="card-body">
                    <canvas id="revenueChart" height="300"></canvas>
                </div>
            </div>
        </div>
        <div class="col-12 col-lg-4">
            <div class="card border-0 shadow-sm h-100">
                <div class="card-header bg-white py-3">
                    <h5 class="card-title mb-0 fw-bold">System Information</h5>
                </div>
                <div class="card-body">
                    <p>This panel allows you to manage the core modules of the Japanese Learning Web application.</p>
                    <ul>
                        <li><strong>Users Management:</strong> Change user roles to grant admin privileges or ban violating users.</li>
                        <li><strong>Lessons:</strong> Create new lessons, view and update existing content paths.</li>
                        <li><strong>Payments:</strong> View the detailed history of every premium subscription transaction.</li>
                    </ul>
                </div>
            </div>
        </div>
    </div>
</div>

<script src="https://cdn.jsdelivr.net/npm/chart.js@4.4.0/dist/chart.umd.min.js"></script>
<script>
    const ctx = document.getElementById('revenueChart').getContext('2d');
    const gradient = ctx.createLinearGradient(0, 0, 0, 300);
    gradient.addColorStop(0, 'rgba(13, 110, 253, 0.8)');
    gradient.addColorStop(1, 'rgba(13, 110, 253, 0.1)');
    
    new Chart(ctx, {
        type: 'bar',
        data: {
            labels: ${chartLabels},
            datasets: [{
                label: 'Doanh thu (VNĐ)',
                data: ${chartValues},
                backgroundColor: gradient,
                borderColor: 'rgba(13, 110, 253, 1)',
                borderWidth: 2,
                borderRadius: 8,
                borderSkipped: false
            }]
        },
        options: {
            responsive: true,
            maintainAspectRatio: false,
            plugins: {
                legend: { display: false },
                tooltip: {
                    callbacks: {
                        label: function(context) {
                            return new Intl.NumberFormat('vi-VN').format(context.raw) + ' ₫';
                        }
                    }
                }
            },
            scales: {
                y: {
                    beginAtZero: true,
                    ticks: {
                        callback: function(value) {
                            return new Intl.NumberFormat('vi-VN').format(value) + ' ₫';
                        }
                    },
                    grid: { color: 'rgba(0,0,0,0.05)' }
                },
                x: {
                    grid: { display: false }
                }
            }
        }
    });
</script>

<jsp:include page="footer.jsp" />
