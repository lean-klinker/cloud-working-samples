import React, {useEffect, useState} from 'react';
import logo from './logo.svg';
import './App.css';
import {withAuthenticator} from '@aws-amplify/ui-react';
import { API } from 'aws-amplify';

function App() {
  const [state, setState] = useState({isLoading: true, result: null, error: null});
  useEffect(() => {
    API.get('footballapi', '/teams').then(result => {
      console.log(JSON.stringify(result));
    })
  }, [])
  return (
    <div className="App">
      <header className="App-header">
        <img src={logo} className="App-logo" alt="logo" />
        <p>
          Edit <code>src/App.js</code> and save to reload.
        </p>
        <a
          className="App-link"
          href="https://reactjs.org"
          target="_blank"
          rel="noopener noreferrer"
        >
          Learn React
        </a>
      </header>
    </div>
  );
}

export default withAuthenticator(App);
