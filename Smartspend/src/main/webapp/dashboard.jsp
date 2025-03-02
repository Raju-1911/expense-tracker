<%@ page import="java.sql.*, java.util.*, javax.servlet.http.*" %>
<%@ page import="util.DBconnection" %>
<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>

<%
    HttpSession sessionObj = request.getSession(false);
    String firstName = (sessionObj != null) ? (String) sessionObj.getAttribute("firstName") : null;
    if (firstName == null) {
        response.sendRedirect("login.jsp");
        return;
    }

    Map<String, Double> categoryExpenses = new HashMap<>();
    Map<String, Double> categoryLimits = new HashMap<>();
    double totalExpenses = 0.0;
    
    try (Connection conn = DBconnection.getConnection()) {
        // Total expenses calculation
        String totalQuery = "SELECT SUM(amount) as total FROM expenses WHERE user_id=?";
        try (PreparedStatement totalStmt = conn.prepareStatement(totalQuery)) {
            totalStmt.setInt(1, (Integer) sessionObj.getAttribute("userId"));
            try (ResultSet totalRs = totalStmt.executeQuery()) {
                if (totalRs.next()) {
                    totalExpenses = totalRs.getDouble("total");
                }
            }
        }
        
        // Category-wise expense calculation
        String categoryQuery = "SELECT category, SUM(amount) as total FROM expenses " +
                             "WHERE user_id=? AND MONTH(date) = MONTH(CURRENT_DATE()) " +
                             "AND YEAR(date) = YEAR(CURRENT_DATE()) GROUP BY category";
        try (PreparedStatement catStmt = conn.prepareStatement(categoryQuery)) {
            catStmt.setInt(1, (Integer) sessionObj.getAttribute("userId"));
            try (ResultSet catRs = catStmt.executeQuery()) {
                while (catRs.next()) {
                    String category = catRs.getString("category");
                    double amount = catRs.getDouble("total");
                    categoryExpenses.put(category, amount);
                }
            }
        }

        // Retrieve category limits
        String limitsQuery = "SELECT category, monthly_limit FROM category_limits WHERE user_id=?";
        try (PreparedStatement limitsStmt = conn.prepareStatement(limitsQuery)) {
            limitsStmt.setInt(1, (Integer) sessionObj.getAttribute("userId"));
            try (ResultSet limitsRs = limitsStmt.executeQuery()) {
                while (limitsRs.next()) {
                    categoryLimits.put(
                        limitsRs.getString("category"),
                        limitsRs.getDouble("monthly_limit")
                    );
                }
            }
        }
    } catch (SQLException e) {
        e.printStackTrace();
        // You might want to add proper error handling here
        // For example, setting an error message attribute and redirecting to an error page
        request.setAttribute("errorMessage", "Database error occurred: " + e.getMessage());
        // request.getRequestDispatcher("error.jsp").forward(request, response);
        // return;
    }

    // Check if user is logged in (this was duplicated, moved it to the top)
    Integer userId = (Integer) sessionObj.getAttribute("userId");
    if (userId == null) {
        response.sendRedirect(request.getContextPath() + "/login.jsp");
        return;
    }
%>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Expense Tracker Dashboard</title>
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.0.0/css/all.min.css">
    <style>
        * {
            margin: 0;
            padding: 0;
            box-sizing: border-box;
        }
        
        :root {
            --primary-color: #4f46e5;
            --primary-dark: #4338ca;
            --primary-light: #818cf8;
            --secondary-color: #f3f4f6;
            --text-light: #6b7280;
            --text-dark: #1f2937;
            --white: #ffffff;
            --danger: #ef4444;
            --warning: #f59e0b;
            --success: #10b981;
            --sidebar-width: 280px;
        }

        body {
            font-family: 'Inter', sans-serif;
            background: linear-gradient(135deg, #f6f7ff 0%, #e8eaff 100%);
            min-height: 100vh;
            display: flex;
        }

        .glass-effect {
            background: rgba(255, 255, 255, 0.9);
            backdrop-filter: blur(10px);
            border: 1px solid rgba(255, 255, 255, 0.2);
            box-shadow: 0 8px 32px rgba(31, 38, 135, 0.15);
        }

        .sidebar {
            width: var(--sidebar-width);
            background: linear-gradient(180deg, var(--primary-color), var(--primary-dark));
            padding: 2rem 1.5rem;
            height: 100vh;
            position: fixed;
            left: 0;
            top: 0;
            z-index: 40;
        }

        .logo {
            font-size: 1.5rem;
            font-weight: 700;
            color: var(--white);
            display: flex;
            align-items: center;
            gap: 0.75rem;
            padding: 0.5rem 1rem;
            margin-bottom: 2rem;
        }

        .nav-items {
            display: flex;
            flex-direction: column;
            gap: 0.5rem;
        }

        .nav-item a {
            text-decoration: none;
            color: var(--white);
            font-weight: 500;
            display: flex;
            align-items: center;
            gap: 0.75rem;
            padding: 0.875rem 1rem;
            border-radius: 0.5rem;
            transition: all 0.2s ease;
        }

        .nav-item a:hover {
            background: rgba(255, 255, 255, 0.1);
        }

        .main-content {
            margin-left: var(--sidebar-width);
            flex: 1;
            padding: 2rem;
        }

        .dashboard-header {
            margin-bottom: 2rem;
        }

        .dashboard-header h1 {
            font-size: 1.875rem;
            font-weight: 700;
            color: var(--text-dark);
            margin-bottom: 0.5rem;
        }

        .dashboard-header p {
            color: var(--text-light);
        }

        .total-expenses-card {
            background: linear-gradient(135deg, var(--primary-color), var(--primary-dark));
            color: var(--white);
            border-radius: 1rem;
            padding: 2rem;
            margin-bottom: 2rem;
            box-shadow: 0 10px 20px rgba(79, 70, 229, 0.2);
            display: flex;
            justify-content: space-between;
            align-items: center;
        }

        .expenses-info {
            flex: 1;
        }

        .total-expenses-amount {
            font-size: 2.5rem;
            font-weight: 700;
            margin: 1rem 0;
        }

        .user-profile {
            display: flex;
            align-items: center;
            gap: 1.5rem;
            padding-left: 2rem;
            border-left: 2px solid rgba(255, 255, 255, 0.2);
        }

        .profile-pic {
            width: 64px;
            height: 64px;
            border-radius: 50%;
            border: 3px solid var(--white);
            overflow: hidden;
        }

        .profile-pic img {
            width: 100%;
            height: 100%;
            object-fit: cover;
        }

        .user-info {
            display: flex;
            flex-direction: column;
            gap: 0.5rem;
            color: var(--white);
        }

        .listen-time {
            font-size: 0.875rem;
            opacity: 0.9;
        }

        .categories-grid {
            display: grid;
            grid-template-columns: repeat(auto-fit, minmax(300px, 1fr));
            gap: 1.5rem;
            margin-top: 2rem;
        }

        .category-card {
            background: var(--white);
            border-radius: 1rem;
            padding: 1.5rem;
            transition: transform 0.3s ease;
            box-shadow: 0 4px 6px rgba(0, 0, 0, 0.05);
        }

        .category-card:hover {
            transform: translateY(-5px);
        }

        .category-header {
            display: flex;
            align-items: center;
            justify-content: space-between;
            margin-bottom: 1rem;
        }

        .category-icon {
            width: 3.5rem;
            height: 3.5rem;
            background: var(--primary-light);
            border-radius: 50%;
            display: flex;
            align-items: center;
            justify-content: center;
            color: var(--white);
            font-size: 1.5rem;
        }

        .category-title {
            font-size: 1.25rem;
            font-weight: 600;
            color: var(--text-dark);
            margin: 1rem 0;
        }

        .category-amount {
            font-size: 1.5rem;
            font-weight: 700;
            color: var(--text-dark);
        }

        .progress-bar {
            height: 0.5rem;
            background: var(--secondary-color);
            border-radius: 1rem;
            margin: 1rem 0;
            overflow: hidden;
        }

        .progress-fill {
            height: 100%;
            border-radius: 1rem;
            transition: width 0.3s ease, background-color 0.3s ease;
        }

        .limit-info {
            display: flex;
            justify-content: space-between;
            font-size: 0.875rem;
            color: var(--text-light);
        }

        .notification {
            position: fixed;
            top: 1rem;
            right: 1rem;
            padding: 1rem;
            border-radius: 0.5rem;
            background: var(--white);
            box-shadow: 0 4px 6px rgba(0, 0, 0, 0.1);
            z-index: 100;
            display: flex;
            align-items: center;
            gap: 0.75rem;
            transform: translateX(120%);
            transition: transform 0.3s ease;
        }

        .notification.show {
            transform: translateX(0);
        }

        .notification i {
            font-size: 1.25rem;
            color: var(--warning);
        }

        .limit-modal {
            display: none;
            position: fixed;
            top: 0;
            left: 0;
            width: 100%;
            height: 100%;
            background: rgba(0, 0, 0, 0.5);
            justify-content: center;
            align-items: center;
            z-index: 50;
        }

        .limit-modal-content {
            background: var(--white);
            padding: 2rem;
            border-radius: 1rem;
            width: 90%;
            max-width: 500px;
        }

        .limit-form {
            display: flex;
            flex-direction: column;
            gap: 1rem;
        }

        .limit-input {
            padding: 0.75rem;
            border: 1px solid var(--secondary-color);
            border-radius: 0.5rem;
            font-size: 1rem;
        }

        .btn {
            padding: 0.75rem 1.5rem;
            border: none;
            border-radius: 0.5rem;
            font-weight: 500;
            cursor: pointer;
            transition: background-color 0.2s ease;
        }

        .btn-primary {
            background: var(--primary-color);
            color: var(--white);
        }

        .btn-primary:hover {
            background: var(--primary-dark);
        }

        .btn-secondary {
            background: var(--secondary-color);
            color: var(--text-dark);
        }

        .btn-secondary:hover {
            background: #e5e7eb;
        }

        @media (max-width: 1024px) {
            :root {
                --sidebar-width: 240px;
            }

            .total-expenses-card {
                flex-direction: column;
                gap: 2rem;
            }

            .user-profile {
                border-left: none;
                border-top: 2px solid rgba(255, 255, 255, 0.2);
                padding-left: 0;
                padding-top: 2rem;
            }
        }

        @media (max-width: 768px) {
            .sidebar {
                transform: translateX(-100%);
                transition: transform 0.3s ease;
            }

            .sidebar.active {
                transform: translateX(0);
            }

            .main-content {
                margin-left: 0;
                padding: 1rem;
            }

            .categories-grid {
                grid-template-columns: 1fr;
            }
        }
    </style>
</head>
<body>
    <div class="sidebar glass-effect">
        <div class="logo">
            <i class="fas fa-wallet"></i>
            Smart Spend
        </div>

        <div class="nav-items">
            <div class="nav-item">
                <a href="dashboard.jsp"><i class="fas fa-chart-line"></i>Dashboard</a>
            </div>
            <div class="nav-item">
                <a href="AddExpense.jsp"><i class="fas fa-plus-circle"></i>Add Expense</a>
            </div>
            <div class="nav-item">
                <a href="ShopExpenses.jsp"><i class="fas fa-store"></i>Shop Expenses</a>
            </div>
            <div class="nav-item">
                <a href="Analytics.jsp"><i class="fas fa-chart-pie"></i>Analytics</a>
            </div>
            <div class="nav-item">
                <a href="Profile.jsp"><i class="fas fa-user"></i>Profile</a>
            </div>
            <div class="nav-item">
                <a href="Settings.jsp"><i class="fas fa-cog"></i>Settings</a>
            </div>
            <div class="nav-item">
                <a href="logout.jsp"><i class="fas fa-sign-out-alt"></i>Log out</a>
            </div>
        </div>
    </div>

    <div class="main-content">
        <div class="dashboard-header">
            <h1>Welcome back, <%= firstName %>!</h1>
            <p>Track and manage your expenses efficiently</p>
        </div>

        <div class="total-expenses-card glass-effect">
            <div class="expenses-info">
                <h2>Total Monthly Expenses</h2>
                <div class="total-expenses-amount">
                    ₹<%= String.format("%.2f", totalExpenses) %>
                </div>
                <p>Current Month Overview</p>
            </div>
            <div class="user-profile">
                <div class="profile-pic">
                    <img src="/api/placeholder/64/64" alt="Profile Picture">
                </div>
                <div class="user-info">
                    <strong><%= firstName %></strong>
                    <span class="listen-time" id="listenTime">Online for: 0h 0m</span>
                </div>
            </div>
        </div>

        <div class="categories-grid">
            <!-- Food Category -->
            <div class="category-card glass-effect" data-category="Food">
                <div class="category-header">
                    <div class="category-icon">
                        <i class="fas fa-utensils"></i>
                    </div>
                    <button class="btn btn-secondary" onclick="showLimitModal('Food')">
                        <i class="fas fa-cog"></i>
                    </button>
                </div>
                <h3 class="category-title">Food</h3>
                <p class="category-amount">₹<span id="Food-amount"><%= String.format("%.2f", categoryExpenses.getOrDefault("Food", 0.0)) %></span></p>
                <div class="progress-bar">
                    <div class="progress-fill" id="Food-progress" 
                         style="width: <%= Math.min((categoryExpenses.getOrDefault("Food", 0.0) / categoryLimits.getOrDefault("Food", 500.0)) * 100, 100) %>%; 
                                background-color: <%= (categoryExpenses.getOrDefault("Food", 0.0) / categoryLimits.getOrDefault("Food", 500.0)) * 100 >= 100 ? 
                                "var(--danger)" : ((categoryExpenses.getOrDefault("Food", 0.0) / categoryLimits.getOrDefault("Food", 500.0)) * 100 >= 80 ? 
                                "var(--warning)" : "var(--success)") %>">
                    </div>
                </div>
                <div class="limit-info">
                    <span>Monthly Limit:</span>
                    <span>₹<span id="Food-limit"><%= String.format("%.2f", categoryLimits.getOrDefault("Food", 500.0)) %></span></span>
                </div>
            </div>

            <!-- Transport Category -->
            <div class="category-card glass-effect" data-category="Transport">
                <div class="category-header">
                    <div class="category-icon">
                        <i class="fas fa-car"></i>
                    </div>
                    <button class="btn btn-secondary" onclick="showLimitModal('Transport')">
                        <i class="fas fa-cog"></i>
                    </button>
                </div>
                <h3 class="category-title">Transport</h3>
                <p class="category-amount">₹<span id="Transport-amount"><%= String.format("%.2f", categoryExpenses.getOrDefault("Transport", 0.0)) %></span></p>
                <div class="progress-bar">
                    <div class="progress-fill" id="Transport-progress" 
                         style="width: <%= Math.min((categoryExpenses.getOrDefault("Transport", 0.0) / categoryLimits.getOrDefault("Transport", 300.0)) * 100, 100) %>%; 
                                background-color: <%= (categoryExpenses.getOrDefault("Transport", 0.0) / categoryLimits.getOrDefault("Transport", 300.0)) * 100 >= 100 ? 
                                "var(--danger)" : ((categoryExpenses.getOrDefault("Transport", 0.0) / categoryLimits.getOrDefault("Transport", 300.0)) * 100 >= 80 ? 
                                "var(--warning)" : "var(--success)") %>">
                    </div>
                </div>
                <div class="limit-info">
                    <span>Monthly Limit:</span>
                    <span>₹<span id="Transport-limit"><%= String.format("%.2f", categoryLimits.getOrDefault("Transport", 300.0)) %></span></span>
                </div>
            </div>

            <!-- Bills Category -->
            <div class="category-card glass-effect" data-category="Bills">
                <div class="category-header">
                    <div class="category-icon">
                        <i class="fas fa-file-invoice-dollar"></i>
                    </div>
                    <button class="btn btn-secondary" onclick="showLimitModal('Bills')">
                        <i class="fas fa-cog"></i>
                    </button>
                </div>
                <h3 class="category-title">Bills</h3>
                <p class="category-amount">₹<span id="Bills-amount"><%= String.format("%.2f", categoryExpenses.getOrDefault("Bills", 0.0)) %></span></p>
                <div class="progress-bar">
                    <div class="progress-fill" id="Bills-progress" 
                         style="width: <%= Math.min((categoryExpenses.getOrDefault("Bills", 0.0) / categoryLimits.getOrDefault("Bills", 1000.0)) * 100, 100) %>%; 
                                background-color: <%= (categoryExpenses.getOrDefault("Bills", 0.0) / categoryLimits.getOrDefault("Bills", 1000.0)) * 100 >= 100 ? 
                                "var(--danger)" : ((categoryExpenses.getOrDefault("Bills", 0.0) / categoryLimits.getOrDefault("Bills", 1000.0)) * 100 >= 80 ? 
                                "var(--warning)" : "var(--success)") %>">
                    </div>
                </div>
                <div class="limit-info">
                    <span>Monthly Limit:</span>
                    <span>₹<span id="Bills-limit"><%= String.format("%.2f", categoryLimits.getOrDefault("Bills", 1000.0)) %></span></span>
                </div>
            </div>

            <!-- Entertainment Category -->
            <div class="category-card glass-effect" data-category="Entertainment">
                <div class="category-header">
                    <div class="category-icon">
                        <i class="fas fa-film"></i>
                    </div>
                    <button class="btn btn-secondary" onclick="showLimitModal('Entertainment')">
                        <i class="fas fa-cog"></i>
                    </button>
                </div>
                <h3 class="category-title">Entertainment</h3>
                <p class="category-amount">₹<span id="Entertainment-amount"><%= String.format("%.2f", categoryExpenses.getOrDefault("Entertainment", 0.0)) %></span></p>
                <div class="progress-bar">
                    <div class="progress-fill" id="Entertainment-progress" 
                         style="width: <%= Math.min((categoryExpenses.getOrDefault("Entertainment", 0.0) / categoryLimits.getOrDefault("Entertainment", 200.0)) * 100, 100) %>%; 
                                background-color: <%= (categoryExpenses.getOrDefault("Entertainment", 0.0) / categoryLimits.getOrDefault("Entertainment", 200.0)) * 100 >= 100 ? 
                                "var(--danger)" : ((categoryExpenses.getOrDefault("Entertainment", 0.0) / categoryLimits.getOrDefault("Entertainment", 200.0)) * 100 >= 80 ? 
                                "var(--warning)" : "var(--success)") %>">
                    </div>
                </div>
                <div class="limit-info">
                    <span>Monthly Limit:</span>
                    <span>₹<span id="Entertainment-limit"><%= String.format("%.2f", categoryLimits.getOrDefault("Entertainment", 200.0)) %></span></span>
                </div>
            </div>

            <!-- Other Category -->
            <div class="category-card glass-effect" data-category="Other">
                <div class="category-header">
                    <div class="category-icon">
                        <i class="fas fa-ellipsis-h"></i>
                    </div>
                    <button class="btn btn-secondary" onclick="showLimitModal('Other')">
                        <i class="fas fa-cog"></i>
                    </button>
                </div>
                <h3 class="category-title">Other</h3>
                <p class="category-amount">₹<span id="Other-amount"><%= String.format("%.2f", categoryExpenses.getOrDefault("Other", 0.0)) %></span></p>
                <div class="progress-bar">
                    <div class="progress-fill" id="Other-progress" 
                         style="width: <%= Math.min((categoryExpenses.getOrDefault("Other", 0.0) / categoryLimits.getOrDefault("Other", 400.0)) * 100, 100) %>%; 
                                background-color: <%= (categoryExpenses.getOrDefault("Other", 0.0) / categoryLimits.getOrDefault("Other", 400.0)) * 100 >= 100 ? 
                                "var(--danger)" : ((categoryExpenses.getOrDefault("Other", 0.0) / categoryLimits.getOrDefault("Other", 400.0)) * 100 >= 80 ? 
                                "var(--warning)" : "var(--success)") %>">
                    </div>
                </div>
                <div class="limit-info">
                    <span>Monthly Limit:</span>
                    <span>₹<span id="Other-limit"><%= String.format("%.2f", categoryLimits.getOrDefault("Other", 400.0)) %></span></span>
                </div>
            </div>
        </div>
    </div>

    <!-- Limit Modal -->
    <div id="limitModal" class="limit-modal">
        <div class="limit-modal-content glass-effect">
            <h2>Set Monthly Limit</h2>
            <form class="limit-form" onsubmit="updateLimit(event)">
                <input type="hidden" id="currentCategory" name="category">
                <input type="number" id="limitAmount" name="limit" class="limit-input" placeholder="Enter monthly limit" step="0.01" required>
                <div style="display: flex; gap: 1rem;">
                    <button type="submit" class="btn btn-primary">Save</button>
                    <button type="button" class="btn btn-secondary" onclick="hideLimitModal()">Cancel</button>
                </div>
            </form>
        </div>
    </div>

    <!-- Notification Container -->
    <div class="notification" id="notification">
        <i class="fas fa-exclamation-circle"></i>
        <div>
            <strong id="notificationTitle"></strong>
            <p id="notificationMessage"></p>
        </div>
    </div>

    <script>
        // Initialize categoryData with the server-side values
        const categoryData = {
            Food: {
                amount: <%= categoryExpenses.getOrDefault("Food", 0.0) %>,
                limit: <%= categoryLimits.getOrDefault("Food", 500.0) %>
            },
            Transport: {
                amount: <%= categoryExpenses.getOrDefault("Transport", 0.0) %>,
                limit: <%= categoryLimits.getOrDefault("Transport", 300.0) %>
            },
            Bills: {
                amount: <%= categoryExpenses.getOrDefault("Bills", 0.0) %>,
                limit: <%= categoryLimits.getOrDefault("Bills", 1000.0) %>
            },
            Entertainment: {
                amount: <%= categoryExpenses.getOrDefault("Entertainment", 0.0) %>,
                limit: <%= categoryLimits.getOrDefault("Entertainment", 200.0) %>
            },
            Other: {
                amount: <%= categoryExpenses.getOrDefault("Other", 0.0) %>,
                limit: <%= categoryLimits.getOrDefault("Other", 400.0) %>
            }
        };

        // Timer for online duration
        let startTime = new Date();
        setInterval(() => {
            let now = new Date();
            let diff = now - startTime;
            let hours = Math.floor(diff / (1000 * 60 * 60));
            let minutes = Math.floor((diff % (1000 * 60 * 60)) / (1000 * 60));
            document.getElementById('listenTime').textContent = `Online for: ${hours}h ${minutes}m`;
        }, 60000);

        // Modal functions
        function showLimitModal(category) {
            document.getElementById('currentCategory').value = category;
            document.getElementById('limitAmount').value = categoryData[category].limit;
            document.getElementById('limitModal').style.display = 'flex';
        }

        function hideLimitModal() {
            document.getElementById('limitModal').style.display = 'none';
        }

        // Update limit function
        async function updateLimit(event) {
            event.preventDefault();
            const category = document.getElementById('currentCategory').value;
            const newLimit = parseFloat(document.getElementById('limitAmount').value);

            try {
                const response = await fetch('updatelimit', {
                    method: 'POST',
                    headers: {
                        'Content-Type': 'application/json',
                    },
                    body: JSON.stringify({
                        category: category,
                        limit: newLimit
                    })
                });

                if (response.ok) {
                    categoryData[category].limit = newLimit;
                    document.getElementById(`${category}-limit`).textContent = newLimit.toFixed(2);
                    updateProgressBar(category);
                    showNotification('Success', `${category} limit updated successfully!`);
                    hideLimitModal();
                } else {
                    showNotification('Error', 'Failed to update limit. Please try again.');
                }
            } catch (error) {
                showNotification('Error', 'An error occurred. Please try again.');
            }
        }

        // Update progress bar function
        function updateProgressBar(category) {
            const amount = categoryData[category].amount;
            const limit = categoryData[category].limit;
            const percentage = Math.min((amount / limit) * 100, 100);
            const progressBar = document.getElementById(`${category}-progress`);
            
            progressBar.style.width = `${percentage}%`;
            if (percentage >= 100) {
                progressBar.style.backgroundColor = 'var(--danger)';
            } else if (percentage >= 80) {
                progressBar.style.backgroundColor = 'var(--warning)';
            } else {
                progressBar.style.backgroundColor = 'var(--success)';
            }
        }

        // Notification function
        function showNotification(title, message) {
            const notification = document.getElementById('notification');
            document.getElementById('notificationTitle').textContent = title;
            document.getElementById('notificationMessage').textContent = message;
            notification.classList.add('show');
            setTimeout(() => {
                notification.classList.remove('show');
            }, 3000);
        }

        // Mobile sidebar toggle
        document.addEventListener('DOMContentLoaded', () => {
            const sidebar = document.querySelector('.sidebar');
            const mainContent = document.querySelector('.main-content');
            
            mainContent.addEventListener('click', () => {
                if (window.innerWidth <= 768) {
                    sidebar.classList.remove('active');
                }
            });
        });
    </script>
</body>
</html>