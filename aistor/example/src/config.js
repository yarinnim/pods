import { Client } from 'minio';
import { 
  STORAGE_HOST, STORAGE_PORT,
  STORAGE_USE_SSL, STORAGE_PART_STYLE,
  STORAGE_ACCESS_KEY, STORAGE_SECRET_KEY } from './constant.js';

export const minioClient = new Client({
  endPoint: STORAGE_HOST,
  port: parseInt(STORAGE_PORT, 10),
  useSSL: STORAGE_USE_SSL === 'true',
  partStyle: STORAGE_PART_STYLE === 'true',
  accessKey: STORAGE_ACCESS_KEY,
  secretKey: STORAGE_SECRET_KEY,

  partSize: 10 * 1024 * 1024, // 10Mb

});

