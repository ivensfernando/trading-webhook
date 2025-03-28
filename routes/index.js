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

export default router;
