# Infrastructure (SST)

This directory contains the SST stack used to deploy the Flutter web app to AWS.

This project uses **SST v4**, so it does **not** require CDK dependencies (`aws-cdk-lib` or `constructs`).

## What it deploys

- S3 bucket for static assets
- CloudFront distribution in front of the bucket
- Optional custom domain if `WEB_DOMAIN` is provided

## Prerequisites

- AWS account
- GitHub repository configured with OIDC role ARN in `AWS_GITHUB_OIDC_ROLE_ARN` secret
- Node.js 20+
- Flutter SDK installed (required because SST runs `flutter build web --release`)

## Local deploy

```bash
cd infrastructure
pnpm install --frozen-lockfile
AWS_REGION=us-east-1 npx sst deploy --region us-east-1
```

## Remove stack

```bash
npx sst remove --region us-east-1
```
