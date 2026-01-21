<%@ page contentType="text/html;charset=UTF-8" %>
<%@ page import="java.util.List" %>
<%@ page import="com.japaneselearning.model.Lesson" %>

<%
    List<Lesson> lessons = (List<Lesson>) request.getAttribute("lessons");
%>

<h2>Lesson List</h2>

<% if (lessons == null || lessons.isEmpty()) { %>
    <p>Chưa có lesson nào.</p>
<% } else { %>
    <ul>
    <% for (Lesson l : lessons) { %>
        <li>
            <a href="lesson-detail?id=<%= l.getLessonId() %>">
                <%= l.getName() %> - <%= l.getLevel() %>
            </a>
        </li>
    <% } %>
    </ul>
<% } %>
