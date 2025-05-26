import pkg from 'pg';

import dotenv from 'dotenv';
dotenv.config({ path: '.env' });


const { Pool } = pkg;
const pool = new Pool({
  user: process.env.PGUSER,
  host: process.env.PGHOST,
  database: process.env.PGDATABASE,
  password: process.env.PGPASSWORD,
  port: process.env.PGPORT || 5432,
});
// console.log('✅ pool:', pool);
export default pool;
