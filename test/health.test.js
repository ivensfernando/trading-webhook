import request from 'supertest';
import app from '../app.js';
import assert from 'assert'; // ✅ Import built-in assertion module

describe('GET /health', () => {
    it('should return 200 OK', async () => {
        const res = await request(app).get('/health');
        assert.strictEqual(res.statusCode, 200);
        assert.strictEqual(res.text, 'OK');
    });
});
