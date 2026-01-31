// script.js
import http from 'k6/http';
import { sleep, check } from 'k6';
import { Counter, Trend, Rate, Gauge } from 'k6/metrics';

/* ------------------------
   Custom metrics
------------------------- */

// How many requests we send
export const requestsTotal = new Counter('custom_http_requests_total');

// End-to-end request latency
export const requestLatency = new Trend('custom_http_request_latency_ms');

// Success / failure ratio
export const requestSuccess = new Rate('custom_http_success');

// Payload size
export const responseSize = new Gauge('custom_http_response_size_bytes');

/* ------------------------
   Test options
------------------------- */
export const options = {
  vus: 5,
  duration: '30s',

  thresholds: {
    custom_http_success: ['rate>0.99'],
    custom_http_request_latency_ms: ['p(95)<500'],
  },
};

/* ------------------------
   Test logic
------------------------- */
export default function () {
  const url = 'http://nginx-test.default.svc.cluster.local';

  const res = http.get(url, {
    tags: {
      service: 'nginx-test',
      env: 'local',
      endpoint: '/',
    },
  });

  // Built-in validation
  const ok = check(res, {
    'status is 200': (r) => r.status === 200,
  });

  /* ------------------------
     Emit custom metrics
  ------------------------- */

  requestsTotal.add(1, {
    service: 'nginx-test',
    env: 'local',
  });

  requestLatency.add(res.timings.duration, {
    service: 'nginx-test',
    endpoint: '/',
  });

  requestSuccess.add(ok, {
    service: 'nginx-test',
  });

  responseSize.add(res.body.length, {
    service: 'nginx-test',
  });

  sleep(1);
}