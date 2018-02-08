#!/bin/bash

http POST $SERVER/api/v1/protected/surveys \
  "Authorization:Bearer $AUTH_TOKEN" \
  siteId="$SITE_ID"