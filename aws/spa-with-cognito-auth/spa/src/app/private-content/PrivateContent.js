import React from "react";
import {useFetchGet} from "../hooks/useFetch";

export default function PrivateContent() {
    const [isLoading, error, result] = useFetchGet('/api/message');

    if (isLoading) {
        return <span>Loading data...</span>
    }

    if (error) {
        return <span>Error {error}</span>
    }

    return (
        <div>
            You are authenticated.

            <span>{result.text}</span>
        </div>
    )
}