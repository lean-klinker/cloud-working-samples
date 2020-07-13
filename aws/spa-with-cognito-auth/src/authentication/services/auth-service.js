import {UserManager, WebStorageStateStore, User} from 'oidc-client';

export class AuthService {
    get settings() {
        return this.manager.settings;
    }

    get userStore() {
        return this.settings.userStore;
    }

    get userKey() {
        return `oidc.user:${this.settings.authority}:${this.settings.client_id}`
    }

    constructor(settings) {
        this.manager = new UserManager({
            ...settings,
            userStore: new WebStorageStateStore({ store: window.sessionStorage })
        });
    }

    isAuthenticated = () => {
        const storedUser = this.getStoredUser();
        return storedUser && !storedUser.expired;
    }

    signinRedirect = async () => {
        await this.manager.signinRedirect();
    };

    signinRedirectCallback = async () => {
        await this.manager.signinRedirectCallback();
    };

    getUser = () => {
        return this.manager.getUser();
    }

    getStoredUser = () => {
        const serializedUser = window.sessionStorage.getItem(this.userKey);
        return serializedUser
            ? User.fromStorageString(serializedUser)
            : null;
    }
}