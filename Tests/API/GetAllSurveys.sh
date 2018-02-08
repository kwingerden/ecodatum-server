#!/bin/bash

http GET $SERVER/api/v1/protected/surveys \
  "Authorization:Bearer $AUTH_TOKEN"