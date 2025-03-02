<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Verify OTP - SmartSpend</title>
    <link href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.0.0/css/all.min.css" rel="stylesheet">
    <style>
        body {
            font-family: Arial, sans-serif;
            background-color: #f3f4f6;
            display: flex;
            justify-content: center;
            align-items: center;
            min-height: 100vh;
            margin: 0;
        }

        .container {
            background-color: white;
            padding: 2rem;
            border-radius: 12px;
            box-shadow: 0 4px 6px rgba(0, 0, 0, 0.1);
            width: 100%;
            max-width: 400px;
        }

        .logo {
            text-align: center;
            font-size: 2.5em;
            color: #667eea;
            margin-bottom: 1rem;
        }

        h1 {
            text-align: center;
            color: #2d3748;
            margin-bottom: 1.5rem;
        }

        .verification-input {
            display: flex;
            gap: 8px;
            justify-content: center;
            margin-bottom: 20px;
        }

        .verification-input input {
            width: 40px;
            height: 40px;
            text-align: center;
            font-size: 1.2em;
            border: 1px solid #ddd;
            border-radius: 8px;
            outline: none;
        }

        .verification-input input:focus {
            border-color: #667eea;
            box-shadow: 0 0 0 2px rgba(102, 126, 234, 0.2);
        }

        .submit-btn {
            width: 100%;
            padding: 12px;
            background-color: #667eea;
            color: white;
            border: none;
            border-radius: 8px;
            font-size: 1em;
            cursor: pointer;
            transition: background-color 0.2s;
        }

        .submit-btn:hover {
            background-color: #5a67d8;
        }

        .resend-link {
            text-align: center;
            margin-top: 15px;
        }

        .resend-link a {
            color: #667eea;
            text-decoration: none;
            font-size: 0.9em;
        }

        .alert {
            padding: 12px;
            border-radius: 8px;
            margin-bottom: 15px;
            text-align: center;
            display: none;
        }

        .alert-success {
            background-color: #c6f6d5;
            color: #2f855a;
        }

        .alert-error {
            background-color: #fed7d7;
            color: #c53030;
        }
    </style>
</head>
<body>
    <div class="container">
        <div class="logo">
            <i class="fas fa-shield-alt"></i>
        </div>
        <h1>Verify Your Email</h1>
        
        <div id="alertBox" style="display: none;" class="alert"></div>
        
        <form id="otpForm" onsubmit="return verifyOTP(event)">
            <p style="text-align: center; margin-bottom: 20px;">
                Please enter the verification code sent to your email
            </p>
            
            <input type="hidden" id="email" name="email">
            
            <div class="verification-input">
                <input type="text" maxlength="1" pattern="[0-9]" inputmode="numeric" required>
                <input type="text" maxlength="1" pattern="[0-9]" inputmode="numeric" required>
                <input type="text" maxlength="1" pattern="[0-9]" inputmode="numeric" required>
                <input type="text" maxlength="1" pattern="[0-9]" inputmode="numeric" required>
                <input type="text" maxlength="1" pattern="[0-9]" inputmode="numeric" required>
                <input type="text" maxlength="1" pattern="[0-9]" inputmode="numeric" required>
            </div>

            <button type="submit" class="submit-btn">Verify Code</button>
            
            <div class="resend-link">
                <a href="#" onclick="resendOTP(event)">Didn't receive the code? Resend</a>
            </div>
        </form>
    </div>

    <script>
        // Set email from sessionStorage when page loads
        document.addEventListener('DOMContentLoaded', function() {
            var email = sessionStorage.getItem('registrationEmail');
            if (!email) {
                window.location.href = 'forgot-password.jsp';
                return;
            }
            document.getElementById('email').value = email;
        });

        // Handle OTP input navigation
        var otpInputs = document.querySelectorAll('.verification-input input');
        otpInputs.forEach(function(input, index) {
            input.addEventListener('keyup', function(e) {
                if (e.key !== "Backspace" && index < otpInputs.length - 1 && input.value) {
                    otpInputs[index + 1].focus();
                }
                if (e.key === "Backspace" && index > 0) {
                    otpInputs[index - 1].focus();
                }
            });

            // Handle paste event
            input.addEventListener('paste', function(e) {
                e.preventDefault();
                var pastedData = e.clipboardData.getData('text').slice(0, 6);
                if (/^\d+$/.test(pastedData)) {
                    Array.from(pastedData).forEach(function(digit, i) {
                        if (otpInputs[i]) {
                            otpInputs[i].value = digit;
                        }
                    });
                    if (otpInputs[5].value) {
                        otpInputs[5].focus();
                    }
                }
            });
        });

        function verifyOTP(event) {
            event.preventDefault();
            var code = Array.from(otpInputs).map(function(input) { return input.value; }).join('');
            var email = document.getElementById('email').value;

            fetch('VerifyOTPServlet', {
                method: 'POST',
                headers: {
                    'Content-Type': 'application/x-www-form-urlencoded'
                },
                body: 'code=' + encodeURIComponent(code) + '&email=' + encodeURIComponent(email)
            })
            .then(function(response) {
                return response.json();
            })
            .then(function(data) {
                if (data.success) {
                    showAlert('Email verified successfully!', 'success');
                    setTimeout(function() {
                        window.location.href = data.redirectUrl;
                    }, 1500);
                } else {
                    showAlert(data.message || 'Invalid verification code', 'error');
                }
            })
            .catch(function(error) {
                showAlert('An error occurred. Please try again.', 'error');
            });
            
            return false;
        }

        function resendOTP(event) {
            event.preventDefault();
            var email = document.getElementById('email').value;

            fetch('ResendOTPServlet', {
                method: 'POST',
                headers: {
                    'Content-Type': 'application/x-www-form-urlencoded'
                },
                body: 'email=' + encodeURIComponent(email)
            })
            .then(function(response) {
                return response.json();
            })
            .then(function(data) {
                if (data.success) {
                    showAlert('New verification code sent!', 'success');
                } else {
                    showAlert(data.message || 'Failed to send new code', 'error');
                }
            })
            .catch(function(error) {
                showAlert('An error occurred. Please try again.', 'error');
            });
        }

        function showAlert(message, type) {
            var alertBox = document.getElementById('alertBox');
            alertBox.textContent = message;
            alertBox.className = 'alert alert-' + type;
            alertBox.style.display = 'block';
            setTimeout(function() {
                alertBox.style.display = 'none';
            }, 5000);
        }
    </script>
</body>
</html>