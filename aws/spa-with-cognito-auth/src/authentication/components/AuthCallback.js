import React from "react";

export default function AuthCallback({signinRedirectCallback}) {
    signinRedirectCallback();
    return (
        <span>Finishing signin process...</span>
    )
}