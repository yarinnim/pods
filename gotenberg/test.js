import fs from 'node:fs/promises';
import path from 'node:path';
// Configuration
const GOTENBERG_URL = 'http://gotenberg.localhost.com/forms/chromium/convert/html';
const APP_ID = '29412b0478e4';
const APP_SECRET = 'Mjk0MTJiMDQ3OGU0';
const TARGET_URL = 'https://sparksuite.github.io/simple-html-invoice-template/';
const OUTPUT_PATH = path.join(process.cwd(), 'invoice.pdf');

async function generateInvoice() {
  try {
    console.log(`1. Fetching HTML content from: ${TARGET_URL}`);
    const response = await fetch(TARGET_URL);

    if (!response.ok) {
      throw new Error(`Failed to fetch HTML: ${response.status} ${response.statusText}`);
    }

    // Store the HTML content in a variable
    const htmlContent = await response.text();
    console.log(`   Successfully fetched HTML (${htmlContent.length} characters).`);

    console.log('2. Preparing multipart form-data for Gotenberg...');
    const formData = new FormData();

    // Gotenberg expects the HTML file to be named index.html
    const htmlBlob = new Blob([htmlContent], { type: 'text/html' });
    formData.append('files', htmlBlob, 'index.html');

    console.log(`3. Sending request to Gotenberg at ${GOTENBERG_URL}...`);
    const gotenbergResponse = await fetch(GOTENBERG_URL, {
      method: 'POST',
      headers: {
        'X-App-ID': APP_ID,
        'X-App-Secret': APP_SECRET,
      },
      body: formData
    });

    if (!gotenbergResponse.ok) {
      const errorText = await gotenbergResponse.text();
      throw new Error(`Gotenberg conversion failed (${gotenbergResponse.status}): ${errorText}`);
    }

    console.log('4. Receiving and saving PDF file...');
    const pdfBuffer = Buffer.from(await gotenbergResponse.arrayBuffer());
    await fs.writeFile(OUTPUT_PATH, pdfBuffer);

    console.log(`✅ Success! PDF saved to: ${OUTPUT_PATH}`);

  } catch (error) {
    console.error('❌ Error generating PDF:', error.message);
    process.exit(1);
  }
}

generateInvoice();
