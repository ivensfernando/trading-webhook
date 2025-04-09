import express from 'express';
const router = express.Router();

/* GET home page. */
router.get('/', function (req, res) {
  res.render('index', { title: 'Express' });
});

/* Health check route */
router.get('/health', function (req, res) {
  res.status(200).send('OK');
});

router.post('/webhook', function (req, res) {
  const alertData = req.body;
  //
  console.log('Received alert from TradingView:', alertData);

  // You can do something with the alertData here, like:
  // - Save it to a database
  // - Trigger a trade
  // - Forward to another API
  // - Send a notification

  res.status(200).send('Alert received');
});

export default router;
