import { minioClient, bucketName, objectName } from './config.js';
import path from 'path';

const downloadPath = path.join('./downloads', 'saved-report.pdf');

let size = 0
const dataStream = await minioClient.getObject(bucketName, objectName)
dataStream.on('data', function (chunk) {
  size += chunk.length
})
dataStream.on('end', function () {
  console.log('End. Total size = ' + size)
})
dataStream.on('error', function (err) {
  console.log(err)
})


minioClient.fGetObject(bucketName, objectName, downloadPath);
