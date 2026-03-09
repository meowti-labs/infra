# Runbook

## 1) dl 정적 서비스 점검 (Story #2)

사전 조건:
- nginx 설정 파일 존재: `/srv/infra/nginx/conf.d/dl.meowti.kr.conf`
- 대상 파일 존재(최소): `/srv/web/dl.meowti.kr/files/instances/instance.zip`

점검 커맨드:
```bash
cd /srv/infra
docker compose -f compose/nginx/docker-compose.yml ps
curl -I -H 'Host: dl.meowti.kr' http://127.0.0.1/healthz
curl -I -H 'Host: dl.meowti.kr' http://127.0.0.1/instance.zip
curl -I https://dl.meowti.kr/instance.zip
```

기대 결과:
- `/healthz` -> `200 OK`
- `/instance.zip`(로컬 Host 헤더) -> `200 OK`
- `https://dl.meowti.kr/instance.zip` -> `200 OK`

## 2) dl 배포 (Story #3)

업로드된 zip을 버전 파일로 보관하고 latest 링크를 교체:
- `/srv/shared/downloads/instance.zip`는 업로드 원본(입력) 경로입니다.
- `/srv/web/dl.meowti.kr/files/instances/...`는 스크립트가 생성/갱신하는 배포 결과(서빙) 경로입니다.
```bash
cd /srv/infra
./scripts/deploy-instance.sh /srv/shared/downloads/instance.zip
```

배포 직후 검증(1분 내):
```bash
ls -l /srv/web/dl.meowti.kr/files/instance.zip
ls -l /srv/web/dl.meowti.kr/files/instances | tail -n 5
ls -l /srv/web/dl.meowti.kr/files/instance.sha256
cat /srv/web/dl.meowti.kr/files/instance.sha256
sha256sum "$(readlink -f /srv/web/dl.meowti.kr/files/instance.zip)"
curl -I https://dl.meowti.kr/instance.zip
```

기대 결과:
- `instance-YYYYMMDD-HHMM(.n).zip` 형태 버전 파일이 `instances/`에 추가
- `/srv/web/dl.meowti.kr/files/instance.zip`이 최신 버전 파일을 가리킴
- `/srv/web/dl.meowti.kr/files/instance.sha256`이 최신 sha 파일을 가리킴
- `cat instance.sha256`의 해시와 `sha256sum` 결과가 동일

## 3) 트러블슈팅

`ERR: input zip not found`:
- 입력 경로 확인: `ls -l /srv/shared/downloads`

`ERR: directory is not writable`:
- 권한 확인: `namei -l /srv/web/dl.meowti.kr/files`
- 소유권 조정: `sudo chown -R ubuntu:ubuntu /srv/web/dl.meowti.kr`

404/예상과 다른 파일 다운로드:
- 링크 확인: `readlink -f /srv/web/dl.meowti.kr/files/instance.zip`
- nginx 반영 확인: `docker exec infra-nginx nginx -T | grep -n "instance.zip"`

컨테이너 이상:
- `docker compose -f compose/nginx/docker-compose.yml ps`
- `docker logs --tail=200 infra-nginx`
- `docker exec infra-nginx nginx -t`

## 4) 운영자 확인 절차 (배포 직후)
1. `deploy-instance.sh` 출력에서 version zip / latest 링크 경로를 확인한다.
2. `instance.zip` 링크가 최신 버전 파일을 가리키는지 확인한다.
3. `instance.sha256` 링크가 최신 sha 파일을 가리키는지 확인한다.
4. `sha256sum`과 `cat instance.sha256` 값이 일치하는지 확인한다.
5. 외부 URL `https://dl.meowti.kr/instance.zip`이 200인지 확인한다.
6. 문제 시 트러블슈팅 섹션 순서대로 원인을 분류한다.
