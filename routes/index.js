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

  if (!body || Object.keys(body).length === 0) {
    console.warn('❌ Received empty body');
    return res.status(400).send('Invalid or missing JSON body');
  }

  const {
    alert_name,
    event,
    symbol,
    exchange,
    interval,
    alert_time,
    server_time,
    open,
    close,
    high,
    low,
    volume,
    currency,
    base_currency,
    plot,
    strategy_description
  } = body;


  try {
    await db.query(
        `INSERT INTO alerts (
          alert_name, event, symbol, exchange, interval,
          alert_time, server_time, open, close, high, low, volume,
          currency, base_currency, plot, description, received_at, body
        )
         VALUES (
                  $1, $2, $3, $4, $5,
                  $6, $7, $8, $9, $10, $11, $12,
                  $13, $14, $15, $16, NOW(), $17
                )`,
        [
          alert_name || 'unknown',
          event,
          symbol,
          exchange,
          interval,
          alert_time ? new Date(alert_time) : null,
          server_time ? new Date(server_time) : null,
          open,
          close,
          high,
          low,
          volume,
          currency,
          base_currency,
          plot,
          strategy_description,
          body // save raw JSON
        ]
    );

    console.log(`✅ Alert saved: ${alert_name}`);
    res.status(200).send('Alert received and saved');
  } catch (err) {
    console.error('❌ Error saving alert:', err);
    if (!res.headersSent) {
      res.status(500).send('Error saving alert');
    }
  }
});

export default router;
