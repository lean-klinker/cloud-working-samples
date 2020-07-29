import {FakeUserManager} from '../../testing/fake-user-manager';
import {AuthService} from './auth-service';
import {User} from 'oidc-client';

describe('AuthService', () => {
    let userManager, authService;

    beforeEach(() => {
        userManager = new FakeUserManager();
        authService = new AuthService(userManager, userManager.storage);
    });

    test('when no user is stored then user is not authenticated', () => {
        expect(authService.isAuthenticated()).toEqual(false);
    });

    test('when user has expired then user is not authenticated', () => {
        userManager.setupExpiredUser();

        expect(authService.isAuthenticated()).toEqual(false);
    });

    test('when stored user is still valid then user is authenticated', () => {
        userManager.setupAuthenticatedUser();

        expect(authService.isAuthenticated()).toEqual(true);
    });

    test('when sign in is initiated then redirects to signin', async () => {
        await authService.signinRedirect();

        expect(userManager.signinRedirect).toHaveBeenCalled();
    });

    test('when sign in completed then sign in redirect callback is used', async () => {
        await authService.signinRedirectCallback();

        expect(userManager.signinRedirectCallback).toHaveBeenCalled();
    });

    test('when getting user the user is returned from user manager', async () => {
        userManager.user = new User({});

        const actual = await authService.getUser();

        expect(actual).toEqual(userManager.user);
    });

    test('when getting access token then returns access token if authenticated', async () => {
        userManager.setupUser({
            access_token: 'this.is.data',
            expires_at: Date.parse('9999-12-31')
        });

        const accessToken = await authService.getAccessToken();

        expect(accessToken).toEqual('this.is.data');
    });

    test('when getting access token then returns null if unauthenticated', async () => {
        const accessToken = await authService.getAccessToken();

        expect(accessToken).toEqual(null);
    });
});