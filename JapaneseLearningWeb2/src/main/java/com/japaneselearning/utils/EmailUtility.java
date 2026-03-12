package com.japaneselearning.utils;

import okhttp3.*;
import com.google.gson.Gson;
import com.google.gson.JsonArray;
import com.google.gson.JsonObject;
import jakarta.mail.MessagingException;
import java.io.IOException;

public class EmailUtility {

    // Brevo API configuration
    private static final String BREVO_API_URL = "https://api.brevo.com/v3/smtp/email";
    private static final String API_KEY = getApiKey();
    private static final String SENDER_EMAIL = "de190574lenhaphuong@gmail.com";
    private static final String SENDER_NAME = "Japanese Learning Support";

    private static String getApiKey() {
        String envKey = System.getenv("BREVO_API_KEY");
        if (envKey != null && !envKey.isEmpty()) {
            System.out.println("[EmailUtility] Using BREVO_API_KEY from environment variable");
            return envKey;
        }
        System.out.println("[EmailUtility] WARNING: BREVO_API_KEY env var not set, using fallback hardcoded key");
        return "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";
    }

    public static void sendEmail(String toAddress, String subject, String messageContent) throws MessagingException {
        OkHttpClient client = new OkHttpClient();
        Gson gson = new Gson();

        // Build the JSON payload for Brevo API
        JsonObject jsonPayload = new JsonObject();

        // 1. Sender
        JsonObject sender = new JsonObject();
        sender.addProperty("name", SENDER_NAME);
        sender.addProperty("email", SENDER_EMAIL);
        jsonPayload.add("sender", sender);

        // 2. To (Recipients array)
        JsonArray toArray = new JsonArray();
        JsonObject recipient = new JsonObject();
        recipient.addProperty("email", toAddress);
        toArray.add(recipient);
        jsonPayload.add("to", toArray);

        // 3. Subject and Content
        jsonPayload.addProperty("subject", subject);
        jsonPayload.addProperty("htmlContent", messageContent);

        // Convert JsonObject to String
        String jsonString = gson.toJson(jsonPayload);

        // Create RequestBody
        MediaType JSON = MediaType.get("application/json; charset=utf-8");
        RequestBody body = RequestBody.create(jsonString, JSON);

        // Build HTTP Request
        Request request = new Request.Builder()
                .url(BREVO_API_URL)
                .addHeader("accept", "application/json")
                .addHeader("api-key", API_KEY)
                .addHeader("content-type", "application/json")
                .post(body)
                .build();

        // Execute Request
        try (Response response = client.newCall(request).execute()) {
            if (!response.isSuccessful()) {
                String errorBody = response.body() != null ? response.body().string() : "No response body";
                throw new MessagingException("Failed to send email via Brevo API: HTTP " + response.code() + " - " + errorBody);
            }
        } catch (IOException e) {
            throw new MessagingException("Network error occurred while connecting to Brevo API", e);
        }
    }
}
