#!/usr/bin/env bash

echo "creating bucket"
OUT_S3_CREATE=$(aws s3api create-bucket --bucket dnsapi.xyz)
echo $OUT_S3_CREATE

echo "zipping script"
zip dnsapi_lambda.zip dnsapi_lambda.py

echo "uploading script"
OUT_S3_UPLOAD=$(aws s3api put-object --key "dnsapi_lambda.zip" --bucket dnsapi.xyz --body dnsapi_lambda.zip)
echo $OUT_S3_UPLOAD

echo "creating policy"
OUT_POLICY=$(aws iam create-policy --policy-name dnsapi_lambda --policy-document file://iam_policy)
echo $OUT_POLICY

echo "creating role"
OUT_ROLE=$(aws iam create-role --role-name dnsapi_lambda --assume-role-policy-document file://iam_role)
echo $OUT_ROLE

echo "parsing policy arn"
POLICY_ARN=$(echo $OUT_POLICY | sed 's/.*Arn": "//g' | sed 's/\",.*$//g')
echo $POLICY_ARN

echo "attaching policy to role"
OUT_POLICY_ATTACH=$(aws iam attach-role-policy --role-name dnsapi_lambda --policy-arn "${POLICY_ARN}")
echo $OUT_POLICY_ATTACH

echo "deleting lambda function"
OUT_LAMBDA_DELETE=$(aws lambda delete-function --function-name dnsapi_lambda)
echo $OUT_LAMBDA_DELETE

echo "creating lambda function"
OUT_LAMBDA_CREATE=$(aws lambda create-function --function-name dnsapi_lambda --role arn:aws:iam::669895679474:role/dnsapi_lambda --runtime python2.7 --handler dnsapi_lambda.lambda_handler --code '{"S3Bucket": "dnsapi.xyz","S3Key":"dnsapi_lambda.zip"}' )
echo $OUT_LAMBDA_CREATE

exit

echo "creating api"
OUT_API_CREATE=$(aws apigateway create-rest-api --name dnsapi)
echo $OUT_API_CREATE

echo "parsing api id"
API_ID=$(echo ${OUT_API_CREATE} | sed 's/.*id": "//g' | sed 's/".*$//g')
echo $API_ID

echo "parsing resource id"
RESOURCE_ID=$(aws apigateway get-resources \
  --rest-api-id "${API_ID}" \
  --output text \
  --query 'items[?path==`'/'`].[id]')
echo $RESOURCE_ID

echo "creating api method"
OUT_API_METHOD=$(aws apigateway put-method --rest-api-id ${API_ID} --http-method GET --resource-id ${RESOURCE_ID} --authorization-type none --no-api-key-required)
echo $OUT_API_METHOD

#TODO: broken
#echo "creating api method integration"
#OUT_API_METHOD_INT=$(aws apigateway put-integration --type LAMBDA --rest-api-id ${API_ID} --resource-id ${RESOURCE_ID} --http-method GET)
#echo $OUT_API_METHOD_INT


