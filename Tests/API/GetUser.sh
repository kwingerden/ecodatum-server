#!/bin/bash

http GET $SERVER/api/v1/protected/users/$USER_ID \
  "Authorization:Bearer $AUTH_TOKEN"