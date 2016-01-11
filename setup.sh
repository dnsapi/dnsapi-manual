#!/usr/bin/env bash

OUT_POLICY=$(aws iam create-policy --policy-name dnsapi_lambda --policy-document file://iam_policy)

echo $OUT_POLICY
echo "----"

OUT_ROLE=$(aws iam create-role --role-name dnsapi_lambda --assume-role-policy-document file://iam_role)

echo $OUT_ROLE
echo "----"

POLICY_ARN=$(echo $OUT_POLICY | sed 's/.*Arn": "//g' | sed 's/\",.*$//g')

echo $POLICY_ARN
echo "----"

OUT_POLICY_ATTACH=$(aws iam attach-role-policy --role-name dnsapi_lambda --policy-arn "${POLICY_ARN}")

echo "----"
