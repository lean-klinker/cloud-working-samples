export function extractAuthorizationFromRequest({headers = {}}) {
    const authKey = headers.hasOwnProperty('authorization') ? 'authorization' : 'Authorization';
    const value = headers[authKey];
    if (!value) {
        throw new Error(`No authorization found in headers: ${JSON.stringify(headers)}`);
    }

    return value;
}