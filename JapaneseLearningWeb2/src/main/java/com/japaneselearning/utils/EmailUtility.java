package com.japaneselearning.utils;

import java.util.Properties;
import jakarta.mail.Authenticator;
import jakarta.mail.Message;
import jakarta.mail.MessagingException;
import jakarta.mail.PasswordAuthentication;
import jakarta.mail.Session;
import jakarta.mail.Transport;
import jakarta.mail.internet.InternetAddress;
import jakarta.mail.internet.MimeMessage;

public class EmailUtility {

    public static void sendEmail(String toAddress, String subject, String messageContent) throws MessagingException {
        // SMTP server settings
        String host = "smtp.gmail.com";
        String port = "587";
        final String senderEmail = "de190574lenhaphuong@gmail.com";
        final String password = "dxph pwuz cnrq hack";

        // Setup properties for the mail session
        Properties properties = new Properties();
        properties.put("mail.smtp.host", host);
        properties.put("mail.smtp.port", port);
        properties.put("mail.smtp.auth", "true");
        properties.put("mail.smtp.starttls.enable", "true");
        properties.put("mail.smtp.ssl.protocols", "TLSv1.2");
        properties.put("mail.smtp.ssl.trust", "smtp.gmail.com");

        // Authenticator
        Authenticator auth = new Authenticator() {
            @Override
            public PasswordAuthentication getPasswordAuthentication() {
                return new PasswordAuthentication(senderEmail, password);
            }
        };

        Session session = Session.getInstance(properties, auth);

        // Create a new e-mail message
        MimeMessage msg = new MimeMessage(session);
        try{
            msg.setFrom(new InternetAddress(senderEmail, "Japanese Learning Support", "UTF-8"));
        }catch(java.io.UnsupportedEncodingException e){
            e.printStackTrace();
            msg.setFrom(new InternetAddress(senderEmail));
        }
        InternetAddress[] toAddresses = { new InternetAddress(toAddress) };
        msg.setRecipients(Message.RecipientType.TO, toAddresses);
        msg.setSubject(subject, "UTF-8");
        msg.setContent(messageContent, "text/html; charset=UTF-8");

        // Send the message
        Transport.send(msg);
    }
}
