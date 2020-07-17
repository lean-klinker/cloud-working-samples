import React from 'react';
import {BrowserRouter} from "react-router-dom";

import './App.css';
import Routes from "./Routes";
import {AuthProvider} from "../authentication/providers/AuthProvider";
import Navbar from "./navbar/Navbar";
import {SettingsProvider} from "../authentication/providers/SettingsProvider";

export default function App({settings, authService}) {
    return (
        <SettingsProvider settings={settings}>
            <AuthProvider authService={authService}>
                <BrowserRouter>
                    <div className={'application'}>
                        <header className={'header'}>
                            <Navbar/>
                        </header>
                        <main className={'main'}>
                            <Routes/>
                        </main>
                    </div>
                </BrowserRouter>
            </AuthProvider>
        </SettingsProvider>
    );
}