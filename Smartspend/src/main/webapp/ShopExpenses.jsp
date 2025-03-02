<%@ page import="java.sql.*" %>
<%@ page import="java.text.DecimalFormat" %>
<%@ page import="java.util.ArrayList" %>
<%@ page import="java.util.List" %>
<%@ page import="util.DBconnection" %>
<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Expense Tracker Pro</title>
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.0.0/css/all.min.css">
    <style>
        body {
            font-family: 'Segoe UI', 'Arial', sans-serif;
            background: linear-gradient(135deg, #1e3a5f 0%, #0d1b2a 100%);
            margin: 0;
            padding: 0;
            color: #fff;
            min-height: 100vh;
        }

        .back-button, .analytics-button {
            position: fixed;
            top: 20px;
            padding: 10px 20px;
            border-radius: 6px;
            cursor: pointer;
            text-decoration: none;
            z-index: 1000;
            background: rgba(30, 77, 140, 0.8);
            color: white;
            border: 1px solid #2d6bbd;
            transition: all 0.3s ease;
            backdrop-filter: blur(5px);
            display: flex;
            align-items: center;
            gap: 8px;
            font-weight: 500;
        }

        .back-button {
            left: 20px;
        }

        .analytics-button {
            right: 20px;
        }

        .back-button:hover, .analytics-button:hover {
            background: rgba(45, 107, 189, 0.9);
            transform: translateY(-2px);
            box-shadow: 0 4px 8px rgba(0, 0, 0, 0.2);
        }

        .container {
            max-width: 1200px;
            margin: 80px auto 40px;
            padding: 30px;
            background: rgba(26, 54, 93, 0.8);
            box-shadow: 0 8px 32px rgba(0, 0, 0, 0.3);
            border-radius: 12px;
            backdrop-filter: blur(10px);
            border: 1px solid rgba(255, 255, 255, 0.1);
        }

        .summary {
            display: flex;
            justify-content: space-between;
            margin-bottom: 30px;
            gap: 20px;
        }

        .summary-item {
            flex: 1;
            padding: 25px;
            background: rgba(35, 72, 118, 0.7);
            border-radius: 12px;
            text-align: center;
            box-shadow: 0 4px 20px rgba(0, 0, 0, 0.15);
            position: relative;
            border: 1px solid rgba(45, 107, 189, 0.3);
            transition: all 0.3s ease;
        }
        
        .summary-item:hover {
            transform: translateY(-5px);
            box-shadow: 0 8px 25px rgba(0, 0, 0, 0.2);
            background: rgba(35, 72, 118, 0.8);
        }

        .summary-item .trend {
            position: absolute;
            top: 15px;
            right: 15px;
            font-size: 14px;
            font-weight: 600;
            padding: 4px 8px;
            border-radius: 20px;
            background: rgba(0, 0, 0, 0.2);
        }

        .trend.positive {
            color: #4ade80;
        }

        .trend.negative {
            color: #f87171;
        }

        .summary-item h3 {
            margin: 0 0 15px 0;
            color: #fff;
            font-size: 18px;
            font-weight: 500;
        }

        .summary-item .value {
            font-size: 28px;
            font-weight: bold;
            color: #fff;
            margin-bottom: 10px;
        }

        .form-row {
            display: flex;
            gap: 20px;
            margin-bottom: 25px;
        }

        .form-group {
            flex: 1;
        }

        .form-group label {
            display: block;
            margin-bottom: 8px;
            font-weight: 500;
            color: #fff;
            font-size: 15px;
        }

        .form-group input, .form-group select {
            width: 100%;
            padding: 12px 15px;
            border: 1px solid rgba(45, 107, 189, 0.3);
            border-radius: 6px;
            box-sizing: border-box;
            background: rgba(35, 72, 118, 0.4);
            color: #fff;
            font-size: 15px;
            transition: all 0.3s ease;
        }

        .form-group input:focus, .form-group select:focus {
            outline: none;
            border-color: #4d8fdb;
            background: rgba(35, 72, 118, 0.6);
            box-shadow: 0 0 0 2px rgba(77, 143, 219, 0.2);
        }

        button {
            background: #1e4d8c;
            color: white;
            border: 1px solid #2d6bbd;
            padding: 12px 24px;
            border-radius: 6px;
            cursor: pointer;
            font-weight: 500;
            transition: all 0.3s ease;
            font-size: 15px;
            display: flex;
            align-items: center;
            gap: 8px;
        }

        button:hover {
            background: #2d6bbd;
            transform: translateY(-2px);
            box-shadow: 0 4px 8px rgba(0, 0, 0, 0.2);
        }

        .filter-section {
            background: rgba(35, 72, 118, 0.4);
            padding: 25px;
            border-radius: 12px;
            margin-bottom: 30px;
            border: 1px solid rgba(45, 107, 189, 0.3);
        }

        table {
            width: 100%;
            border-collapse: collapse;
            margin-top: 25px;
            background: rgba(35, 72, 118, 0.4);
            border-radius: 12px;
            overflow: hidden;
            box-shadow: 0 4px 20px rgba(0, 0, 0, 0.15);
        }

        table th, table td {
            padding: 15px;
            text-align: left;
            border-bottom: 1px solid rgba(45, 107, 189, 0.3);
            color: #fff;
        }

        table th {
            background: rgba(30, 77, 140, 0.6);
            font-weight: 500;
            font-size: 15px;
        }

        table tr:hover {
            background-color: rgba(26, 54, 93, 0.6);
        }

        .delete-btn {
            background: rgba(220, 38, 38, 0.8);
            color: white;
            border: none;
            padding: 8px 14px;
            border-radius: 6px;
            cursor: pointer;
            transition: all 0.3s ease;
        }

        .delete-btn:hover {
            background: rgba(185, 28, 28, 0.9);
            transform: translateY(-2px);
        }

        /* Pop-up Notification Styles */
        .notification {
            position: fixed;
            top: 20px;
            right: 20px;
            padding: 16px 24px;
            border-radius: 8px;
            color: #fff;
            font-weight: 500;
            box-shadow: 0 4px 12px rgba(0, 0, 0, 0.15);
            display: flex;
            align-items: center;
            gap: 12px;
            transform: translateX(150%);
            transition: transform 0.5s cubic-bezier(0.68, -0.55, 0.27, 1.55);
            z-index: 1001;
            max-width: 350px;
        }

        .notification.success {
            background: rgba(6, 95, 70, 0.9);
            border-left: 4px solid #10b981;
        }

        .notification.error {
            background: rgba(153, 27, 27, 0.9);
            border-left: 4px solid #ef4444;
        }

        .notification.show {
            transform: translateX(0);
        }

        .notification-icon {
            font-size: 20px;
        }

        .notification-content {
            flex: 1;
        }

        .notification-close {
            background: none;
            border: none;
            color: rgba(255, 255, 255, 0.7);
            font-size: 18px;
            cursor: pointer;
            padding: 0;
            margin: 0;
            transition: color 0.3s ease;
        }

        .notification-close:hover {
            color: #fff;
            transform: none;
        }

        .page-title {
            text-align: center;
            margin-bottom: 30px;
            color: #fff;
            font-size: 30px;
            font-weight: 600;
        }

        .empty-state {
            text-align: center;
            padding: 30px;
            color: rgba(255, 255, 255, 0.7);
            font-style: italic;
        }

        @media (max-width: 768px) {
            .container {
                margin: 70px 15px 30px;
                padding: 20px;
            }
            
            .form-row, .summary {
                flex-direction: column;
            }
            
            .back-button, .analytics-button {
                padding: 8px 16px;
                font-size: 14px;
            }
        }
    </style>
</head>
<body>
    <a href="dashboard.jsp" class="back-button"><i class="fas fa-arrow-left"></i> Back</a>
    <a href="shopanalytics.jsp" class="analytics-button"><i class="fas fa-chart-line"></i> Analytics</a>
    
    <div class="container">
        <h1 class="page-title">Expense Tracker Pro</h1>

        <%!
        public static class Summary {
            private double totalExpenditure;
            private double totalIncome;
            private double totalProfit;
            private double previousTotalExpenditure;
            private double previousTotalIncome;
            private double previousTotalProfit;

            public Summary() {
                this.totalExpenditure = 0.0;
                this.totalIncome = 0.0;
                this.totalProfit = 0.0;
                this.previousTotalExpenditure = 0.0;
                this.previousTotalIncome = 0.0;
                this.previousTotalProfit = 0.0;
            }

            public void calculate(Connection conn, int userId, String startDate, String endDate) throws SQLException {
                String currentPeriodSql = "SELECT COALESCE(SUM(expenditure), 0) as total_expenditure, COALESCE(SUM(income), 0) as total_income, COALESCE(SUM(profit), 0) as total_profit FROM shop_daily_expenses WHERE user_id = ?";
                String previousPeriodSql = "SELECT COALESCE(SUM(expenditure), 0) as previous_total_expenditure, COALESCE(SUM(income), 0) as previous_total_income, COALESCE(SUM(profit), 0) as previous_total_profit FROM shop_daily_expenses WHERE user_id = ?";

                if (startDate != null && !startDate.trim().isEmpty() && endDate != null && !endDate.trim().isEmpty()) {
                    currentPeriodSql += " AND date BETWEEN ? AND ?";
                    previousPeriodSql += " AND date BETWEEN DATE_SUB(?, INTERVAL DATEDIFF(?, ?) DAY) AND ?";
                }

                try (PreparedStatement currentStmt = conn.prepareStatement(currentPeriodSql);
                     PreparedStatement previousStmt = conn.prepareStatement(previousPeriodSql)) {
                    
                    currentStmt.setInt(1, userId);
                    previousStmt.setInt(1, userId);
                    
                    if (startDate != null && !startDate.trim().isEmpty() && endDate != null && !endDate.trim().isEmpty()) {
                        currentStmt.setString(2, startDate);
                        currentStmt.setString(3, endDate);
                        
                        previousStmt.setString(2, startDate);
                        previousStmt.setString(3, endDate);
                        previousStmt.setString(4, startDate);
                        previousStmt.setString(5, endDate);
                    }
                    
                    ResultSet currentRs = currentStmt.executeQuery();
                    ResultSet previousRs = previousStmt.executeQuery();
                    
                    if (currentRs.next()) {
                        this.totalExpenditure = currentRs.getDouble("total_expenditure");
                        this.totalIncome = currentRs.getDouble("total_income");
                        this.totalProfit = currentRs.getDouble("total_profit");
                    }
                    
                    if (previousRs.next()) {
                        this.previousTotalExpenditure = previousRs.getDouble("previous_total_expenditure");
                        this.previousTotalIncome = previousRs.getDouble("previous_total_income");
                        this.previousTotalProfit = previousRs.getDouble("previous_total_profit");
                    }
                }
            }

            public double getTotalExpenditure() { return totalExpenditure; }
            public double getTotalIncome() { return totalIncome; }
            public double getTotalProfit() { return totalProfit; }
            public double getPreviousTotalExpenditure() { return previousTotalExpenditure; }
            public double getPreviousTotalIncome() { return previousTotalIncome; }
            public double getPreviousTotalProfit() { return previousTotalProfit; }
        }

        public List<Object[]> fetchRecords(Connection conn, int userId, String startDate, String endDate) throws SQLException {
            List<Object[]> records = new ArrayList<>();
            
            String sql = "SELECT * FROM shop_daily_expenses WHERE user_id = ?";
            if (startDate != null && !startDate.trim().isEmpty() && endDate != null && !endDate.trim().isEmpty()) {
                sql += " AND date BETWEEN ? AND ?";
            }
            sql += " ORDER BY date DESC";

            try (PreparedStatement stmt = conn.prepareStatement(sql)) {
                stmt.setInt(1, userId);
                
                if (startDate != null && !startDate.trim().isEmpty() && endDate != null && !endDate.trim().isEmpty()) {
                    stmt.setString(2, startDate);
                    stmt.setString(3, endDate);
                }
                
                ResultSet rs = stmt.executeQuery();
                while (rs.next()) {
                    Object[] record = {
                        rs.getInt("id"),
                        rs.getString("date"),
                        rs.getDouble("expenditure"),
                        rs.getDouble("income"),
                        rs.getDouble("profit")
                    };
                    records.add(record);
                }
            }
            return records;
        }
        %>

        <%
        String message = "";
        String messageType = "";
        
        // Get the filter parameters
        String startDate = request.getParameter("startDate");
        String endDate = request.getParameter("endDate");
        
        if (request.getParameter("clear") != null) {
            startDate = null;
            endDate = null;
        }
        
        Connection conn = null;
        Summary summary = new Summary();
        List<Object[]> records = new ArrayList<>();
        DecimalFormat df = new DecimalFormat("#,##0.00");

        int userId = 0;
        HttpSession userSession = request.getSession(false);
        if (userSession != null && userSession.getAttribute("userId") != null) {
            userId = (Integer) userSession.getAttribute("userId");
        }

        // Check if it's a POST request to avoid duplicate submissions on refresh
        boolean isPostRequest = "POST".equalsIgnoreCase(request.getMethod());

        try {
            conn = DBconnection.getConnection();

            if (isPostRequest && request.getParameter("submit") != null) {
                try {
                    double expenditure = Double.parseDouble(request.getParameter("expenditure"));
                    double income = Double.parseDouble(request.getParameter("income"));
                    double profit = income - expenditure;
                    String date = request.getParameter("date");

                    String sql = "INSERT INTO shop_daily_expenses (expenditure, income, profit, date, user_id) VALUES (?, ?, ?, ?, ?)";
                    try (PreparedStatement stmt = conn.prepareStatement(sql)) {
                        stmt.setDouble(1, expenditure);
                        stmt.setDouble(2, income);
                        stmt.setDouble(3, profit);
                        stmt.setString(4, date);
                        stmt.setInt(5, userId);
                        
                        int result = stmt.executeUpdate();
                        if (result > 0) {
                            message = "Expense added successfully!";
                            messageType = "success";
                            // Redirect to prevent form resubmission on refresh
                            response.sendRedirect(request.getRequestURI() + "?success=add");
                            return;
                        }
                    }
                } catch (Exception e) {
                    message = "Error adding expense: " + e.getMessage();
                    messageType = "error";
                }
            }

            if (isPostRequest && request.getParameter("delete") != null) {
                try {
                    int id = Integer.parseInt(request.getParameter("id"));
                    String sql = "DELETE FROM shop_daily_expenses WHERE id = ? AND user_id = ?";
                    try (PreparedStatement stmt = conn.prepareStatement(sql)) {
                        stmt.setInt(1, id);
                        stmt.setInt(2, userId);
                        int result = stmt.executeUpdate();
                        if (result > 0) {
                            message = "Record deleted successfully!";
                            messageType = "success";
                            // Redirect to prevent form resubmission on refresh
                            response.sendRedirect(request.getRequestURI() + "?success=delete");
                            return;
                        }
                    }
                } catch (Exception e) {
                    message = "Error deleting record: " + e.getMessage();
                    messageType = "error";
                }
            }
            
            // Handle GET parameters for notifications after redirect
            if (request.getParameter("success") != null) {
                String successAction = request.getParameter("success");
                if ("add".equals(successAction)) {
                    message = "Expense added successfully!";
                    messageType = "success";
                } else if ("delete".equals(successAction)) {
                    message = "Record deleted successfully!";
                    messageType = "success";
                }
            }

            summary.calculate(conn, userId, startDate, endDate);
            records = fetchRecords(conn, userId, startDate, endDate);

        } catch (Exception e) {
            message = "Database error: " + e.getMessage();
            messageType = "error";
        } finally {
            if (conn != null) {
                try {
                    conn.close();
                } catch (SQLException e) {
                    e.printStackTrace();
                }
            }
        }

        double expenditureTrend = summary.getPreviousTotalExpenditure() > 0 ? 
            ((summary.getTotalExpenditure() - summary.getPreviousTotalExpenditure()) / summary.getPreviousTotalExpenditure() * 100) : 0;
        double incomeTrend = summary.getPreviousTotalIncome() > 0 ? 
            ((summary.getTotalIncome() - summary.getPreviousTotalIncome()) / summary.getPreviousTotalIncome() * 100) : 0;
        double profitTrend = summary.getPreviousTotalProfit() > 0 ? 
            ((summary.getTotalProfit() - summary.getPreviousTotalProfit()) / summary.getPreviousTotalProfit() * 100) : 0;
        %>

        <!-- Notification pop-up -->
        <% if (!message.isEmpty()) { %>
        <div id="notification" class="notification <%= messageType %>">
            <div class="notification-icon">
                <i class="fas <%= messageType.equals("success") ? "fa-check-circle" : "fa-exclamation-circle" %>"></i>
            </div>
            <div class="notification-content">
                <%= message %>
            </div>
            <button class="notification-close" onclick="closeNotification()">
                <i class="fas fa-times"></i>
            </button>
        </div>
        <% } %>

        <div class="summary">
            <div class="summary-item">
                <h3>Total Expenditure</h3>
                <div class="value">$<%= df.format(summary.getTotalExpenditure()) %></div>
                <div class="trend <%= expenditureTrend < 0 ? "positive" : (expenditureTrend > 0 ? "negative" : "") %>">
                    <%= expenditureTrend != 0 ? (expenditureTrend < 0 ? "▼" : "▲") : "" %> <%= df.format(Math.abs(expenditureTrend)) %>%
                </div>
            </div>
            <div class="summary-item">
                <h3>Total Income</h3>
                <div class="value">$<%= df.format(summary.getTotalIncome()) %></div>
                <div class="trend <%= incomeTrend > 0 ? "positive" : (incomeTrend < 0 ? "negative" : "") %>">
                    <%= incomeTrend != 0 ? (incomeTrend > 0 ? "▲" : "▼") : "" %> <%= df.format(Math.abs(incomeTrend)) %>%
                </div>
            </div>
            <div class="summary-item">
                <h3>Total Profit</h3>
                <div class="value">$<%= df.format(summary.getTotalProfit()) %></div>
                <div class="trend <%= profitTrend > 0 ? "positive" : (profitTrend < 0 ? "negative" : "") %>">
                    <%= profitTrend != 0 ? (profitTrend > 0 ? "▲" : "▼") : "" %> <%= df.format(Math.abs(profitTrend)) %>%
                </div>
            </div>
        </div>

        <div class="filter-section">
            <form method="get" class="form-row">
                <div class="form-group">
                    <label for="startDate">Start Date</label>
                    <input type="date" id="startDate" name="startDate" value="<%= startDate != null ? startDate : "" %>">
                </div>
                <div class="form-group">
                    <label for="endDate">End Date</label>
                    <input type="date" id="endDate" name="endDate" value="<%= endDate != null ? endDate : "" %>">
                </div>
                <div class="form-group" style="display: flex; gap: 10px; align-items: flex-end;">
                    <button type="submit"><i class="fas fa-filter"></i> Apply Filter</button>
                    <button type="submit" name="clear" value="true"><i class="fas fa-eraser"></i> Clear Filter</button>
                </div>
            </form>
        </div>

        <form method="post" class="form-row" id="expenseForm">
            <div class="form-group">
                <label for="expenditure">Expenditure ($)</label>
                <input type="number" id="expenditure" name="expenditure" step="0.01" required min="0">
            </div>
            <div class="form-group">
                <label for="income">Income ($)</label>
                <input type="number" id="income" name="income" step="0.01" required min="0">
            </div>
            <div class="form-group">
                <label for="date">Date</label>
                <input type="date" id="date" name="date" required value="<%= new java.text.SimpleDateFormat("yyyy-MM-dd").format(new java.util.Date()) %>">
            </div>
            <div class="form-group" style="display: flex; align-items: flex-end;">
                <button type="submit" name="submit"><i class="fas fa-plus-circle"></i> Add Expense</button>
            </div>
        </form>

        <% if (!records.isEmpty()) { %>
        <table>
            <thead>
                <tr>
                    <th>Date</th>
                    <th>Expenditure</th>
                    <th>Income</th>
                    <th>Profit</th>
                    <th>Action</th>
                </tr>
            </thead>
            <tbody>
                <% for (Object[] record : records) { %>
                    <tr>
                        <td><%= record[1] %></td>
                        <td>$<%= df.format((Double)record[2]) %></td>
                        <td>$<%= df.format((Double)record[3]) %></td>
                        <td>$<%= df.format((Double)record[4]) %></td>
                        <td>
                            <form method="post" style="display: inline;" class="delete-form">
                                <input type="hidden" name="id" value="<%= record[0] %>">
                                <button type="submit" name="delete" class="delete-btn"><i class="fas fa-trash"></i></button>
                            </form>
                        </td>
                    </tr>
                <% } %>
            </tbody>
        </table>
        <% } else { %>
        <div class="empty-state">
            <p>No expense records found. Add your first expense using the form above.</p>
        </div>
        <% } %>

        <script>
            // Show notification
            const notification = document.getElementById('notification');
            if (notification) {
                setTimeout(() => {
                    notification.classList.add('show');
                }, 100);
                
                setTimeout(() => {
                    closeNotification();
                }, 5000);
            }
            
            function closeNotification() {
                const notification = document.getElementById('notification');
                if (notification) {
                    notification.classList.remove('show');
                    setTimeout(() => {
                        notification.remove();
                    }, 500);
                }
            }
            
            // Form validation for expense form
            document.getElementById('expenseForm').addEventListener('submit', function(e) {
                const expenditure = document.getElementById('expenditure').value;
                const income = document.getElementById('income').value;
                const date = document.getElementById('date').value;
                
                if (!expenditure || !income || !date) {
                    e.preventDefault();
                    alert('Please fill in all required fields');
                    return;
                }
                
                if (parseFloat(expenditure) < 0 || parseFloat(income) < 0) {
                    e.preventDefault();
                    alert('Values cannot be negative');
                    return;
                }
                
                if (!confirm('Are you sure you want to add this expense?')) {
                    e.preventDefault();
                }
            });

            // Form validation for filter
            document.querySelector('.filter-section form').addEventListener('submit', function(e) {
                if (!e.submitter || e.submitter.name !== 'clear') {
                    const startDate = document.getElementById('startDate').value;
                    const endDate = document.getElementById('endDate').value;
                    
                    if ((startDate && !endDate) || (!startDate && endDate)) {
                        e.preventDefault();
                        alert('Please select both start and end dates, or leave both empty');
                        return;
                    }
                    
                    if (startDate && endDate && startDate > endDate) {
                        e.preventDefault();
                        alert('Start date cannot be later than end date');
                    }
                }
            });
            
            // Confirm deletion
            document.querySelectorAll('.delete-form').forEach(form => {
                form.addEventListener('submit', function(e) {
                    if (!confirm('Are you sure you want to delete this record? This action cannot be undone.')) {
                        e.preventDefault();
                    }
                });
            });
        </script>
    </div>
</body>
</html>