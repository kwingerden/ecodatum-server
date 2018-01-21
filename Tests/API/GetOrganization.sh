#!/bin/bash

http GET $SERVER/api/v1/protected/organizations/$ID \
  "Authorization:Bearer $AUTH_TOKEN"