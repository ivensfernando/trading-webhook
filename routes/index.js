import express from 'express';
import db from '../db.js';
const router = express.Router();

/* GET home page. */
router.get('/', function (req, res) {
  res.render('index', { title: 'Express' });
});

/* Health check route */
router.get('/health', function (req, res) {
  res.status(200).send('OK');
});

router.get('/health/db', async (req, res) => {
  try {
    const result = await db.query('SELECT NOW()');
    res.status(200).json({ dbTime: result.rows[0].now });
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

router.post('/webhook',  async function (req, res) {
  const body = req.body;
  //
  console.log('Received alert from TradingView:', body);

  const alertName = body.alert_name || 'BTC_CU';

  try {
    await db.query(
        `INSERT INTO alerts (alert_name, body)
       VALUES ($1, $2)`,
        [alertName, body]
    );

    console.log('✅ Alert received and saved:', alertName);
    res.status(200).send('Alert received and saved');
  } catch (err) {
    console.error('❌ Error saving alert:', err);
    res.status(500).send('Error saving alert');
  }

  // You can do something with the alertData here, like:
  // - Save it to a database
  // - Trigger a trade
  // - Forward to another API
  // - Send a notification

  res.status(200).send('Alert received');
});

export default router;
