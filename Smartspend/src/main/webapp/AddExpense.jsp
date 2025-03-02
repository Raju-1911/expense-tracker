<%@ page import="java.sql.Date" %>
<%@ page import="java.sql.Connection" %>
<%@ page import="java.sql.PreparedStatement" %>
<%@ page import="java.sql.ResultSet" %>
<%@ page import="java.util.ArrayList" %>
<%@ page import="java.util.List" %>
<%@ page import="util.DBconnection" %>
<%
    Integer userId = (Integer) session.getAttribute("userId");
    if (userId == null) {
        response.sendRedirect("login.jsp?redirect=AddExpense.jsp");
        return;
    }

    String successMessage = null;
    String errorMessage = null;

    if (request.getMethod().equals("POST") && request.getParameter("action") != null && request.getParameter("action").equals("add")) {
        String name = request.getParameter("name");
        double amount = Double.parseDouble(request.getParameter("amount"));
        String category = request.getParameter("category");
        String date = request.getParameter("date");

        try {
            Connection con = DBconnection.getConnection();
            PreparedStatement pst = con.prepareStatement("INSERT INTO expenses (name, amount, category, date, user_id) VALUES (?, ?, ?, ?, ?)");
            pst.setString(1, name);
            pst.setDouble(2, amount);
            pst.setString(3, category);
            pst.setDate(4, Date.valueOf(date));
            pst.setInt(5, userId);
            pst.executeUpdate();
            response.sendRedirect("AddExpense.jsp?success=added");
            return;
        } catch (Exception e) {
            errorMessage = "Error: " + e.getMessage();
        }
    }

    if (request.getMethod().equals("POST") && request.getParameter("action") != null && request.getParameter("action").equals("delete")) {
        int id = Integer.parseInt(request.getParameter("id"));
        try {
            Connection con = DBconnection.getConnection();
            PreparedStatement pst = con.prepareStatement("DELETE FROM expenses WHERE id = ? AND user_id = ?");
            pst.setInt(1, id);
            pst.setInt(2, userId);
            int rows = pst.executeUpdate();
            if (rows > 0) {
                response.sendRedirect("AddExpense.jsp?success=deleted");
            } else {
                response.sendRedirect("AddExpense.jsp?error=notfound");
            }
            return;
        } catch (Exception e) {
            errorMessage = "Error: " + e.getMessage();
        }
    }

    if (request.getParameter("success") != null) {
        if (request.getParameter("success").equals("added")) {
            successMessage = "Expense added successfully!";
        } else if (request.getParameter("success").equals("deleted")) {
            successMessage = "Expense deleted successfully!";
        }
    }

    if (request.getParameter("error") != null) {
        if (request.getParameter("error").equals("notfound")) {
            errorMessage = "No expense found with that ID.";
        }
    }

    String filterCategory = request.getParameter("filterCategory") != null ? request.getParameter("filterCategory") : "";
    String filterStartDate = request.getParameter("filterStartDate") != null ? request.getParameter("filterStartDate") : "";
    String filterEndDate = request.getParameter("filterEndDate") != null ? request.getParameter("filterEndDate") : "";
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Daily Expenses</title>
    <link href="https://fonts.googleapis.com/css2?family=Poppins:wght@300;400;500;600;700&display=swap" rel="stylesheet">
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">
    <style>
        :root {
            --primary: #6366f1;
            --primary-dark: #4f46e5;
            --primary-light: #818cf8;
            --secondary: #f59e0b;
            --secondary-light: #fbbf24;
            --success: #10b981;
            --success-light: #d1fae5;
            --danger: #ef4444;
            --danger-light: #fee2e2;
            --text: #1e293b;
            --text-light: #64748b;
            --text-white: #f8fafc;
            --bg: #f1f5f9;
            --card: #ffffff;
            --card-hover: #f8fafc;
            --border: #e2e8f0;
            --border-focus: #cbd5e1;
            --shadow-sm: 0 1px 2px 0 rgba(0, 0, 0, 0.05);
            --shadow: 0 4px 6px -1px rgba(0, 0, 0, 0.1), 0 2px 4px -1px rgba(0, 0, 0, 0.06);
            --shadow-lg: 0 10px 15px -3px rgba(0, 0, 0, 0.1), 0 4px 6px -2px rgba(0, 0, 0, 0.05);
        }

        * {
            margin: 0;
            padding: 0;
            box-sizing: border-box;
        }

        body {
            font-family: 'Poppins', sans-serif;
            background-color: var(--bg);
            color: var(--text);
            line-height: 1.6;
            min-height: 100vh;
            display: flex;
        }

        .app-container {
            display: flex;
            flex-direction: column;
            width: 100%;
            margin-left: 300px;
        }

        .app-header {
            background: linear-gradient(135deg, #6366f1 0%, #4f46e5 100%);
            color: white;
            padding: 1.5rem 2rem;
            box-shadow: var(--shadow);
            position: sticky;
            top: 0;
            z-index: 100;
        }

        .header-content {
            max-width: 1200px;
            margin: 0 auto;
            display: flex;
            justify-content: space-between;
            align-items: center;
        }

        .app-title {
            font-size: 1.75rem;
            font-weight: 700;
            display: flex;
            align-items: center;
            gap: 0.75rem;
            letter-spacing: -0.5px;
        }

        .sidebar {
            width: 300px;
            background-color: var(--card);
            box-shadow: var(--shadow-lg);
            position: fixed;
            top: 0;
            bottom: 0;
            left: 0;
            z-index: 10;
            padding: 2rem;
            overflow-y: auto;
        }

        .sidebar-header {
            margin-bottom: 1.5rem;
        }

        .sidebar-title {
            font-size: 1.5rem;
            font-weight: 600;
            color: var(--primary-dark);
        }

        .sidebar-body {
            display: flex;
            flex-direction: column;
            gap: 1rem;
        }

        .container {
            max-width: 1200px;
            margin: 0 auto;
            padding: 2rem;
            flex-grow: 1;
        }

        .message {
            padding: 1rem 1.25rem;
            border-radius: 0.5rem;
            margin-bottom: 1.5rem;
            display: flex;
            align-items: center;
            gap: 0.75rem;
            opacity: 0.95;
            box-shadow: var(--shadow-sm);
            animation: fadeIn 0.5s ease;
        }

        @keyframes fadeIn {
            from { opacity: 0; transform: translateY(-10px); }
            to { opacity: 0.95; transform: translateY(0); }
        }

        .success {
            background-color: var(--success-light);
            color: var(--success);
            border-left: 4px solid var(--success);
        }

        .error {
            background-color: var(--danger-light);
            color: var(--danger);
            border-left: 4px solid var(--danger);
        }

        .card {
            background-color: var(--card);
            border-radius: 1rem;
            box-shadow: var(--shadow);
            margin-bottom: 2rem;
            overflow: hidden;
            transition: transform 0.3s ease, box-shadow 0.3s ease;
        }

        .card-header {
            background: linear-gradient(to right, rgba(99, 102, 241, 0.1), rgba(99, 102, 241, 0.05));
            padding: 1.25rem 1.5rem;
            border-bottom: 1px solid var(--border);
        }

        .card-title {
            font-size: 1.25rem;
            font-weight: 600;
            color: var(--primary-dark);
            display: flex;
            align-items: center;
            gap: 0.75rem;
        }

        .card-body {
            padding: 1.5rem;
        }

        .form-row {
            display: flex;
            gap: 1.25rem;
            margin-bottom: 1.25rem;
            flex-wrap: wrap;
        }

        .form-group {
            flex: 1;
            min-width: 200px;
        }

        .form-control {
            width: 100%;
            padding: 0.75rem 1rem;
            border: 1px solid var(--border);
            border-radius: 0.5rem;
            font-family: inherit;
            font-size: 0.875rem;
            transition: all 0.2s;
            background-color: #f8fafc;
        }

        .btn {
            display: inline-flex;
            align-items: center;
            justify-content: center;
            gap: 0.5rem;
            padding: 0.75rem 1.25rem;
            border-radius: 0.5rem;
            font-weight: 500;
            font-size: 0.875rem;
            cursor: pointer;
            transition: all 0.2s;
            border: none;
            box-shadow: var(--shadow-sm);
        }

        .btn-primary {
            background-color: var(--primary);
            color: white;
        }

        .table-container {
            overflow-x: auto;
            border-radius: 0.5rem;
            box-shadow: var(--shadow-sm);
        }

        table {
            width: 100%;
            border-collapse: collapse;
            font-size: 0.875rem;
        }

        th, td {
            padding: 1rem;
            text-align: left;
            border-bottom: 1px solid var(--border);
        }

        .category-badge {
            display: inline-flex;
            align-items: center;
            padding: 0.25rem 0.75rem;
            border-radius: 50px;
            font-size: 0.75rem;
            font-weight: 500;
        }

        .category-Food { background-color: #e0f2fe; color: #0284c7; }
        .category-Transport { background-color: #dcfce7; color: #16a34a; }
        .category-Bills { background-color: #ffedd5; color: #ea580c; }
        .category-Entertainment { background-color: #fee2e2; color: #dc2626; }
        .category-Other { background-color: #f3e8ff; color: #9333ea; }

        .action-btn {
            display: inline-flex;
            align-items: center;
            justify-content: center;
            width: 2rem;
            height: 2rem;
            border-radius: 50%;
            background-color: var(--danger-light);
            color: var(--danger);
            border: none;
            cursor: pointer;
            transition: all 0.2s;
        }

        .empty-state {
            display: flex;
            flex-direction: column;
            align-items: center;
            justify-content: center;
            padding: 3rem 1rem;
            text-align: center;
            color: var(--text-light);
        }

        .quick-actions {
            position: fixed;
            bottom: 2rem;
            right: 2rem;
            display: flex;
            flex-direction: column;
            gap: 1rem;
            z-index: 5;
        }

        .quick-action-btn {
            width: 3.5rem;
            height: 3.5rem;
            border-radius: 50%;
            display: flex;
            align-items: center;
            justify-content: center;
            background-color: var(--primary);
            color: white;
            box-shadow: var(--shadow-lg);
            border: none;
            cursor: pointer;
        }

        @media (max-width: 768px) {
            .app-container {
                margin-left: 0;
            }
            .sidebar {
                display: none;
            }
        }
    </style>
</head>
<body>
    <div class="sidebar">
        <div class="sidebar-header">
            <h2 class="sidebar-title">Daily Expenses</h2>
        </div>
        <div class="sidebar-body">
            <button class="btn btn-primary" onclick="toggleAddExpenseForm()">
                <i class="fas fa-plus-circle"></i> Add Expense
            </button>
            <button class="btn btn-outline" onclick="toggleFilterForm()">
                <i class="fas fa-filter"></i> Filter Expenses
            </button>
            <a href="dashboard.jsp" class="btn btn-outline">
                <i class="fas fa-arrow-left"></i> Dashboard
            </a>
        </div>
    </div>

    <div class="app-container">
        <header class="app-header">
            <div class="header-content">
                <h1 class="app-title">
                    <i class="fas fa-coins"></i>
                    Welcome to Your Daily Expenses
                </h1>
            </div>
        </header>

        <div class="main-content">
            <div class="container">
                <% if (successMessage != null) { %>
                    <div class="message success">
                        <i class="fas fa-check-circle"></i>
                        <%= successMessage %>
                    </div>
                <% } %>

                <% if (errorMessage != null) { %>
                    <div class="message error">
                        <i class="fas fa-exclamation-circle"></i>
                        <%= errorMessage %>
                    </div>
                <% } %>

                <div class="card">
                    <div class="card-header">
                        <h2 class="card-title">
                            <i class="fas fa-receipt"></i>
                            Expense Records
                        </h2>
                    </div>
                    <div class="card-body">
                        <%
                            Connection con = null;
                            PreparedStatement pst = null;
                            ResultSet rs = null;
                            try {
                                con = DBconnection.getConnection();
                                String query = "SELECT * FROM expenses WHERE user_id = ?";
                                List<Object> params = new ArrayList<>();
                                params.add(userId);

                                if (!filterCategory.isEmpty()) {
                                    query += " AND category = ?";
                                    params.add(filterCategory);
                                }
                                if (!filterStartDate.isEmpty()) {
                                    query += " AND date >= ?";
                                    params.add(Date.valueOf(filterStartDate));
                                }
                                if (!filterEndDate.isEmpty()) {
                                    query += " AND date <= ?";
                                    params.add(Date.valueOf(filterEndDate));
                                }

                                query += " ORDER BY date DESC";
                                pst = con.prepareStatement(query);
                                
                                int paramIndex = 1;
                                for (Object param : params) {
                                    if (param instanceof String) {
                                        pst.setString(paramIndex++, (String) param);
                                    } else if (param instanceof Date) {
                                        pst.setDate(paramIndex++, (Date) param);
                                    } else if (param instanceof Integer) {
                                        pst.setInt(paramIndex++, (Integer) param);
                                    }
                                }

                                rs = pst.executeQuery();
                                boolean hasRecords = false;
                        %>
                        <div class="table-container">
                            <table>
                                <thead>
                                    <tr>
                                        <th>Date</th>
                                        <th>Description</th>
                                        <th>Category</th>
                                        <th>Amount</th>
                                        <th>Action</th>
                                    </tr>
                                </thead>
                                <tbody>
                                    <% while (rs.next()) { 
                                        hasRecords = true;
                                        String category = rs.getString("category");
                                        String icon = "";
                                        switch(category) {
                                            case "Food": icon = "fa-utensils"; break;
                                            case "Transport": icon = "fa-bus"; break;
                                            case "Bills": icon = "fa-file-invoice"; break;
                                            case "Entertainment": icon = "fa-gamepad"; break;
                                            default: icon = "fa-tag";
                                        }
                                    %>
                                    <tr>
                                        <td><%= rs.getDate("date") %></td>
                                        <td><%= rs.getString("name") %></td>
                                        <td>
                                            <span class="category-badge category-<%= category %>">
                                                <i class="fas <%= icon %>"></i>
                                                <%= category %>
                                            </span>
                                        </td>
                                        <td>$<%= String.format("%.2f", rs.getDouble("amount")) %></td>
                                        <td>
                                            <form method="post" onsubmit="return confirm('Delete this expense?')">
                                                <input type="hidden" name="action" value="delete">
                                                <input type="hidden" name="id" value="<%= rs.getInt("id") %>">
                                                <button type="submit" class="action-btn">
                                                    <i class="fas fa-trash"></i>
                                                </button>
                                            </form>
                                        </td>
                                    </tr>
                                    <% } 
                                    if (!hasRecords) { %>
                                    <tr>
                                        <td colspan="5">
                                            <div class="empty-state">
                                                <i class="fas fa-inbox"></i>
                                                <p>No expenses recorded yet</p>
                                            </div>
                                        </td>
                                    </tr>
                                    <% } %>
                                </tbody>
                            </table>
                        </div>
                        <% } catch (Exception e) {
                            out.println("<div class='message error'><i class='fas fa-exclamation-circle'></i> Error loading expenses: " + e.getMessage() + "</div>");
                        } finally {
                            try { if (rs != null) rs.close(); } catch (Exception e) {}
                            try { if (pst != null) pst.close(); } catch (Exception e) {}
                        } %>
                    </div>
                </div>

                <div class="card" id="addExpenseForm" style="display: none;">
                    <div class="card-header">
                        <h2 class="card-title">
                            <i class="fas fa-plus"></i>
                            New Expense
                        </h2>
                    </div>
                    <div class="card-body">
                        <form method="post" action="AddExpense.jsp">
                            <input type="hidden" name="action" value="add">
                            <div class="form-row">
                                <div class="form-group">
                                    <label>Description</label>
                                    <input type="text" name="name" class="form-control" required>
                                </div>
                                <div class="form-group">
                                    <label>Amount</label>
                                    <input type="number" step="0.01" name="amount" class="form-control" required>
                                </div>
                            </div>
                            <div class="form-row">
                                <div class="form-group">
                                    <label>Category</label>
                                    <select name="category" class="form-control" required>
                                        <option value="Food">Food</option>
                                        <option value="Transport">Transport</option>
                                        <option value="Bills">Bills</option>
                                        <option value="Entertainment">Entertainment</option>
                                        <option value="Other">Other</option>
                                    </select>
                                </div>
                                <div class="form-group">
                                    <label>Date</label>
                                    <input type="date" name="date" class="form-control" required>
                                </div>
                            </div>
                            <div class="form-row">
                                <button type="submit" class="btn btn-primary">
                                    <i class="fas fa-save"></i> Save Expense
                                </button>
                            </div>
                        </form>
                    </div>
                </div>

                <div class="card" id="filterForm" style="display: none;">
                    <div class="card-header">
                        <h2 class="card-title">
                            <i class="fas fa-filter"></i>
                            Filter Options
                        </h2>
                    </div>
                    <div class="card-body">
                        <form id="filterFormContent">
                            <div class="form-row">
                                <div class="form-group">
                                    <label>Category</label>
                                    <select name="filterCategory" class="form-control">
                                        <option value="">All Categories</option>
                                        <option value="Food" <%= "Food".equals(filterCategory) ? "selected" : "" %>>Food</option>
                                        <option value="Transport" <%= "Transport".equals(filterCategory) ? "selected" : "" %>>Transport</option>
                                        <option value="Bills" <%= "Bills".equals(filterCategory) ? "selected" : "" %>>Bills</option>
                                        <option value="Entertainment" <%= "Entertainment".equals(filterCategory) ? "selected" : "" %>>Entertainment</option>
                                        <option value="Other" <%= "Other".equals(filterCategory) ? "selected" : "" %>>Other</option>
                                    </select>
                                </div>
                                <div class="form-group">
                                    <label>From Date</label>
                                    <input type="date" name="filterStartDate" class="form-control" value="<%= filterStartDate %>">
                                </div>
                                <div class="form-group">
                                    <label>To Date</label>
                                    <input type="date" name="filterEndDate" class="form-control" value="<%= filterEndDate %>">
                                </div>
                            </div>
                            <div class="form-row">
                                <button type="button" onclick="applyFilters()" class="btn btn-primary">
                                    <i class="fas fa-filter"></i> Apply Filters
                                </button>
                                <button type="button" onclick="clearFilters()" class="btn btn-outline">
                                    <i class="fas fa-times"></i> Clear
                                </button>
                            </div>
                        </form>
                    </div>
                </div>
            </div>
        </div>

        <div class="quick-actions">
            <button class="quick-action-btn" onclick="toggleAddExpenseForm()">
                <i class="fas fa-plus"></i>
            </button>
        </div>
    </div>

    <script>
        function toggleAddExpenseForm() {
            const form = document.getElementById('addExpenseForm');
            form.style.display = form.style.display === 'none' ? 'block' : 'none';
            document.getElementById('filterForm').style.display = 'none';
            if (form.style.display === 'block') {
                form.scrollIntoView({ behavior: 'smooth' });
                document.querySelector('input[name="date"]').valueAsDate = new Date();
            }
        }

        function toggleFilterForm() {
            const form = document.getElementById('filterForm');
            form.style.display = form.style.display === 'none' ? 'block' : 'none';
            document.getElementById('addExpenseForm').style.display = 'none';
            if (form.style.display === 'block') {
                form.scrollIntoView({ behavior: 'smooth' });
            }
        }

        function applyFilters() {
            const form = document.getElementById('filterFormContent');
            const params = new URLSearchParams(new FormData(form));
            window.location.href = `AddExpense.jsp?${params.toString()}`;
        }

        function clearFilters() {
            window.location.href = 'AddExpense.jsp';
        }

        // Auto-hide messages after 5 seconds
        setTimeout(() => {
            document.querySelectorAll('.message').forEach(msg => {
                msg.style.opacity = '0';
                setTimeout(() => msg.remove(), 500);
            });
        }, 5000);
    </script>
</body>
</html>