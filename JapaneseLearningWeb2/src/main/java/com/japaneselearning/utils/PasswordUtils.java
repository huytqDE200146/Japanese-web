package com.japaneselearning.utils;

import org.mindrot.jbcrypt.BCrypt;

public class PasswordUtils {
    
    // Hash a plain text password
    public static String hashPassword(String plainTextPassword) {
        return BCrypt.hashpw(plainTextPassword, BCrypt.gensalt());
    }

    // Check if the plain text password matches the hashed password
    public static boolean checkPassword(String plainTextPassword, String hashedPassword) {
        if (hashedPassword == null || !hashedPassword.startsWith("$2a$")) {
            // For older passwords that might not be hashed. Fallback or return false.
            return plainTextPassword.equals(hashedPassword);
        }
        try {
            return BCrypt.checkpw(plainTextPassword, hashedPassword);
        } catch (Exception e) {
            e.printStackTrace();
            return false;
        }
    }
}
