import React, {createContext, useState} from "react";
import {AuthService} from "../services/auth-service";

const AuthContext = createContext({
    signinRedirect: () => Promise.resolve(),
    signinRedirectCallback: () => Promise.resolve(),
    getUser: () => null,
    isAuthenticated: () => false
});

export const AuthConsumer = AuthContext.Consumer;

export function AuthProvider({children, settings}) {
    const [authService] = useState(new AuthService(settings));
    return (
        <AuthContext.Provider value={authService}>
            {children}
        </AuthContext.Provider>
    )
}