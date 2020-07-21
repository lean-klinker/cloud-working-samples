import {extractAuthorizationFromRequest} from './authorization-extractor';

export function createOpenIdConfigRequestFromToken({ iss }) {
    return {
        method: 'GET',
        url: `${iss}/.well-known/openid-configuration`
    }
}

export function createUserInfoRequestFromExpressRequest(req, { userinfo_endpoint }) {
    return {
        method: 'GET',
        url: userinfo_endpoint,
        headers: {
            Authorization: extractAuthorizationFromRequest(req)
        }
    }
}