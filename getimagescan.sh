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

# Check if image scan exists before waiting
IMAGE_SCAN_STATUS=$(aws ecr describe-image-scan-findings --region "$REGION" --repository-name "$ECR_REPO" --image-id imageTag="$IMAGE_TAG" 2>/dev/null)

if [ -z "$IMAGE_SCAN_STATUS" ]; then
    echo "No image scan found. Triggering the scan..."
    aws ecr start-image-scan --repository-name "$ECR_REPO" --image-id imageTag="$IMAGE_TAG" --region "$REGION"
fi

# Timeout after 10 minutes if scan is still not complete
TIMEOUT=600  # 10 minutes timeout
ELAPSED_TIME=0
until [ "$SCAN_STATUS" -eq "0" ] || [ "$ELAPSED_TIME" -ge "$TIMEOUT" ]; do
    echo "Waiting for scan to complete..."
    aws ecr wait image-scan-complete --region "$REGION" --repository-name "$ECR_REPO" --image-id imageTag="$IMAGE_TAG"
    SCAN_STATUS=$?
    sleep 5
    ELAPSED_TIME=$((ELAPSED_TIME + 5))
done

if [ "$ELAPSED_TIME" -ge "$TIMEOUT" ]; then
    echo "Timeout reached while waiting for scan completion."
    exit 1
fi

# Get the scan findings
SCAN_FINDINGS=$(aws ecr describe-image-scan-findings --region "$REGION" --repository-name "$ECR_REPO" --image-id imageTag="$IMAGE_TAG")

# Parse critical and high severity findings
CRITICAL=$(echo "$SCAN_FINDINGS" | jq -r '.imageScanFindings.findingSeverityCounts.CRITICAL // 0')
HIGH=$(echo "$SCAN_FINDINGS" | jq -r '.imageScanFindings.findingSeverityCounts.HIGH // 0')

# Check for vulnerabilities
if [ "$HIGH" -gt "20" ] || [ "$CRITICAL" -gt "0" ]; then
    echo "Docker image contains vulnerabilities"
    exit 1
fi

echo "INFO: No vulnerabilities found"
