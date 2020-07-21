# What does the lambda do?

This lambda application setups an api that returns some text and the current user.

## How is the lambda secured?

This lambda application has no knowledge of its security settings. This express application
is secured using an api gateway with a Cognito Authorizer.

Before a request reaches the lambda application the user must provide a valid JWT token in the
`Authorization` header of the request.
