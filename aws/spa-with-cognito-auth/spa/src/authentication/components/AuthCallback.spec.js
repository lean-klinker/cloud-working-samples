import React from 'react';
import {cleanup, render} from '@testing-library/react';
import {AuthProvider} from '../providers/AuthProvider';
import {createMemoryHistory} from 'history';
import AuthCallback from './AuthCallback';
import {FakeUserManager} from '../../testing/fake-user-manager';
import {AuthService} from '../services/auth-service';
import {Router} from 'react-router';

describe('AuthCallback', () => {
    let userManager, history;

    beforeEach(() => {
        history = createMemoryHistory();
        userManager = new FakeUserManager();
    });

    test('when rendered then shows finishing sign in', () => {
        const {container} = renderAuthCallback();

        expect(container).toHaveTextContent('Finishing');
    });

    test('when rendered then redirects to private route', async () => {
        userManager.setupAuthenticatedUser();

        const {findByText} = renderAuthCallback();
        await findByText(/finished/);

        expect(history.location.pathname).toEqual('/private');
    });

    afterEach(() => {
        cleanup();
    })

    function renderAuthCallback() {
        return render(
            <AuthProvider authService={new AuthService(userManager, userManager.storage)}>
                <Router history={history}>
                    <AuthCallback/>
                </Router>
            </AuthProvider>
        );
    }
});