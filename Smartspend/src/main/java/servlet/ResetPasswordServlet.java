package servlet;

import java.io.IOException;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;
import util.DBconnection;
import org.mindrot.jbcrypt.BCrypt;
import java.util.logging.Logger;
import java.util.logging.Level;

@WebServlet("/ResetPasswordServlet")
public class ResetPasswordServlet extends HttpServlet {
    private static final Logger LOGGER = Logger.getLogger(ResetPasswordServlet.class.getName());

    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        
        HttpSession session = request.getSession(false);
        String sessionToken = (session != null) ? (String) session.getAttribute("reset_token") : null;
        String requestToken = request.getParameter("token");
        String newPassword = request.getParameter("newPassword");
        String confirmPassword = request.getParameter("confirmPassword");
        
        // Log the values for debugging
        LOGGER.info("Session Token: " + sessionToken);
        LOGGER.info("Request Token: " + requestToken);
        
        // Check if either token is present
        if (sessionToken == null && (requestToken == null || requestToken.trim().isEmpty())) {
            request.setAttribute("error", "Invalid request or session expired.");
            request.getRequestDispatcher("forgot-password.jsp").forward(request, response);
            return;
        }
        
        // Validate passwords match
        if (!newPassword.equals(confirmPassword)) {
            request.setAttribute("error", "Passwords do not match.");
            request.getRequestDispatcher("reset-password.jsp?token=" + requestToken).forward(request, response);
            return;
        }
        
        // Get email from session
        String email = (session != null) ? (String) session.getAttribute("registrationEmail") : null;
        
        // If email is not in session, try to get it from database using token
        if (email == null || email.trim().isEmpty()) {
            email = getEmailFromToken(requestToken);
            if (email == null) {
                request.setAttribute("error", "Invalid token or session expired. Please try again.");
                request.getRequestDispatcher("forgot-password.jsp").forward(request, response);
                return;
            }
        }
        
        try (Connection conn = DBconnection.getConnection()) {
            // Update password in the users table
            String sql = "UPDATE users SET password = ? WHERE email = ?";
            try (PreparedStatement pstmt = conn.prepareStatement(sql)) {
                String hashedPassword = hashPassword(newPassword);
                pstmt.setString(1, hashedPassword);
                pstmt.setString(2, email);
                int rowsUpdated = pstmt.executeUpdate();
                
                if (rowsUpdated > 0) {
                    // Mark the token as used
                    markTokenAsUsed(conn, requestToken);
                    
                    // Clean up the session
                    if (session != null) {
                        session.removeAttribute("reset_token");
                        session.removeAttribute("registrationEmail");
                    }
                    
                    response.sendRedirect("login.jsp?reset=success");
                } else {
                    LOGGER.warning("No user found with email: " + email);
                    request.setAttribute("error", "User not found. Please try again.");
                    request.getRequestDispatcher("forgot-password.jsp").forward(request, response);
                }
            }
        } catch (SQLException e) {
            LOGGER.log(Level.SEVERE, "Database error during password reset", e);
            request.setAttribute("error", "An error occurred. Please try again.");
            request.getRequestDispatcher("reset-password.jsp?token=" + requestToken).forward(request, response);
        }
    }
    
    private String getEmailFromToken(String token) {
        try (Connection conn = DBconnection.getConnection()) {
            String sql = "SELECT email FROM password_reset_tokens WHERE token = ? AND used = false AND expires_at > NOW()";
            try (PreparedStatement pstmt = conn.prepareStatement(sql)) {
                pstmt.setString(1, token);
                try (ResultSet rs = pstmt.executeQuery()) {
                    if (rs.next()) {
                        return rs.getString("email");
                    }
                }
            }
        } catch (SQLException e) {
            LOGGER.log(Level.SEVERE, "Error retrieving email from token", e);
        }
        return null;
    }
    
    private void markTokenAsUsed(Connection conn, String token) throws SQLException {
        String sql = "UPDATE password_reset_tokens SET used = true WHERE token = ?";
        try (PreparedStatement pstmt = conn.prepareStatement(sql)) {
            pstmt.setString(1, token);
            pstmt.executeUpdate();
        }
    }
    
    private String hashPassword(String password) {
        // Use BCrypt for hashing to match the login servlet's verification method
        return BCrypt.hashpw(password, BCrypt.gensalt());
    }
}