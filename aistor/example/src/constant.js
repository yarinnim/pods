import dotenv from 'dotenv';

dotenv.config();

export const STORAGE_HOST = process.env.STORAGE_HOST;
export const STORAGE_PORT = process.env.STORAGE_PORT;
export const STORAGE_USE_SSL = process.env.STORAGE_USE_SSL;
export const STORAGE_PART_STYLE = process.env.STORAGE_PART_STYLE;
export const STORAGE_ACCESS_KEY = process.env.STORAGE_ACCESS_KEY;
export const STORAGE_SECRET_KEY = process.env.STORAGE_SECRET_KEY;
