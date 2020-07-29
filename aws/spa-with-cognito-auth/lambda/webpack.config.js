const path = require('path');

module.exports = {
    entry: {
        lambda: './lambda.js'
    },
    output: {
        path: path.resolve(__dirname, 'build')
    },
    target: 'node',
    mode: 'development'
}