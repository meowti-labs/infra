# Runbook

## 1) dl.meowti.kr 정적 배포 점검 (Story #2)

사전 조건:
- 파일 존재: `/srv/web/dl.meowti.kr/files/instances/instance.zip`
- nginx 설정 파일 존재: `/srv/infra/nginx/conf.d/dl.meowti.kr.conf`

배포/재기동:
```bash
cd /srv/infra
docker compose -f compose/nginx/docker-compose.yml up -d
```

1분 내 검증:
```bash
cd /srv/infra
docker compose -f compose/nginx/docker-compose.yml ps
curl -I -H 'Host: dl.meowti.kr' http://127.0.0.1/healthz
curl -I -H 'Host: dl.meowti.kr' http://127.0.0.1/instance.zip
curl -I https://dl.meowti.kr/instance.zip
ls -l /srv/web/dl.meowti.kr/files/instances/instance.zip
```

기대 결과:
- `healthz`: `200 OK`
- `instance.zip`(로컬 Host 헤더): `200 OK`
- `https://dl.meowti.kr/instance.zip`: `200 OK`
- 파일 경로 확인 시 실제 파일이 존재

## 2) 트러블슈팅

404 발생 시:
- 파일 존재 확인: `ls -l /srv/web/dl.meowti.kr/files/instances/instance.zip`
- vhost 반영 확인: `docker exec infra-nginx nginx -T | grep dl.meowti.kr -n`

403/권한 문제 시:
- 권한 확인: `namei -l /srv/web/dl.meowti.kr/files/instances/instance.zip`
- 소유권/권한 조정: `sudo chown -R ubuntu:ubuntu /srv/web/dl.meowti.kr`

컨테이너 비정상 시:
- 상태 확인: `docker compose -f compose/nginx/docker-compose.yml ps`
- 로그 확인: `docker logs --tail=200 infra-nginx`
- 설정 문법: `docker exec infra-nginx nginx -t`

## 3) 운영자 확인 절차 (배포 직후)
1. compose 상태가 `Up`인지 확인한다.
2. `/healthz`가 200인지 확인한다.
3. `/instance.zip`이 로컬 Host 헤더 기준 200인지 확인한다.
4. 외부 HTTPS URL이 200인지 확인한다.
5. `/srv/web/dl.meowti.kr/files/instances/instance.zip` 존재를 확인한다.
6. 실패 시 로그 200줄을 확보하고 원인을 runbook 트러블슈팅 순서대로 분류한다.
