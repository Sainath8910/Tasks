<%@ page import="java.sql.*" %>
<%
    String taskName = request.getParameter("taskName");
    String username = (String) session.getAttribute("username");

    if (username == null) {
        response.sendRedirect("login.jsp");
        return;
    }

    if (taskName != null && !taskName.isEmpty()) {
        Connection conn = null;
        PreparedStatement deleteTaskStmt = null;
        PreparedStatement updateAnalyticsStmt = null;

        try {
            Class.forName("com.mysql.cj.jdbc.Driver");
            conn = DriverManager.getConnection("jdbc:mysql://localhost:3306/task", "root", "*******");

            conn.setAutoCommit(false);

            String deleteTaskQuery = "DELETE FROM tasks WHERE user_name = ? AND task_name = ?";
            deleteTaskStmt = conn.prepareStatement(deleteTaskQuery);
            deleteTaskStmt.setString(1, username);
            deleteTaskStmt.setString(2, taskName);

            int rowsAffected = deleteTaskStmt.executeUpdate();

            if (rowsAffected > 0) {
                String updateAnalyticsQuery = "UPDATE analytics SET completed_tasks = completed_tasks + 1 WHERE user_name = ?";
                updateAnalyticsStmt = conn.prepareStatement(updateAnalyticsQuery);
                updateAnalyticsStmt.setString(1, username);
                int analyticsUpdated = updateAnalyticsStmt.executeUpdate();

                if (analyticsUpdated > 0) {
                    conn.commit();
                    out.println("<script>alert('Task completed successfully!'); window.location='ii.jsp';</script>");
                } else {
                    conn.rollback();
                    out.println("<p style='color:red;'>Error updating analytics. Please try again.</p>");
                }
            } else {
                out.println("<p style='color:red;'>Task not found!</p>");
            }
        } catch (Exception e) {
            e.printStackTrace();
            out.println("<p style='color:red;'>Error: " + e.getMessage() + "</p>");
            if (conn != null) conn.rollback();
        } finally {
            if (deleteTaskStmt != null) try { deleteTaskStmt.close(); } catch (SQLException ignored) {}
            if (updateAnalyticsStmt != null) try { updateAnalyticsStmt.close(); } catch (SQLException ignored) {}
            if (conn != null) try { conn.close(); } catch (SQLException ignored) {}
        }
    } else {
        out.println("<p style='color:red;'>Invalid Task Name!</p>");
    }
%>
<a href="ii.jsp">Back</a>
