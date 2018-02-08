#!/bin/bash

http GET $SERVER/api/v1/protected/measurements/$MEASUREMENT_ID \
  "Authorization:Bearer $AUTH_TOKEN"