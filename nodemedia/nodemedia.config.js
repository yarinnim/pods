const config = {
  logType: 3,

  rtmp: {
    port: 1935,
    chunk_size: 60000,
    gop_cache: false,
    ping: 30,
    ping_timeout: 60
  },

  http: {
    port: 8000,
    allow_origin: '*'
  },

  trans: {
    ffmpeg: '/usr/bin/ffmpeg',
    tasks: [
      {
        app: 'live',
        hls: true,
        hlsFlags: '[hls_time=1:hls_list_size=3:hls_flags=delete_segments]'
      }
    ]
  }
};

module.exports = config;

