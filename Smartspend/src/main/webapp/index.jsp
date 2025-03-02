
<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>SmartSpend - Expense Tracker</title>
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
            padding: 50px 40px;
            border-radius: 20px;
            box-shadow: 0 20px 40px rgba(0, 0, 0, 0.2);
            width: 100%;
            max-width: 480px;
            backdrop-filter: blur(10px);
        }

        .logo {
            text-align: center;
            margin-bottom: 40px;
        }

        .logo i {
            font-size: 3em;
            color: #667eea;
            margin-bottom: 15px;
        }

        h1 {
            color: #2d3748;
            font-size: 2.4em;
            font-weight: 700;
            margin-bottom: 30px;
            text-align: center;
        }

        .subtitle {
            color: #718096;
            text-align: center;
            margin-bottom: 40px;
            font-size: 1.1em;
            line-height: 1.6;
        }

        .buttons {
            display: flex;
            flex-direction: column;
            gap: 16px;
        }

        .btn {
            text-decoration: none;
            padding: 16px 24px;
            border-radius: 12px;
            font-size: 1.1em;
            font-weight: 600;
            text-align: center;
            transition: all 0.3s ease;
            display: flex;
            align-items: center;
            justify-content: center;
            gap: 10px;
        }

        .btn-primary {
            background: #667eea;
            color: white;
        }

        .btn-secondary {
            background: #ffffff;
            color: #667eea;
            border: 2px solid #667eea;
        }

        .btn:hover {
            transform: translateY(-2px);
            box-shadow: 0 8px 15px rgba(102, 126, 234, 0.2);
        }

        .btn i {
            font-size: 1.2em;
        }
    </style>
</head>
<body>
    <div class="container">
        <div class="logo">
            <i class="fas fa-wallet"></i>
        </div>
        <h1>SmartSpend</h1>
        <p class="subtitle">Take control of your finances with smart expense tracking and insightful analytics</p>
        <div class="buttons">
            <a href="login.jsp" class="btn btn-primary">
                <i class="fas fa-sign-in-alt"></i>
                Sign In
            </a>
            <a href="register.jsp" class="btn btn-secondary">
                <i class="fas fa-user-plus"></i>
                Create Account
            </a>
        </div>
    </div>
</body>
</html>