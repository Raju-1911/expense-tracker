package servlet;

import java.io.IOException;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.time.LocalDateTime;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import util.DBconnection;
import org.mindrot.jbcrypt.BCrypt;

@WebServlet("/RegisterServlet")
public class RegisterServlet extends HttpServlet {
    
    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
            
        // Check if this is a password reset or new registration
        String token = request.getParameter("token");
        
        if (token != null && !token.isEmpty()) {
            handlePasswordReset(request, response, token);
        } else {
            handleNewRegistration(request, response);
        }
    }
    
    private void handleNewRegistration(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        
        String firstName = request.getParameter("firstName");
        String lastName = request.getParameter("lastName");
        String email = request.getParameter("email");
        String password = request.getParameter("password");
        String confirmPassword = request.getParameter("confirmPassword");
        
        // Validate input
        if (firstName == null || lastName == null || email == null || 
            password == null || confirmPassword == null) {
            request.setAttribute("error", "All fields are required.");
            request.getRequestDispatcher("register.jsp").forward(request, response);
            return;
        }
        
        // Check password match
        if (!password.equals(confirmPassword)) {
            request.setAttribute("error", "Passwords do not match.");
            request.getRequestDispatcher("register.jsp").forward(request, response);
            return;
        }
        
        Connection conn = null;
        PreparedStatement pstmt = null;
        ResultSet rs = null;
        
        try {
            conn = DBconnection.getConnection();
            
            // Check if email already exists
            String checkEmailSql = "SELECT COUNT(*) FROM users WHERE email = ?";
            pstmt = conn.prepareStatement(checkEmailSql);
            pstmt.setString(1, email);
            rs = pstmt.executeQuery();
            
            if (rs.next() && rs.getInt(1) > 0) {
                request.setAttribute("error", "Email already registered.");
                request.getRequestDispatcher("register.jsp").forward(request, response);
                return;
            }
            
            // Hash the password with BCrypt
            String hashedPassword = hashPassword(password);
            
            // Insert new user
            String insertSql = "INSERT INTO users (first_name, last_name, email, password) VALUES (?, ?, ?, ?)";
            pstmt = conn.prepareStatement(insertSql);
            pstmt.setString(1, firstName);
            pstmt.setString(2, lastName);
            pstmt.setString(3, email);
            pstmt.setString(4, hashedPassword);
            
            int result = pstmt.executeUpdate();
            
            if (result > 0) {
                response.sendRedirect("login.jsp?registered=true");
            } else {
                request.setAttribute("error", "Registration failed. Please try again.");
                request.getRequestDispatcher("register.jsp").forward(request, response);
            }
            
        } catch (SQLException e) {
            e.printStackTrace();
            request.setAttribute("error", "An error occurred. Please try again later.");
            request.getRequestDispatcher("register.jsp").forward(request, response);
        } finally {
            closeResources(conn, pstmt, rs);
        }
    }
    
    private void handlePasswordReset(HttpServletRequest request, HttpServletResponse response, String token)
            throws ServletException, IOException {
            
        String newPassword = request.getParameter("newPassword");
        String confirmPassword = request.getParameter("confirmPassword");
        
        if (newPassword == null || confirmPassword == null) {
            request.setAttribute("error", "Please enter both passwords.");
            request.getRequestDispatcher("reset-password.jsp?token=" + token).forward(request, response);
            return;
        }
        
        if (!newPassword.equals(confirmPassword)) {
            request.setAttribute("error", "Passwords do not match.");
            request.getRequestDispatcher("reset-password.jsp?token=" + token).forward(request, response);
            return;
        }
        
        Connection conn = null;
        PreparedStatement pstmt = null;
        ResultSet rs = null;
        
        try {
            conn = DBconnection.getConnection();
            
            // Verify token and check expiry
            String checkTokenSql = "SELECT * FROM users WHERE reset_token = ? AND reset_token_expiry > ?";
            pstmt = conn.prepareStatement(checkTokenSql);
            pstmt.setString(1, token);
            pstmt.setObject(2, LocalDateTime.now());
            rs = pstmt.executeQuery();
            
            if (!rs.next()) {
                request.setAttribute("error", "Invalid or expired reset token.");
                request.getRequestDispatcher("reset-password.jsp?token=" + token).forward(request, response);
                return;
            }
            
            // Hash the new password with BCrypt
            String hashedPassword = hashPassword(newPassword);
            
            // Update password and clear reset token
            String updatePasswordSql = "UPDATE users SET password = ?, reset_token = NULL, reset_token_expiry = NULL WHERE reset_token = ?";
            pstmt = conn.prepareStatement(updatePasswordSql);
            pstmt.setString(1, hashedPassword);
            pstmt.setString(2, token);
            pstmt.executeUpdate();
            
            response.sendRedirect("login.jsp?reset=success");
            
        } catch (SQLException e) {
            e.printStackTrace();
            request.setAttribute("error", "An error occurred. Please try again later.");
            request.getRequestDispatcher("reset-password.jsp?token=" + token).forward(request, response);
        } finally {
            closeResources(conn, pstmt, rs);
        }
    }
    
    private String hashPassword(String password) {
        // Generate a salt with a cost factor of 12
        return BCrypt.hashpw(password, BCrypt.gensalt(12));
    }
    
    private void closeResources(Connection conn, PreparedStatement pstmt, ResultSet rs) {
        try {
            if (rs != null) rs.close();
            if (pstmt != null) pstmt.close();
            if (conn != null) conn.close();
        } catch (SQLException e) {
            e.printStackTrace();
        }
    }
}