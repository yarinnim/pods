import { minioClient } from './config.js';

const bucketName = 'wetvpro-reels';
const objectName = `minio-${new Date().getTime()}.pdf`;
const filePath = './assets/minio.pdf';

function upload() {
  return minioClient.fPutObject(bucketName, objectName, filePath)
    .then((result) => {
      console.log('[INFO] Uploaded successfully.');
      console.log({ result });
    })
    .catch((error) => {
      const { message } = error;
      console.error(`[ERROR] ${message}`);
      console.error({ error });
    });
}

upload().then(console.log);
