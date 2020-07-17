import React, {createContext, useContext} from "react";

const AuthContext = createContext();

export function useAuthService() {
    const context = useContext(AuthContext);
    if (context === undefined) {
        throw new Error(`${useAuthService.name} must be used inside AuthProvider`)
    }

    return context;
}

export function AuthProvider({authService, children}) {
    return (
        <AuthContext.Provider value={authService}>
            {children}
        </AuthContext.Provider>
    )
}