#!/bin/bash

http POST $SERVER/api/v1/public/users?code=$ORGANIZATION_CODE= name="$NAME" email="$EMAIL" password="$PASSWORD"