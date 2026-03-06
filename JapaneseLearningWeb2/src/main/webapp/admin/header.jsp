<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Admin Dashboard - Japanese Learning</title>
    <!-- Bootstrap 5 CSS -->
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet">
    <link href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.0.0/css/all.min.css" rel="stylesheet">
    <style>
        body { font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif; background-color: #f8f9fa; }
        .sidebar { min-height: 100vh; background-color: #343a40; color: white; position: sticky; top: 0; align-self: flex-start; overflow-y: auto; }
        .sidebar a { color: #adb5bd; text-decoration: none; padding: 15px 20px; display: block; border-left: 3px solid transparent; }
        .sidebar a:hover, .sidebar a.active { color: #fff; background-color: #495057; border-left-color: #0d6efd; }
        .sidebar i { margin-right: 10px; width: 20px; text-align: center; }
        .content { padding: 20px; width: 100%; }
        .navbar-admin { background-color: #fff; box-shadow: 0 2px 4px rgba(0,0,0,.08); }
    </style>
</head>
<body>
    <div class="d-flex">
        <!-- Sidebar -->
        <div class="sidebar d-flex flex-column" style="width: 250px;">
            <div class="p-3 fs-4 fw-bold text-center border-bottom border-secondary">
                <i class="fa-solid fa-language text-primary"></i> JPL Admin
            </div>
            <div class="mt-3">
                <a href="${pageContext.request.contextPath}/admin/dashboard" class="<c:if test='${pageContext.request.requestURI.endsWith("home.jsp")}'>active</c:if>">
                    <i class="fa-solid fa-gauge"></i> Dashboard
                </a>
                <a href="${pageContext.request.contextPath}/admin/users" class="<c:if test='${pageContext.request.requestURI.endsWith("users.jsp")}'>active</c:if>">
                    <i class="fa-solid fa-users"></i> Users Management
                </a>
                <a href="${pageContext.request.contextPath}/admin/lessons" class="<c:if test='${pageContext.request.requestURI.endsWith("lessons.jsp")}'>active</c:if>">
                    <i class="fa-solid fa-book"></i> Lessons
                </a>
                <a href="${pageContext.request.contextPath}/admin/payments" class="<c:if test='${pageContext.request.requestURI.endsWith("payments.jsp")}'>active</c:if>">
                    <i class="fa-solid fa-money-bill-wave"></i> Payments
                </a>
            </div>
            <div class="mt-auto mb-4">
                <a href="${pageContext.request.contextPath}/" target="_blank">
                    <i class="fa-solid fa-external-link-alt"></i> View Site
                </a>
                <a href="${pageContext.request.contextPath}/logout">
                    <i class="fa-solid fa-sign-out-alt"></i> Logout
                </a>
            </div>
        </div>

        <!-- Main Content -->
        <div class="content flex-grow-1">
            <!-- Navbar -->
            <nav class="navbar navbar-expand-lg navbar-admin rounded mb-4">
                <div class="container-fluid">
                    <button class="btn btn-outline-secondary d-md-none me-2" type="button">
                        <i class="fa-solid fa-bars"></i>
                    </button>
                    <span class="navbar-brand mb-0 h1">Control Panel</span>
                    <div class="d-flex align-items-center">
                        <span class="me-3">Hello, <strong>${sessionScope.user.fullName}</strong></span>
                        <img src="https://ui-avatars.com/api/?name=${sessionScope.user.fullName}&background=random" 
                             alt="Avatar" class="rounded-circle" width="32" height="32">
                    </div>
                </div>
            </nav>

            <!-- Alerts -->
            <c:if test="${not empty sessionScope.msgSuccess}">
                <div class="alert alert-success alert-dismissible fade show" role="alert">
                    <i class="fa-solid fa-check-circle me-2"></i>${sessionScope.msgSuccess}
                    <button type="button" class="btn-close" data-bs-dismiss="alert" aria-label="Close"></button>
                </div>
                <c:remove var="msgSuccess" scope="session"/>
            </c:if>
            <c:if test="${not empty sessionScope.msgError}">
                <div class="alert alert-danger alert-dismissible fade show" role="alert">
                    <i class="fa-solid fa-exclamation-circle me-2"></i>${sessionScope.msgError}
                    <button type="button" class="btn-close" data-bs-dismiss="alert" aria-label="Close"></button>
                </div>
                <c:remove var="msgError" scope="session"/>
            </c:if>
