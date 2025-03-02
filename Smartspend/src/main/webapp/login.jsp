<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Sign In - SmartSpend</title>
    <link href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.0.0/css/all.min.css" rel="stylesheet">
    <style>
        * {
            margin: 0;
            padding: 0;
            box-sizing: border-box;
        }

        body {
            font-family: 'Inter', -apple-system, BlinkMacSystemFont, sans-serif;
            background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
            min-height: 100vh;
            display: flex;
            justify-content: center;
            align-items: center;
            padding: 20px;
        }

        .container {
            background: rgba(255, 255, 255, 0.95);
            padding: 40px;
            border-radius: 20px;
            box-shadow: 0 20px 40px rgba(0, 0, 0, 0.2);
            width: 100%;
            max-width: 420px;
            backdrop-filter: blur(10px);
        }

        .card-header {
            text-align: center;
            margin-bottom: 30px;
        }

        .logo {
            margin-bottom: 20px;
        }

        .logo i {
            font-size: 3em;
            color: #667eea;
        }

        h1 {
            color: #2d3748;
            font-size: 2em;
            font-weight: 700;
        }

        .subtitle {
            color: #666;
            margin-top: 5px;
            font-size: 0.9em;
        }

        .alert {
            padding: 12px;
            margin-bottom: 20px;
            border-radius: 8px;
            color: white;
            text-align: center;
            font-size: 0.9em;
        }

        .alert-success {
            background-color: #48bb78;
        }

        .alert-error {
            background-color: #f56565;
        }

        .form-group {
            margin-bottom: 20px;
        }

        .form-group label {
            display: block;
            margin-bottom: 8px;
            color: #4a5568;
            font-size: 0.9em;
            font-weight: 500;
        }

        .input-group {
            position: relative;
        }

        .input-group i {
            position: absolute;
            left: 12px;
            top: 50%;
            transform: translateY(-50%);
            color: #667eea;
        }

        .input-group input {
            width: 100%;
            padding: 12px 12px 12px 40px;
            border-radius: 8px;
            border: 1px solid #ddd;
            font-size: 0.95em;
            transition: all 0.3s ease;
        }

        .input-group input:focus {
            outline: none;
            border-color: #667eea;
            box-shadow: 0 0 0 2px rgba(102, 126, 234, 0.2);
        }

        .form-check {
            display: flex;
            justify-content: space-between;
            align-items: center;
            margin: 15px 0;
        }

        .show-password {
            display: flex;
            align-items: center;
            gap: 5px;
            cursor: pointer;
        }

        .show-password input {
            margin-right: 5px;
        }

        .forgot-password {
            color: #667eea;
            text-decoration: none;
            font-size: 0.9em;
            transition: color 0.3s ease;
        }

        .forgot-password:hover {
            color: #5a6fd1;
            text-decoration: underline;
        }

        button {
            width: 100%;
            padding: 12px;
            border-radius: 8px;
            border: none;
            background-color: #667eea;
            color: white;
            font-size: 1em;
            font-weight: 500;
            cursor: pointer;
            transition: all 0.3s ease;
            margin-top: 10px;
        }

        button:hover {
            background-color: #5a6fd1;
            transform: translateY(-1px);
        }

        button:active {
            transform: translateY(0);
        }

        .footer {
            text-align: center;
            margin-top: 25px;
            padding-top: 20px;
            border-top: 1px solid #eee;
            font-size: 0.9em;
        }

        .footer a {
            color: #667eea;
            text-decoration: none;
            font-weight: 500;
        }

        .footer a:hover {
            text-decoration: underline;
        }
    </style>
</head>
<body>
    <div class="container">
        <div class="card-header">
            <div class="logo">
                <i class="fas fa-wallet"></i>
            </div>
            <h1>Welcome Back</h1>
            <p class="subtitle">Sign in to continue to SmartSpend</p>
        </div>
        
        <% if (request.getParameter("registered") != null) { %>
            <div class="alert alert-success">Registration successful! Please login.</div>
        <% } %>
        <% if (request.getParameter("error") != null) { %>
            <div class="alert alert-error">Invalid email or password.</div>
        <% } %>
        
        <form action="LoginServlet" method="post">
            <% String redirect = request.getParameter("redirect");
               if (redirect != null && !redirect.isEmpty()) { %>
                <input type="hidden" name="redirect" value="<%= redirect %>">
            <% } %>
            
            <div class="form-group">
                <label for="email">Email Address</label>
                <div class="input-group">
                    <i class="fas fa-envelope"></i>
                    <input type="email" id="email" name="email" placeholder="Enter your email" required>
                </div>
            </div>

            <div class="form-group">
                <label for="password">Password</label>
                <div class="input-group">
                    <i class="fas fa-lock"></i>
                    <input type="password" id="password" name="password" placeholder="Enter your password" required>
                </div>
            </div>

            <div class="form-check">
                <label class="show-password">
                    <input type="checkbox" onclick="togglePassword()"> Show Password
                </label>
                <a href="forgot-password.jsp" class="forgot-password">Forgot Password?</a>
            </div>

            <button type="submit">Sign In</button>
        </form>

        <div class="footer">
            <p>Don't have an account? <a href="register.jsp">Sign up</a></p>
        </div>
    </div>

    <script>
        function togglePassword() {
            const passwordField = document.getElementById('password');
            passwordField.type = passwordField.type === 'password' ? 'text' : 'password';
        }
    </script>
</body>
</html>