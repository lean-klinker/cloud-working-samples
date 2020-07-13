import React from "react";
import {AuthConsumer} from "../providers/AuthProvider";
import {Route} from "react-router-dom";

export default function ProtectedRoute({component, ...rest}) {
    const renderHandler = Component => props => {
        return (
            <AuthConsumer>
                {
                    ({isAuthenticated, signinRedirect}) => {
                        const authenticated = isAuthenticated();
                        if (!!Component && authenticated) {
                            return <Component {...props} />
                        } else {
                            signinRedirect();
                            return <span>loading...</span>
                        }
                    }
                }
            </AuthConsumer>
        )
    }
    return <Route {...rest} render={renderHandler(component)} />
}