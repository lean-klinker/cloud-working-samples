# What does the React App do?

This application provides a minimal set of libraries and setup for showing protected and public content.

## How are users authenticated?

This application uses [OpenID Connect](https://openid.net/connect/) to authenticate users. It does this through
AWS [Cognito](https://aws.amazon.com/cognito/). 

Users are able to sign-up using an email address. Users must verify their email address before they are allowed to sign
in to the application. 

Users will be prompted to login when they visit the protected section of the site. However, they are allowed to view the 
public content while not logged in.

## How does this work?

This application uses a library called `oidc-client` for most of the heavy lifting. `oidc-client` knows how to handle
the interactions with any [OpenID Connect](https://openid.net/connect/) provider. We need to tell the `oidc-client` to 
use [Cognito](https://aws.amazon.com/cognito/). This is being done using a `settings.json` that is uploaded to s3 when
the application deploys.

The interactions with `oidc-client` can be found in the [auth-service.js](../spa/src/authentication/services/auth-service.js).

The `settings.json` file is loaded in [AuthProvider](../spa/src/authentication/providers/AuthProvider.js).

### Why use `settings.json`?

This allows for the infrastructure to be generated and for the application to consume the newly created infrastructure.

This also allows for the application to be built once and deployed anywhere. This aligns with the ideals outlined in
[12 factor apps](https://12factor.net/). Instead of building the frontend for each environment specifically we can build
the front-end once and provide configuration information for each environment.

#### How is `settings.json` created?

You can find the general template in [settings.json](../infrastructure/templates/spa/settings.json). 

When terraform executes it replaces the `${variable name}` with values specified in 
[s3.tf](../infrastructure/common/s3.tf). This allows the frontend's configuration to change per
environment without a rebuild.