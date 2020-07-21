import jsonWebToken from 'jsonwebtoken';

import {extractAuthorizationFromRequest} from './authorization-extractor';

export function readTokenFromRequest(req) {
    const authHeader = extractAuthorizationFromRequest(req);
    return jsonWebToken.decode(authHeader.split(' ')[1]);
}