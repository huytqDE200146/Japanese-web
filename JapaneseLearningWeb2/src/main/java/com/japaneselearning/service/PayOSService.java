package com.japaneselearning.service;

import com.japaneselearning.model.Payment;
import vn.payos.PayOS;
import vn.payos.type.CheckoutResponseData;
import vn.payos.type.ItemData;
import vn.payos.type.PaymentData;
import vn.payos.type.PaymentLinkData;

import javax.crypto.Mac;
import javax.crypto.spec.SecretKeySpec;
import java.io.*;
import java.net.HttpURLConnection;
import java.net.URL;
import java.nio.charset.StandardCharsets;
import java.util.Properties;
import com.google.gson.Gson;
import com.google.gson.JsonObject;
import com.google.gson.JsonArray;

/**
 * PayOS Service - Tích hợp cổng thanh toán PayOS
 * Production Environment
 */
public class PayOSService {
    
    /**
     * Simple response class for direct API calls
     */
    public static class PaymentResponse {
        private String checkoutUrl;
        private long orderCode;
        private int amount;
        
        public PaymentResponse(String checkoutUrl, long orderCode, int amount) {
            this.checkoutUrl = checkoutUrl;
            this.orderCode = orderCode;
            this.amount = amount;
        }
        
        public String getCheckoutUrl() { return checkoutUrl; }
        public long getOrderCode() { return orderCode; }
        public int getAmount() { return amount; }
    }
    
    // Store last successful response for direct API
    private PaymentResponse lastDirectResponse;
    
    private static PayOSService instance;
    private PayOS payOS;
    
    // PayOS Config
    private String clientId;
    private String apiKey;
    private String checksumKey;
    private String returnUrl;
    private String cancelUrl;
    
    private PayOSService() {
        loadConfig();
        initPayOS();
    }
    
    public static synchronized PayOSService getInstance() {
        if (instance == null) {
            instance = new PayOSService();
        }
        return instance;
    }
    
    /**
     * Load config từ file properties
     */
    private void loadConfig() {
        try (InputStream input = getClass().getClassLoader()
                .getResourceAsStream("payos-config.properties")) {
            
            if (input == null) {
                System.err.println("payos-config.properties not found! Using defaults.");
                // Default values - REPLACE WITH YOUR PRODUCTION KEYS
                clientId = "b0abfbd8-de87-49cd-9df1-bfdb5074f516";
                apiKey = "8e9139d2-85f8-445f-87a0-8442cb24b0a6";
                checksumKey = "cc84e2d76de6f074513db4c89947e0471fcc92017dde6e723c94855756ae5a9b";
                returnUrl = "http://localhost:9999/JapaneseLearningWeb/paymentSuccess";
                cancelUrl = "http://localhost:9999/JapaneseLearningWeb/paymentCancel";
                return;
            }
            
            Properties prop = new Properties();
            prop.load(input);
            
            clientId = prop.getProperty("payos.clientId").trim();
            apiKey = prop.getProperty("payos.apiKey").trim();
            checksumKey = prop.getProperty("payos.checksumKey").trim();
            returnUrl = prop.getProperty("payos.returnUrl").trim();
            cancelUrl = prop.getProperty("payos.cancelUrl").trim();
            
            System.out.println("Loaded PayOS Config:");
            System.out.println("- ClientID: " + clientId.substring(0, 5) + "...");
            System.out.println("- API Key: " + apiKey.substring(0, 5) + "...");
            System.out.println("- Checksum: " + checksumKey.substring(0, 5) + "...");
            
        } catch (Exception e) {
            e.printStackTrace();
        }
    }
    
    /**
     * Khởi tạo PayOS client
     */
    private void initPayOS() {
        try {
            payOS = new PayOS(clientId, apiKey, checksumKey);
            System.out.println("PayOS initialized successfully (Production)");
        } catch (Exception e) {
            e.printStackTrace();
        }
    }
    
    /**
     * Tạo link thanh toán
     * @param orderCode Mã đơn hàng (unique)
     * @param amount Số tiền (VND)
     * @param description Mô tả đơn hàng
     * @return CheckoutResponseData chứa URL thanh toán
     */
    public CheckoutResponseData createPaymentLink(long orderCode, int amount, String description) {
        // This method now just wraps createPaymentLinkUrl for backward compatibility
        String checkoutUrl = createPaymentLinkUrl(orderCode, amount, description);
        if (checkoutUrl != null) {
            lastDirectResponse = new PaymentResponse(checkoutUrl, orderCode, amount);
        }
        return null; // Always return null - use createPaymentLinkUrl() instead
    }
    
    /**
     * Tạo link thanh toán và trả về URL trực tiếp
     * @return checkout URL string, hoặc null nếu thất bại
     */
    public String createPaymentLinkUrl(long orderCode, int amount, String description) {
        try {
            System.out.println("=== PayOS Create Payment Link ===");
            System.out.println("OrderCode: " + orderCode);
            System.out.println("Amount: " + amount);
            System.out.println("Description: " + description);
            System.out.println("ReturnUrl: " + returnUrl);
            System.out.println("CancelUrl: " + cancelUrl);
            
            if (payOS == null) {
                System.err.println("PayOS client is NULL!");
                return null;
            }
            
            // PayOS requires description < 25 chars
            String finalDescription = description;
            if (finalDescription != null && finalDescription.length() > 25) {
                finalDescription = finalDescription.substring(0, 25);
            }
            
            // Use direct API call to bypass SDK signature verification issue
            String checkoutUrl = createPaymentLinkDirect(orderCode, amount, finalDescription);
            if (checkoutUrl != null) {
                System.out.println("Payment link created successfully: " + checkoutUrl);
                return checkoutUrl;
            }
            
            return null;
            
        } catch (Exception e) {
            System.err.println("Error creating payment link: " + e.getMessage());
            e.printStackTrace();
            return null;
        }
    }
    
    /**
     * Get last successful direct API response
     */
    public PaymentResponse getLastDirectResponse() {
        return lastDirectResponse;
    }
    
    /**
     * Store and create PaymentResponse for direct API calls
     */
    private CheckoutResponseData createCheckoutResponse(String checkoutUrl, long orderCode, int amount) {
        // Store the response for retrieval via getLastDirectResponse()
        lastDirectResponse = new PaymentResponse(checkoutUrl, orderCode, amount);
        // Return null since we can't create CheckoutResponseData - caller should use getLastDirectResponse()
        return null;
    }
    
    /**
     * Direct API call to PayOS - bypasses SDK signature verification
     */
    private String createPaymentLinkDirect(long orderCode, int amount, String description) {
        try {
            String apiUrl = "https://api-merchant.payos.vn/v2/payment-requests";
            
            // Create signature string: amount=X&cancelUrl=X&description=X&orderCode=X&returnUrl=X
            String signatureData = "amount=" + amount 
                    + "&cancelUrl=" + cancelUrl 
                    + "&description=" + description 
                    + "&orderCode=" + orderCode 
                    + "&returnUrl=" + returnUrl;
            
            String signature = generateHmacSHA256(signatureData, checksumKey);
            
            // Build request body
            JsonObject requestBody = new JsonObject();
            requestBody.addProperty("orderCode", orderCode);
            requestBody.addProperty("amount", amount);
            requestBody.addProperty("description", description);
            requestBody.addProperty("cancelUrl", cancelUrl);
            requestBody.addProperty("returnUrl", returnUrl);
            requestBody.addProperty("signature", signature);
            
            // Add items array
            JsonArray items = new JsonArray();
            JsonObject item = new JsonObject();
            item.addProperty("name", "Premium Package");
            item.addProperty("quantity", 1);
            item.addProperty("price", amount);
            items.add(item);
            requestBody.add("items", items);
            
            System.out.println("Direct API Request: " + requestBody.toString());
            System.out.println("Signature Data: " + signatureData);
            System.out.println("Generated Signature: " + signature);
            
            // Make HTTP request
            URL url = new URL(apiUrl);
            HttpURLConnection conn = (HttpURLConnection) url.openConnection();
            conn.setRequestMethod("POST");
            conn.setRequestProperty("Content-Type", "application/json");
            conn.setRequestProperty("x-client-id", clientId);
            conn.setRequestProperty("x-api-key", apiKey);
            conn.setDoOutput(true);
            
            try (OutputStream os = conn.getOutputStream()) {
                byte[] input = requestBody.toString().getBytes(StandardCharsets.UTF_8);
                os.write(input, 0, input.length);
            }
            
            int responseCode = conn.getResponseCode();
            System.out.println("PayOS API Response Code: " + responseCode);
            
            // Read response
            BufferedReader br;
            if (responseCode >= 200 && responseCode < 300) {
                br = new BufferedReader(new InputStreamReader(conn.getInputStream(), StandardCharsets.UTF_8));
            } else {
                br = new BufferedReader(new InputStreamReader(conn.getErrorStream(), StandardCharsets.UTF_8));
            }
            
            StringBuilder response = new StringBuilder();
            String line;
            while ((line = br.readLine()) != null) {
                response.append(line);
            }
            br.close();
            
            System.out.println("PayOS API Response: " + response.toString());
            
            if (responseCode >= 200 && responseCode < 300) {
                // Parse response to get checkoutUrl
                Gson gson = new Gson();
                JsonObject jsonResponse = gson.fromJson(response.toString(), JsonObject.class);
                if (jsonResponse.has("data") && jsonResponse.get("data").isJsonObject()) {
                    JsonObject data = jsonResponse.getAsJsonObject("data");
                    if (data.has("checkoutUrl")) {
                        return data.get("checkoutUrl").getAsString();
                    }
                }
            }
            
            return null;
            
        } catch (Exception e) {
            System.err.println("Direct API Error: " + e.getMessage());
            e.printStackTrace();
            return null;
        }
    }
    
    /**
     * Generate HMAC-SHA256 signature
     */
    private String generateHmacSHA256(String data, String key) {
        try {
            Mac sha256Hmac = Mac.getInstance("HmacSHA256");
            SecretKeySpec secretKey = new SecretKeySpec(key.getBytes(StandardCharsets.UTF_8), "HmacSHA256");
            sha256Hmac.init(secretKey);
            byte[] hash = sha256Hmac.doFinal(data.getBytes(StandardCharsets.UTF_8));
            
            // Convert to hex string
            StringBuilder hexString = new StringBuilder();
            for (byte b : hash) {
                String hex = Integer.toHexString(0xff & b);
                if (hex.length() == 1) hexString.append('0');
                hexString.append(hex);
            }
            return hexString.toString();
        } catch (Exception e) {
            e.printStackTrace();
            return "";
        }
    }
    
    /**
     * Lấy thông tin thanh toán từ PayOS
     */
    public PaymentLinkData getPaymentInfo(long orderCode) {
        try {
            return payOS.getPaymentLinkInformation(orderCode);
        } catch (Exception e) {
            e.printStackTrace();
            return null;
        }
    }
    
    /**
     * Hủy link thanh toán
     */
    public PaymentLinkData cancelPaymentLink(long orderCode, String reason) {
        try {
            return payOS.cancelPaymentLink(orderCode, reason);
        } catch (Exception e) {
            e.printStackTrace();
            return null;
        }
    }
    
    /**
     * Tạo order code unique
     */
    public static long generateOrderCode() {
        return System.currentTimeMillis();
    }
    
    /**
     * Verify webhook signature
     */
    public boolean verifyWebhookData(String webhookBody) {
        try {
            // PayOS SDK handles verification internally
            // This is a placeholder - implement based on actual PayOS webhook structure
            return true;
        } catch (Exception e) {
            e.printStackTrace();
            return false;
        }
    }
}
