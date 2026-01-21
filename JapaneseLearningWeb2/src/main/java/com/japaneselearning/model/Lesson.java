package com.japaneselearning.model;

import java.sql.Timestamp;

public class Lesson {

    private int lessonId;
    private String name;
    private String level;
    private String description;
    private String contentPath;
    private Timestamp createdAt;

    public Lesson() {
    }

    public Lesson(int lessonId, String name, String level,
                  String description, String contentPath,
                  Timestamp createdAt) {
        this.lessonId = lessonId;
        this.name = name;
        this.level = level;
        this.description = description;
        this.contentPath = contentPath;
        this.createdAt = createdAt;
    }

    public int getLessonId() {
        return lessonId;
    }

    public void setLessonId(int lessonId) {
        this.lessonId = lessonId;
    }

    public String getName() {
        return name;
    }

    public void setName(String name) {
        this.name = name;
    }

    public String getLevel() {
        return level;
    }

    public void setLevel(String level) {
        this.level = level;
    }

    public String getDescription() {
        return description;
    }

    public void setDescription(String description) {
        this.description = description;
    }

    public String getContentPath() {
        return contentPath;
    }

    public void setContentPath(String contentPath) {
        this.contentPath = contentPath;
    }

    public Timestamp getCreatedAt() {
        return createdAt;
    }

    public void setCreatedAt(Timestamp createdAt) {
        this.createdAt = createdAt;
    }
}
