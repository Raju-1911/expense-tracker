<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Create Account - SmartSpend</title>
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
            max-width: 480px;
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

        .alert-error {
            background-color: #f56565;
        }

        .alert-success {
            background-color: #48bb78;
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

        .validation-message {
            font-size: 0.85em;
            color: #f56565;
            margin-top: 5px;
            display: none;
        }

        .password-requirements {
            font-size: 0.85em;
            color: #666;
            margin-top: 5px;
            padding-left: 5px;
        }

        .show-password {
            display: flex;
            align-items: center;
            margin-top: 8px;
            cursor: pointer;
        }

        .show-password input {
            margin-right: 5px;
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
            margin-top: 20px;
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
            <h1>Create Account</h1>
            <p class="subtitle">Join SmartSpend to manage your finances better</p>
        </div>
        
        <% 
        String error = request.getParameter("error");
        if (error != null) {
            String errorMessage = "";
            switch(error) {
                case "email_exists":
                    errorMessage = "Email is already registered. Please use a different email.";
                    break;
                case "invalid_input":
                    errorMessage = "Please check your input and try again.";
                    break;
                case "database":
                    errorMessage = "An error occurred. Please try again later.";
                    break;
                case "password_mismatch":
                    errorMessage = "Passwords do not match.";
                    break;
                default:
                    errorMessage = "Registration failed. Please try again.";
            }
        %>
            <div class="alert alert-error"><%= errorMessage %></div>
        <% } %>

        <% if (request.getParameter("success") != null) { %>
            <div class="alert alert-success">Account created successfully! Please log in.</div>
        <% } %>
<!-- ... (keep existing head section and styles) ... -->

<form action="RegisterServlet" method="post" id="registrationForm" onsubmit="return validateForm()">
    <div class="form-group">
        <label for="firstName">First Name</label>
        <div class="input-group">
            <i class="fas fa-user"></i>
            <input type="text" id="firstName" name="firstName" placeholder="Enter your first name" required
                   pattern="[A-Za-z ]{2,50}" title="Please enter a valid first name (2-50 characters, letters only)">
        </div>
        <div class="validation-message" id="firstname-validation"></div>
    </div>

    <div class="form-group">
        <label for="lastName">Last Name</label>
        <div class="input-group">
            <i class="fas fa-user"></i>
            <input type="text" id="lastName" name="lastName" placeholder="Enter your last name" required
                   pattern="[A-Za-z ]{2,50}" title="Please enter a valid last name (2-50 characters, letters only)">
        </div>
        <div class="validation-message" id="lastname-validation"></div>
    </div>

    <div class="form-group">
        <label for="email">Email Address</label>
        <div class="input-group">
            <i class="fas fa-envelope"></i>
            <input type="email" id="email" name="email" placeholder="Enter your email address" required>
        </div>
        <div class="validation-message" id="email-validation"></div>
    </div>

    <div class="form-group">
        <label for="password">Password</label>
        <div class="input-group">
            <i class="fas fa-lock"></i>
            <input type="password" id="password" name="password" placeholder="Create a password" required
                   pattern="(?=.*\d)(?=.*[a-z])(?=.*[A-Z])(?=.*[!@#$%^&*]).{8,}"
                   title="Must contain at least 8 characters, including uppercase, lowercase, number and special character">
        </div>
        <label class="show-password">
            <input type="checkbox" onclick="togglePassword('password')"> Show Password
        </label>
    </div>

    <div class="form-group">
        <label for="confirmPassword">Confirm Password</label>
        <div class="input-group">
            <i class="fas fa-lock"></i>
            <input type="password" id="confirmPassword" name="confirmPassword" placeholder="Confirm your password" required>
        </div>
        <div class="validation-message" id="password-validation"></div>
        <label class="show-password">
            <input type="checkbox" onclick="togglePassword('confirmPassword')"> Show Password
        </label>
    </div>

    <button type="submit">Create Account</button>
</form>

<script>
    function validateForm() {
        let isValid = true;
        const password = document.getElementById("password");
        const confirmPassword = document.getElementById("confirmPassword");
        const email = document.getElementById("email");
        const firstName = document.getElementById("firstName");
        const lastName = document.getElementById("lastName");

        // Reset validation messages
        document.querySelectorAll('.validation-message').forEach(msg => {
            msg.style.display = 'none';
        });

        // Name validation
        if (!firstName.value.match(/^[A-Za-z ]{2,50}$/)) {
            document.getElementById("firstname-validation").textContent = "Please enter a valid first name";
            document.getElementById("firstname-validation").style.display = "block";
            isValid = false;
        }

        if (!lastName.value.match(/^[A-Za-z ]{2,50}$/)) {
            document.getElementById("lastname-validation").textContent = "Please enter a valid last name";
            document.getElementById("lastname-validation").style.display = "block";
            isValid = false;
        }

        // Email validation
        if (!email.value.match(/^[^\s@]+@[^\s@]+\.[^\s@]+$/)) {
            document.getElementById("email-validation").textContent = "Please enter a valid email address";
            document.getElementById("email-validation").style.display = "block";
            isValid = false;
        }

        // Password validation
        if (password.value !== confirmPassword.value) {
            document.getElementById("password-validation").textContent = "Passwords don't match";
            document.getElementById("password-validation").style.display = "block";
            isValid = false;
        }

        if (!password.value.match(/(?=.*\d)(?=.*[a-z])(?=.*[A-Z])(?=.*[!@#$%^&*]).{8,}/)) {
            document.getElementById("password-validation").textContent = 
                "Password must contain at least 8 characters, including uppercase, lowercase, number and special character";
            document.getElementById("password-validation").style.display = "block";
            isValid = false;
        }

        return isValid;
    }
 // Real-time validation
    document.querySelectorAll('input').forEach(input => {
        input.addEventListener('input', function() {
            this.classList.remove('invalid');
            const validationMessage = this.parentElement.querySelector('.validation-message');
            if (validationMessage) {
                validationMessage.style.display = 'none';
            }
        });
    });


    // ... (keep existing togglePassword and other functions) ...
</script>