import React from 'react';
import ReactDOM from 'react-dom';
import './index.css';
import App from './app/App';
import * as serviceWorker from './serviceWorker';

async function main() {
    const response = await fetch('settings.json');
    const settings = await response.json();

    ReactDOM.render(
        <React.StrictMode>
            <App settings={settings}/>
        </React.StrictMode>,
        document.getElementById('root')
    );
}
main()
    .catch(err => console.error(err));
serviceWorker.unregister();
