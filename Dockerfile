# Alpine Linux with OpenJDK JRE
FROM openjdk:8-jre-alpine
RUN apk --no-cache add curl
EXPOSE 9090
# copy jar into image
COPY target/spring-petclinic-*.jar /var/tmp/spring-petclinic.jar
# run application with this command line 
ENTRYPOINT ["java","-jar","/var/tmp/spring-petclinic.jar","--server.port=9090"]