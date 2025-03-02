<%@ page import="java.sql.*, util.DBconnection, org.json.simple.JSONObject, java.util.*" %>
<%
response.setContentType("application/json");
JSONObject result = new JSONObject();
Connection conn = null;
PreparedStatement ps = null;
ResultSet rs = null;

try {
    // Validate user session
    Integer userId = (Integer) session.getAttribute("userId");
    if (userId == null) {
        throw new Exception("User not logged in");
    }

    // Get database connection
    conn = DBconnection.getConnection();

    // Prepare and execute query
    ps = conn.prepareStatement(
        "SELECT category, SUM(amount) as total " +
        "FROM expenses " +
        "WHERE user_id = ? AND MONTH(date) = MONTH(CURRENT_DATE()) " +
        "GROUP BY category"
    );
    ps.setInt(1, userId);
    rs = ps.executeQuery();

    // Process results
    while (rs.next()) {
        String category = rs.getString("category");
        if (category != null) {
            // Explicitly cast to ensure type safety
            result.put(category.toLowerCase(), Double.valueOf(rs.getDouble("total")));
        }
    }

    out.print(result.toString());

} catch (Exception e) {
    // Log the error (replace with proper logging)
    e.printStackTrace();

    // Send error response
    response.setStatus(HttpServletResponse.SC_INTERNAL_SERVER_ERROR);
    JSONObject errorObj = new JSONObject();
    errorObj.put("error", e.getMessage());
    out.print(errorObj.toString());

} finally {
    // Close resources
    try {
        if (rs != null) rs.close();
        if (ps != null) ps.close();
        if (conn != null) conn.close();
    } catch (SQLException e) {
        e.printStackTrace();
    }
}
%>