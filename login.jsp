<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ page import="java.sql.*" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Login</title>
    <link rel="stylesheet" href="styles.css">
</head>
<body>

    <div class="login-page">
        <div class="login-form">
            <h2>Login</h2>
            <form action="login.jsp" method="post">
                <input type="text" name="username" placeholder="Username" required>
                <input type="password" name="password" placeholder="Password" required>
                <button type="submit">Login</button>
            </form>
            <p style="padding-top: 5%;">New user? <a href="register.jsp">Register</a></p>
        </div>
    </div>

    <%
        if (request.getMethod().equalsIgnoreCase("POST")) {
            String username = request.getParameter("username");
            String password = request.getParameter("password");

            Connection conn = null;
            PreparedStatement pst = null;
            ResultSet rs = null;

            try {
                Class.forName("com.mysql.cj.jdbc.Driver");
                conn = DriverManager.getConnection("jdbc:mysql://localhost:3306/task", "root", "*******");

                String query = "SELECT * FROM user WHERE user_name = ? AND password = ?";
                pst = conn.prepareStatement(query);
                pst.setString(1, username);
                pst.setString(2, password);
                rs = pst.executeQuery();

                if (rs.next()) {
                    session.setAttribute("username", username);
                    response.sendRedirect("ii.jsp");
                } else {
                    out.println("<script>alert('Invalid username or password!');</script>");
                }
            } catch (Exception e) {
                out.println("<p style='color: red;'>Error: " + e.getMessage() + "</p>");
            } finally {
                if (rs != null) rs.close();
                if (pst != null) pst.close();
                if (conn != null) conn.close();
            }
        }
    %>

</body>
</html>
