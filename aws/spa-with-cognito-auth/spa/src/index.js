import React from 'react';
import ReactDOM from 'react-dom';
import './index.css';
import App from './app/App';
import * as serviceWorker from './serviceWorker';
import {loadSettings} from "./authentication/services/settings-service";
import {AuthService} from "./authentication/services/auth-service";

async function main() {
    const settings = await loadSettings();
    const authService = AuthService.createFromSettings(settings);
    ReactDOM.render(
        <React.StrictMode>
            <App settings={settings} authService={authService}/>
        </React.StrictMode>,
        document.getElementById('root')
    );
}
main()
    .catch(err => console.error(err));
serviceWorker.unregister();
