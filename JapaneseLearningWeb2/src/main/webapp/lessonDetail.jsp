<%@ page contentType="text/html;charset=UTF-8" %>
<%@ page import="com.japaneselearning.model.Lesson" %>

<%
    Lesson lesson = (Lesson) request.getAttribute("lesson");
    String content = (String) request.getAttribute("lessonContent");
%>

<h1><%= lesson.getName() %></h1>
<p>Level: <%= lesson.getLevel() %></p>

<hr>

<div class="lesson-content">
    <%= content %>
</div>