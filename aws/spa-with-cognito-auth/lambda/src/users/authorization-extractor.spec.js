import {extractAuthorizationFromRequest} from './authorization-extractor';

describe('authorization-extract', () => {
    test('when "authorization" specified in request header then returns "authorization" value', () => {
        const req = {
            headers: {
                authorization: 'Some value goes here'
            }
        };

        const value = extractAuthorizationFromRequest(req);

        expect(value).toEqual('Some value goes here');
    });

    test('when "Authoriation" specified in request header then returns "Authorization" value', () => {
        const req = {
            headers: {
                Authorization: 'this value'
            }
        };

        const value = extractAuthorizationFromRequest(req);

        expect(value).toEqual('this value');
    });

    test('when no authorization header specified then throws exception', () => {
        const req = { headers: {} };

        expect(() => extractAuthorizationFromRequest(req)).toThrow();
    })
})