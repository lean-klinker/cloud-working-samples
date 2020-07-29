import React, {useEffect, useState} from 'react';
import {useAuthService} from "../providers/AuthProvider";
import {useHistory} from "react-router-dom";

export default function AuthCallback() {
    const [isSigninDone, setIsSigninDone] = useState(false);
    const service = useAuthService();
    const history = useHistory();
    useEffect(() => {
        service.signinRedirectCallback()
            .then(() => {
                if (service.isAuthenticated()) {
                    history.push('/private');
                    setIsSigninDone(true);
                }
            })
            .catch(err => console.error(err));
    }, [service, history])

    if (isSigninDone) {
        return <span>Signin finished redirecting...</span>;
    }

    return <span>Finishing signin process...</span>;
}