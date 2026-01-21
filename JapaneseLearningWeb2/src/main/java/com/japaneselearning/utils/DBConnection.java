/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/Classes/Class.java to edit this template
 */
package com.japaneselearning.utils;



import java.sql.Connection;
import java.sql.DriverManager;

public class DBConnection {

    private static final String URL =
    "jdbc:sqlserver://localhost:1433;databaseName=japanese_web;encrypt=true;trustServerCertificate=true";
private static final String USER = "sa";
private static final String PASSWORD = "1";

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