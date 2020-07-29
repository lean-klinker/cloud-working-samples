import React from 'react';
import {cleanup, render} from '@testing-library/react';
import {SettingsProvider, useSettings} from './SettingsProvider';
import {TEST_SETTINGS} from '../../testing/test-settings';
import {ignoreConsoleErrors, restoreConsoleError} from '../../testing/logging';

describe('SettingsProvider', () => {
    let settings;

    beforeEach(() => {
        settings = TEST_SETTINGS;
    });

    test('when settings hook is used then settings are available to component', () => {
        const {container} = renderWithSettingsProvider();

        expect(container).toHaveTextContent(`Client Id: ${settings.client_id}`)
    });

    test('when settings hook is used outside provider then throws error', () => {
        ignoreConsoleErrors();

        expect(() => render(<TestComponent />)).toThrow();
    })

    afterEach(() => {
        restoreConsoleError();
        cleanup();
    })

    function renderWithSettingsProvider() {
        return render(
            <SettingsProvider settings={settings}>
                <TestComponent />
            </SettingsProvider>
        )
    }
});

function TestComponent() {
    const settings = useSettings();
    return (
        <span>Client Id: {settings.client_id}</span>
    )
}