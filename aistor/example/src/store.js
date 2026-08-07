import fs from 'fs';
import { minioClient, bucketName, objectName, metaData } from './config.js';

const fileStream = fs.createReadStream('./assets/minio.pdf');
const fileStats = fs.statSync('./assets/minio.pdf');
const objectSize = fileStats.size;

minioClient.putObject(bucketName, objectName, fileStream, objectSize, metaData, function(err, etag) {
  console.log({ err, etag });
  if (err) {
    return console.log(err);
  }
  console.log('Object uploaded successfully, etag:', etag);
});
