<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ page import="java.sql.*" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <title>Registration</title>
    <link rel="stylesheet" href="styl.css">
</head>
<body>
    <h2>Register</h2>

    <div class="register-container" id="register">
        <form id="registerForm" action="register.jsp" method="post" style="padding-right: 20px;">
            <label for="regName">Full Name:</label>
            <input type="text" id="regName" name="regName" required><br>

            <label for="regEmail">Email:</label>
            <input type="email" id="regEmail" name="regEmail" required><br>

            <label for="regPhone">Phone Number:</label>
            <input type="tel" id="regPhone" name="regPhone" required><br>

            <label for="username">User Name:</label>
            <input type="text" id="username" name="username" required><br>

            <label for="regPassword">Password:</label>
            <input type="password" id="regPassword" name="regPassword" required><br>

            <label for="regConfirmPassword">Confirm Password:</label>
            <input type="password" id="regConfirmPassword" name="regConfirmPassword" required><br>

            <button type="submit" name="submit">Register</button>
        </form>
    </div>

    <%
    if (request.getMethod().equalsIgnoreCase("post")) {
        String name = request.getParameter("regName");
        String email = request.getParameter("regEmail");
        String phone = request.getParameter("regPhone");
        String username = request.getParameter("username");
        String password = request.getParameter("regPassword");
        String confirmPassword = request.getParameter("regConfirmPassword");

        if (!password.equals(confirmPassword)) {
            out.println("<script>alert('Passwords do not match!');</script>");
        } else {
            Connection conn = null;
            PreparedStatement checkEmailPst = null;
            PreparedStatement userPst = null;
            PreparedStatement analyticsPst = null;
            ResultSet rs = null;

            try {
                Class.forName("com.mysql.cj.jdbc.Driver");
                conn = DriverManager.getConnection("jdbc:mysql://localhost:3306/task", "root", "*******");
                conn.setAutoCommit(false);

                String checkEmailQuery = "SELECT email FROM user WHERE email = ?";
                checkEmailPst = conn.prepareStatement(checkEmailQuery);
                checkEmailPst.setString(1, email);
                rs = checkEmailPst.executeQuery();

                if (rs.next()) {
                    out.println("<p style='color: red;'>Error: Email is already registered!</p>");
                } else {
                    String userQuery = "INSERT INTO user (user_name, name, email, password, mobile_no) VALUES (?, ?, ?, ?, ?)";
                    userPst = conn.prepareStatement(userQuery);
                    userPst.setString(1, username);
                    userPst.setString(2, name);
                    userPst.setString(3, email);
                    userPst.setString(4, password);
                    userPst.setString(5, phone);

                    int userRowCount = userPst.executeUpdate();

                    if (userRowCount > 0) {
                        String analyticsQuery = "INSERT INTO analytics (user_name, total_tasks, completed_tasks, deleted_tasks) VALUES (?, 0, 0, 0)";
                        analyticsPst = conn.prepareStatement(analyticsQuery);
                        analyticsPst.setString(1, username);
                        analyticsPst.executeUpdate();

                        conn.commit();

                        out.println("<script>alert('Registration Successful!'); window.location='login.jsp';</script>");
                    } else {
                        conn.rollback();
                        out.println("<p style='color: red;'>Error: Registration Failed!</p>");
                    }
                }
            } catch (Exception e) {
                e.printStackTrace();
                out.println("<p style='color: red;'>Error: " + e.getMessage() + "</p>");
                if (conn != null) conn.rollback();
            } finally {
                if (rs != null) rs.close();
                if (checkEmailPst != null) checkEmailPst.close();
                if (userPst != null) userPst.close();
                if (analyticsPst != null) analyticsPst.close();
                if (conn != null) conn.close();
            }
        }
    }
    %>
</body>
</html>
