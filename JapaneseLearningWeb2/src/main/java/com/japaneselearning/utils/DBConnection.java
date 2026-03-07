<<<<<<< HEAD
/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/Classes/Class.java to edit this template
 */
=======
>>>>>>> f88f49bbc623c4dcecf2fbf29b3238f8f6b4161b
package com.japaneselearning.utils;

import java.sql.Connection;
import java.sql.DriverManager;

public class DBConnection {

    private static final String URL
            = "jdbc:sqlserver://localhost:1433;databaseName=japanese_web;encrypt=true;trustServerCertificate=true";
    private static final String USER = "sa";
<<<<<<< HEAD
    private static final String PASSWORD = "1";
=======
    private static final String PASSWORD = "sa";
>>>>>>> f88f49bbc623c4dcecf2fbf29b3238f8f6b4161b

    public static Connection getConnection() {
        try {
            Class.forName("com.microsoft.sqlserver.jdbc.SQLServerDriver");
            return DriverManager.getConnection(URL, USER, PASSWORD);
        } catch (Exception e) {
            e.printStackTrace();
        }
        return null;
    }
}
