#!/bin/bash

http POST $SERVER/api/v1/protected/measurements \
  "Authorization:Bearer $AUTH_TOKEN" \
  surveyId="$SURVEY_ID" \
  abioticFactorId="$ABIOTIC_FACTOR_ID" \
  measurementUnitId="$MEASUREMENT_UNIT_ID" \
  value="$VALUE"