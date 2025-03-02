<%@ page import="java.sql.*, java.util.*, javax.servlet.http.*" %>
<%@ page import="util.DBconnection" %>
<%
    HttpSession sessionObj = request.getSession(false);
    String firstName = (sessionObj != null) ? (String) sessionObj.getAttribute("firstName") : null;
    if (firstName == null) {
        response.sendRedirect("login.jsp");
        return;
    }

    // Fetch user details and analytics
    String lastName = "", email = "", phone = "", joinDate = "";
    int totalExpenses = 0;
    Map<String, Integer> categoryExpenses = new HashMap<>();
    
    try (Connection conn = DBconnection.getConnection()) {
        // Fetch user details
        PreparedStatement ps = conn.prepareStatement(
            "SELECT * FROM users WHERE user_id = ?"
        );
        ps.setInt(1, (Integer) sessionObj.getAttribute("userId"));
        ResultSet rs = ps.executeQuery();
        if (rs.next()) {
            lastName = rs.getString("last_name");
            email = rs.getString("email");
            phone = rs.getString("phone");
            joinDate = rs.getDate("join_date").toString();
        }

        // Get total expenses
        ps = conn.prepareStatement(
            "SELECT SUM(amount) as total FROM expenses WHERE user_id = ?"
        );
        ps.setInt(1, (Integer) sessionObj.getAttribute("userId"));
        rs = ps.executeQuery();
        if (rs.next()) {
            totalExpenses = rs.getInt("total");
        }

        // Get category-wise expenses
        ps = conn.prepareStatement(
            "SELECT category, SUM(amount) as amount FROM expenses WHERE user_id = ? GROUP BY category"
        );
        ps.setInt(1, (Integer) sessionObj.getAttribute("userId"));
        rs = ps.executeQuery();
        while (rs.next()) {
            categoryExpenses.put(rs.getString("category"), rs.getInt("amount"));
        }
    } catch (Exception e) {
        e.printStackTrace();
    }
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Profile Dashboard - Smart Spend</title>
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.0.0/css/all.min.css">
    <style>
        :root {
            --primary-color: #6366f1;
            --secondary-color: #4f46e5;
            --success-color: #22c55e;
            --background-color: #f8fafc;
            --card-background: #ffffff;
            --text-primary: #1e293b;
            --text-secondary: #64748b;
            --border-color: #e2e8f0;
            --shadow-sm: 0 1px 2px 0 rgb(0 0 0 / 0.05);
            --shadow-md: 0 4px 6px -1px rgb(0 0 0 / 0.1);
            --shadow-lg: 0 10px 15px -3px rgb(0 0 0 / 0.1);
        }

        * {
            margin: 0;
            padding: 0;
            box-sizing: border-box;
            font-family: 'Inter', system-ui, sans-serif;
        }

        body {
            background-color: var(--background-color);
            color: var(--text-primary);
            line-height: 1.5;
        }

        .dashboard {
            max-width: 1200px;
            margin: 0 auto;
            padding: 2rem;
        }

        .profile-header {
            display: grid;
            grid-template-columns: auto 1fr auto;
            align-items: center;
            gap: 2rem;
            background: var(--card-background);
            padding: 2rem;
            border-radius: 1rem;
            box-shadow: var(--shadow-lg);
            margin-bottom: 2rem;
        }

        .profile-avatar {
            width: 120px;
            height: 120px;
            background: linear-gradient(135deg, var(--primary-color), var(--secondary-color));
            border-radius: 1rem;
            display: flex;
            align-items: center;
            justify-content: center;
            color: white;
            font-size: 3rem;
        }

        .profile-info h1 {
            font-size: 2rem;
            font-weight: 700;
            color: var(--text-primary);
            margin-bottom: 0.5rem;
        }

        .profile-meta {
            color: var(--text-secondary);
            display: flex;
            gap: 1.5rem;
            font-size: 0.875rem;
        }

        .meta-item {
            display: flex;
            align-items: center;
            gap: 0.5rem;
        }

        .quick-actions {
            display: flex;
            gap: 1rem;
        }

        .btn {
            display: inline-flex;
            align-items: center;
            gap: 0.5rem;
            padding: 0.75rem 1.5rem;
            border-radius: 0.75rem;
            font-weight: 600;
            font-size: 0.875rem;
            transition: all 0.2s;
            cursor: pointer;
        }

        .btn-primary {
            background: var(--primary-color);
            color: white;
            border: none;
        }

        .btn-outline {
            background: transparent;
            border: 2px solid var(--primary-color);
            color: var(--primary-color);
        }

        .btn:hover {
            transform: translateY(-2px);
            box-shadow: var(--shadow-md);
        }

        .dashboard-grid {
            display: grid;
            grid-template-columns: 2fr 1fr;
            gap: 2rem;
        }

        .card {
            background: var(--card-background);
            border-radius: 1rem;
            padding: 1.5rem;
            box-shadow: var(--shadow-md);
        }

        .card-header {
            display: flex;
            justify-content: space-between;
            align-items: center;
            margin-bottom: 1.5rem;
        }

        .card-title {
            font-size: 1.25rem;
            font-weight: 600;
            color: var(--text-primary);
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
            border-radius: 1rem;
            box-shadow: var(--shadow-sm);
            border: 1px solid var(--border-color);
        }

        .stat-card h3 {
            color: var(--text-secondary);
            font-size: 0.875rem;
            font-weight: 500;
            margin-bottom: 0.5rem;
        }

        .stat-card p {
            font-size: 1.5rem;
            font-weight: 700;
            color: var(--text-primary);
        }

        .expense-list {
            display: grid;
            gap: 1rem;
        }

        .expense-item {
            display: flex;
            justify-content: space-between;
            align-items: center;
            padding: 1rem;
            background: var(--background-color);
            border-radius: 0.75rem;
        }

        .expense-category {
            display: flex;
            align-items: center;
            gap: 0.75rem;
        }

        .category-icon {
            width: 2.5rem;
            height: 2.5rem;
            border-radius: 0.75rem;
            background: var(--primary-color);
            color: white;
            display: flex;
            align-items: center;
            justify-content: center;
        }

        .expense-amount {
            font-weight: 600;
            color: var(--text-primary);
        }

        @media (max-width: 1024px) {
            .dashboard-grid {
                grid-template-columns: 1fr;
            }
        }

        @media (max-width: 768px) {
            .profile-header {
                grid-template-columns: 1fr;
                text-align: center;
            }

            .profile-avatar {
                margin: 0 auto;
            }

            .profile-meta {
                justify-content: center;
                flex-wrap: wrap;
            }

            .quick-actions {
                justify-content: center;
            }

            .stats-grid {
                grid-template-columns: 1fr;
            }
        }
    </style>
</head>
<body>
    <div class="dashboard">
        <div class="profile-header">
            <div class="profile-avatar">
                <i class="fas fa-user"></i>
            </div>
            <div class="profile-info">
                <h1><%= firstName %> <%= lastName %></h1>
                <div class="profile-meta">
                    <div class="meta-item">
                        <i class="fas fa-envelope"></i>
                        <%= email %>
                    </div>
                    <div class="meta-item">
                        <i class="fas fa-phone"></i>
                        <%= phone %>
                    </div>
                    <div class="meta-item">
                        <i class="fas fa-calendar"></i>
                        Member since <%= joinDate %>
                    </div>
                </div>
            </div>
            <div class="quick-actions">
                <button class="btn btn-primary" onclick="location.href='edit-profile.jsp'">
                    <i class="fas fa-edit"></i>
                    Edit Profile
                </button>
                <button class="btn btn-outline" onclick="location.href='change-password.jsp'">
                    <i class="fas fa-key"></i>
                    Security
                </button>
            </div>
        </div>

        <div class="stats-grid">
            <div class="stat-card">
                <h3>Total Expenses</h3>
                <p>$<%= String.format("%,d", totalExpenses) %></p>
            </div>
            <div class="stat-card">
                <h3>Monthly Average</h3>
                <p>$<%= String.format("%,d", totalExpenses/12) %></p>
            </div>
            <div class="stat-card">
                <h3>Active Categories</h3>
                <p><%= categoryExpenses.size() %></p>
            </div>
        </div>

        <div class="dashboard-grid">
            <div class="card">
                <div class="card-header">
                    <h2 class="card-title">Expense Categories</h2>
                    <button class="btn btn-outline" onclick="location.href='expenses.jsp'">
                        View All
                    </button>
                </div>
                <div class="expense-list">
                    <% for (Map.Entry<String, Integer> entry : categoryExpenses.entrySet()) { %>
                        <div class="expense-item">
                            <div class="expense-category">
                                <div class="category-icon">
                                    <i class="fas fa-tags"></i>
                                </div>
                                <div>
                                    <h3><%= entry.getKey() %></h3>
                                    <p class="text-sm text-gray-500"><%= String.format("%.1f", (entry.getValue() * 100.0 / totalExpenses)) %>% of total</p>
                                </div>
                            </div>
                            <div class="expense-amount">
                                $<%= String.format("%,d", entry.getValue()) %>
                            </div>
                        </div>
                    <% } %>
                </div>
            </div>

            <div class="card">
                <div class="card-header">
                    <h2 class="card-title">Quick Actions</h2>
                </div>
                <div class="quick-actions-list">
                    <button class="btn btn-outline w-full mb-3" onclick="location.href='add-expense.jsp'">
                        <i class="fas fa-plus"></i>
                        Add New Expense
                    </button>
                    <button class="btn btn-outline w-full mb-3" onclick="location.href='reports.jsp'">
                        <i class="fas fa-chart-bar"></i>
                        View Reports
                    </button>
                    <button class="btn btn-outline w-full" onclick="location.href='settings.jsp'">
                        <i class="fas fa-cog"></i>
                        Settings
                    </button>
                </div>
            </div>
        </div>
    </div>
</body>
</html>