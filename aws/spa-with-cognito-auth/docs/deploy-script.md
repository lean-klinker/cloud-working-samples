# What does the script do?

1. Create an S3 bucket to store terraform state.
    1. Read more about terraform here: [Infrastructure Docs](infrastructure.md)
1. Builds the single page application
    1. Read more about the React app here: [React App](react-app.md)
1. Creates infrastructure using terraform command line
    1. Read more about terraform cli here: [Terraform CLI](https://www.terraform.io/docs/commands/index.html)
1. Invalidates CloudFront cache
    1. Read more about CloudFront here: [CloudFront](https://aws.amazon.com/cloudfront/)
    1. Specific files must be invalidated after deployment to ensure
    the latest versions of files are served to visitors.
1. Conditionally: Teardown all of the infrastructure created by terraform.