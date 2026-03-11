package com.japaneselearning.utils;

import java.sql.Connection;
import java.sql.DriverManager;

public class DBConnection {

    private static final String URL
            = "jdbc:sqlserver://SQL8006.site4now.net;databaseName=db_ac68c7_japaneseweb;encrypt=true;trustServerCertificate=true";
    private static final String USER = "db_ac68c7_japaneseweb_admin";
    
    // Lưu ý: Thay đổi mật khẩu này cho đúng với cấu hình SQL Server trên máy bạn
    private static final String PASSWORD = "Nhaphuong@123"; 

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