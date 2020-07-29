import {
    createOpenIdConfigRequestFromToken,
    createUserInfoRequestFromExpressRequest
} from './openid-request-factory';
import {createUser} from './user-factory';
import {readTokenFromRequest} from './token-reader';

export async function loadUserFromRequest(req, requestor) {
    const token = readTokenFromRequest(req);
    const openidConfigResponse = await requestor.request(createOpenIdConfigRequestFromToken(token));
    const userInfoResponse = await requestor.request(createUserInfoRequestFromExpressRequest(req, openidConfigResponse.data));
    return createUser(token, userInfoResponse.data);
}