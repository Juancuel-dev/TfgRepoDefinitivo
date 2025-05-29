import http from 'k6/http';
import { check, sleep } from 'k6';

export let options = {
  vus: 100, // Número de usuarios virtuales
  duration: '30s', // Duración total del test
};

const BASE_URL = 'http://localhost:8080/gateway/users/me';
const AUTH_TOKEN = 'Bearer eyJhbGciOiJIUzI1NiJ9.eyJjbGllbnRJZCI6ImJiY2QwZGM2LTJhYWQtNGJmNi1hMzA1LTFmMTg1MmFjNDMzYyIsInJvbGUiOiJBRE1JTiIsInVzZXJuYW1lIjoianVhbmN1ZWwiLCJpYXQiOjE3NDg1MjY4MjUsImV4cCI6MTc0ODYxMzIyNX0.biSvLQpkucvGZOK5mpx2aodwwhOGKD-dU5_jJvTl5lc';

export default function () {
  const res = http.get(BASE_URL, {
    headers: {
      Authorization: AUTH_TOKEN,
    },
  });

  check(res, {
    'status is 200': (r) => r.status === 200,
  });

  sleep(1); // Puedes ajustar esto para mayor carga (por ejemplo, sleep(0.1) o quitarlo)
}
