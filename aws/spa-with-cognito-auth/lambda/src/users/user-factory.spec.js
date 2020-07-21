import {createUser} from './user-factory';

describe('user-factory', () => {
    test('when user created then token is included', () => {
        const token = {iss: 'data',};

        const user = createUser(token, {});

        expect(user).toEqual(token);
    });

    test('when user created then user info is included', () => {
        const userInfo = {username: 'bill'};

        const user = createUser({}, userInfo);

        expect(user).toEqual(userInfo);
    });
})