<%@ page import="java.sql.*" %>
<%
    String taskName = request.getParameter("taskName");
    String taskDescription = request.getParameter("taskDescription");
    String taskPriority = request.getParameter("taskPriority");
    String taskDate = request.getParameter("taskDate");
    String username = (String) session.getAttribute("username");

    if (username == null) {
        response.sendRedirect("login.jsp");
        return;
    }

    if (taskName != null && !taskName.isEmpty()) {
        Connection conn = null;
        PreparedStatement insertStmt = null;
        PreparedStatement deleteStmt = null;
        PreparedStatement updateAnalyticsStmt = null;

        try {
            Class.forName("com.mysql.cj.jdbc.Driver");
            conn = DriverManager.getConnection("jdbc:mysql://localhost:3306/task", "root", "*******");

            conn.setAutoCommit(false);

            String insertSQL = "INSERT INTO tasks (user_name, task_name, discription, priority, date) VALUES (?, ?, ?, ?, ?)";
            insertStmt = conn.prepareStatement(insertSQL);
            insertStmt.setString(1, username);
            insertStmt.setString(2, taskName);
            insertStmt.setString(3, taskDescription);
            insertStmt.setString(4, taskPriority);
            insertStmt.setString(5, taskDate);
            int insertResult = insertStmt.executeUpdate();

            if (insertResult > 0) {
                String deleteSQL = "DELETE FROM delete_tas WHERE user_name = ? AND task_name = ?";
                deleteStmt = conn.prepareStatement(deleteSQL);
                deleteStmt.setString(1, username);
                deleteStmt.setString(2, taskName);
                int deleteResult = deleteStmt.executeUpdate();

                if (deleteResult > 0) {
                    String updateAnalyticsSQL = "UPDATE analytics SET deleted_tasks = deleted_tasks - 1 WHERE user_name = ? AND deleted_tasks > 0";
                    updateAnalyticsStmt = conn.prepareStatement(updateAnalyticsSQL);
                    updateAnalyticsStmt.setString(1, username);
                    int analyticsUpdated = updateAnalyticsStmt.executeUpdate();

                    if (analyticsUpdated > 0) {
                        conn.commit();
                        out.println("<script>alert('Task restored successfully!'); window.location='ii.jsp';</script>");
                    } else {
                        conn.rollback();
                        out.println("<p style='color:red;'>Error updating analytics. Please try again.</p>");
                    }
                } else {
                    conn.rollback();
                    out.println("<p style='color:orange;'>Task not found in trash!</p>");
                }
            } else {
                out.println("<p style='color:red;'>Failed to restore task!</p>");
            }
        } catch (Exception e) {
            e.printStackTrace();
            out.println("<p style='color:red;'>Error: " + e.getMessage() + "</p>");
            if (conn != null) conn.rollback();
        } finally {
            try {
                if (insertStmt != null) insertStmt.close();
                if (deleteStmt != null) deleteStmt.close();
                if (updateAnalyticsStmt != null) updateAnalyticsStmt.close();
                if (conn != null) conn.close();
            } catch (SQLException e) {
                e.printStackTrace();
            }
        }
    } else {
        out.println("<p style='color:red;'>Invalid Task Name!</p>");
    }
%>
<a href="ii.jsp">Back</a>
