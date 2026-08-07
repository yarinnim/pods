const config = require('./constant');
const { HOST, PORT, DATABASE, USERNAME, PASSWORD } = config;
console.log({ config });

const password = encodeURIComponent(PASSWORD);
console.log({ password });
const db = connect(`mongodb://${USERNAME}:${password}@${HOST}:${PORT}/${DATABASE}`);
module.exports = db;
