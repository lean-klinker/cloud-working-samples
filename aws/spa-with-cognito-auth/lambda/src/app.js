import express from 'express';
import bodyParser from 'body-parser';
import awsServerlessExpressMiddleware from 'aws-serverless-express/middleware';
import cors from 'cors';

import {user} from './middleware/user-middleware';

const app = express();
app.use(cors({
    credentials: true
}));
app.use(bodyParser.json());
app.use(bodyParser.urlencoded({ extended: true }));
app.use(awsServerlessExpressMiddleware.eventContext());
app.use(user())

app.get('/api/message', async (req, res) => {
    res.json({
        text: 'Hello Lambda!',
        user: req.user
    });
})

module.exports = {
    app
}