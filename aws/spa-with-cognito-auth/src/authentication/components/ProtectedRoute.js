import React from "react";
import {useAuthService} from "../providers/AuthProvider";
import {Route} from "react-router-dom";

export default function ProtectedRoute({component, ...rest}) {
    const authService = useAuthService();
    const renderHandler = Component => props => {
        if (!!Component && authService.isAuthenticated()) {
            return <Component {...props} />
        } else {
            authService.signinRedirect();
            return <span>loading...</span>
        }
    }
    return <Route {...rest} render={renderHandler(component)} />
}