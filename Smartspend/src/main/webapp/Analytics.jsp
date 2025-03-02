<%@ page import="java.sql.*" %>
<%@ page import="java.util.*" %>
<%@ page import="util.DBconnection" %>
<%@ page import="java.time.*" %>
<%@ page import="java.time.format.*" %>
<!DOCTYPE html>
<html>
<head>
    <title>Analytics Dashboard</title>
    <script src="https://cdnjs.cloudflare.com/ajax/libs/Chart.js/3.9.1/chart.min.js"></script>
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.5.1/css/all.min.css">
    <style>
        :root {
            --primary-color: #4299e1;
            --secondary-color: #2c5282;
            --background-color: #f7fafc;
            --card-background: #ffffff;
            --text-color: #2d3748;
            --border-color: #e2e8f0;
        }

        body {
            font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, sans-serif;
            margin: 0;
            padding: 0;
            background-color: var(--background-color);
            color: var(--text-color);
        }

        .header {
            background-color: var(--primary-color);
            color: white;
            padding: 1rem 2rem;
            box-shadow: 0 2px 4px rgba(0,0,0,0.1);
            display: flex;
            justify-content: space-between;
            align-items: center;
        }

        .header a {
            color: white;
            text-decoration: none;
            padding: 0.5rem 1rem;
            border: 2px solid white;
            border-radius: 4px;
            transition: all 0.3s;
        }

        .header a:hover {
            background-color: white;
            color: var(--primary-color);
        }

        .container {
            max-width: 1200px;
            margin: 2rem auto;
            padding: 0 1rem;
        }

        .stats-grid {
            display: grid;
            grid-template-columns: repeat(auto-fit, minmax(240px, 1fr));
            gap: 1.5rem;
            margin-bottom: 2rem;
        }

        .stat-card {
            background: var(--card-background);
            padding: 1.5rem;
            border-radius: 0.5rem;
            box-shadow: 0 2px 4px rgba(0,0,0,0.1);
            transition: transform 0.3s ease;
        }

        .stat-card:hover {
            transform: translateY(-5px);
        }

        .stat-card h3 {
            margin: 0 0 0.5rem 0;
            font-size: 1rem;
            color: var(--secondary-color);
            display: flex;
            align-items: center;
            gap: 0.5rem;
        }

        .stat-card .value {
            font-size: 1.5rem;
            font-weight: bold;
            margin-bottom: 0.5rem;
            color: var(--primary-color);
        }

        .charts-grid {
            display: grid;
            grid-template-columns: repeat(auto-fit, minmax(500px, 1fr));
            gap: 1.5rem;
            margin-bottom: 2rem;
        }

        .chart-container {
            background: var(--card-background);
            padding: 1.5rem;
            border-radius: 0.5rem;
            box-shadow: 0 2px 4px rgba(0,0,0,0.1);
            height: 400px;
            position: relative;
        }

        .chart-container h2 {
            margin: 0 0 1rem 0;
            font-size: 1.2rem;
            color: var(--secondary-color);
            display: flex;
            align-items: center;
            gap: 0.5rem;
        }

        .expense-table {
            width: 100%;
            border-collapse: collapse;
            margin-top: 2rem;
            background: var(--card-background);
            border-radius: 0.5rem;
            overflow: hidden;
            box-shadow: 0 2px 4px rgba(0,0,0,0.1);
        }

        .expense-table th,
        .expense-table td {
            padding: 1rem;
            text-align: left;
            border-bottom: 1px solid var(--border-color);
        }

        .expense-table th {
            background-color: var(--primary-color);
            color: white;
            font-weight: 600;
        }

        .expense-table tr:hover {
            background-color: var(--background-color);
        }

        .category-badge {
            padding: 0.25rem 0.75rem;
            border-radius: 1rem;
            font-size: 0.875rem;
            color: white;
            font-weight: 500;
            text-transform: capitalize;
        }

        .category-badge.high {
            background-color: #e53e3e;
        }

        .category-badge.medium {
            background-color: #ed8936;
        }

        .category-badge.low {
            background-color: #48bb78;
        }

        .trend-indicator {
            display: flex;
            align-items: center;
            gap: 0.5rem;
            font-size: 0.875rem;
            margin-top: 0.5rem;
        }

        .trend-up {
            color: #e53e3e;
        }

        .trend-down {
            color: #48bb78;
        }

        @media (max-width: 768px) {
            .charts-grid {
                grid-template-columns: 1fr;
            }
            
            .chart-container {
                height: 300px;
            }

            .header {
                flex-direction: column;
                gap: 1rem;
                text-align: center;
            }
        }

        .loading {
            position: fixed;
            top: 0;
            left: 0;
            width: 100%;
            height: 100%;
            background: rgba(255, 255, 255, 0.9);
            display: flex;
            justify-content: center;
            align-items: center;
            z-index: 1000;
            transition: opacity 0.3s;
        }

        .loading.hidden {
            opacity: 0;
            pointer-events: none;
        }

        .loading-spinner {
            border: 4px solid #f3f3f3;
            border-top: 4px solid var(--primary-color);
            border-radius: 50%;
            width: 40px;
            height: 40px;
            animation: spin 1s linear infinite;
        }

        @keyframes spin {
            0% { transform: rotate(0deg); }
            100% { transform: rotate(360deg); }
        }
    </style>
</head>
<body>
    <div id="loading" class="loading">
        <div class="loading-spinner"></div>
    </div>

    <%
        Connection conn = null;
        StringBuilder categoriesJson = new StringBuilder("[");
        StringBuilder categoryValuesJson = new StringBuilder("[");
        
        try {
            conn = DBconnection.getConnection();
            
            double totalExpenses = 0;
            String totalQuery = "SELECT SUM(amount) as total FROM expenses";
            PreparedStatement totalStmt = conn.prepareStatement(totalQuery);
            ResultSet totalRs = totalStmt.executeQuery();
            if (totalRs.next()) {
                totalExpenses = totalRs.getDouble("total");
            }

            String monthlyAvgQuery = "SELECT AVG(monthly_total) as monthly_avg FROM (SELECT SUM(amount) as monthly_total FROM expenses GROUP BY YEAR(date), MONTH(date)) as monthly_totals";
            PreparedStatement avgStmt = conn.prepareStatement(monthlyAvgQuery);
            ResultSet avgRs = avgStmt.executeQuery();
            double monthlyAverage = 0;
            if (avgRs.next()) {
                monthlyAverage = avgRs.getDouble("monthly_avg");
            }

            String categoryQuery = "SELECT category, SUM(amount) as total FROM expenses GROUP BY category ORDER BY total DESC";
            PreparedStatement catStmt = conn.prepareStatement(categoryQuery);
            ResultSet catRs = catStmt.executeQuery();
            String highestCategory = "";
            double highestCategoryAmount = 0;
            Map<String, Double> categoryData = new LinkedHashMap<>();
            
            while (catRs.next()) {
                String category = catRs.getString("category");
                double amount = catRs.getDouble("total");
                categoryData.put(category, amount);
                
                if (highestCategory.isEmpty()) {
                    highestCategory = category;
                    highestCategoryAmount = amount;
                }
                
                if (categoriesJson.length() > 1) {
                    categoriesJson.append(",");
                    categoryValuesJson.append(",");
                }
                categoriesJson.append("\"").append(category).append("\"");
                categoryValuesJson.append(amount);
            }

            String currentMonthQuery = "SELECT SUM(amount) as total FROM expenses WHERE MONTH(date) = MONTH(CURRENT_DATE()) AND YEAR(date) = YEAR(CURRENT_DATE())";
            PreparedStatement currentStmt = conn.prepareStatement(currentMonthQuery);
            ResultSet currentRs = currentStmt.executeQuery();
            double currentMonth = 0;
            if (currentRs.next()) {
                currentMonth = currentRs.getDouble("total");
            }

            String previousMonthQuery = "SELECT SUM(amount) as total FROM expenses WHERE MONTH(date) = MONTH(DATE_SUB(CURRENT_DATE(), INTERVAL 1 MONTH)) AND YEAR(date) = YEAR(DATE_SUB(CURRENT_DATE(), INTERVAL 1 MONTH))";
            PreparedStatement prevStmt = conn.prepareStatement(previousMonthQuery);
            ResultSet prevRs = prevStmt.executeQuery();
            double previousMonth = 0;
            if (prevRs.next()) {
                previousMonth = prevRs.getDouble("total");
            }

            double monthlyChange = previousMonth > 0 ? ((currentMonth - previousMonth) / previousMonth) * 100 : 0;
            
            categoriesJson.append("]");
            categoryValuesJson.append("]");
    %>
    
    <header class="header">
        <h1>Analytics Dashboard</h1>
        <a href="AddExpense.jsp"><i class="fas fa-arrow-left"></i> Back to Expenses</a>
    </header>
    
    <div class="container">
        <div class="stats-grid">
            <div class="stat-card">
                <h3><i class="fas fa-money-bill-wave"></i> Total Expenses</h3>
                <div class="value">$<%= String.format("%,.2f", totalExpenses) %></div>
                <div class="trend-indicator <%= monthlyChange > 0 ? "trend-up" : "trend-down" %>">
                    <i class="fas fa-<%= monthlyChange > 0 ? "arrow-up" : "arrow-down" %>"></i>
                    <%= String.format("%.1f", Math.abs(monthlyChange)) %>% from last month
                </div>
            </div>
            <div class="stat-card">
                <h3><i class="fas fa-calculator"></i> Monthly Average</h3>
                <div class="value">$<%= String.format("%,.2f", monthlyAverage) %></div>
            </div>
            <div class="stat-card">
                <h3><i class="fas fa-trophy"></i> Highest Category</h3>
                <div class="value"><%= highestCategory %></div>
                <div class="trend-indicator">
                    $<%= String.format("%,.2f", highestCategoryAmount) %>
                </div>
            </div>
            <div class="stat-card">
                <h3><i class="fas fa-chart-pie"></i> Budget Status</h3>
                <div class="value">
                    <%= currentMonth > monthlyAverage ? "Over Budget" : "On Track" %>
                </div>
                <div class="trend-indicator <%= currentMonth > monthlyAverage ? "trend-up" : "trend-down" %>">
                    <%= String.format("%.1f", Math.abs(((currentMonth - monthlyAverage) / monthlyAverage) * 100)) %>% 
                    <%= currentMonth > monthlyAverage ? "above" : "below" %> average
                </div>
            </div>
        </div>

        <div class="charts-grid">
            <div class="chart-container">
                <h2><i class="fas fa-chart-bar"></i> Category Expenses</h2>
                <canvas id="categoryBarChart"></canvas>
            </div>
            <div class="chart-container">
                <h2><i class="fas fa-chart-pie"></i> Category Distribution</h2>
                <canvas id="categoryPieChart"></canvas>
            </div>
        </div>

        <table class="expense-table">
            <thead>
                <tr>
                    <th>Category</th>
                    <th>Amount</th>
                    <th>Percentage</th>
                    <th>Status</th>
                </tr>
            </thead>
            <tbody>
                <%
                    for (Map.Entry<String, Double> entry : categoryData.entrySet()) {
                        double percentage = (entry.getValue() / totalExpenses) * 100;
                        String status = percentage > 30 ? "high" : 
                                      percentage > 20 ? "medium" : "low";
                %>
                <tr>
                    <td><i class="fas fa-folder"></i> <%= entry.getKey() %></td>
                    <td>$<%= String.format("%,.2f", entry.getValue()) %></td>
                    <td><%= String.format("%.1f", percentage) %>%</td>
                    <td><span class="category-badge <%= status %>">
                        <%= status.substring(0, 1).toUpperCase() + status.substring(1) %>
                    </span></td>
                </tr>
                <%
                    }
                %>
            </tbody>
        </table>
    </div>

    <script>
        const categories = <%= categoriesJson.toString() %>;
        const categoryValues = <%= categoryValuesJson.toString() %>;

        new Chart(document.getElementById('categoryBarChart'), {
            type: 'bar',
            data: {
                labels: categories,
                datasets: [{
                    label: 'Category Expenses',
                    data: categoryValues,
                    backgroundColor: '#4299e1',
                    borderRadius: 6,
                    hoverBackgroundColor: '#2c5282'
                }]
            },
            options: {
                responsive: true,
                maintainAspectRatio: false,
                plugins: {
                    legend: {
                        position: 'bottom'
                    },
                    tooltip: {
                        callbacks: {
                            label: function(context) {
                                return context.label + ': $' + context.raw.toLocaleString();
                            }}
                    }
                },
                scales: {
                    y: {
                        beginAtZero: true,
                        ticks: {
                            callback: value => '$' + value.toLocaleString()
                        },
                        grid: {
                            color: 'rgba(0, 0, 0, 0.1)'
                        }
                    },
                    x: {
                        grid: {
                            display: false
                        }
                    }
                }
            }
        });

        new Chart(document.getElementById('categoryPieChart'), {
            type: 'doughnut',
            data: {
                labels: categories,
                datasets: [{
                    data: categoryValues,
                    backgroundColor: [
                        '#e53e3e', '#48bb78', '#ed8936', '#9c27b0', 
                        '#4299e1', '#ecc94b', '#805ad5', '#38b2ac',
                        '#667eea', '#ed64a6', '#48bb78', '#4299e1'
                    ],
                    borderWidth: 2,
                    borderColor: '#ffffff'
                }]
            },
            options: {
                responsive: true,
                maintainAspectRatio: false,
                plugins: {
                    legend: {
                        position: 'bottom',
                        labels: {
                            padding: 20,
                            font: {
                                size: 12
                            }
                        }
                    },
                    tooltip: {
                        callbacks: {
                            label: function(context) {
                                const value = context.raw;
                                const total = context.dataset.data.reduce((a, b) => a + b, 0);
                                const percentage = ((value / total) * 100).toFixed(1);
                                return `${context.label}: $${value.toLocaleString()} (${percentage}%)`;
                            }
                        }
                    }
                },
                cutout: '60%',
                animation: {
                    animateRotate: true,
                    animateScale: true
                },
                hover: {
                    mode: 'nearest',
                    intersect: true
                }
            }
        });

        document.addEventListener('DOMContentLoaded', function() {
            setTimeout(() => {
                document.getElementById('loading').classList.add('hidden');
            }, 500);
        });
    </script>
    <%
        } catch (Exception e) {
            out.println("<div class='container'><div class='message error'>Error: " + e.getMessage() + "</div></div>");
        } finally {
            if (conn != null) {
                try {
                    conn.close();
                } catch (SQLException e) {
                    out.println("<div class='container'><div class='message error'>Error closing connection: " + e.getMessage() + "</div></div>");
                }
            }
        }
    %>
</body>
</html>