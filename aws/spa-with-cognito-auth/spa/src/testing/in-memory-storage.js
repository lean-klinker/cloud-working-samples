import {User} from 'oidc-client';
import {TEST_SETTINGS} from './test-settings';

export class InMemoryStorage {
    constructor() {
        this.map = new Map();
    }

    getItem(key) {
        return this.map.get(key);
    }

    setItem(key, value) {
        this.map.set(key, value);
    }

    clear() {
        this.map.clear();
    }

    setupUser({expires_at = null, ...rest} = {}) {
        const user = new User({
            ...rest,
            expires_at
        });
        this.setItem(`oidc.user:${TEST_SETTINGS.authority}:${TEST_SETTINGS.client_id}`, user.toStorageString());
    }

    setupAuthenticatedUser() {
        this.setupUser({ expires_at: Date.parse('9999-12-31') });
    }

    setupExpiredUser() {
        this.setupUser({expires_at: Date.parse('1776-07-04')});
    }
}