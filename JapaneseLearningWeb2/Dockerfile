# ===== BƯỚC 1: Build WAR từ source =====
FROM maven:3.9-eclipse-temurin-17 AS build

WORKDIR /app

# Copy pom.xml trước để tận dụng Docker cache cho dependencies
COPY pom.xml .
RUN mvn dependency:go-offline -B

# Copy source code và build
COPY src ./src
RUN mvn clean package -DskipTests -B

# ===== BƯỚC 2: Deploy lên Tomcat =====
FROM tomcat:10.1-jdk17

# Xóa các app mặc định của Tomcat cho sạch server
RUN rm -rf /usr/local/tomcat/webapps/*

# Copy file WAR đã build từ bước 1 vào Tomcat
COPY --from=build /app/target/JapaneseLearningWeb-1.0-SNAPSHOT.war /usr/local/tomcat/webapps/ROOT.war

# Mở cổng 8080
EXPOSE 8080

# Khởi động Tomcat
CMD ["catalina.sh", "run"]