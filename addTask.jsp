<%@ page import="java.sql.*" %>
<%
    String taskTitle = request.getParameter("taskTitle");
    String taskDescription = request.getParameter("taskDescription");
    String taskPriority = request.getParameter("taskPriority");
    String taskDate = request.getParameter("taskDate");
    String username = (String) session.getAttribute("username");

    if (username == null) {
        response.sendRedirect("login.jsp");
        return;
    }

    out.println("<p>Task Title: " + taskTitle + "</p>");
    out.println("<p>Task Description: " + taskDescription + "</p>");
    out.println("<p>Task Priority: " + taskPriority + "</p>");
    out.println("<p>Task Date: " + taskDate + "</p>");

    if (taskTitle == null || taskDescription == null || taskPriority == null || taskDate == null) {
        out.println("<p style='color:red;'>Error: One or more form fields are empty!</p>");
        return;
    }

    Connection con = null;
    PreparedStatement ps = null;
    PreparedStatement updateAnalyticsPs = null;

    try {
        Class.forName("com.mysql.cj.jdbc.Driver");
        con = DriverManager.getConnection("jdbc:mysql://localhost:3306/task", "root", "*******");

        con.setAutoCommit(false);

        String query = "INSERT INTO tasks (user_name, task_name, discription, priority, date) VALUES (?, ?, ?, ?, ?)";
        ps = con.prepareStatement(query);
        ps.setString(1, username);
        ps.setString(2, taskTitle);
        ps.setString(3, taskDescription);
        ps.setString(4, taskPriority);
        ps.setString(5, taskDate);

        int rowsInserted = ps.executeUpdate();
        
        if (rowsInserted > 0) {
            String updateAnalyticsQuery = "UPDATE analytics SET total_tasks = total_tasks + 1 WHERE user_name = ?";
            updateAnalyticsPs = con.prepareStatement(updateAnalyticsQuery);
            updateAnalyticsPs.setString(1, username);

            int analyticsUpdated = updateAnalyticsPs.executeUpdate();

            if (analyticsUpdated > 0) {
                con.commit();
                response.sendRedirect("ii.jsp");
            } else {
                con.rollback();
                out.println("<p>Error updating analytics. Please try again.</p>");
            }
        } else {
            out.println("<p>Error adding task. Please try again.</p>");
        }
    } catch (Exception e) {
        e.printStackTrace();
        out.println("<p>Database error: " + e.getMessage() + "</p>");
        if (con != null) con.rollback();
    } finally {
        if (ps != null) try { ps.close(); } catch (SQLException ignored) {}
        if (updateAnalyticsPs != null) try { updateAnalyticsPs.close(); } catch (SQLException ignored) {}
        if (con != null) try { con.close(); } catch (SQLException ignored) {}
    }
%>
