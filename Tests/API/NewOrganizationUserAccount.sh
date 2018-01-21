#!/bin/bash

http POST $SERVER/api/v1/public/users \
  fullName="$FULL_NAME" \
  email="$EMAIL" \
  password="$PASSWORD" \
  organizationCode="$CODE"


