import jwt from 'jsonwebtoken';
import {extractUserFromToken, user} from './user-middleware';

const USER_INFO_ENDPOINT = 'https://some.data.com/userinfo';
const ISSUER_URL = 'https://some.cognito.service.com';

describe('user-middleware', () => {
    let middleware, requestor, next, authToken, request;

    beforeEach(async () => {
        const openIdConfig = {userinfo_endpoint: USER_INFO_ENDPOINT};
        const userInfo = {username: 'bill'};
        requestor = {
            get: jest.fn().mockImplementation((url) => {
                if (url.includes(ISSUER_URL)) {
                    return Promise.resolve({data: openIdConfig});
                }
                return Promise.resolve({data: userInfo});
            })
        };

        next = jest.fn();
        authToken = generateJwt({iss: ISSUER_URL});
        request = createRequest();
        middleware = user(requestor);
    });

    test('when request is contains token then user is set on request', async () => {
        await executeMiddleware();

        expect(request.user).toMatchObject({
            iss: ISSUER_URL,
            username: 'bill'
        });
    });

    test('when request received then calls next middleware', async () => {
        await executeMiddleware();

        expect(next).toHaveBeenCalled();
    });

    test('when request received then gets openid configuration from issuer', async () => {
        await executeMiddleware();

        expect(requestor.get).toHaveBeenCalledWith(`${ISSUER_URL}/.well-known/openid-configuration`);
    });

    test('when running locally then sets user to local user', async () => {
        process.env.ENV = 'local';

        await executeMiddleware()

        expect(request.user).toEqual({
            username: 'bob'
        })
    })

    afterEach(() => {
        process.env.ENV = undefined;
    })

    async function executeMiddleware() {
        await middleware(request, null, next);
    }

    function generateJwt(payload = {}) {
        return jwt.sign(payload, 'secret');
    }

    function createRequest() {
        return {
            headers: {
                Authorization: `Bearer ${authToken}`
            }
        };
    }
});