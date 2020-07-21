# `amplify init`

**BEWARE** Running amplify init will create cloud resources

## AWS Resources Created

### IAM Roles

Amplify will create the following IAM Roles:

- `amplify-{project name}-{environment name}-{random number}-authRole`
- `amplify-{project name}-{environment name}-{random number}-unauthRole` 

### S3 Bucket

Amplify will create the following S3 Bucket:

- `amplify-{project name}-{environment name}-{random number}-deployment`

### CloudFormation Template

Amplify will deploy the above using a cloud formation template.