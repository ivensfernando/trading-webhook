import pkg from 'pg';
import dotenv from 'dotenv';
dotenv.config({ path: '../.env' });

const { Pool } = pkg;

const pool = new Pool({
  user: process.env.PGUSER,
  host: process.env.PGHOST,
  database: process.env.PGDATABASE,
  password: process.env.PGPASSWORD,
  port: process.env.PGPORT || 5432,
});

(async () => {
  try {
      // console.log('[DEBUG] PGPASSWORD:', typeof process.env.PGPASSWORD, process.env.PGPASSWORD);
    const res = await pool.query('SELECT NOW()');
    console.log('✅ DB Time1:', res.rows[0].now);
    await pool.end();
  } catch (err) {
    console.error('❌ DB Error:', err.message);
  }
})();
