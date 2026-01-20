package model;

public class Vocabulary {
    private int vocabId;
    private int lessonId;
    private String word;
    private String meaning;
    private String imageUrl;

    public Vocabulary() {
    }

    public Vocabulary(int vocabId, int lessonId, String word, String meaning, String imageUrl) {
        this.vocabId = vocabId;
        this.lessonId = lessonId;
        this.word = word;
        this.meaning = meaning;
        this.imageUrl = imageUrl;
    }

    public int getVocabId() {
        return vocabId;
    }

    public void setVocabId(int vocabId) {
        this.vocabId = vocabId;
    }

    public int getLessonId() {
        return lessonId;
    }

    public void setLessonId(int lessonId) {
        this.lessonId = lessonId;
    }

    public String getWord() {
        return word;
    }

    public void setWord(String word) {
        this.word = word;
    }

    public String getMeaning() {
        return meaning;
    }

    public void setMeaning(String meaning) {
        this.meaning = meaning;
    }

    public String getImageUrl() {
        return imageUrl;
    }

    public void setImageUrl(String imageUrl) {
        this.imageUrl = imageUrl;
    }
}
