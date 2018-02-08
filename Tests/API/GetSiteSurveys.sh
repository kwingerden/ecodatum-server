#!/bin/bash

http GET $SERVER/api/v1/protected/sites/$SITE_ID/surveys \
  "Authorization:Bearer $AUTH_TOKEN"