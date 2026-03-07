<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<%@taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt"%>

<jsp:include page="header.jsp" />

<div class="container-fluid">
    <div class="row align-items-center mb-4">
        <div class="col">
            <h2 class="h3 mb-0">Users Management</h2>
        </div>
    </div>

    <div class="card shadow-sm border-0">
        <div class="card-body">
            <div class="table-responsive">
                <table class="table table-hover table-bordered align-middle">
                    <thead class="table-light">
                        <tr>
                            <th>ID</th>
                            <th>Username</th>
                            <th>Full Name</th>
                            <th>Email</th>
                            <th>Role</th>
                            <th>Status</th>
                            <th>Premium</th>
                            <th class="text-end">Actions</th>
                        </tr>
                    </thead>
                    <tbody>
                        <c:forEach var="u" items="${userList}">
                            <tr>
                                <td>${u.id}</td>
                                <td><strong>${u.username}</strong>
                                    <c:if test="${not empty u.googleId}">
                                        <br><span class="badge bg-secondary" style="font-size: 0.65em;">Google</span>
                                    </c:if>
                                </td>
                                <td>${u.fullName}</td>
                                <td>${u.email}</td>
                                <td>
                                    <c:choose>
                                        <c:when test="${u.role == 'ADMIN'}">
                                            <span class="badge bg-danger">ADMIN</span>
                                        </c:when>
                                        <c:otherwise>
                                            <span class="badge bg-primary">USER</span>
                                        </c:otherwise>
                                    </c:choose>
                                </td>
                                <td>
                                    <c:choose>
                                        <c:when test="${u.status == 'ACTIVE'}">
                                            <span class="badge bg-success">ACTIVE</span>
                                        </c:when>
                                        <c:when test="${u.status == 'BAN'}">
                                            <span class="badge bg-dark">BANNED</span>
                                        </c:when>
                                        <c:otherwise>
                                            <span class="badge bg-secondary">${u.status}</span>
                                        </c:otherwise>
                                    </c:choose>
                                </td>
                                <td>
                                    <c:choose>
                                        <c:when test="${u.premium}">
                                            <span class="text-warning"><i class="fa-solid fa-crown"></i> Yes</span><br>
                                            <small class="text-muted"><fmt:formatDate value="${u.premiumUntil}" pattern="dd/MM/yyyy"/></small>
                                        </c:when>
                                        <c:otherwise>
                                            <span class="text-muted">No</span>
                                        </c:otherwise>
                                    </c:choose>
                                </td>
                                <td class="text-end">
                                    <button type="button" class="btn btn-sm btn-outline-primary" 
                                            data-bs-toggle="modal" data-bs-target="#editRoleModal${u.id}"
                                            <c:if test="${u.id == sessionScope.user.id}">disabled</c:if>>
                                        <i class="fa-solid fa-user-shield"></i> Role
                                    </button>
                                    
                                    <c:choose>
                                        <c:when test="${u.status == 'ACTIVE'}">
                                            <button type="button" class="btn btn-sm btn-outline-danger" 
                                                    data-bs-toggle="modal" data-bs-target="#banModal${u.id}"
                                                    <c:if test="${u.id == sessionScope.user.id}">disabled</c:if>>
                                                <i class="fa-solid fa-ban"></i> Ban
                                            </button>
                                        </c:when>
                                        <c:when test="${u.status == 'BAN'}">
                                            <form action="${pageContext.request.contextPath}/admin/users" method="POST" class="d-inline">
                                                <input type="hidden" name="action" value="updateStatus">
                                                <input type="hidden" name="userId" value="${u.id}">
                                                <input type="hidden" name="status" value="ACTIVE">
                                                <button type="submit" class="btn btn-sm btn-outline-success">
                                                    <i class="fa-solid fa-check"></i> Unban
                                                </button>
                                            </form>
                                        </c:when>
                                    </c:choose>
                                    
                                    <button type="button" class="btn btn-sm btn-outline-warning" 
                                            data-bs-toggle="modal" data-bs-target="#premiumModal${u.id}">
                                        <i class="fa-solid fa-crown"></i> Premium
                                    </button>
                                    
                                    <button type="button" class="btn btn-sm btn-outline-danger" 
                                            data-bs-toggle="modal" data-bs-target="#deleteModal${u.id}"
                                            <c:if test="${u.id == sessionScope.user.id}">disabled</c:if>>
                                        <i class="fa-solid fa-trash"></i> Xoá
                                    </button>
                                </td>
                            </tr>
                            
                            <!-- Role Modal -->
                            <div class="modal fade" id="editRoleModal${u.id}" tabindex="-1" aria-hidden="true">
                                <div class="modal-dialog">
                                    <div class="modal-content">
                                        <form action="${pageContext.request.contextPath}/admin/users" method="POST">
                                            <div class="modal-header">
                                                <h5 class="modal-title">Edit Role for ${u.username}</h5>
                                                <button type="button" class="btn-close" data-bs-dismiss="modal" aria-label="Close"></button>
                                            </div>
                                            <div class="modal-body">
                                                <input type="hidden" name="action" value="updateRole">
                                                <input type="hidden" name="userId" value="${u.id}">
                                                <div class="mb-3">
                                                    <label class="form-label">Role</label>
                                                    <select class="form-select" name="role">
                                                        <option value="USER" ${u.role == 'USER' ? 'selected' : ''}>USER</option>
                                                        <option value="ADMIN" ${u.role == 'ADMIN' ? 'selected' : ''}>ADMIN</option>
                                                    </select>
                                                </div>
                                                <p class="text-warning small"><i class="fa-solid fa-triangle-exclamation"></i> Warning: Granting ADMIN role gives this user full control over the system.</p>
                                            </div>
                                            <div class="modal-footer">
                                                <button type="button" class="btn btn-secondary" data-bs-dismiss="modal">Cancel</button>
                                                <button type="submit" class="btn btn-primary">Save Changes</button>
                                            </div>
                                        </form>
                                    </div>
                                </div>
                            </div>

                            <!-- Ban Modal -->
                            <div class="modal fade" id="banModal${u.id}" tabindex="-1" aria-hidden="true">
                                <div class="modal-dialog">
                                    <div class="modal-content">
                                        <form action="${pageContext.request.contextPath}/admin/users" method="POST">
                                            <div class="modal-header">
                                                <h5 class="modal-title text-danger">Confirm Ban User</h5>
                                                <button type="button" class="btn-close" data-bs-dismiss="modal" aria-label="Close"></button>
                                            </div>
                                            <div class="modal-body">
                                                <input type="hidden" name="action" value="updateStatus">
                                                <input type="hidden" name="userId" value="${u.id}">
                                                <input type="hidden" name="status" value="BAN">
                                                <p>Are you sure you want to ban user <strong>${u.username}</strong>?</p>
                                                <p class="text-muted">They will no longer be able to log in to the system.</p>
                                            </div>
                                            <div class="modal-footer">
                                                <button type="button" class="btn btn-secondary" data-bs-dismiss="modal">Cancel</button>
                                                <button type="submit" class="btn btn-danger">Yes, Ban User</button>
                                            </div>
                                        </form>
                                    </div>
                                </div>
                            </div>

                            <!-- Premium Modal -->
                            <div class="modal fade" id="premiumModal${u.id}" tabindex="-1" aria-hidden="true">
                                <div class="modal-dialog">
                                    <div class="modal-content">
                                        <form action="${pageContext.request.contextPath}/admin/users" method="POST">
                                            <div class="modal-header">
                                                <h5 class="modal-title"><i class="fa-solid fa-crown text-warning"></i> Premium - ${u.username}</h5>
                                                <button type="button" class="btn-close" data-bs-dismiss="modal" aria-label="Close"></button>
                                            </div>
                                            <div class="modal-body">
                                                <input type="hidden" name="action" value="togglePremium">
                                                <input type="hidden" name="userId" value="${u.id}">
                                                
                                                <c:choose>
                                                    <c:when test="${u.premium}">
                                                        <div class="alert alert-info">
                                                            <i class="fa-solid fa-crown text-warning"></i> 
                                                            User đang là <strong>Premium</strong> đến 
                                                            <strong><fmt:formatDate value="${u.premiumUntil}" pattern="dd/MM/yyyy HH:mm"/></strong>
                                                        </div>
                                                        <input type="hidden" name="premium" value="false">
                                                        <p>Bạn có muốn <strong class="text-danger">huỷ Premium</strong> của user này?</p>
                                                    </c:when>
                                                    <c:otherwise>
                                                        <input type="hidden" name="premium" value="true">
                                                        <div class="mb-3">
                                                            <label class="form-label">Số ngày Premium</label>
                                                            <select class="form-select" name="days">
                                                                <option value="30" selected>30 ngày</option>
                                                                <option value="90">90 ngày</option>
                                                                <option value="180">180 ngày</option>
                                                                <option value="365">365 ngày</option>
                                                            </select>
                                                        </div>
                                                        <p class="text-muted small">Cấp Premium cho user <strong>${u.username}</strong>.</p>
                                                    </c:otherwise>
                                                </c:choose>
                                            </div>
                                            <div class="modal-footer">
                                                <button type="button" class="btn btn-secondary" data-bs-dismiss="modal">Cancel</button>
                                                <c:choose>
                                                    <c:when test="${u.premium}">
                                                        <button type="submit" class="btn btn-danger">Huỷ Premium</button>
                                                    </c:when>
                                                    <c:otherwise>
                                                        <button type="submit" class="btn btn-warning">Cấp Premium</button>
                                                    </c:otherwise>
                                                </c:choose>
                                            </div>
                                        </form>
                                    </div>
                                </div>
                            </div>

                            <!-- Delete User Modal -->
                            <div class="modal fade" id="deleteModal${u.id}" tabindex="-1" aria-hidden="true">
                                <div class="modal-dialog">
                                    <div class="modal-content">
                                        <form action="${pageContext.request.contextPath}/admin/users" method="POST">
                                            <div class="modal-header">
                                                <h5 class="modal-title text-danger"><i class="fa-solid fa-trash me-2"></i>Xoá User</h5>
                                                <button type="button" class="btn-close" data-bs-dismiss="modal" aria-label="Close"></button>
                                            </div>
                                            <div class="modal-body">
                                                <input type="hidden" name="action" value="deleteUser">
                                                <input type="hidden" name="userId" value="${u.id}">
                                                <div class="alert alert-danger">
                                                    <i class="fa-solid fa-triangle-exclamation me-1"></i>
                                                    <strong>Cảnh báo:</strong> Hành động này không thể hoàn tác!
                                                </div>
                                                <p>Bạn có chắc chắn muốn xoá user <strong>${u.username}</strong>?</p>
                                                <p class="text-muted small">Tất cả dữ liệu liên quan (thanh toán, premium...) sẽ bị xoá vĩnh viễn.</p>
                                            </div>
                                            <div class="modal-footer">
                                                <button type="button" class="btn btn-secondary" data-bs-dismiss="modal">Huỷ</button>
                                                <button type="submit" class="btn btn-danger">Xoá vĩnh viễn</button>
                                            </div>
                                        </form>
                                    </div>
                                </div>
                            </div>

                        </c:forEach>
                        <c:if test="${empty userList}">
                            <tr>
                                <td colspan="8" class="text-center py-4">No users found.</td>
                            </tr>
                        </c:if>
                    </tbody>
                </table>
            </div>
        </div>
    </div>
</div>

<jsp:include page="footer.jsp" />
