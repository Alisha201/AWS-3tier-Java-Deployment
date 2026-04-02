#!/bin/bash

# 1. Define the variables
export DB_ENDPOINT="java-app-db.cbawocwsggda.us-west-2.rds.amazonaws.com"
export DB_NAME="petclinic"
export DB_USER="admin"
export DB_PASS="****123"

# 2. Navigate to the app directory 
cd /home/abu_alisha/ || cd /home/ubuntu/

# 3. Start the jar file
nohup java -jar spring-petclinic-3.1.0-SNAPSHOT.jar \
  --spring.datasource.url=jdbc:mysql://${DB_ENDPOINT}:3306/${DB_NAME} \
  --spring.datasource.username=${DB_USER} \
  --spring.datasource.password=${DB_PASS} > app.log 2>&1 &





