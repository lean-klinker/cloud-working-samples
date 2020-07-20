import {getUserInfo} from './helpers/user-info-loader';

const express = require('express');
const bodyParser = require('body-parser');
const awsServerlessExpressMiddleware = require('aws-serverless-express/middleware');
const cors = require('cors');
const app = express();

app.use(cors({
    credentials: true
}));
app.use(bodyParser.json());
app.use(bodyParser.urlencoded({ extended: true }));
app.use(awsServerlessExpressMiddleware.eventContext());

app.get('/api/message', async (req, res) => {
    console.log(`Api Gateway Event: ${JSON.stringify(req.apiGateway.event)}`);
    console.log(`Authorizer: ${JSON.stringify(req.apiGateway.event.requestContext.authorizer)}`);
    const userInfo = await getUserInfo(req.apiGateway.event);
    console.log(`User Info: ${JSON.stringify(userInfo)}`);
    res.json({ text: 'Hello Lambda!' });
})

module.exports = {
    app
}