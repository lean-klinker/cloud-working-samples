import jsonWebToken from 'jsonwebtoken';
import {
    createOpenIdConfigRequestFromToken,
    createUserInfoRequestFromExpressRequest
} from './openid-request-factory';

const ISSUER_URL = 'https://openid.com';

describe('openid-request-factory', () => {
    test('when open id config request created then returns openid config url', () => {
        const request = createOpenIdConfigRequestFromToken({ iss: ISSUER_URL });

        expect(request).toEqual({
            url: `${ISSUER_URL}/.well-known/openid-configuration`,
            method: 'GET'
        });
    });

    test('when user info request created then returns user info request', () => {
        const openIdConfig = { userinfo_endpoint: 'https://user.info' }
        const expressRequest = createExpressRequest();
        const request = createUserInfoRequestFromExpressRequest(expressRequest, openIdConfig);

        expect(request).toEqual({
            url: 'https://user.info',
            method: 'GET',
            headers: {
                Authorization: expressRequest.headers.authorization
            }
        })
    })

    function createExpressRequest() {
        return {
            headers: {
                authorization: `Bearer ${generateJwt()}`
            }
        }
    }

    function generateJwt() {
        return jsonWebToken.sign({
            iss: ISSUER_URL
        }, 'secret');
    }
})