#!/bin/bash

http GET $SERVER/api/v1/protected/surveys/$SURVEY_ID \
  "Authorization:Bearer $AUTH_TOKEN"