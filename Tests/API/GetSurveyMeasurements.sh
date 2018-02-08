#!/bin/bash

http GET $SERVER/api/v1/protected/surveys/$SURVEY_ID/measurements \
  "Authorization:Bearer $AUTH_TOKEN"