import {useEffect, useState} from "react";
import {useSettings} from "../../authentication/providers/SettingsProvider";
import {useAuthService} from "../../authentication/providers/AuthProvider";

function getFullUrl(baseUrl, path) {
    return `${baseUrl}${path}`;
}

function createLoadingState() {
    return { isLoading: true, result: null, error: null };
}

function createErrorState(error) {
    return { isLoading: false, result: null, error };
}

function createResultState(result) {
    return { isLoading: false, result, error: null };
}

function createUnauthorizedState() {
    return {isLoading: false, error: 'You must be logged in.', result: null};
}

async function executeFetch({url, authService}) {
    if (!authService.isAuthenticated()) {
        return createUnauthorizedState();
    }

    const accessToken = await authService.getAccessToken();
    const headers = { Authorization: `Bearer ${accessToken}` }
    const response = await fetch(url, { headers });
    if (response.ok){
        return createResultState(await response.json());
    }


    return createErrorState(response.error());
}

export function useFetchGet(url) {
    const [state, setState] = useState(createLoadingState());

    const {api_url} = useSettings();
    const authService = useAuthService();

    useEffect(() => {
        executeFetch({url: getFullUrl(api_url, url), authService})
            .then(result => {
                setState(result);
            })
            .catch(err => {
                setState(createErrorState('Could not fetch data correctly. Check console for error.'));
                console.log(err);
            });
    }, [url, api_url, authService]);

    return [state];
}