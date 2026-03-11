# Runbook

## 0) nginx 자동 기동 기준 점검 (Story #15)

기본 검증(권장):
```bash
cd /srv/infra
./scripts/check-nginx-autostart.sh
```

기대 결과:
- restart policy: `unless-stopped`
- 컨테이너 상태: `running` + `healthy`
- `GET /healthz`(Host: dl.meowti.kr): `200 OK`

재부팅 검증 절차(운영 점검 시):
```bash
sudo reboot
# SSH 재접속 후
cd /srv/infra
docker compose -f compose/nginx/docker-compose.yml ps
./scripts/check-nginx-autostart.sh
```

## 1) dl 정적 서비스 점검 (Story #2, #16)

자동 검증(권장):
```bash
cd /srv/infra
./scripts/check-dl-static.sh
```

수동 보조 검증:

사전 조건:
- nginx 설정 파일 존재: `/srv/infra/nginx/conf.d/dl.meowti.kr.conf`
- 대상 파일 존재(최소): `/srv/web/dl.meowti.kr/files/instance.zip`

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

## 3) HTTPS/Redirect 검증 (Story #4)

정책(역할 분리):
- `http -> https` 리다이렉트 책임은 Cloudflare Edge가 가진다.
- Origin nginx는 정적 파일 서빙만 담당하고, TLS 종단/리다이렉트 정책은 Cloudflare에서 운영한다.

검증 커맨드:
```bash
curl -I http://dl.meowti.kr/instance.zip
curl -I https://dl.meowti.kr/instance.zip
```

기대 결과:
- HTTP 응답은 `301/302/308` + `Location: https://dl.meowti.kr/...`
- HTTPS 응답은 `200 OK` (브라우저 인증서 경고 없음)
- HSTS를 쓰기로 결정했다면 `strict-transport-security` 헤더가 존재

실패 시 조치:
- HTTP가 `200`이면 Cloudflare Redirect Rule 또는 Always Use HTTPS 설정을 재확인
- 인증서 경고가 있으면 Cloudflare SSL/TLS 모드와 인증서 상태를 재확인
- 원인 확인 후 결과를 본 문서에 날짜와 함께 갱신

## 4) 배포 성공 1분 판정 (Story #5)

### 4-1. 절차 (업로드 -> 스크립트 실행 -> 확인)
```bash
# 1) 업로드 파일 준비
ls -l /srv/shared/downloads/instance.zip

# 2) 배포 실행
cd /srv/infra
./scripts/deploy-instance.sh /srv/shared/downloads/instance.zip

# 3) 1분 검증
curl -I http://dl.meowti.kr/instance.zip
curl -I https://dl.meowti.kr/instance.zip
curl -I https://dl.meowti.kr/instance.sha256
ls -l /srv/web/dl.meowti.kr/files/instance.zip
ls -l /srv/web/dl.meowti.kr/files/instances | tail -n 5
sha256sum "$(readlink -f /srv/web/dl.meowti.kr/files/instance.zip)"
cat /srv/web/dl.meowti.kr/files/instance.sha256
```

### 4-2. 기대 결과
- HTTP -> `301/302/308` 리다이렉트
- HTTPS `instance.zip` -> `200 OK`
- HTTPS `instance.sha256` -> `200 OK`
- latest 링크(`/instance.zip`)가 최신 버전 파일을 가리킴
- `instances/`에 신규 버전 파일 존재
- `sha256sum` 결과와 `instance.sha256` 해시가 동일

### 4-3. 실패 체크포인트(최소)
- 404: `readlink -f /srv/web/dl.meowti.kr/files/instance.zip` 경로와 파일 존재 확인
- 403/권한: `namei -l /srv/web/dl.meowti.kr/files` 후 소유권/권한 점검
- 리로드 누락: `docker exec infra-nginx nginx -t && docker exec infra-nginx nginx -s reload`
- 무결성 실패: `sha256sum` 결과와 `cat instance.sha256` 비교 후 불일치 시 재배포

## 5) 트러블슈팅

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

## 6) 운영자 확인 절차 (배포 직후)
1. `deploy-instance.sh` 출력에서 version zip / latest 링크 경로를 확인한다.
2. `instance.zip` 링크가 최신 버전 파일을 가리키는지 확인한다.
3. `instance.sha256` 링크가 최신 sha 파일을 가리키는지 확인한다.
4. `sha256sum`과 `cat instance.sha256` 값이 일치하는지 확인한다.
5. `curl -I http://dl.meowti.kr/instance.zip`가 301/302/308인지 확인한다.
6. `curl -I https://dl.meowti.kr/instance.zip`가 200인지 확인한다.
