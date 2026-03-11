# Dashboard Guide

## 1) 사용자 10초 온보딩
1. `https://dl.meowti.kr/instance.zip`를 다운로드합니다.
2. Prism Launcher에서 instance를 import합니다.
3. 서버 주소 `mc.meowti.kr`를 등록합니다.
4. 디스코드에서 화이트리스트 승인 후 접속합니다.

## 2) 운영자 기본 점검
1. nginx 상태 확인: `docker compose -f /srv/infra/compose/nginx/docker-compose.yml ps`
2. dashboard 상태 확인: `docker compose -f /srv/infra/compose/dashboard/docker-compose.yml ps`
3. 프록시 점검: `cd /srv/infra && ./scripts/check-dashboard-proxy.sh`
4. 로컬 확인: `curl -I -H 'Host: dashboard.meowti.kr' http://127.0.0.1/`
5. 공개 확인: `curl -I https://dashboard.meowti.kr/`

## 3) 자주 발생하는 문제
- `502 Bad Gateway`
  - dashboard 컨테이너 기동 상태와 `frontdoor-net` 조인 여부를 먼저 확인합니다.
- `Could not resolve host`
  - Cloudflare DNS 레코드(`dashboard`)와 전파 상태를 확인합니다.
- 브라우저에서 예전 응답(`ok`)이 보임
  - 강력 새로고침 후 재확인하고, 필요 시 nginx reload를 수행합니다.

## 4) 배포/갱신
```bash
cd /srv/infra
docker compose -f compose/dashboard/docker-compose.yml up -d --build
```

## 5) 범위 안내
- 이 문서는 dashboard MVP(정적 온보딩 안내) 기준입니다.
- API 연동(`online/players/version/updatedAt`)은 후속 Story에서 추가합니다.
