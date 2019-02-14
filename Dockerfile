FROM openjdk:8

WORKDIR /app

COPY dbflute-intro.jar /app

EXPOSE 8926
CMD ["java", "-jar", "-Dintro.host=0.0.0.0", "dbflute-intro.jar"]
