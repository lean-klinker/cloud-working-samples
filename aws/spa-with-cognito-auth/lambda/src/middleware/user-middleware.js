import jwt from 'jsonwebtoken';
import axios from 'axios';

export function user(requestor = axios) {
    return async (req, res, next) => {
        req.user = await loadUserFromRequest(req, requestor);
        next();
    };
}

async function loadUserFromRequest(req, requestor) {
    if (isLocal()) {
        return getLocalUser();
    }

    const token = extractUserFromToken(req);
    return await loadUserInfo(token, req, requestor);
}

async function loadUserInfo(token, req, requestor) {
    const openIdConfigurationUrl = `${token.iss}/.well-known/openid-configuration`;
    const openIdConfig = (await requestor.get(openIdConfigurationUrl)).data;
    const userInfo = await requestor.get(openIdConfig.userinfo_endpoint, {
        headers: {
            Authorization: req.headers.Authorization
        }
    });
    return {
        ...token,
        ...userInfo.data
    };
}

function isLocal() {
    return process.env.ENV === 'local';
}

function getLocalUser() {
    return {username: 'bob'};
}

function extractUserFromToken(req) {
    const token = req.headers['authorization'].split(' ')[1];
    return jwt.decode(token);
}