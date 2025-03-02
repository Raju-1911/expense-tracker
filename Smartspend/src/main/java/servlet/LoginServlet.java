package servlet;

import java.io.*;
import javax.servlet.*;
import javax.servlet.http.*;
import javax.servlet.annotation.WebServlet;
import java.sql.*;
import org.mindrot.jbcrypt.BCrypt;

@WebServlet("/LoginServlet")
public class LoginServlet extends HttpServlet {
    
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        
        String email = request.getParameter("email");
        String password = request.getParameter("password");

        try {
            // Get database connection
            Class.forName("com.mysql.cj.jdbc.Driver");
            Connection conn = DriverManager.getConnection(
                "jdbc:mysql://localhost:3306/expense_tracker",
                "root",
                "1813"
            );

            // Check user credentials
            String sql = "SELECT * FROM users WHERE email = ? AND status = 'active'";
            PreparedStatement stmt = conn.prepareStatement(sql);
            stmt.setString(1, email);

            ResultSet rs = stmt.executeQuery();

            if (rs.next()) {
                String hashedPassword = rs.getString("password");

                boolean passwordMatch = false;
                try {
                    // Try BCrypt verification first
                    passwordMatch = BCrypt.checkpw(password, hashedPassword);
                } catch (IllegalArgumentException e) {
                    // If BCrypt fails, check if passwords match directly
                    passwordMatch = password.equals(hashedPassword);
                }

                if (passwordMatch) {
                    // Create session with user details
                    HttpSession session = request.getSession();
                    session.setAttribute("userId", rs.getInt("id"));
                    session.setAttribute("userEmail", email);
                    session.setAttribute("firstName", rs.getString("first_name"));
                    session.setAttribute("lastName", rs.getString("last_name"));
                    session.setAttribute("role", rs.getString("role"));

                    // Redirect based on role
                    String role = rs.getString("role");
                    if ("admin".equalsIgnoreCase(role)) {
                        response.sendRedirect("admin/dashboard.jsp");
                    } else {
                        response.sendRedirect("dashboard.jsp");
                    }
                    return;
                }
            }

            // Invalid credentials
            response.sendRedirect("login.jsp?error=invalid");

            rs.close();
            stmt.close();
            conn.close();

        } catch (Exception e) {
            e.printStackTrace();
            response.sendRedirect("login.jsp?error=system");
        }
    }
}