import axios from 'axios';
import { loadUserFromRequest } from '../users/user-loader';

export function user(requestor = axios) {
    return async (req, res, next) => {
        if (isLocal()) {
            return getLocalUser();
        }

        req.user = await loadUserFromRequest(req, requestor);
        next();
    };
}

function isLocal() {
    return process.env.ENV === 'local';
}

function getLocalUser() {
    return {username: 'bob'};
}