# Sử dụng tomcat 10 với Java 17
FROM tomcat:10.1-jdk17

# Xóa các app mặc định của Tomcat cho sạch server
RUN rm -rf /usr/local/tomcat/webapps/*

#Copy file war từ thư mục vào Tomcat
COPY target/JapaneseLearningWeb-1.0-SNAPSHOT.war /usr/local/tomcat/webapps/ROOT.war

# Mở cổng 8080
EXPOSE 8080

# Khởi động Tomcat
CMD ["catalina.sh", "run"]