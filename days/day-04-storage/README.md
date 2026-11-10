# Day 4 — Inspect S3 storage

**Objective:** Understand S3 object storage and verify private bucket access, encryption and public-access controls.

**Where to run:** Mac/Linux or CloudShell, from repository root. **File:** [`run-chapter.sh`](run-chapter.sh) (read-only; requires an existing bucket).

1. Choose a bucket **you own**, in the correct Region, and set:
   ```bash
   export AWS_REGION=eu-west-2
   export BUCKET_NAME=REPLACE_WITH_YOUR_BUCKET_NAME
   aws sts get-caller-identity
   ```
2. If your book exercise calls for a new bucket, create it deliberately using AWS Console or the following **billable** example (names are globally unique and must be replaced):
   ```bash
   aws s3api create-bucket --bucket "$BUCKET_NAME" --region "$AWS_REGION" --create-bucket-configuration LocationConstraint="$AWS_REGION"
   aws s3api put-public-access-block --bucket "$BUCKET_NAME" --public-access-block-configuration BlockPublicAcls=true,IgnorePublicAcls=true,BlockPublicPolicy=true,RestrictPublicBuckets=true
   aws s3api put-bucket-encryption --bucket "$BUCKET_NAME" --server-side-encryption-configuration '{"Rules":[{"ApplyServerSideEncryptionByDefault":{"SSEAlgorithm":"AES256"}}]}'
   ```
   Explicit `LocationConstraint` syntax here targets `eu-west-2`; special cases such as `us-east-1` use different creation syntax.
3. Read-only verification:
   ```bash
   bash days/day-04-storage/run-chapter.sh
   aws s3 ls "s3://$BUCKET_NAME/"
   ```
4. **Verify:** `head-bucket` succeeds, public-access-block settings are active and server-side encryption is configured. `AccessDenied` may reflect IAM rather than nonexistence.

**Cleanup:** If this is a dedicated disposable lab bucket, review its contents, versions and delete markers; use `aws s3 rb "s3://$BUCKET_NAME" --force` only for an **unversioned** disposable bucket after confirmation. Versioned buckets require additional removal of versions/delete markers, and Object Lock/MFA Delete can block deletion. Do not delete any bucket that has unrelated data. See [cleanup](../../docs/cleanup.md). Next: [Day 5](../day-05-vpc/README.md).
