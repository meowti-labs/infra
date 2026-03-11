# Architecture

## 1) /srv 운영 표준

| Path | 목적 | Git 커밋 여부 |
|---|---|---|
| `/srv/infra` | 인프라 정의(compose/nginx/scripts/docs) | 허용 |
| `/srv/mc/sunlit-valley` | Minecraft 런타임(world/logs/config/runtime) | 금지 |
| `/srv/shared/downloads` | 외부 반입 파일(예: 업로드된 zip) | 금지 |
| `/srv/secrets` | 시크릿(.env, key, token) | 금지 |
| `/srv/web/dl.meowti.kr/files` | 다운로드 배포물 루트(instance.zip, instances/, meta/) | 금지 |
| `/srv/web` 하위 앱 런타임 | dashboard/api 런타임 산출물 | 금지 |

기본 원칙:
- 런타임 데이터는 `/srv`에 두고, 레포에는 운영 정의만 유지합니다.
- `.env.example`만 커밋하고 실제 값은 `/srv/secrets`에서 주입합니다.
- 대용량 배포물(zip, world)은 Git이 아니라 파일 경로/배포 스크립트로 운영합니다.

## 2) Front Door / 도메인 정책

현재(PR#1) 범위:
- `dl.meowti.kr` -> docker nginx 정적 파일 서빙

향후 고정 라우팅 정책:
- `dashboard.meowti.kr` -> Next.js
- `api.meowti.kr` -> Spring Boot (Kotlin)

CORS 복잡도 회피 옵션(권장):
- `dashboard.meowti.kr/api/*`를 nginx에서 `api` 업스트림으로 프록시
- 브라우저 입장에서 동일 origin 경로(`/api`)를 사용하도록 고정

## 3) 운영 표준 체크포인트

- nginx 컨테이너는 `restart: unless-stopped`를 사용해 재부팅 복구를 보장합니다.
- 다운로드 루트(`/srv/web/dl.meowti.kr/files`)는 컨테이너에 read-only로 마운트합니다.
- 점검 엔드포인트는 `GET /healthz`를 사용합니다.
