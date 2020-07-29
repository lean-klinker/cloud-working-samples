import React from "react";
import {Switch, Route, Redirect} from "react-router-dom";
import ProtectedRoute from "../authentication/components/ProtectedRoute";
import PrivateContent from "./private-content/PrivateContent";
import Home from "./home/Home";
import AuthCallback from "../authentication/components/AuthCallback";

export default function Routes() {
    return (
        <Switch>
            <Route path={'/home'} component={Home} />
            <ProtectedRoute path={'/private'} component={PrivateContent} />
            <Route path={'/.auth/callback'} component={AuthCallback} />
            <Redirect to={'/home'} from={'**'} />
        </Switch>
    )
}