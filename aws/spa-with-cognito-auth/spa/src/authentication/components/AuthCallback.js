import React, {useEffect} from "react";
import {useAuthService} from "../providers/AuthProvider";
import {useHistory} from "react-router-dom";

export default function AuthCallback() {
    const service = useAuthService();
    const history = useHistory();
    useEffect(() => {
        async function finishSignin() {
            await service.signinRedirectCallback();
            if (service.isAuthenticated()) {
                history.push('/private');
            }
        }

        finishSignin();
    }, [service, history])

    return (
        <span>Finishing signin process...</span>
    )
}