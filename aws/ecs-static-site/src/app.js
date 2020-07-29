const express = require('express');
const cors = require('cors');
const winston = require('winston');
const expressWinston = require('express-winston');

const app = express();
app.use(cors());
app.use(expressWinston.logger({
    transports: [
        new winston.transports.Console()
    ],
    format: winston.format.combine(
        winston.format.colorize(),
        winston.format.simple()
    )
}));

app.get('/', (req, res) => {
    res.json({ message: 'Hello' });
});

module.exports = {
    app
}