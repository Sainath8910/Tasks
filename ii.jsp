<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.text.SimpleDateFormat" %>
<%@ page import="java.util.Date" %>
<%@ page import="java.sql.*" %>
<%
    Connection con = null;
    PreparedStatement ps = null;
    ResultSet rs = null;

    String username = (String) session.getAttribute("username");
    if (username == null) {
        response.sendRedirect("login.jsp");
    }
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Task Scheduler</title>
    <link rel="stylesheet" href="styles.css">
    <style>
        .task-card{
            flex-shrink: 0;
            width: 275px;
            display: flex;
            flex-direction: column;
            justify-content: space-between;
        }
    </style>
</head>
<body>
    <div id="mainPage" style="display: block;">
        <div class="main-container" style="width:100%">
            <aside class="left-panel">
                <h2>Menu</h2>
                <nav>
                    <ul>
                        <li onclick="navigateTo('dashboard')">Dashboard</li>
                        <li onclick="navigateTo('analytics')">Analytics</li>
                        <li onclick="navigateTo('trash')">Trash</li>
                        <li onclick="navigateTo('calendar')">Calendar</li>
                        <li onclick="navigateTo('profile')">User Profile</li>
                        <li onclick="logout()">Logout</li>
                    </ul>
                </nav>
            </aside>

            <div class="content-area">
                <section id="dashboard" class="section">
                    <header style="text-align:center;padding-bottom: 30px;">
                        <h1>Task Scheduler</h1>
                        <p>Welcome, <%= username %>!</p>
                    </header>
                    <div class="add-task">
                        <button onclick="navigateTo('taskFormSection')">Add New Task</button>
                    </div>
                    <h1>Your Tasks</h1>
                    <div class="task-list">
                            <%
                                try {
                                    Class.forName("com.mysql.cj.jdbc.Driver");
                                    con = DriverManager.getConnection("jdbc:mysql://localhost:3306/task", "root", "*******");
                                    String query = "SELECT * FROM tasks WHERE user_name=?";
                                    ps = con.prepareStatement(query);
                                    ps.setString(1, username);
                                    
                                    rs = ps.executeQuery();
                                    boolean hasData = false;
                                    while (rs.next()) {
                                        hasData = true;
                            %>
                            <li class="task-card">
                                <h3><strong><%= rs.getString("task_name") %></strong></h3>
                                <p><strong>Description:</strong> <%= rs.getString("discription") %></p>
                                <p><strong>Priority:</strong> <%= rs.getString("priority") %></p>
                                <p><strong>Due Date:</strong> <%= rs.getString("date") %></p>
                                <div style="display: flex; gap: 110px;padding-left:15px;height:25px;">
                                    <form action="delete.jsp" method="post">
                                        <input type="hidden" name="taskName" value="<%= rs.getString("task_name") %>">
                                        <input type="hidden" name="taskDescription" value="<%= rs.getString("discription") %>">
                                        <input type="hidden" name="taskPriority" value="<%= rs.getString("priority") %>">
                                        <input type="hidden" name="taskDate" value="<%= rs.getString("date") %>">
                                        <button type="submit" onclick="return confirm('Are you sure you want to delete this task?');" style="border-radius: 5px; width: 50px;background-color: rgb(184,224,210);">
                                            Delete
                                        </button>
                                    </form>
                                    <form action="complete.jsp" method="post">
                                        <input type="hidden" name="taskName" value="<%= rs.getString("task_name") %>">
                                        <input type="hidden" name="taskDescription" value="<%= rs.getString("discription") %>">
                                        <input type="hidden" name="taskPriority" value="<%= rs.getString("priority") %>">
                                        <input type="hidden" name="taskDate" value="<%= rs.getString("date") %>">
                                        <button type="submit" onclick="return confirm('Are you sure you completed this task?');" style="border-radius: 5px; width: 70px;background-color: rgb(184,224,210);">
                                            Complete
                                        </button>
                                    </form>                                    
                                </div>
                            </li>
                            <%
                                    }
                                    if (!hasData) {
                                        out.println("<p>No tasks found for user: " + username + "</p>");
                                    }
                                } catch (Exception e) {
                                    e.printStackTrace();
                                    out.println("<p style='color:red;'>Error: " + e.getMessage() + "</p>");
                                } finally {
                                    try {
                                        if (rs != null) rs.close();
                                        if (ps != null) ps.close();
                                        if (con != null) con.close();
                                    } catch (SQLException e) {
                                        e.printStackTrace();
                                    }
                                }
                            %>
                    </div>
                </section>

                <section id="taskFormSection" class="section" style="display: none;">
                    <h2>Add Task</h2>
                    <form id="taskForm" action="addTask.jsp" method="post">
                        <label for="taskTitle">Title:</label>
                        <input type="text" id="taskTitle" name="taskTitle" required><br>
                        <label for="taskDescription">Description:</label>
                        <textarea id="taskDescription" name="taskDescription" required></textarea><br>
                        <label for="taskPriority">Priority:</label>
                        <select id="taskPriority" name="taskPriority" required>
                            <option value="high">High</option>
                            <option value="medium">Medium</option>
                            <option value="low">Low</option>
                        </select><br>
                        <label for="taskDate">Due Date:</label>
                        <input type="date" id="taskDate" name="taskDate" required><br>
                        <button type="submit">Add Task</button>
                    </form>
                </section>

                <section id="analytics" class="section">
                    <h2>Analytics</h2><br><br>
                    <%
                        try {
                            con = DriverManager.getConnection("jdbc:mysql://localhost:3306/task", "root", "*******");
                            ps = con.prepareStatement("SELECT * FROM analytics WHERE user_name=?");
                            ps.setString(1, username);
                            rs = ps.executeQuery();

                            if (rs.next()) {
                    %>
                                <p><strong>Total number of tasks:</strong> <%= rs.getInt("total_tasks") %></p><br>
                                <p><strong>Total number of completed tasks:</strong> <%= rs.getInt("completed_tasks") %></p><br>
                                <p><strong>Total number of deleted tasks:</strong> <%= rs.getInt("deleted_tasks") %></p><br>
                            <% } else { %>
                                <p>No analytics data available for user.</p>
                            <% }
                        } catch (Exception e) {
                            out.println("<p style='color:red;'>Database Error: " + e.getMessage() + "</p>");
                        } finally {
                            try {
                                if (rs != null) rs.close();
                                if (ps != null) ps.close();
                                if (con != null) con.close();
                            } catch (SQLException e) {
                                e.printStackTrace();
                            }
                        }
                    %>
                </section>

                <section id="profile" class="section">
                    <h2>User Profile</h2><br><br>
                    <%
                        try {
                            con = DriverManager.getConnection("jdbc:mysql://localhost:3306/task", "root", "*******");
                            ps = con.prepareStatement("SELECT * FROM user WHERE user_name=?");
                            ps.setString(1, username);
                            rs = ps.executeQuery();

                            if (rs.next()) {
                    %>
                    <p><strong>Name :</strong> <%= rs.getString("name") != null ? rs.getString("name") : "No name available" %></p><br>
                    <p><strong>Email :</strong> <%= rs.getString("email") != null ? rs.getString("email") : "No email available" %></p><br>
                    <p><strong>Mobile number :</strong> <%= rs.getString("mobile_no") != null ? rs.getString("mobile_no") : "No mobile number" %></p><br>
                    <p><strong>User Name :</strong> <%= rs.getString("user_name") != null ? rs.getString("user_name") : "No user name" %></p>
                            <% } else { %>
                                <p>No user data available for user.</p>
                            <% }
                        } catch (Exception e) {
                            out.println("<p style='color:red;'>Database Error: " + e.getMessage() + "</p>");
                        } finally {
                            try {
                                if (rs != null) rs.close();
                                if (ps != null) ps.close();
                                if (con != null) con.close();
                            } catch (SQLException e) {
                                e.printStackTrace();
                            }
                        }
                    %>
                </section>

                <section id="calendar" class="section" style="padding-bottom: 50px;">
                    <h2>Find Tasks</h2><br>
                     <div style="display: flex; justify-content: center; align-items: center;">
                    <form method="get" action="ii.jsp">
                        <input type="date" id="taskDate" name="taskDate" required style="padding:10px;height: 35px;width: 150px;border-radius: 5px;border: 1px solid #ccc;">
                        <button type="submit" style="background-color:#2ecc71;width: 30px;height: 30px;border-radius: 5px;border-color: #2ecc71;">Go</button>
                    </form></div><br><br>
                    <h2>Task List</h2><br>
                    <div class="task-list">
                            <% 
                                try {
                                        String selectedDate = request.getParameter("taskDate");
                                        Class.forName("com.mysql.cj.jdbc.Driver");
                                        con = DriverManager.getConnection("jdbc:mysql://localhost:3306/task", "root", "*******");
                                        String query = "SELECT * FROM tasks WHERE user_name=? AND date=?";
                                        ps = con.prepareStatement(query);
                                        ps.setString(1, username);
                                        ps.setString(2, selectedDate);
                                        rs = ps.executeQuery();
                
                                        boolean hasData = false;
                                        while (rs.next()) {
                                            hasData = true;
                            %>
                                            <li class="task-card">
                                                <h3><strong><%= rs.getString("task_name") %></strong></h3>
                                                <p><strong>Description:</strong> <%= rs.getString("discription") %></p>
                                                <p><strong>Priority:</strong> <%= rs.getString("priority") %></p>
                                                <p><strong>Due Date:</strong> <%= rs.getString("date") %></p>
                                                <div style="display: flex; gap: 110px;padding-left:15px;height:25px;">
                                                    <form action="delete.jsp" method="post">
                                                        <input type="hidden" name="taskName" value="<%= rs.getString("task_name") %>">
                                                        <input type="hidden" name="taskDescription" value="<%= rs.getString("discription") %>">
                                                        <input type="hidden" name="taskPriority" value="<%= rs.getString("priority") %>">
                                                        <input type="hidden" name="taskDate" value="<%= rs.getString("date") %>">
                                                        <button type="submit" onclick="return confirm('Are you sure you want to delete this task?');" style="border-radius: 5px; width: 50px;background-color: rgb(184,224,210);">
                                                            Delete
                                                        </button>
                                                    </form>
                                                    <form action="complete.jsp" method="post">
                                                        <input type="hidden" name="taskName" value="<%= rs.getString("task_name") %>">
                                                        <input type="hidden" name="taskDescription" value="<%= rs.getString("discription") %>">
                                                        <input type="hidden" name="taskPriority" value="<%= rs.getString("priority") %>">
                                                        <input type="hidden" name="taskDate" value="<%= rs.getString("date") %>">
                                                        <button type="submit" onclick="return confirm('Are you sure you completed this task?');" style="border-radius: 5px; width: 70px;background-color: rgb(184,224,210);">
                                                            Complete
                                                        </button>
                                                    </form>                                    
                                                </div>
                                            </li>
                            <%  
                                        }
                                        if (!hasData) {
                                            out.println("<p>No tasks found for the selected date: " + selectedDate + " </p>");
                                        }
                                } catch (Exception e) {
                                    e.printStackTrace();
                                    out.println("<p style='color:red;'>Error: " + e.getMessage() + "</p>");
                                } finally {
                                    try {
                                        if (rs != null) rs.close();
                                        if (ps != null) ps.close();
                                        if (con != null) con.close();
                                    } catch (SQLException e) {
                                        e.printStackTrace();
                                    }
                                }
                            %>
                    </div>
                </section>
                
                <section id="trash" class="section">
                    <h2>Trash</h2><br><br>
                    <div class="task-list">
                        <%
                            try {
                                Class.forName("com.mysql.cj.jdbc.Driver");
                                con = DriverManager.getConnection("jdbc:mysql://localhost:3306/task", "root", "*******");
                                String query = "SELECT * FROM delete_tas WHERE user_name=?";
                                ps = con.prepareStatement(query);
                                ps.setString(1, username);
                                rs = ps.executeQuery();
                                boolean hasData = false;
                                while (rs.next()) {
                                    hasData = true;
                        %>
                        <li class="task-card">
                            <h3><strong><%= rs.getString("task_name") %></strong></h3>
                            <p><strong>Description:</strong> <%= rs.getString("discription") %></p>
                            <p><strong>Priority:</strong> <%= rs.getString("priority") %></p>
                            <p><strong>Due Date:</strong> <%= rs.getString("date") %></p>
                            <div style="display: flex; gap: 110px;padding-left:15px;height:25px;justify-content: center;">
                                <form action="restore.jsp" method="post">
                                    <input type="hidden" name="taskName" value="<%= rs.getString("task_name") %>">
                                    <input type="hidden" name="taskDescription" value="<%= rs.getString("discription") %>">
                                    <input type="hidden" name="taskPriority" value="<%= rs.getString("priority") %>">
                                    <input type="hidden" name="taskDate" value="<%= rs.getString("date") %>">
                                    <button type="submit" onclick="return confirm('Are you sure you want to restore this task?');" style="border-radius: 5px; width: 70px;background-color: rgb(184,224,210);">
                                        Restore
                                    </button>
                                </form>                                    
                            </div>
                        </li>
                        <%
                                }
                                if (!hasData) {
                                    out.println("<p>No tasks found for user: " + username + "</p>");
                                }
                            } catch (Exception e) {
                                e.printStackTrace();
                                out.println("<p style='color:red;'>Error: " + e.getMessage() + "</p>");
                            } finally {
                                try {
                                    if (rs != null) rs.close();
                                    if (ps != null) ps.close();
                                    if (con != null) con.close();
                                } catch (SQLException e) {
                                    e.printStackTrace();
                                }
                            }
                        %>
                    </div>
                </section>
            </div>
        </div>
    </div>
    <script src="script.js"></script>
</body>
</html>
