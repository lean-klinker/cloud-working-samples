export function createUser(token, userInfo) {
    return {
        ...token,
        ...userInfo
    }
}