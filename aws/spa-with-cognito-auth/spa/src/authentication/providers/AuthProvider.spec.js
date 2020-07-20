import React from 'react';
import {cleanup, render} from '@testing-library/react';
import {AuthProvider, useAuthService} from './AuthProvider';
import {FakeUserManager} from '../../testing/fake-user-manager';
import {AuthService} from '../services/auth-service';
import {ignoreConsoleErrors, restoreConsoleError} from '../../testing/logging';

describe('AuthProvider', () => {
    let authService, userManager;

    beforeEach(() => {
        userManager = new FakeUserManager();
        userManager.setupAuthenticatedUser();

        authService = new AuthService(userManager, userManager.storage);
    })

    test('when auth service hook is used then auth service is available', () => {
        const {container} = renderWithAuthProvider();

        expect(container).toHaveTextContent('Is Authenticated: true');
    });

    test('when auth service hook is used outside provider then error is raised', () => {
        ignoreConsoleErrors()

        expect(() => render(<TestComponent />)).toThrow();
    })

    afterEach(() => {
        restoreConsoleError();
        cleanup();
    })

    function renderWithAuthProvider() {
        return render(
            <AuthProvider authService={authService}>
                <TestComponent />
            </AuthProvider>
        );
    }
});

function TestComponent() {
    const service = useAuthService();
    return (
        <span>Is Authenticated: {`${service.isAuthenticated()}`}</span>
    );
}