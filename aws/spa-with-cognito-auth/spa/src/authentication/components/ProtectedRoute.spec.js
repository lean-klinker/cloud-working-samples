import React from 'react';
import {cleanup, render} from '@testing-library/react';
import {Switch, Router, Redirect, Route} from 'react-router';
import {createMemoryHistory} from 'history';
import {FakeUserManager} from '../../testing/fake-user-manager';
import {AuthProvider} from '../providers/AuthProvider';
import {AuthService} from '../services/auth-service';
import ProtectedRoute from './ProtectedRoute';

describe('ProtectedRoute', () => {
    let userManager, history;

    beforeEach(() => {
        history = createMemoryHistory();
        userManager = new FakeUserManager();
    });

    test('when user is authenticated then shows protected component', () => {
        userManager.setupAuthenticatedUser();
        history.push('/protected');

        const {container} = renderWithRouting();

        expect(container).toHaveTextContent('Authed');
    });

    test('when user is unauthenticated then redirects to sigin', () => {
        history.push('/protected');

        renderWithRouting();

        expect(userManager.signinRedirect).toHaveBeenCalled();
    });

    test('when user is waiting to be redirected then shows loading', () => {
        history.push('/protected');

        const {container} = renderWithRouting();

        expect(container).toHaveTextContent('loading');
    })

    afterEach(() => {
        cleanup();
    });

    function renderWithRouting() {
        return render(
            <AuthProvider authService={new AuthService(userManager, userManager.storage)}>
                <Router history={history}>
                    <TestRoutes/>
                </Router>
            </AuthProvider>
        );
    }
});

function TestComponent() {
    return <span>Authed</span>;
}

function TestRoutes() {
    return (
        <Switch>
            <ProtectedRoute path={'/protected'} component={TestComponent}/>
        </Switch>
    );
}