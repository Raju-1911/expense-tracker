<%@ page contentType="application/json" %>
<%@ page import="java.sql.*" %>
<%@ page import="util.DBconnection" %>
<%@ page import="org.json.simple.JSONObject" %>
<%
    // Set response type to JSON
    response.setContentType("application/json");
    JSONObject jsonResponse = new JSONObject();

    try {
        // Check if user is logged in
        HttpSession sessionObj = request.getSession(false);
        Integer userId = (sessionObj != null) ? (Integer) sessionObj.getAttribute("userId") : null;
        
        if (userId == null) {
            jsonResponse.put("status", "error");
            jsonResponse.put("message", "User not logged in");
            out.print(jsonResponse.toString());
            return;
        }

        // Get and validate parameters
        String category = request.getParameter("category");
        String limitStr = request.getParameter("limit");

        if (category == null || category.trim().isEmpty() || limitStr == null || limitStr.trim().isEmpty()) {
            jsonResponse.put("status", "error");
            jsonResponse.put("message", "Missing required parameters");
            out.print(jsonResponse.toString());
            return;
        }

        // Validate category
        String[] validCategories = {"Food", "Transport", "Bills", "Entertainment", "Other"};
        boolean isValidCategory = false;
        for (String validCategory : validCategories) {
            if (validCategory.equals(category)) {
                isValidCategory = true;
                break;
            }
        }

        if (!isValidCategory) {
            jsonResponse.put("status", "error");
            jsonResponse.put("message", "Invalid category");
            out.print(jsonResponse.toString());
            return;
        }

        // Parse and validate limit
        double limit;
        try {
            limit = Double.parseDouble(limitStr);
            if (limit < 0) {
                throw new NumberFormatException("Limit cannot be negative");
            }
        } catch (NumberFormatException e) {
            jsonResponse.put("status", "error");
            jsonResponse.put("message", "Invalid limit format: " + e.getMessage());
            out.print(jsonResponse.toString());
            return;
        }

        // Update database
        try (Connection conn = DBconnection.getConnection()) {
            // First check if the record exists
            String checkQuery = "SELECT COUNT(*) FROM category_limits WHERE user_id = ? AND category = ?";
            try (PreparedStatement checkPs = conn.prepareStatement(checkQuery)) {
                checkPs.setInt(1, userId);
                checkPs.setString(2, category);
                
                ResultSet rs = checkPs.executeQuery();
                rs.next();
                boolean recordExists = rs.getInt(1) > 0;

                // Prepare appropriate query based on existence
                String query;
                if (recordExists) {
                    query = "UPDATE category_limits SET monthly_limit = ? WHERE user_id = ? AND category = ?";
                } else {
                    query = "INSERT INTO category_limits (monthly_limit, user_id, category) VALUES (?, ?, ?)";
                }

                try (PreparedStatement ps = conn.prepareStatement(query)) {
                    ps.setDouble(1, limit);
                    ps.setInt(2, userId);
                    ps.setString(3, category);
                    
                    int rowsAffected = ps.executeUpdate();
                    
                    if (rowsAffected > 0) {
                        jsonResponse.put("status", "success");
                        jsonResponse.put("message", "Limit updated successfully");
                        jsonResponse.put("newLimit", limit);
                    } else {
                        jsonResponse.put("status", "error");
                        jsonResponse.put("message", "Failed to update limit");
                    }
                }
            }
        } catch (SQLException e) {
            jsonResponse.put("status", "error");
            jsonResponse.put("message", "Database error: " + e.getMessage());
        }
    } catch (Exception e) {
        jsonResponse.put("status", "error");
        jsonResponse.put("message", "Unexpected error: " + e.getMessage());
    }
    
    out.print(jsonResponse.toString());
%>