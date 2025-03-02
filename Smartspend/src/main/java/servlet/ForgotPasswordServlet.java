package servlet;

import java.io.IOException;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import util.DBconnection;
import util.EmailUtil;

@WebServlet("/ForgotPasswordServlet")
public class ForgotPasswordServlet extends HttpServlet {
    
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        String email = request.getParameter("email");
        
        try (Connection conn = DBconnection.getConnection()) {
            // First check if email exists in users table
            String checkEmailSql = "SELECT * FROM users WHERE email = ?";
            try (PreparedStatement pstmt = conn.prepareStatement(checkEmailSql)) {
                pstmt.setString(1, email);
                ResultSet rs = pstmt.executeQuery();
                
                if (!rs.next()) {
                    request.setAttribute("error", "Email address not found.");
                    request.getRequestDispatcher("forgot-password.jsp").forward(request, response);
                    return;
                }
            }
            
            // Generate and save OTP
            try {
                String otp = EmailUtil.generateAndSaveOTP(email);
                
                // Send verification email
                EmailUtil.sendVerificationEmail(email, otp);
                
                // Set success message and redirect
                request.setAttribute("success", "A verification code has been sent to your email.");
                request.getSession().setAttribute("reset_email", email); // Store email in session for verification
                request.getRequestDispatcher("verify-otp.jsp").forward(request, response);
                
            } catch (Exception e) {
                e.printStackTrace();
                request.setAttribute("error", "Failed to send verification email. Please try again later.");
                request.getRequestDispatcher("forgot-password.jsp").forward(request, response);
            }
            
        } catch (Exception e) {
            e.printStackTrace();
            request.setAttribute("error", "An error occurred. Please try again later.");
            request.getRequestDispatcher("forgot-password.jsp").forward(request, response);
        }
    }
}