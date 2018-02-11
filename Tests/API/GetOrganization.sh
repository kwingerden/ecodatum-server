#!/bin/bash

http GET $SERVER/api/v1/protected/organizations/$ORGANIZATION_ID \
  "Authorization:Bearer $AUTH_TOKEN"