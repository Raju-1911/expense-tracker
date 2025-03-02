package util;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.SQLException;
import java.sql.Timestamp;
import java.util.Properties;
import java.util.Random;
import java.util.logging.Level;
import java.util.logging.Logger;

import jakarta.mail.*;
import jakarta.mail.internet.InternetAddress;
import jakarta.mail.internet.MimeMessage;

public class EmailUtil {
    private static final Logger LOGGER = Logger.getLogger(EmailUtil.class.getName());
    
    // Email configuration
    private static final String FROM_EMAIL = "kolaramakrishna73@gmail.com";
    private static final String EMAIL_PASSWORD = "pxrb ttmf yqba lxom";
    private static final String SMTP_HOST = "smtp.gmail.com";
    private static final String SMTP_PORT = "587";
    
    // OTP configuration
    private static final int OTP_LENGTH = 6;
    private static final int OTP_EXPIRY_MINUTES = 15;
    
    /**
     * Generates and saves an OTP for password reset
     * @param email The user's email address
     * @return The generated OTP
     * @throws EmailException if there's an error in the process
     */
    public static String generateAndSaveOTP(String email) throws EmailException {
        if (email == null || email.trim().isEmpty()) {
            throw new EmailException("Email address cannot be empty");
        }
        
        try {
            // Generate OTP
            String otp = generateOTP();
            
            // Save OTP to database
            saveOTPToDatabase(email, otp);
            
            return otp;
        } catch (SQLException e) {
            LOGGER.log(Level.SEVERE, "Error saving OTP to database", e);
            throw new EmailException("Failed to generate and save OTP: " + e.getMessage());
        }
    }
    
    /**
     * Sends a verification email with the OTP
     * @param toEmail Recipient's email address
     * @param otp The OTP to be sent
     * @throws EmailException if there's an error sending the email
     */
    public static void sendVerificationEmail(String toEmail, String otp) throws EmailException {
        if (toEmail == null || toEmail.trim().isEmpty()) {
            throw new EmailException("Recipient email address cannot be empty");
        }
        
        if (otp == null || otp.trim().isEmpty()) {
            throw new EmailException("OTP cannot be empty");
        }
        
        try {
            Session session = createMailSession();
            Message message = createEmailMessage(session, toEmail, otp);
            Transport.send(message);
            LOGGER.info("Verification email sent successfully to: " + toEmail);
        } catch (MessagingException e) {
            LOGGER.log(Level.SEVERE, "Failed to send verification email", e);
            throw new EmailException("Failed to send verification email: " + e.getMessage());
        }
    }
    
    /**
     * Creates and configures the mail session
     * @return Configured Session object
     */
    private static Session createMailSession() {
        Properties props = new Properties();
        props.put("mail.smtp.auth", "true");
        props.put("mail.smtp.starttls.enable", "true");
        props.put("mail.smtp.host", SMTP_HOST);
        props.put("mail.smtp.port", SMTP_PORT);
        props.put("mail.smtp.ssl.protocols", "TLSv1.2");
        props.put("mail.smtp.ssl.trust", SMTP_HOST);
        
        return Session.getInstance(props, new Authenticator() {
            @Override
            protected PasswordAuthentication getPasswordAuthentication() {
                return new PasswordAuthentication(FROM_EMAIL, EMAIL_PASSWORD);
            }
        });
    }
    
    /**
     * Creates the email message with HTML content
     * @param session Mail session
     * @param toEmail Recipient's email
     * @param otp The OTP to be included in the email
     * @return Configured Message object
     * @throws MessagingException if there's an error creating the message
     */
    private static Message createEmailMessage(Session session, String toEmail, String otp) throws MessagingException {
        Message message = new MimeMessage(session);
        message.setFrom(new InternetAddress(FROM_EMAIL));
        message.setRecipients(Message.RecipientType.TO, InternetAddress.parse(toEmail));
        message.setSubject("SmartSpend Password Reset");
        
        String htmlContent = String.format(
            "<div style='font-family: Arial, sans-serif; max-width: 600px; margin: 0 auto;'>" +
            "<div style='background-color: #667eea; padding: 20px; text-align: center;'>" +
            "<h1 style='color: white; margin: 0;'>SmartSpend</h1>" +
            "</div>" +
            "<div style='background-color: #f8fafc; padding: 40px 20px; text-align: center;'>" +
            "<h2 style='color: #2d3748; margin-bottom: 20px;'>Password Reset Code</h2>" +
            "<p style='color: #4a5568; margin-bottom: 30px;'>Use the following code to reset your password:</p>" +
            "<div style='background-color: white; padding: 20px; border-radius: 8px; border: 1px solid #e2e8f0; display: inline-block;'>" +
            "<h1 style='color: #667eea; letter-spacing: 5px; margin: 0;'>%s</h1>" +
            "</div>" +
            "<p style='color: #718096; margin-top: 30px; font-size: 14px;'>This code will expire in %d minutes.</p>" +
            "<p style='color: #718096; font-size: 12px;'>If you didn't request this code, please ignore this email.</p>" +
            "</div>" +
            "</div>",
            otp, OTP_EXPIRY_MINUTES
        );
        
        message.setContent(htmlContent, "text/html; charset=utf-8");
        return message;
    }
    
    /**
     * Generates a random OTP
     * @return Generated OTP string
     */
    private static String generateOTP() {
        Random random = new Random();
        return String.format("%0" + OTP_LENGTH + "d", random.nextInt((int) Math.pow(10, OTP_LENGTH)));
    }
    
    /**
     * Saves the OTP to the database
     * @param email User's email
     * @param otp Generated OTP
     * @throws SQLException if there's a database error
     */
    private static void saveOTPToDatabase(String email, String otp) throws SQLException {
        try (Connection conn = DBconnection.getConnection()) {
            Timestamp currentTime = new Timestamp(System.currentTimeMillis());
            Timestamp expiryTime = new Timestamp(currentTime.getTime() + (OTP_EXPIRY_MINUTES * 60 * 1000));
            
            // Insert new OTP with created_at timestamp
            String sql = "INSERT INTO password_reset_tokens (email, token, expires_at, created_at, used) " +
                         "VALUES (?, ?, ?, ?, false)";
            
            try (PreparedStatement pstmt = conn.prepareStatement(sql)) {
                pstmt.setString(1, email);
                pstmt.setString(2, otp);
                pstmt.setTimestamp(3, expiryTime);
                pstmt.setTimestamp(4, currentTime);
                pstmt.executeUpdate();
            }
        }
    }
    
    /**
     * Custom exception class for email-related errors
     */
    public static class EmailException extends Exception {
        public EmailException(String message) {
            super(message);
        }
    }
}