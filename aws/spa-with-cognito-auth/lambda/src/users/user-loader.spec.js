import jsonWebToken from 'jsonwebtoken';

import {loadUserFromRequest} from './user-loader';

const ISSUER_URL = 'https://something.com';
const USER_INFO_ENDPOINT = 'https://user.info';

describe('user-loader', () => {
    let requestor;

    beforeEach(() => {
        requestor = {
            request: jest.fn().mockImplementation((options) => {
                if (options.url.includes(ISSUER_URL)) {
                    return Promise.resolve({data: {userinfo_endpoint: USER_INFO_ENDPOINT}});
                }

                return Promise.resolve({data: {username: 'bob'}});
            })
        };
    });

    test('when user loaded from request then returns user', async () => {
        const user = await loadUserFromRequest(createRequest(), requestor);

        expect(user).toMatchObject({
            username: 'bob',
            iss: ISSUER_URL
        });
    });

    function createRequest() {
        const token = jsonWebToken.sign({iss: ISSUER_URL}, 'stuff');
        return {
            headers: {
                authorization: `Bearer ${token}`
            }
        };
    }
});