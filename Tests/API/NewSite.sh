#!/bin/bash

http POST $SERVER/api/v1/protected/sites \
  "Authorization:Bearer $AUTH_TOKEN" \
  name="$NAME" \
  description="$DESCRIPTION" \
  latitude="$LATITUDE" \
  longitude="$LONGITUDE" \
  organizationId="$ORGANIZATION_ID"