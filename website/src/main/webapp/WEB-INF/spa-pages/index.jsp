<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>

<!doctype html>
<html lang="en">

<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1">

  <title>Website</title>

  <!-- CSS gerados pelo Vite -->
<%--  <c:forEach var="css" items="${cssFiles}">--%>
<%--    <link rel="stylesheet" href="${pageContext.request.contextPath}/static/assets/index-BKCXkP_B.js" />--%>
<%--  </c:forEach>--%>

</head>

<body>

<div id="root"></div>
<script type="module" src="${contextPath}/static/${js_file}"></script>
<script type="module" src="${contextPath}/static/${css_file}"></script>
<%--${pageContext.request.contextPath}/assets/${js_file}--%>
<%--${pageContext.request.contextPath}/assets/${css_file}--%>
</body>

</html>
