import React from 'react';
import {BrowserRouter} from "react-router-dom";

import './App.css';
import Routes from "./Routes";
import {AuthProvider} from "../authentication/providers/AuthProvider";
import Navbar from "./navbar/Navbar";

export default function App({settings}) {
    return (
        <AuthProvider settings={settings}>
            <BrowserRouter>
                <div className={'application'}>
                    <header className={'header'}>
                        <Navbar />
                    </header>
                    <main className={'main'}>
                        <Routes/>
                    </main>
                </div>
            </BrowserRouter>
        </AuthProvider>
    );
}