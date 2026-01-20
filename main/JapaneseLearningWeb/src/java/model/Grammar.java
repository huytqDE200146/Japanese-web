package model;

public class Grammar {
    private int grammarId;
    private int lessonId;
    private String content;

    public Grammar() {
    }

    public Grammar(int grammarId, int lessonId, String content) {
        this.grammarId = grammarId;
        this.lessonId = lessonId;
        this.content = content;
    }

    public int getGrammarId() {
        return grammarId;
    }

    public void setGrammarId(int grammarId) {
        this.grammarId = grammarId;
    }

    public int getLessonId() {
        return lessonId;
    }

    public void setLessonId(int lessonId) {
        this.lessonId = lessonId;
    }

    public String getContent() {
        return content;
    }

    public void setContent(String content) {
        this.content = content;
    }
}
