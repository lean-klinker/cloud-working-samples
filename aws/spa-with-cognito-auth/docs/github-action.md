# What does the GitHub Action do?

This action runs through a fairly common set of steps for a CI/CD pipeline.
1. Clone Repository
1. Setup required tools
    1. In our case: Node, Yarn, and Terraform
1. Run Tests
1. Deploy to environment

## How do I know which environment to deploy?

This can be done in many ways. Some options include:

- Branch name
    - Example: 
        - branch `master` deploys to environment `pilot`
        - branch `staging` deploys to environment `staging` 
        - branch `prod` deploys to environment `prod`
- Continuous Deployment
    - All changes go directly to `prod`
        - This generally requires adding post deployment tests to your pipeline to ensure each deployment
        works before proceeding to deploying to the next environment.

## Secrets

**DO NOT PUT AWS CREDENTIALS IN THE WORKFLOW FILE**

This rule goes for any CI system you would choose. Keep secrets such as access keys, tokens, passwords, etc out of 
clear text. Favor using environment variables that the CI system can provide when the build runs.

To manage GitHub secrets see here: [GitHub Secrets](https://docs.github.com/en/actions/configuring-and-managing-workflows/creating-and-storing-encrypted-secrets)

## Why does each step point to a script?

The approach of putting what each step does into a separate script means that the workflow file is only responsible
for the order the of execution not what each thing means.

Using scripts in this way allows for easier editing and keeps the workflow file small and simpler to understand.