#!/bin/bash

# Validate input parameters
if [ "$#" -ne 3 ]; then
    echo "Usage: $0 <ecr_repo> <image_tag> <region>"
    exit 1
fi

ECR_REPO=$1
IMAGE_TAG=$2
REGION=$3
SCAN_STATUS=1

# Wait for the scan to complete
until [ "$SCAN_STATUS" -eq "0" ]; do
    echo "Waiting for scan to complete..."
    aws ecr wait image-scan-complete --region "$REGION" --repository-name "$ECR_REPO" --image-id imageTag="$IMAGE_TAG"
    SCAN_STATUS=$?
    sleep 5
done

# Get the scan findings
SCAN_FINDINGS=$(aws ecr describe-image-scan-findings --region "$REGION" --repository-name "$ECR_REPO" --image-id imageTag="$IMAGE_TAG")
CRITICAL=$(echo "$SCAN_FINDINGS" | jq '.imageScanFindings.findingSeverityCounts.CRITICAL')
HIGH=$(echo "$SCAN_FINDINGS" | jq '.imageScanFindings.findingSeverityCounts.HIGH')

# Check for vulnerabilities
if { [ "$CRITICAL" != "null" ] || [ "$HIGH" != "null" ]; } && [ "$HIGH" -gt "90" ]; then
    echo "Docker image contains vulnerabilities"
    exit 1
fi

echo "INFO: No Vulnerabilities found"


