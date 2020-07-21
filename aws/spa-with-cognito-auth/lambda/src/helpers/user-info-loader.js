import axios from 'axios';

export async function getUserInfo(authorizationHeader) {

    const openIdConfigUrl = `${issuerUrl}/.well-known/openid-configuration`;
    const response = await axios.get(openIdConfigUrl);
    const {userinfo_endpoint} = response.data;
    const userInfo = await axios.get(userinfo_endpoint, {
        headers: {
            Authorization: gatewayEvent.headers.Authorization
        }
    });
    return userInfo.data;
}