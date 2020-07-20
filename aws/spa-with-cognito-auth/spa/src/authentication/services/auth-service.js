import {UserManager, WebStorageStateStore, User} from 'oidc-client';

export class AuthService {
    get settings() {
        return this.manager.settings;
    }

    get userKey() {
        return `oidc.user:${this.settings.authority}:${this.settings.client_id}`;
    }

    constructor(manager, storage) {
        this.manager = manager;
        this.storage = storage;
    }

    isAuthenticated = () => {
        const storedUser = this.getStoredUser();
        return !!storedUser && !storedUser.expired;
    };

    signinRedirect = async () => {
        await this.manager.signinRedirect();
    };

    signinRedirectCallback = async () => {
        await this.manager.signinRedirectCallback();
    };

    getUser = () => {
        return this.manager.getUser();
    };

    getStoredUser = () => {
        const serializedUser = this.storage.getItem(this.userKey);
        return serializedUser
            ? User.fromStorageString(serializedUser)
            : null;
    };

    getAccessToken = async () => {
        if (!this.isAuthenticated()) {
            return null;
        }

        const user = await this.getUser();
        return user.access_token;
    };

    static createFromSettings(settings) {
        const storage = window.sessionStorage;
        const manager = new UserManager({
            ...settings,
            userStore: new WebStorageStateStore({store: storage})
        });
        return new AuthService(manager, storage);
    }
}