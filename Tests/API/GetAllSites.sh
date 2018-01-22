#!/bin/bash

http GET $SERVER/api/v1/protected/sites \
  "Authorization:Bearer $AUTH_TOKEN"