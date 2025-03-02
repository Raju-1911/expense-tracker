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
    <title>Expense Analytics</title>
    <script src="https://cdn.jsdelivr.net/npm/chart.js"></script>
    <style>
        body {
            font-family: 'Arial', sans-serif;
            background: #f5f7fa;
            margin: 0;
            padding: 0;
            color: #333;
            min-height: 100vh;
        }

        .back-button {
            position: fixed;
            top: 20px;
            left: 20px;
            padding: 12px 24px;
            border-radius: 8px;
            cursor: pointer;
            text-decoration: none;
            z-index: 1000;
            background: #4a90e2;
            color: white;
            border: none;
            box-shadow: 0 2px 4px rgba(0,0,0,0.1);
            transition: all 0.3s ease;
        }

        .back-button:hover {
            background: #357abd;
            transform: translateY(-2px);
        }

        .container {
            max-width: 1200px;
            margin: 0 auto;
            padding: 40px 20px;
        }

        .header {
            text-align: center;
            margin-bottom: 40px;
            padding-top: 20px;
        }

        .header h1 {
            font-size: 2.5em;
            margin: 0;
            color: #2c3e50;
        }

        .stats-grid {
            display: grid;
            grid-template-columns: repeat(auto-fit, minmax(250px, 1fr));
            gap: 20px;
            margin-bottom: 40px;
        }

        .stat-card {
            background: white;
            border-radius: 12px;
            padding: 20px;
            text-align: center;
            box-shadow: 0 4px 6px rgba(0,0,0,0.1);
            transition: transform 0.3s ease;
        }

        .stat-card:hover {
            transform: translateY(-5px);
        }

        .stat-card h3 {
            margin: 0;
            font-size: 1.2em;
            color: #7f8c8d;
        }

        .stat-card .value {
            font-size: 2em;
            font-weight: bold;
            margin: 10px 0;
            color: #2c3e50;
        }

        .chart-grid {
            display: grid;
            grid-template-columns: repeat(auto-fit, minmax(500px, 1fr));
            gap: 20px;
            margin-bottom: 40px;
        }

        .chart-container {
            background: white;
            border-radius: 12px;
            padding: 20px;
            box-shadow: 0 4px 6px rgba(0,0,0,0.1);
        }

        .filter-section {
            background: white;
            padding: 20px;
            border-radius: 12px;
            margin-bottom: 40px;
            box-shadow: 0 4px 6px rgba(0,0,0,0.1);
        }

        .form-row {
            display: flex;
            gap: 15px;
            margin-bottom: 20px;
            align-items: flex-end;
            justify-content: center;
        }

        .form-group {
            flex: 1;
            max-width: 300px;
        }

        .form-group label {
            display: block;
            margin-bottom: 5px;
            color: #7f8c8d;
            font-weight: 500;
        }

        .form-group input {
            width: 100%;
            padding: 10px;
            border: 1px solid #dfe6e9;
            border-radius: 8px;
            background: #fff;
            color: #2d3436;
        }

        button {
            background: #4a90e2;
            color: white;
            border: none;
            padding: 12px 24px;
            border-radius: 8px;
            cursor: pointer;
            font-weight: 500;
            transition: all 0.3s ease;
        }

        button:hover {
            background: #357abd;
            transform: translateY(-2px);
        }

        @media (max-width: 768px) {
            .form-row {
                flex-direction: column;
                align-items: stretch;
            }
            
            .form-group {
                max-width: none;
            }
            
            .chart-grid {
                grid-template-columns: 1fr;
            }
        }
    </style>
</head>
<body>
    <a href="ShopExpenses.jsp" class="back-button">Back</a>
    
    <div class="container">
        <%
        Connection conn = null;
        DecimalFormat df = new DecimalFormat("₹#,##,##0.00");
        
        int userId = 0;
        HttpSession userSession = request.getSession(false);
        if (userSession != null && userSession.getAttribute("userId") != null) {
            userId = (Integer) userSession.getAttribute("userId");
        }

        // Get date parameters
        String startDate = request.getParameter("startDate");
        String endDate = request.getParameter("endDate");
        
        if (request.getParameter("clear") != null) {
            startDate = null;
            endDate = null;
        }

        // Initialize variables for analytics
        double totalExpenditure = 0;
        double totalIncome = 0;
        double totalProfit = 0;
        double avgDailyExpenditure = 0;
        double avgDailyIncome = 0;
        int totalDays = 0;
        
        // Lists for chart data
        List<String> dates = new ArrayList<>();
        List<Double> expenditures = new ArrayList<>();
        List<Double> incomes = new ArrayList<>();
        List<Double> profits = new ArrayList<>();

        try {
            conn = DBconnection.getConnection();
            
            String sql = "SELECT date, expenditure, income, profit FROM shop_daily_expenses WHERE user_id = ?";
            if (startDate != null && !startDate.trim().isEmpty() && endDate != null && !endDate.trim().isEmpty()) {
                sql += " AND date BETWEEN ? AND ?";
            }
            sql += " ORDER BY date";

            try (PreparedStatement stmt = conn.prepareStatement(sql)) {
                stmt.setInt(1, userId);
                
                if (startDate != null && !startDate.trim().isEmpty() && endDate != null && !endDate.trim().isEmpty()) {
                    stmt.setString(2, startDate);
                    stmt.setString(3, endDate);
                }
                
                ResultSet rs = stmt.executeQuery();
                while (rs.next()) {
                    dates.add(rs.getString("date"));
                    expenditures.add(rs.getDouble("expenditure"));
                    incomes.add(rs.getDouble("income"));
                    profits.add(rs.getDouble("profit"));
                    
                    totalExpenditure += rs.getDouble("expenditure");
                    totalIncome += rs.getDouble("income");
                    totalProfit += rs.getDouble("profit");
                    totalDays++;
                }
            }
            
            if (totalDays > 0) {
                avgDailyExpenditure = totalExpenditure / totalDays;
                avgDailyIncome = totalIncome / totalDays;
            }
            
        } catch (Exception e) {
            e.printStackTrace();
        } finally {
            if (conn != null) {
                try {
                    conn.close();
                } catch (SQLException e) {
                    e.printStackTrace();
                }
            }
        }
        %>

        <div class="header">
            <h1>Financial Analytics Dashboard</h1>
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
                <div class="form-group" style="display: flex; gap: 10px;">
                    <button type="submit">Apply Filter</button>
                    <button type="submit" name="clear" value="true">Clear Filter</button>
                </div>
            </form>
        </div>

        <div class="stats-grid">
            <div class="stat-card">
                <h3>Total Income</h3>
                <div class="value"><%= df.format(totalIncome) %></div>
            </div>
            <div class="stat-card">
                <h3>Total Expenditure</h3>
                <div class="value"><%= df.format(totalExpenditure) %></div>
            </div>
            <div class="stat-card">
                <h3>Total Profit</h3>
                <div class="value"><%= df.format(totalProfit) %></div>
            </div>
            <div class="stat-card">
                <h3>Avg. Daily Income</h3>
                <div class="value"><%= df.format(avgDailyIncome) %></div>
            </div>
            <div class="stat-card">
                <h3>Avg. Daily Expenditure</h3>
                <div class="value"><%= df.format(avgDailyExpenditure) %></div>
            </div>
            <div class="stat-card">
                <h3>Total Days</h3>
                <div class="value"><%= totalDays %></div>
            </div>
        </div>

        <div class="chart-grid">
            <div class="chart-container">
                <canvas id="trendChart"></canvas>
            </div>
            <div class="chart-container">
                <canvas id="profitChart"></canvas>
            </div>
        </div>

        <script>
            // Convert Java lists to JavaScript arrays
            const dates = <%= dates.toString() %>;
            const expenditures = <%= expenditures.toString() %>;
            const incomes = <%= incomes.toString() %>;
            const profits = <%= profits.toString() %>;

            // Function to format numbers in Indian currency
            const formatInr = (value) => {
                return '₹' + value.toLocaleString('en-IN', {
                    maximumFractionDigits: 2,
                    minimumFractionDigits: 2
                });
            };

            // Trend Chart
            new Chart(document.getElementById('trendChart'), {
                type: 'line',
                data: {
                    labels: dates,
                    datasets: [{
                        label: 'Income',
                        data: incomes,
                        borderColor: '#4a90e2',
                        tension: 0.4,
                        fill: false
                    }, {
                        label: 'Expenditure',
                        data: expenditures,
                        borderColor: '#e74c3c',
                        tension: 0.4,
                        fill: false
                    }]
                },
                options: {
                    responsive: true,
                    plugins: {
                        title: {
                            display: true,
                            text: 'Income vs Expenditure Trend',
                            color: '#2c3e50'
                        },
                        legend: {
                            labels: {
                                color: '#2c3e50'
                            }
                        }
                    },
                    scales: {
                        y: {
                            beginAtZero: true,
                            ticks: {
                                color: '#2c3e50',
                                callback: value => formatInr(value)
                            },
                            grid: {
                                color: 'rgba(0, 0, 0, 0.1)'
                            }
                        },
                        x: {
                            ticks: {
                                color: '#2c3e50'
                            },
                            grid: {
                                color: 'rgba(0, 0, 0, 0.1)'
                            }
                        }
                    }
                }
            });

            // Profit Chart
            new Chart(document.getElementById('profitChart'), {
                type: 'bar',
                data: {
                    labels: dates,
                    datasets: [{
                        label: 'Profit',
                        data: profits,
                        backgroundColor: profits.map(profit => 
                            profit >= 0 ? 'rgba(74, 144, 226, 0.7)' : 'rgba(231, 76, 60, 0.7)'
                        ),
                        borderColor: profits.map(profit => 
                            profit >= 0 ? '#4a90e2' : '#e74c3c'
                        ),
                        borderWidth: 1
                    }]
                },
                options: {
                    responsive: true,
                    plugins: {
                        title: {
                            display: true,
                            text: 'Daily Profit Analysis',
                            color: '#2c3e50'
                        },
                        legend: {
                            labels: {
                                color: '#2c3e50'
                            }
                        }
                    },
                    scales: {
                        y: {
                            beginAtZero: true,
                            ticks: {
                                color: '#2c3e50',
                                callback: value => formatInr(value)
                            },
                            grid: {
                                color: 'rgba(0, 0, 0, 0.1)'
                            }
                        },
                        x: {
                            ticks: {
                                color: '#2c3e50'
                            },
                            grid: {
                                color: 'rgba(0, 0, 0, 0.1)'
                            }
                        }
                    }
                }
            });

            // Form validation
            document.querySelector('form').addEventListener('submit', function(e) {
                if (!e.submitter || e.submitter.name !== 'clear') {
                    const startDate = document.getElementById('startDate').value;
                    const endDate = document.getElementById('endDate').value;
                    
                    if (startDate && endDate && startDate > endDate) {
                        e.preventDefault();
                        alert('Start date cannot be later than end date');
                    }
                }
            });
        </script>
    </div>
</body>
</html>