<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<%@taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt"%>

<jsp:include page="header.jsp" />

<div class="container-fluid">
    <div class="row align-items-center mb-4">
        <div class="col">
            <h2 class="h3 mb-0">Lessons Management</h2>
        </div>
        <div class="col-auto">
            <button class="btn btn-primary" data-bs-toggle="modal" data-bs-target="#addLessonModal">
                <i class="fa-solid fa-plus me-1"></i> Add New Lesson
            </button>
        </div>
    </div>

    <!-- Lessons Table -->
    <div class="card">
        <div class="card-body">
            <div class="table-responsive">
                <table class="table table-hover align-middle">
                    <thead class="table-light">
                        <tr>
                            <th>#</th>
                            <th>Name</th>
                            <th>Level</th>
                            <th>Description</th>
                            <th>Content Path</th>
                            <th>Created At</th>
                            <th>Actions</th>
                        </tr>
                    </thead>
                    <tbody>
                        <c:forEach var="lesson" items="${lessonList}" varStatus="st">
                            <tr>
                                <td>${st.count}</td>
                                <td><strong>${lesson.name}</strong></td>
                                <td><span class="badge bg-info text-dark">${lesson.level}</span></td>
                                <td>${lesson.description}</td>
                                <td><code>${lesson.contentPath}</code></td>
                                <td><fmt:formatDate value="${lesson.createdAt}" pattern="dd/MM/yyyy HH:mm"/></td>
                                <td>
                                    <button class="btn btn-sm btn-outline-primary me-1" data-bs-toggle="modal" data-bs-target="#editLessonModal"
                                            onclick="fillEditForm('${lesson.lessonId}', '${lesson.name}', '${lesson.level}', '${lesson.description}', '${lesson.contentPath}')">
                                        <i class="fa-solid fa-pen"></i>
                                    </button>
                                    <form action="${pageContext.request.contextPath}/admin/lessons" method="POST" style="display:inline"
                                          onsubmit="return confirm('Bạn có chắc muốn xoá bài học này?')">
                                        <input type="hidden" name="action" value="delete">
                                        <input type="hidden" name="lessonId" value="${lesson.lessonId}">
                                        <button type="submit" class="btn btn-sm btn-outline-danger">
                                            <i class="fa-solid fa-trash"></i>
                                        </button>
                                    </form>
                                </td>
                            </tr>
                        </c:forEach>
                        <c:if test="${empty lessonList}">
                            <tr>
                                <td colspan="7" class="text-center text-muted py-4">Chưa có bài học nào.</td>
                            </tr>
                        </c:if>
                    </tbody>
                </table>
            </div>
        </div>
    </div>

    <!-- Add Lesson Modal -->
    <div class="modal fade" id="addLessonModal" tabindex="-1" aria-hidden="true">
        <div class="modal-dialog modal-lg">
            <div class="modal-content">
                <form action="${pageContext.request.contextPath}/admin/lessons" method="POST">
                    <div class="modal-header">
                        <h5 class="modal-title">Add New Lesson</h5>
                        <button type="button" class="btn-close" data-bs-dismiss="modal" aria-label="Close"></button>
                    </div>
                    <div class="modal-body">
                        <input type="hidden" name="action" value="add">
                        
                        <div class="row mb-3">
                            <div class="col-md-8">
                                <label class="form-label">Lesson Name/Category</label>
                                <input type="text" class="form-control" name="name" required placeholder="e.g. Hiragana cơ bản">
                            </div>
                            <div class="col-md-4">
                                <label class="form-label">Level</label>
                                <select class="form-select" name="level">
                                    <option value="N5">N5</option>
                                    <option value="N4">N4</option>
                                    <option value="N3">N3</option>
                                    <option value="N2">N2</option>
                                    <option value="N1">N1</option>
                                </select>
                            </div>
                        </div>
                        
                        <div class="mb-3">
                            <label class="form-label">Description (Chapter/Sub-category)</label>
                            <input type="text" class="form-control" name="description" placeholder="e.g. Học bảng chữ cái Hiragana cơ bản">
                        </div>
                        
                        <div class="mb-3">
                            <label class="form-label">Content Path (HTML File)</label>
                            <input type="text" class="form-control" name="contentPath" required placeholder="lessons/n5/hiragana.html">
                            <div class="form-text">Relative path to the lesson content within the webapp folder.</div>
                        </div>
                    </div>
                    <div class="modal-footer">
                        <button type="button" class="btn btn-secondary" data-bs-dismiss="modal">Cancel</button>
                        <button type="submit" class="btn btn-primary">Save Lesson</button>
                    </div>
                </form>
            </div>
        </div>
    </div>

    <!-- Edit Lesson Modal -->
    <div class="modal fade" id="editLessonModal" tabindex="-1" aria-hidden="true">
        <div class="modal-dialog modal-lg">
            <div class="modal-content">
                <form action="${pageContext.request.contextPath}/admin/lessons" method="POST">
                    <div class="modal-header">
                        <h5 class="modal-title">Edit Lesson</h5>
                        <button type="button" class="btn-close" data-bs-dismiss="modal" aria-label="Close"></button>
                    </div>
                    <div class="modal-body">
                        <input type="hidden" name="action" value="update">
                        <input type="hidden" name="lessonId" id="editLessonId">
                        
                        <div class="row mb-3">
                            <div class="col-md-8">
                                <label class="form-label">Lesson Name/Category</label>
                                <input type="text" class="form-control" name="name" id="editName" required>
                            </div>
                            <div class="col-md-4">
                                <label class="form-label">Level</label>
                                <select class="form-select" name="level" id="editLevel">
                                    <option value="N5">N5</option>
                                    <option value="N4">N4</option>
                                    <option value="N3">N3</option>
                                    <option value="N2">N2</option>
                                    <option value="N1">N1</option>
                                </select>
                            </div>
                        </div>
                        
                        <div class="mb-3">
                            <label class="form-label">Description</label>
                            <input type="text" class="form-control" name="description" id="editDescription">
                        </div>
                        
                        <div class="mb-3">
                            <label class="form-label">Content Path (HTML File)</label>
                            <input type="text" class="form-control" name="contentPath" id="editContentPath" required>
                        </div>
                    </div>
                    <div class="modal-footer">
                        <button type="button" class="btn btn-secondary" data-bs-dismiss="modal">Cancel</button>
                        <button type="submit" class="btn btn-primary">Update Lesson</button>
                    </div>
                </form>
            </div>
        </div>
    </div>
</div> <!-- End container-fluid -->

<script>
    function fillEditForm(id, name, level, description, contentPath) {
        document.getElementById('editLessonId').value = id;
        document.getElementById('editName').value = name;
        document.getElementById('editLevel').value = level;
        document.getElementById('editDescription').value = description;
        document.getElementById('editContentPath').value = contentPath;
    }
</script>

<jsp:include page="footer.jsp" />

