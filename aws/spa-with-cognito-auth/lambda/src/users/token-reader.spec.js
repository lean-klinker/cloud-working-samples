import jsonWebToken from 'jsonwebtoken';
import {readTokenFromRequest} from './token-reader';

const ISSUER_URL = 'https://something.com';

describe('token-reader', () => {
    test('when token is in request then token is read from "authorization" header', () => {
        const request = { headers: { authorization: `Bearer ${generateJwt()}` } };

        const token = readTokenFromRequest(request);

        expect(token).toMatchObject({
            iss: ISSUER_URL
        })
    });

    function generateJwt() {
        return jsonWebToken.sign({
            iss: ISSUER_URL
        }, 'secret');
    }
})