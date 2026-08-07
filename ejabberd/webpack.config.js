const path = require('path');
const webpack = require('webpack');
const dotenv = require('dotenv');
const baseConfig = require('../../packages/web-config/webpack.config');

dotenv.config({ path: path.resolve(__dirname, '.env') });

const chatServerUrl = process.env.CHAT_SERVER_URL;

/* for local development, we need to use the TLS origin of the chat server */
// const chatHost = new URL(chatServerUrl).hostname;
// const chatTlsOrigin = `https://${chatHost}:5443`;

module.exports = (processor, conf) => {
  const config = baseConfig(processor, conf, {
    rules: {
      style: {
        use: ['style-loader', 'css-loader', 'postcss-loader'],
      },
    },
    copyPatterns: [
      {
        from: path.resolve('../../node_modules/@xmpp/client/dist/xmpp.min.js'),
        to: 'js/xmpp.min.js',
      },
      {
        from: path.resolve('./assets/js/upload.worker.js'),
        to: 'js/upload.worker.js',
      },
    ],
    htmlPlugin: {
      scriptLoading: 'blocking',
    },
  });

  config.resolve = {
    ...config.resolve,
    fallback: {
      ...(config.resolve?.fallback || {}),
      'node:dns': false,
      dns: false,
      net: false,
      tls: false,
    },
  };

  config.plugins = [
    ...(config.plugins || []),
    new webpack.IgnorePlugin({
      resourceRegExp: /^@xmpp\/(client|tcp|tls|resolve)$/,
    }),
  ];

  // HMR uses /wds so /ws can be proxied to ejabberd.
  config.devServer = {
    ...(config.devServer || {}),
    webSocketServer: {
      type: 'ws',
      options: { path: '/wds' },
    },
    proxy: [
      {
        context: ['/ws'],
        /* for local development, we need to use the TLS origin of the chat server */
        // target: chatTlsOrigin,
        // pathRewrite: { '^/ws': '/websocket' },

        /* for production, we need to use the HTTP origin of the chat server */
        target: chatServerUrl,        
        ws: true,
        changeOrigin: true,
        secure: false,
      },
      {
        context: ['/chat-upload'],
        /* for production, we need to use the HTTP origin of the chat server */
        target: chatServerUrl,
        
        /* for local development, we need to use the TLS origin of the chat server */
        // target: chatTlsOrigin,        
        pathRewrite: { '^/chat-upload': '/upload' },
        changeOrigin: true,
        secure: false,
        proxyTimeout: 600000,
      },
    ],
  };

  return config;
};
