<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Forgot Password - SmartSpend</title>
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
            display: flex;
            justify-content: center;
            align-items: center;
            gap: 8px;
        }

        button:disabled {
            background-color: #a0aec0;
            cursor: not-allowed;
        }

        button:hover:not(:disabled) {
            background-color: #5a6fd1;
            transform: translateY(-1px);
        }

        button:active:not(:disabled) {
            transform: translateY(0);
        }

        .spinner {
            display: none;
            animation: spin 1s linear infinite;
        }

        @keyframes spin {
            0% { transform: rotate(0deg); }
            100% { transform: rotate(360deg); }
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
            <h1>Forgot Password</h1>
            <p class="subtitle">Enter your email to reset password</p>
        </div>
        
        <% if (request.getAttribute("error") != null) { %>
            <div class="alert alert-error"><%= request.getAttribute("error") %></div>
        <% } %>
        
        <% if (request.getAttribute("success") != null) { %>
            <div class="alert alert-success"><%= request.getAttribute("success") %></div>
        <% } %>

        <form id="forgotPasswordForm" onsubmit="return handleForgotPassword(event)">
            <div class="form-group">
                <label for="email">Email Address</label>
                <div class="input-group">
                    <i class="fas fa-envelope"></i>
                    <input type="email" id="email" name="email" placeholder="Enter your email" required>
                </div>
            </div>

            <button type="submit" id="submitButton">
                <span id="buttonText">Send OTP</span>
                <i class="fas fa-spinner fa-spin spinner" id="loadingIcon"></i>
            </button>
        </form>

        <div class="footer">
            <p>Remember your password? <a href="login.jsp">Sign In</a></p>
        </div>
    </div>

    <script>
        let isSubmitting = false;

        async function handleForgotPassword(event) {
            event.preventDefault();
            
            // Prevent double submission
            if (isSubmitting) return false;
            
            const email = document.getElementById('email').value;
            const submitButton = document.getElementById('submitButton');
            const buttonText = document.getElementById('buttonText');
            const loadingIcon = document.getElementById('loadingIcon');
            
            // Update button state
            isSubmitting = true;
            submitButton.disabled = true;
            buttonText.textContent = 'Sending OTP...';
            loadingIcon.style.display = 'inline-block';
            
            try {
                const response = await fetch('ForgotPasswordServlet', {
                    method: 'POST',
                    headers: {
                        'Content-Type': 'application/x-www-form-urlencoded',
                    },
                    body: 'email=' + encodeURIComponent(email)
                });

                if (response.ok) {
                    // Store email and redirect
                    sessionStorage.setItem('registrationEmail', email);
                    window.location.href = 'verify-otp.jsp';
                } else {
                    const data = await response.json();
                    showAlert(data.message || 'An error occurred', 'error');
                    resetButton();
                }
            } catch (error) {
                showAlert('An error occurred. Please try again.', 'error');
                resetButton();
            }
            
            return false;
        }

        function resetButton() {
            const submitButton = document.getElementById('submitButton');
            const buttonText = document.getElementById('buttonText');
            const loadingIcon = document.getElementById('loadingIcon');
            
            isSubmitting = false;
            submitButton.disabled = false;
            buttonText.textContent = 'Send Reset Link';
            loadingIcon.style.display = 'none';
        }

        function showAlert(message, type) {
            // Remove any existing alerts
            const existingAlerts = document.querySelectorAll('.alert');
            existingAlerts.forEach(alert => alert.remove());
            
            // Create new alert
            const alertDiv = document.createElement('div');
            alertDiv.className = `alert alert-${type}`;
            alertDiv.textContent = message;
            
            // Insert alert after card header
            const cardHeader = document.querySelector('.card-header');
            cardHeader.insertAdjacentElement('afterend', alertDiv);
            
            // Remove alert after 5 seconds
            setTimeout(() => alertDiv.remove(), 5000);
        }
    </script>
</body>
</html>