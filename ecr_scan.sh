#!/bin/bash

# Input validation
if [ "$#" -ne 3 ]; then
    echo "Usage: $0 <ecr_repo> <image_tag> <region>"
    exit 1
fi

ECR_REPO=$1
IMAGE_TAG=$2
REGION=$3
SCAN_STATUS=1
RETRY_COUNT=0
MAX_RETRIES=10
RETRY_INTERVAL=5  # Retry interval in seconds

# Function to log messages with timestamps
log_message() {
    echo "$(date '+%Y-%m-%d %H:%M:%S') - $1"
}

# Wait for the image scan to complete
until [ "$SCAN_STATUS" -eq "0" ] || [ "$RETRY_COUNT" -ge "$MAX_RETRIES" ]; do
    log_message "Waiting for ECR scan to complete (Attempt $((RETRY_COUNT+1)) of $MAX_RETRIES)..."
    aws ecr wait image-scan-complete --region "$REGION" --repository-name "$ECR_REPO" --image-id imageTag="$IMAGE_TAG"
    SCAN_STATUS=$?
    if [ "$SCAN_STATUS" -ne "0" ]; then
        log_message "Image scan not complete. Status: $SCAN_STATUS"
    fi
    sleep $RETRY_INTERVAL
    ((RETRY_COUNT++))
done

if [ "$RETRY_COUNT" -ge "$MAX_RETRIES" ]; then
    log_message "ERROR: Image scan did not complete within the expected time."
    exit 1
fi

# Get the scan findings and parse results
SCAN_FINDINGS=$(aws ecr describe-image-scan-findings --region "$REGION" --repository-name "$ECR_REPO" --image-id imageTag="$IMAGE_TAG")
CRITICAL=$(echo "$SCAN_FINDINGS" | jq '.imageScanFindings.findingSeverityCounts.CRITICAL')
HIGH=$(echo "$SCAN_FINDINGS" | jq '.imageScanFindings.findingSeverityCounts.HIGH')

# Assess vulnerabilities
if [ "$CRITICAL" != "null" ] && [ "$CRITICAL" -gt "0" ]; then
    log_message "CRITICAL vulnerabilities found. Exiting."
    exit 1
elif [ "$HIGH" != "null" ] && [ "$HIGH" -gt "15" ]; then
    log_message "HIGH vulnerabilities exceed threshold. Exiting."
    exit 2
else
    log_message "INFO: No major vulnerabilities found."
fi
