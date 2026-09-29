#! /usr/bin/bash

curl \
  --request POST http://gotenberg.localhost.com/forms/chromium/convert/url \
  --header 'X-App-ID: 29412b0478e4' \
  --header 'X-App-Secret: Mjk0MTJiMDQ3OGU0' \
  --form url=https://sparksuite.github.io/simple-html-invoice-template/ \
  -o ~/Documents/invoice.pdf
