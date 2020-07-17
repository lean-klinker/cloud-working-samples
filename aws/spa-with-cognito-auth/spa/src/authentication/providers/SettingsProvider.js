import React, {createContext, useContext} from "react";

const SettingsContext = createContext();

export function useSettings() {
    const context = useContext(SettingsContext);
    if (context === undefined) {
        throw new Error(`${useSettings.name} must be used inside SettingsProvider`)
    }

    return context;
}

export function SettingsProvider({settings, children}) {
    return (
        <SettingsContext.Provider value={settings}>
            {children}
        </SettingsContext.Provider>
    )
}