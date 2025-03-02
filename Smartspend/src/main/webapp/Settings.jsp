<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Expense Tracker - Settings</title>
    <link href="https://cdnjs.cloudflare.com/ajax/libs/bootstrap/5.3.0/css/bootstrap.min.css" rel="stylesheet">
    <link href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.0.0/css/all.min.css" rel="stylesheet">
    <style>
        body {
            min-height: 100vh;
            background-color: #f8f9fa;
            margin: 0;
            padding: 0;
            color: #333;
        }

        .settings-container {
            max-width: 1200px;
            margin: 2rem auto;
            padding: 2rem;
            background: #ffffff;
            box-shadow: 0 2px 10px rgba(0, 0, 0, 0.1);
            border-radius: 10px;
        }

        .nav-pills .nav-link {
            color: #495057;
            margin-bottom: 0.5rem;
            border-radius: 6px;
            transition: all 0.2s ease;
        }

        .nav-pills .nav-link:hover {
            background-color: rgba(13, 110, 253, 0.05);
        }

        .nav-pills .nav-link.active {
            background-color: #0d6efd;
            color: white;
            box-shadow: 0 2px 5px rgba(13, 110, 253, 0.2);
        }

        .settings-header {
            background: #0d6efd;
            color: white;
            padding: 1.5rem;
            border-radius: 8px;
            margin-bottom: 2rem;
        }

        .form-section {
            background: white;
            padding: 1.5rem;
            border-radius: 8px;
            margin-bottom: 1.5rem;
            box-shadow: 0 1px 3px rgba(0, 0, 0, 0.1);
        }

        .category-tag {
            background: #0d6efd;
            color: white;
            padding: 0.4rem 0.8rem;
            border-radius: 50px;
            margin: 0.25rem;
            display: inline-block;
            font-size: 0.9rem;
        }

        .btn-primary {
            background-color: #0d6efd;
            border-color: #0d6efd;
        }

        .btn-primary:hover {
            background-color: #0b5ed7;
            border-color: #0a58ca;
        }

        .feature-card {
            background: white;
            border-radius: 8px;
            padding: 1.25rem;
            margin-bottom: 1rem;
            border: 1px solid #e9ecef;
        }

        .feature-card h5 {
            color: #0d6efd;
            margin-bottom: 1rem;
        }

        .theme-preview {
            width: 40px;
            height: 40px;
            border-radius: 8px;
            margin: 5px;
            cursor: pointer;
            border: 2px solid transparent;
        }

        .theme-preview.active {
            border-color: #0d6efd;
        }

        .custom-switch {
            transform: scale(1.2);
            margin-right: 0.5rem;
        }

        @media (max-width: 768px) {
            .settings-container {
                margin: 1rem;
                padding: 1rem;
            }
        }
    </style>
</head>
<body>
    <div class="container-fluid settings-container">
        <div class="settings-header text-center">
            <h1><i class="fas fa-cog me-2"></i>Expense Tracker Settings</h1>
            <p class="lead mb-0">Customize your expense tracking experience</p>
        </div>

        <div class="row g-4">
            <div class="col-md-3 mb-4">
                <div class="nav flex-column nav-pills sticky-top pt-2" role="tablist">
                    <button class="nav-link active" data-bs-toggle="pill" data-bs-target="#general">
                        <i class="fas fa-sliders-h me-2"></i>General
                    </button>
                    <button class="nav-link" data-bs-toggle="pill" data-bs-target="#notifications">
                        <i class="fas fa-bell me-2"></i>Notifications
                    </button>
                    <button class="nav-link" data-bs-toggle="pill" data-bs-target="#categories">
                        <i class="fas fa-tags me-2"></i>Categories
                    </button>
                    <button class="nav-link" data-bs-toggle="pill" data-bs-target="#security">
                        <i class="fas fa-shield-alt me-2"></i>Security
                    </button>
                    <button class="nav-link" data-bs-toggle="pill" data-bs-target="#budgeting">
                        <i class="fas fa-piggy-bank me-2"></i>Budgeting
                    </button>
                    <button class="nav-link" data-bs-toggle="pill" data-bs-target="#reports">
                        <i class="fas fa-chart-line me-2"></i>Reports
                    </button>
                    <button class="nav-link" data-bs-toggle="pill" data-bs-target="#automation">
                        <i class="fas fa-robot me-2"></i>Automation
                    </button>
                    <button class="nav-link" data-bs-toggle="pill" data-bs-target="#integration">
                        <i class="fas fa-plug me-2"></i>Integrations
                    </button>
                    <button class="nav-link" data-bs-toggle="pill" data-bs-target="#appearance">
                        <i class="fas fa-paint-brush me-2"></i>Appearance
                    </button>
                    <button class="nav-link" data-bs-toggle="pill" data-bs-target="#import-export">
                        <i class="fas fa-exchange-alt me-2"></i>Import/Export
                    </button>
                </div>
            </div>

            <div class="col-md-9">
                <div class="tab-content">
                    <!-- General Settings -->
                    <div class="tab-pane fade show active" id="general">
                        <div class="form-section">
                            <h4 class="mb-4"><i class="fas fa-user text-primary me-2"></i>Profile Information</h4>
                            <div class="row g-3">
                                <div class="col-md-6">
                                    <div class="mb-3">
                                        <label class="form-label">Full Name</label>
                                        <input type="text" class="form-control" value="${user.fullName}">
                                    </div>
                                </div>
                                <div class="col-md-6">
                                    <div class="mb-3">
                                        <label class="form-label">Email Address</label>
                                        <input type="email" class="form-control" value="${user.email}">
                                    </div>
                                </div>
                            </div>
                            <div class="mb-3">
                                <label class="form-label">Profile Picture</label>
                                <input type="file" class="form-control" accept="image/*">
                            </div>
                        </div>

                        <div class="form-section">
                            <h4 class="mb-4"><i class="fas fa-globe text-primary me-2"></i>Regional Settings</h4>
                            <div class="row g-3">
                                <div class="col-md-4">
                                    <div class="mb-3">
                                        <label class="form-label">Currency</label>
                                        <select class="form-select">
                                            <option value="USD">USD ($)</option>
                                            <option value="EUR">EUR (€)</option>
                                            <option value="GBP">GBP (£)</option>
                                            <option value="JPY">JPY (¥)</option>
                                            <option value="AUD">AUD ($)</option>
                                            <option value="CAD">CAD ($)</option>
                                            <option value="INR">INR (₹)</option>
                                        </select>
                                    </div>
                                </div>
                                <div class="col-md-4">
                                    <div class="mb-3">
                                        <label class="form-label">Date Format</label>
                                        <select class="form-select">
                                            <option>MM/DD/YYYY</option>
                                            <option>DD/MM/YYYY</option>
                                            <option>YYYY-MM-DD</option>
                                        </select>
                                    </div>
                                </div>
                                <div class="col-md-4">
                                    <div class="mb-3">
                                        <label class="form-label">Time Zone</label>
                                        <select class="form-select">
                                            <option>UTC-8 (PST)</option>
                                            <option>UTC-5 (EST)</option>
                                            <option>UTC+0 (GMT)</option>
                                            <option>UTC+1 (CET)</option>
                                            <option>UTC+5:30 (IST)</option>
                                        </select>
                                    </div>
                                </div>
                            </div>
                            <div class="d-grid gap-2 d-md-flex justify-content-md-end mt-3">
                                <button class="btn btn-primary" type="button">Save Changes</button>
                            </div>
                        </div>
                    </div>

                    <!-- Notification Settings -->
                    <div class="tab-pane fade" id="notifications">
                        <div class="form-section">
                            <h4 class="mb-4"><i class="fas fa-bell text-primary me-2"></i>Notification Preferences</h4>
                            <div class="feature-card">
                                <h5>Email Notifications</h5>
                                <div class="mb-3 form-check form-switch">
                                    <input type="checkbox" class="form-check-input custom-switch" id="emailDaily">
                                    <label class="form-check-label">Daily Expense Summary</label>
                                </div>
                                <div class="mb-3 form-check form-switch">
                                    <input type="checkbox" class="form-check-input custom-switch" id="emailWeekly">
                                    <label class="form-check-label">Weekly Report</label>
                                </div>
                                <div class="mb-3 form-check form-switch">
                                    <input type="checkbox" class="form-check-input custom-switch" id="emailBudget">
                                    <label class="form-check-label">Budget Alerts</label>
                                </div>
                            </div>

                            <div class="feature-card">
                                <h5>Mobile Notifications</h5>
                                <div class="mb-3 form-check form-switch">
                                    <input type="checkbox" class="form-check-input custom-switch" id="mobilePush">
                                    <label class="form-check-label">Push Notifications</label>
                                </div>
                                <div class="mb-3 form-check form-switch">
                                    <input type="checkbox" class="form-check-input custom-switch" id="mobileReminders">
                                    <label class="form-check-label">Bill Payment Reminders</label>
                                </div>
                            </div>
                            <div class="d-grid gap-2 d-md-flex justify-content-md-end mt-3">
                                <button class="btn btn-primary" type="button">Save Notification Settings</button>
                            </div>
                        </div>
                    </div>

                    <!-- Categories Settings -->
                    <div class="tab-pane fade" id="categories">
                        <div class="form-section">
                            <h4 class="mb-4"><i class="fas fa-tags text-primary me-2"></i>Manage Categories</h4>
                            <div class="mb-4">
                                <label class="form-label">Add New Category</label>
                                <div class="input-group">
                                    <input type="text" class="form-control" placeholder="Category name">
                                    <input type="color" class="form-control form-control-color" value="#0d6efd">
                                    <button class="btn btn-primary">Add Category</button>
                                </div>
                            </div>

                            <div class="mb-4">
                                <h5 class="text-primary">Expense Categories</h5>
                                <div class="category-tag">Food & Dining <i class="fas fa-times ms-2"></i></div>
                                <div class="category-tag">Transportation <i class="fas fa-times ms-2"></i></div>
                                <div class="category-tag">Shopping <i class="fas fa-times ms-2"></i></div>
                                <div class="category-tag">Entertainment <i class="fas fa-times ms-2"></i></div>
                                <div class="category-tag">Bills & Utilities <i class="fas fa-times ms-2"></i></div>
                            </div>

                            <div class="mb-4">
                                <h5 class="text-primary">Income Categories</h5>
                                <div class="category-tag">Salary <i class="fas fa-times ms-2"></i></div>
                                <div class="category-tag">Freelance <i class="fas fa-times ms-2"></i></div>
                                <div class="category-tag">Investments <i class="fas fa-times ms-2"></i></div>
                            </div>
                            <div class="d-grid gap-2 d-md-flex justify-content-md-end mt-3">
                                <button class="btn btn-primary" type="button">Save Category Changes</button>
                            </div>
                        </div>
                    </div>

                    <!-- Security Settings -->
                    <div class="tab-pane fade" id="security">
                        <div class="form-section">
                            <h4 class="mb-4"><i class="fas fa-lock text-primary me-2"></i>Security Settings</h4>
                            <div class="feature-card">
                                <h5>Password Management</h5>
                                <div class="mb-3">
                                    <label class="form-label">Current Password</label>
                                    <input type="password" class="form-control">
                                </div>
                                <div class="mb-3">
                                    <label class="form-label">New Password</label>
                                    <input type="password" class="form-control">
                                </div>
                                <div class="mb-3">
                                    <label class="form-label">Confirm New Password</label>
                                    <input type="password" class="form-control">
                                </div>
                                <button class="btn btn-primary">Update Password</button>
                            </div>

                            <div class="feature-card mt-4">
                                <h5>Two-Factor Authentication</h5>
                                <div class="mb-3 form-check form-switch">
                                    <input type="checkbox" class="form-check-input custom-switch" id="2fa">
                                    <label class="form-check-label">Enable 2FA</label>
                                </div>
                                <div class="mb-3">
                                    <label class="form-label">Authentication Method</label>
                                    <select class="form-select">
                                        <option>Authenticator App</option>
                                        <option>SMS</option>
                                        <option>Email</option>
                                    </select>
                                </div>
                            </div>

                            <div class="feature-card mt-4">
                                <h5>Login History</h5>
                                <div class="table-responsive">
                                    <table class="table table-hover">
                                        <thead>
                                            <tr>
                                                <th>Date</th>
                                                <th>Device</th>
                                                <th>Location</th>
                                                <th>Status</th>
                                            </tr>
                                        </thead>
                                        <tbody>
                                            <tr>
                                                <td>2024-02-14 10:30 AM</td>
                                                <td>Chrome - Windows</td>
                                                <td>New York, USA</td>
                                                <td><span class="badge bg-success">Successful</span></td>
                                            </tr>
                                        </tbody>
                                    </table>
                                </div>
                            </div>
                        </div>
                    </div>

                    <!-- Budgeting Settings -->
                    <div class="tab-pane fade" id="budgeting">
                        <div class="form-section">
                            <h4 class="mb-4"><i class="fas fa-piggy-bank text-primary me-2"></i>Budget Configuration</h4>
                            <div class="feature-card">
                                <h5>Monthly Budget Limits</h5>
                                <div class="row g-3">
                                    <div class="col-md-6 mb-3">
                                        <label class="form-label">Overall Budget</label>
                                        <div class="input-group">
                                            <span class="input-group-text">$</span>
                                            <input type="number" class="form-control" placeholder="Enter amount">
                                        </div>
                                    </div>
                                    <div class="col-md-6 mb-3">
                                        <label class="form-label">Budget Cycle Start Date</label>
                                        <select class="form-select">
                                            <option>1st of month</option>
                                            <option>15th of month</option>
                                            <option>Last day of month</option>
                                        </select>
                                    </div>
                                </div>
                            </div>

                            <div class="feature-card mt-4">
                                <h5>Category-wise Budget</h5>
                                <div class="mb-3">
                                    <label class="form-label">Food & Dining</label>
                                    <div class="input-group">
                                        <span class="input-group-text">$</span>
                                        <input type="number" class="form-control" value="500">
                                    </div>
                                </div>
                                <div class="mb-3">
                                    <label class="form-label">Transportation</label>
                                    <div class="input-group">
                                        <span class="input-group-text">$</span>
                                        <input type="number" class="form-control" value="200">
                                    </div>
                                </div>
                                <button class="btn btn-primary">Save Budget Settings</button>
                            </div>
                        </div>
                    </div>

                    <!-- Reports Settings -->
                    <div class="tab-pane fade" id="reports">
                        <div class="form-section">
                            <h4 class="mb-4"><i class="fas fa-chart-line text-primary me-2"></i>Report Preferences</h4>
                            <div class="feature-card">
                                <h5>Default Report Views</h5>
                                <div class="mb-3">
                                    <label class="form-label">Chart Type</label>
                                    <select class="form-select">
                                        <option>Bar Chart</option>
                                        <option>Pie Chart</option>
                                        <option>Line Graph</option>
                                        <option>Area Chart</option>
                                    </select>
                                </div>
                                <div class="mb-3">
                                    <label class="form-label">Default Time Range</label>
                                    <select class="form-select">
                                        <option>Last 7 days</option>
                                        <option>Last 30 days</option>
                                        <option>Last 3 months</option>
                                        <option>Last 6 months</option>
                                        <option>Last year</option>
                                    </select>
                                </div>
                            </div>

                            <div class="feature-card mt-4">
                                <h5>Scheduled Reports</h5>
                                <div class="mb-3 form-check">
                                    <input type="checkbox" class="form-check-input" id="monthlyReport">
                                    <label class="form-check-label">Monthly Expense Summary</label>
                                </div>
                                <div class="mb-3 form-check">
                                    <input type="checkbox" class="form-check-input" id="quarterlyReport">
                                    <label class="form-check-label">Quarterly Analysis</label>
                                </div>
                                <div class="mb-3 form-check">
                                    <input type="checkbox" class="form-check-input" id="yearlyReport">
                                    <label class="form-check-label">Annual Financial Report</label>
                                </div>
                                <div class="d-grid gap-2 d-md-flex justify-content-md-end mt-3">
                                    <button class="btn btn-primary" type="button">Save Report Settings</button>
                                </div>
                            </div>
                        </div>
                    </div>

                    <!-- Automation Settings -->
                    <div class="tab-pane fade" id="automation">
                        <div class="form-section">
                            <h4 class="mb-4"><i class="fas fa-robot text-primary me-2"></i>Automation Rules</h4>
                            <div class="feature-card">
                                <h5>Recurring Transactions</h5>
                                <div class="table-responsive">
                                    <table class="table table-hover">
                                        <thead>
                                            <tr>
                                                <th>Description</th>
                                                <th>Amount</th>
                                                <th>Frequency</th>
                                                <th>Category</th>
                                                <th>Actions</th>
                                            </tr>
                                        </thead>
                                        <tbody>
                                            <tr>
                                                <td>Rent Payment</td>
                                                <td>$1200</td>
                                                <td>Monthly</td>
                                                <td>Housing</td>
                                                <td>
                                                    <button class="btn btn-sm btn-outline-primary"><i class="fas fa-edit"></i></button>
                                                    <button class="btn btn-sm btn-outline-danger"><i class="fas fa-trash"></i></button>
                                                </td>
                                            </tr>
                                        </tbody>
                                    </table>
                                </div>
                                <button class="btn btn-primary">Add Recurring Transaction</button>
                            </div>

                            <div class="feature-card mt-4">
                                <h5>Smart Categories</h5>
                                <div class="mb-3">
                                    <label class="form-label">Auto-categorization Rules</label>
                                    <div class="input-group mb-3">
                                        <input type="text" class="form-control" placeholder="Transaction contains...">
                                        <select class="form-select">
                                            <option>Food & Dining</option>
                                            <option>Transportation</option>
                                            <option>Shopping</option>
                                        </select>
                                        <button class="btn btn-primary">Add Rule</button>
                                    </div>
                                </div>
                            </div>
                        </div>
                    </div>

                    <!-- Integration Settings -->
                    <div class="tab-pane fade" id="integration">
                        <div class="form-section">
                            <h4 class="mb-4"><i class="fas fa-plug text-primary me-2"></i>Connected Services</h4>
                            <div class="feature-card">
                                <h5>Bank Accounts</h5>
                                <div class="d-grid gap-3">
                                    <div class="p-3 border rounded d-flex justify-content-between align-items-center">
                                        <div>
                                            <i class="fas fa-university me-2"></i>
                                            Chase Bank
                                        </div>
                                        <button class="btn btn-sm btn-outline-danger">Disconnect</button>
                                    </div>
                                    <button class="btn btn-primary">Connect New Bank</button>
                                </div>
                            </div>

                            <div class="feature-card mt-4">
                                <h5>Third-party Apps</h5>
                                <div class="mb-3 form-check form-switch">
                                    <input type="checkbox" class="form-check-input custom-switch" id="googleDrive">
                                    <label class="form-check-label">Google Drive Backup</label>
                                </div>
                                <div class="mb-3 form-check form-switch">
                                    <input type="checkbox" class="form-check-input custom-switch" id="dropbox">
                                    <label class="form-check-label">Dropbox Sync</label>
                                </div>
                                <div class="d-grid gap-2 d-md-flex justify-content-md-end mt-3">
                                    <button class="btn btn-primary" type="button">Save Integration Settings</button>
                                </div>
                            </div>
                        </div>
                    </div>

                    <!-- Appearance Settings -->
                    <div class="tab-pane fade" id="appearance">
                        <div class="form-section">
                            <h4 class="mb-4"><i class="fas fa-paint-brush text-primary me-2"></i>Theme Settings</h4>
                            <div class="feature-card">
                                <h5>Color Themes</h5>
                                <div class="d-flex flex-wrap">
                                    <div class="theme-preview active" style="background: #0d6efd"></div>
                                    <div class="theme-preview" style="background: #198754"></div>
                                    <div class="theme-preview" style="background: #6610f2"></div>
                                    <div class="theme-preview" style="background: #dc3545"></div>
                                </div>
                            </div>

                            <div class="feature-card mt-4">
                                <h5>Display Options</h5>
                                <div class="mb-3">
                                    <label class="form-label">Font Size</label>
                                    <select class="form-select">
                                        <option>Small</option>
                                        <option>Medium</option>
                                        <option>Large</option>
                                    </select>
                                </div>
                                <div class="mb-3 form-check form-switch">
                                    <input type="checkbox" class="form-check-input custom-switch" id="darkMode">
                                    <label class="form-check-label">Dark Mode</label>
                                </div>
                                <div class="d-grid gap-2 d-md-flex justify-content-md-end mt-3">
                                    <button class="btn btn-primary" type="button">Save Appearance Settings</button>
                                </div>
                            </div>
                        </div>
                    </div>

                    <!-- Import/Export Settings -->
                    <div class="tab-pane fade" id="import-export">
                        <div class="form-section">
                            <h4 class="mb-4"><i class="fas fa-exchange-alt text-primary me-2"></i>Data Management</h4>
                            <div class="feature-card">
                                <h5>Import Data</h5>
                                <div class="mb-3">
                                    <label class="form-label">Select File</label>
                                    <input type="file" class="form-control" accept=".csv,.xlsx,.json">
                                </div>
                                <button class="btn btn-primary">Import</button>
                            </div>

                            <div class="feature-card mt-4">
                                <h5>Export Data</h5>
                                <div class="mb-3">
                                    <label class="form-label">Date Range</label>
                                    <div class="row g-2">
                                        <div class="col-md-6">
                                            <input type="date" class="form-control" placeholder="Start Date">
                                        </div>
                                        <div class="col-md-6">
                                            <input type="date" class="form-control" placeholder="End Date">
                                        </div>
                                    </div>
                                </div>
                                <div class="mb-3">
                                    <label class="form-label">Export Format</label>
                                    <select class="form-select">
                                        <option value="csv">CSV</option>
                                        <option value="excel">Excel</option>
                                        <option value="pdf">PDF</option>
                                        <option value="json">JSON</option>
                                    </select>
                                </div>
                                <button class="btn btn-primary">Export Data</button>
                            </div>
                        </div>
                    </div>
                </div>
            </div>
        </div>
    </div>

    <script src="https://cdnjs.cloudflare.com/ajax/libs/bootstrap/5.3.0/js/bootstrap.bundle.min.js"></script>
    <script>
        // Form validation
        (() => {
            'use strict'
            const forms = document.querySelectorAll('.needs-validation')
            Array.from(forms).forEach(form => {
                form.addEventListener('submit', event => {
                    if (!form.checkValidity()) {
                        event.preventDefault()
                        event.stopPropagation()
                    }
                    form.classList.add('was-validated')
                }, false)
            })

            // Theme preview selection
            const themePreviews = document.querySelectorAll('.theme-preview')
            themePreviews.forEach(preview => {
                preview.addEventListener('click', () => {
                    themePreviews.forEach(p => p.classList.remove('active'))
                    preview.classList.add('active')
                })
            })
        })()
    </script>
</body>
</html>