# Getting Started

This sample demonstrates setting up a react [AWS Amplify](https://docs.amplify.aws/) application. 
To get amplify setup you can follow this [tutorial](https://docs.amplify.aws/start/q/integration/react)

**NOTE:** You will need to have admin access to AWS Console and NodeJS installed.

## What does Amplify do?

Amplify has many commands that can be helpful. It is important to know what 
amplify does and when it does it.

### Commands

- [init](./docs/amplify-init.md)
    - Initializes amplify application
- [add api](./docs/amplify-add-api.md)
    - Adds an api to your application
    
## Packages Used

- `aws-amplify` main library for amplify
    - **NOTE:** Installing this package will update the `.gitignore`
    and generate a `aws-exports.js` file
- `@aws-amplify/ui-react`