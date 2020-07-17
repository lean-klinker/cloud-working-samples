import {useEffect, useState} from "react";
import {useSettings} from "../../authentication/providers/SettingsProvider";
import {useAuthService} from "../../authentication/providers/AuthProvider";

function getFullUrl(baseUrl, path) {
    return `${baseUrl}${path}`;
}

async function executeFetch({url, authService}) {
    if (!authService.isAuthenticated()) {
        return {isLoading: false, error: 'You must be logged in.', result: null};
    }

    const accessToken = await authService.getAccessToken();
    const headers = { Authorization: `Bearer ${accessToken}` }
    const response = await fetch(url, { headers });
    if (response.ok)
        return {isLoading: false, result: await response.json(), error: null };

    return {isLoading: false, result: null, error: response.error() };
}

export function useFetchGet(url) {
    const [isLoading, setLoading] = useState(true);
    const [error, setError] = useState(null);
    const [result, setResult] = useState(null);

    const {api_url} = useSettings();
    const authService = useAuthService();

    useEffect(() => {
        executeFetch({url: getFullUrl(api_url, url), authService})
            .then(result => {
                setError(result.error);
                setLoading(result.isLoading);
                setResult(result.result);
            })
            .catch(err => {
                console.log(err);
                setError('Could not fetch data correctly. Check console for error.');
                setLoading(false);
                setResult(null);
            });
    }, [url, api_url, authService]);

    return [isLoading, error, result];
}