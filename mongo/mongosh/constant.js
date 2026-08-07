const dotenv = require('dotenv');

dotenv.config({ 
  path: '.env',
  debug: true,
  override: true,
});

const getEnv = (envName) => process.env[envName];

module.exports = ({
  HOST: getEnv('MONGO_HOST'),
  PORT: getEnv('MONGO_PORT'),
  USERNAME: getEnv('MONGO_USERNAME'),
  PASSWORD: getEnv('MONGO_PASSWORD'),
  DATABASE: getEnv('MONGO_DATABASE'),
});
