<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Reset Password - SmartSpend</title>
    <link href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.0.0/css/all.min.css" rel="stylesheet">
    <style>
        * {
            margin: 0;
            padding: 0;
            box-sizing: border-box;
        }

        body {
            font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif;
            background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
            min-height: 100vh;
            display: flex;
            justify-content: center;
            align-items: center;
            padding: 20px;
        }

        .container {
            background: rgba(255, 255, 255, 0.95);
            width: 100%;
            max-width: 450px;
            padding: 40px;
            border-radius: 20px;
            box-shadow: 0 15px 35px rgba(0, 0, 0, 0.2);
            backdrop-filter: blur(10px);
        }

        .header {
            text-align: center;
            margin-bottom: 35px;
        }

        .header i {
            font-size: 3.5em;
            color: #667eea;
            margin-bottom: 15px;
            display: block;
        }

        .header h2 {
            color: #2d3748;
            font-size: 1.8em;
            font-weight: 600;
        }

        .form-group {
            margin-bottom: 25px;
        }

        .form-group label {
            display: block;
            margin-bottom: 8px;
            color: #4a5568;
            font-weight: 500;
            font-size: 0.95em;
        }

        .input-group {
            position: relative;
            margin-bottom: 5px;
        }

        .input-group i {
            position: absolute;
            left: 15px;
            top: 50%;
            transform: translateY(-50%);
            color: #667eea;
            font-size: 1.1em;
        }

        .input-group input {
            width: 100%;
            padding: 15px 15px 15px 45px;
            border: 2px solid #e2e8f0;
            border-radius: 12px;
            font-size: 1em;
            transition: all 0.3s ease;
            background: white;
        }

        .input-group input:focus {
            border-color: #667eea;
            outline: none;
            box-shadow: 0 0 0 3px rgba(102, 126, 234, 0.1);
        }

        .error {
            color: #e53e3e;
            font-size: 0.85em;
            margin-top: 5px;
            display: block;
        }

        .btn {
            width: 100%;
            padding: 15px;
            background: linear-gradient(to right, #667eea, #764ba2);
            color: white;
            border: none;
            border-radius: 12px;
            font-size: 1em;
            font-weight: 600;
            cursor: pointer;
            transition: all 0.3s ease;
            margin-top: 10px;
        }

        .btn:hover {
            transform: translateY(-1px);
            box-shadow: 0 7px 14px rgba(0, 0, 0, 0.1);
        }

        .btn:active {
            transform: translateY(1px);
        }

        @media (max-width: 480px) {
            .container {
                padding: 30px 20px;
            }

            .header i {
                font-size: 3em;
            }

            .header h2 {
                font-size: 1.5em;
            }
        }

        /* Password strength indicator */
        .password-strength {
            height: 5px;
            margin-top: 10px;
            border-radius: 3px;
            background: #e2e8f0;
            overflow: hidden;
        }

        .strength-meter {
            height: 100%;
            width: 0;
            transition: all 0.3s ease;
        }

        .weak { background-color: #fc8181; width: 33.33%; }
        .medium { background-color: #f6e05e; width: 66.66%; }
        .strong { background-color: #68d391; width: 100%; }
    </style>
</head>
<body>
    <div class="container">
        <div class="header">
            <i class="fas fa-shield-alt"></i>
            <h2>Reset Password</h2>
        </div>
        
        <form action="ResetPasswordServlet" method="post" onsubmit="return validatePasswords()">
            <input type="hidden" name="token" value="${param.token}">
            
            <div class="form-group">
                <label for="password">New Password</label>
                <div class="input-group">
                    <i class="fas fa-lock"></i>
                    <input type="password" id="password" name="newPassword" 
                           placeholder="Enter new password" required
                           oninput="checkPasswordStrength(this.value)">
                </div>
                <div class="password-strength">
                    <div class="strength-meter"></div>
                </div>
                <p class="error" id="passwordError"></p>
            </div>

            <div class="form-group">
                <label for="confirmPassword">Confirm Password</label>
                <div class="input-group">
                    <i class="fas fa-lock-alt"></i>
                    <input type="password" id="confirmPassword" name="confirmPassword" 
                           placeholder="Confirm new password" required>
                </div>
                <p class="error" id="confirmPasswordError"></p>
            </div>
            
            <% if(request.getAttribute("error") != null) { %>
                <div class="error" style="text-align: center; margin-bottom: 15px;">
                    <%= request.getAttribute("error") %>
                </div>
            <% } %>
            
            <button type="submit" class="btn">Reset Password</button>
        </form>
    </div>

    <script>
        function validatePasswords() {
            const password = document.getElementById('password').value;
            const confirmPassword = document.getElementById('confirmPassword').value;
            const passwordError = document.getElementById('passwordError');
            const confirmPasswordError = document.getElementById('confirmPasswordError');
            
            passwordError.textContent = '';
            confirmPasswordError.textContent = '';
            
            if (password.length < 6) {
                passwordError.textContent = 'Password must be at least 6 characters long';
                return false;
            }
            if (password !== confirmPassword) {
                confirmPasswordError.textContent = 'Passwords do not match';
                return false;
            }
            return true;
        }

        function checkPasswordStrength(password) {
            const strengthMeter = document.querySelector('.strength-meter');
            strengthMeter.className = 'strength-meter';
            
            if (password.length === 0) {
                strengthMeter.style.width = '0';
                return;
            }

            let strength = 0;
            if (password.length >= 6) strength++;
            if (password.match(/[a-z]/) && password.match(/[A-Z]/)) strength++;
            if (password.match(/[0-9]/)) strength++;
            if (password.match(/[^a-zA-Z0-9]/)) strength++;

            switch(strength) {
                case 0:
                case 1:
                    strengthMeter.classList.add('weak');
                    break;
                case 2:
                case 3:
                    strengthMeter.classList.add('medium');
                    break;
                case 4:
                    strengthMeter.classList.add('strong');
                    break;
            }
        }
    </script>
</body>
</html>