package model;

public class Lesson {
    private int lessonId;
    private String title;
    private String lessonType;
    private String description;

    public Lesson() {
    }

    public Lesson(int lessonId, String title, String lessonType, String description) {
        this.lessonId = lessonId;
        this.title = title;
        this.lessonType = lessonType;
        this.description = description;
    }

    public int getLessonId() {
        return lessonId;
    }

    public void setLessonId(int lessonId) {
        this.lessonId = lessonId;
    }

    public String getTitle() {
        return title;
    }

    public void setTitle(String title) {
        this.title = title;
    }

    public String getLessonType() {
        return lessonType;
    }

    public void setLessonType(String lessonType) {
        this.lessonType = lessonType;
    }

    public String getDescription() {
        return description;
    }

    public void setDescription(String description) {
        this.description = description;
    }
}
