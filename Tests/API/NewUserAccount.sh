#!/bin/bash

http POST $SERVER/api/v1/protected/users \
  "Authorization:Bearer $AUTH_TOKEN" \
  fullName="$FULL_NAME" \
  email="$EMAIL" \
  password="$PASSWORD"


