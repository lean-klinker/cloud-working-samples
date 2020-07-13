import React, {createContext, useState, useEffect, useContext} from "react";
import {AuthService} from "../services/auth-service";

const AuthContext = createContext();

export function useProvideAuth() {
    const [settings, setSettings] = useState(null);
    useEffect(() => {
        async function loadSettings() {
            const response = await fetch('/settings.json');
            const settings = await response.json();
            setSettings(settings);
        }

        loadSettings();
    }, []);

    if (settings) {
        return new AuthService(settings);
    } else {
        return {
            signinRedirect: () => Promise.resolve(),
            signinRedirectCallback: () => Promise.resolve(),
            getUser: () => null,
            isAuthenticated: () => false
        };
    }
}

export function AuthProvider({children}) {
    const auth = useProvideAuth();
    return (
        <AuthContext.Provider value={auth}>
            {children}
        </AuthContext.Provider>
    )
}

export const useAuthService = () => {
    return useContext(AuthContext);
}