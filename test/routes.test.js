import request from 'supertest';
import { expect } from 'chai';
import app from '../app.js';
import db from '../db.js';

describe('API routes', function () {
  after(async function () {
    await db.end(); // Close DB connection pool
  });

  it('GET /health should return OK', async function () {
    const res = await request(app).get('/health');
    expect(res.status).to.equal(200);
    expect(res.text).to.equal('OK');
  });

  it('GET /health/db should return current db time', async function () {
    this.timeout(10000);
    const res = await request(app).get('/health/db');
    expect(res.status).to.equal(200);
    expect(res.body).to.have.property('dbTime');
  });

  it('POST /webhook should save alert data', async function () {
    this.timeout(10000); // increase timeout

    const fakeAlert = {
      symbol: 'BTCUSD',
      price: 69000,
      time: new Date().toISOString(),
      alert_name: 'Test Alert Mocha'
    };

    const res = await request(app)
      .post('/webhook')
      .send(fakeAlert)
      .set('Content-Type', 'application/json');

    expect(res.status).to.equal(200);
    expect(res.text).to.equal('Alert received and saved');
  });
});
