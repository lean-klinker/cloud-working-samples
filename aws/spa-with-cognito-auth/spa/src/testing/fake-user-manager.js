import {TEST_SETTINGS} from './test-settings';
import {InMemoryStorage} from './in-memory-storage';
import {User} from 'oidc-client';

export class FakeUserManager {
    user = null;


    get settings() {
        return this._settings;
    }

    constructor(storage = new InMemoryStorage()) {
        this._settings = TEST_SETTINGS
        this.storage = storage;
        this._userKey = `oidc.user:${this.settings.authority}:${this.settings.client_id}`;
    }

    signinRedirect = jest.fn().mockResolvedValue();
    signinRedirectCallback = jest.fn().mockResolvedValue();
    getUser = () => Promise.resolve(this.user);

    setupUser({expires_at = null, ...rest} = {}) {
        this.user = new User({
            ...rest,
            expires_at
        });
        this.storage.setItem(this._userKey, this.user.toStorageString());
    }

    setupAuthenticatedUser() {
        this.setupUser({ expires_at: Date.parse('9999-12-31') });
    }

    setupExpiredUser() {
        this.setupUser({expires_at: Date.parse('1776-07-04')});
    }
}