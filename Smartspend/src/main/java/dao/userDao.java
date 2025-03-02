package dao;
import model.user;
import util.DBconnection;
import java.sql.*;
import java.time.LocalDateTime;
import java.util.logging.Logger;
import java.util.logging.Level;
import org.mindrot.jbcrypt.BCrypt;

public class userDao {
    private static final Logger LOGGER = Logger.getLogger(userDao.class.getName());
    private Connection connection;

    public userDao() throws SQLException {
        connection = DBconnection.getConnection();
    }

    public user validateUser(String email, String password) {
        try {
            String sql = "SELECT * FROM users WHERE email = ?";
            PreparedStatement ps = connection.prepareStatement(sql);
            ps.setString(1, email);
            ResultSet rs = ps.executeQuery();
            if (rs.next()) {
                String storedPassword = rs.getString("password");
                if (verifyPassword(password, storedPassword)) {
                    user user = new user();
                    user.setId(rs.getInt("id"));
                    user.setFirstName(rs.getString("first_name"));
                    user.setLastName(rs.getString("last_name"));
                    user.setEmail(rs.getString("email"));
                    user.setRole(rs.getString("role"));
                    user.setStatus(rs.getString("status"));
                    return user;
                }
            }
        } catch (SQLException e) {
            LOGGER.log(Level.SEVERE, "User validation error", e);
        }
        return null;
    }

    private boolean verifyPassword(String inputPassword, String hashedPassword) {
        try {
            return BCrypt.checkpw(inputPassword, hashedPassword);
        } catch (Exception e) {
            LOGGER.log(Level.SEVERE, "Password verification error", e);
            return false;
        }
    }

    public String hashPassword(String plainPassword) {
        return BCrypt.hashpw(plainPassword, BCrypt.gensalt(12));
    }

    public boolean registerUser(user user) {
        try {
            String sql = "INSERT INTO users (first_name, last_name, email, password, role, status, created_at) " +
                         "VALUES (?, ?, ?, ?, ?, ?, ?)";
            PreparedStatement ps = connection.prepareStatement(sql);
            ps.setString(1, user.getFirstName());
            ps.setString(2, user.getLastName());
            ps.setString(3, user.getEmail());
            String hashedPassword = hashPassword(user.getPassword());
            ps.setString(4, hashedPassword);
            ps.setString(5, user.getRole() != null ? user.getRole() : "user");
            ps.setString(6, user.getStatus() != null ? user.getStatus() : "active");
            ps.setTimestamp(7, Timestamp.valueOf(LocalDateTime.now()));
            return ps.executeUpdate() > 0;
        } catch (SQLException e) {
            LOGGER.log(Level.SEVERE, "User registration error", e);
            return false;
        }
    }

    public boolean isEmailExists(String email) {
        try {
            String sql = "SELECT COUNT(*) FROM users WHERE email = ?";
            PreparedStatement ps = connection.prepareStatement(sql);
            ps.setString(1, email);
            ResultSet rs = ps.executeQuery();
            
            if (rs.next()) {
                return rs.getInt(1) > 0;
            }
        } catch (SQLException e) {
            LOGGER.log(Level.SEVERE, "Email check error", e);
        }
        return false;
    }
}