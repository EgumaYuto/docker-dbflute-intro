FROM openjdk:8

WORKDIR /build

COPY dbflute-intro.jar /build
COPY mydbflute /build/mydbflute

EXPOSE 8926
CMD ["java", "-jar", "-Dintro.host=0.0.0.0", "dbflute-intro.jar"]
