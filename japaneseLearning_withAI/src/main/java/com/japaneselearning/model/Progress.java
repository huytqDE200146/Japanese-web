package com.japaneselearning.model;

import java.time.LocalDate;

public class Progress {

    private int userId;
    private int streak;
    private int longestStreak;
    private int totalLessons;
    private int totalQuizzes;
    private LocalDate lastStudyDate;

    // Constructor rỗng
    public Progress() {
    }

    // Constructor đầy đủ
    public Progress(int userId, int streak, int longestStreak, int totalLessons, int totalQuizzes, LocalDate lastStudyDate) {
        this.userId = userId;
        this.streak = streak;
        this.longestStreak = longestStreak;
        this.totalLessons = totalLessons;
        this.totalQuizzes = totalQuizzes;
        this.lastStudyDate = lastStudyDate;
    }

    // Getter & Setter
    public int getUserId() {
        return userId;
    }

    public void setUserId(int userId) {
        this.userId = userId;
    }

    public int getStreak() {
        return streak;
    }

    public void setStreak(int streak) {
        this.streak = streak;
    }
    
    public int getLongestStreak() {
        return longestStreak;
    }

    public void setLongestStreak(int longestStreak) {
        this.longestStreak = longestStreak;
    }

    public int getTotalLessons() {
        return totalLessons;
    }

    public void setTotalLessons(int totalLessons) {
        this.totalLessons = totalLessons;
    }

    public int getTotalQuizzes() {
        return totalQuizzes;
    }

    public void setTotalQuizzes(int totalQuizzes) {
        this.totalQuizzes = totalQuizzes;
    }

    public LocalDate getLastStudyDate() {
        return lastStudyDate;
    }

    public void setLastStudyDate(LocalDate lastStudyDate) {
        this.lastStudyDate = lastStudyDate;
    }
}