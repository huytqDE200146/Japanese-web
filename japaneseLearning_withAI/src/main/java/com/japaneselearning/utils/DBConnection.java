package com.japaneselearning.utils;

import java.sql.Connection;
import java.sql.DriverManager;

public class DBConnection {

    private static final String URL
            = "jdbc:sqlserver://localhost:1433;databaseName=japanese_web;encrypt=true;trustServerCertificate=true";
    private static final String USER = "sa";
    
    // Lưu ý: Thay đổi mật khẩu này cho đúng với cấu hình SQL Server trên máy bạn
    private static final String PASSWORD = "1882005"; 

    public static Connection getConnection() {
        try {
            Class.forName("com.microsoft.sqlserver.jdbc.SQLServerDriver");
            return DriverManager.getConnection(URL, USER, PASSWORD);
        } catch (Exception e) {
            System.err.println("Lỗi kết nối Database: " + e.getMessage());
            e.printStackTrace();
        }
        return null;
    }
}