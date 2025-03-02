package servlet;

import java.io.IOException;
import java.io.PrintWriter;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.Timestamp;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;
import org.json.JSONObject;
import util.DBconnection;
import java.util.logging.Logger;
import java.util.logging.Level;

@WebServlet("/VerifyOTPServlet")
public class VerifyOTPServlet extends HttpServlet {
    private static final Logger LOGGER = Logger.getLogger(VerifyOTPServlet.class.getName());
    
    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        
        response.setContentType("application/json");
        response.setCharacterEncoding("UTF-8");
        PrintWriter out = response.getWriter();
        JSONObject jsonResponse = new JSONObject();
        
        try {
            // Get parameters
            String code = request.getParameter("code");
            String email = request.getParameter("email");
            
            // Try to get email from session if not in request params
            if (email == null || email.trim().isEmpty()) {
                HttpSession session = request.getSession(false);
                if (session != null) {
                    email = (String) session.getAttribute("registrationEmail");
                    LOGGER.info("Email not found in parameters, retrieved from session: " + email);
                }
            }
            
            // Validate input
            if (email == null || email.trim().isEmpty()) {
                LOGGER.warning("Email not provided in request or session");
                jsonResponse.put("success", false);
                jsonResponse.put("message", "Email not provided. Please try again.");
                out.print(jsonResponse.toString());
                return;
            }
            
            if (code == null || code.trim().isEmpty()) {
                jsonResponse.put("success", false);
                jsonResponse.put("message", "Please enter the verification code.");
                out.print(jsonResponse.toString());
                return;
            }
            
            LOGGER.info("Verifying OTP: email=" + email + ", code=" + code);
            
            // Database verification
            try (Connection conn = DBconnection.getConnection()) {
                Timestamp currentTime = new Timestamp(System.currentTimeMillis());
                
                // Check if token exists but is expired (for debugging)
                String checkSql = "SELECT * FROM password_reset_tokens WHERE email = ? AND token = ?";
                try (PreparedStatement checkStmt = conn.prepareStatement(checkSql)) {
                    checkStmt.setString(1, email);
                    checkStmt.setString(2, code);
                    ResultSet checkRs = checkStmt.executeQuery();
                    
                    if (checkRs.next()) {
                        Timestamp expiresAt = checkRs.getTimestamp("expires_at");
                        boolean used = checkRs.getBoolean("used");
                        LOGGER.info("Token found for email: " + email + 
                                   ", expires_at: " + expiresAt + 
                                   ", current time: " + currentTime + 
                                   ", used: " + used);
                    } else {
                        LOGGER.info("No token found for email: " + email + " and code: " + code);
                    }
                }
                
                // Main verification query
                String sql = "SELECT * FROM password_reset_tokens " +
                           "WHERE email = ? AND token = ? AND expires_at > ? AND used = false " +
                           "ORDER BY created_at DESC LIMIT 1";
                
                try (PreparedStatement pstmt = conn.prepareStatement(sql)) {
                    pstmt.setString(1, email);
                    pstmt.setString(2, code);
                    pstmt.setTimestamp(3, currentTime);
                    
                    ResultSet rs = pstmt.executeQuery();
                    
                    if (rs.next()) {
                        // Mark token as used
                        String updateSql = "UPDATE password_reset_tokens SET used = true WHERE email = ? AND token = ?";
                        try (PreparedStatement updateStmt = conn.prepareStatement(updateSql)) {
                            updateStmt.setString(1, email);
                            updateStmt.setString(2, code);
                            updateStmt.executeUpdate();
                        }
                        
                        // Generate reset token and store email in session for reset password page
                        String sessionToken = java.util.UUID.randomUUID().toString();
                        HttpSession session = request.getSession();
                        session.setAttribute("reset_token", sessionToken);
                        session.setAttribute("registrationEmail", email);
                        
                        // Set success response
                        jsonResponse.put("success", true);
                        jsonResponse.put("message", "Verification successful!");
                        jsonResponse.put("redirectUrl", "reset-password.jsp?token=" + sessionToken);
                        
                    } else {
                        jsonResponse.put("success", false);
                        jsonResponse.put("message", "Invalid or expired verification code.");
                    }
                }
            } catch (Exception e) {
                LOGGER.log(Level.SEVERE, "Database error in verification", e);
                jsonResponse.put("success", false);
                jsonResponse.put("message", "Database error occurred. Please try again.");
            }
            
        } catch (Exception e) {
            LOGGER.log(Level.SEVERE, "Unexpected error in verification", e);
            jsonResponse.put("success", false);
            jsonResponse.put("message", "An unexpected error occurred. Please try again.");
        }
        
        out.print(jsonResponse.toString());
    }
}