# meowti-labs / infra

OCI VM `/srv` 운영 표준과 Minecraft Ops 제어면(control plane) 인프라 정의를 관리하는 레포입니다.

## 원칙
- Git에는 재현 가능한 정의만 저장합니다(설정, compose, nginx, 문서, 스크립트).
- 시크릿/런타임 데이터/월드/다운로드 산출물(zip 등)은 Git에 커밋하지 않습니다.
- PR은 Story 단위로 작게 유지하고, 각 PR에 수용 기준과 검증 절차를 포함합니다.

## 현재 포함 범위
- `compose/nginx/docker-compose.yml`: `dl.meowti.kr` 정적 다운로드용 nginx 스택
- `nginx/conf.d/dl.meowti.kr.conf`: 다운로드 전용 vhost
- `docs/architecture.md`: `/srv` 표준 및 도메인 라우팅 정책
- `docs/security.md`: 시크릿/노출 정책
- `docs/runbook.md`: 운영 점검/장애 대응 절차
- `.env.example`: 로컬/운영에서 참조 가능한 비민감 변수 템플릿

## Quickstart (Story #2)
1. 최신 파일 준비: `/srv/web/dl.meowti.kr/files/instance.zip`
2. nginx 기동:
   - `docker compose -f compose/nginx/docker-compose.yml up -d`
3. 로컬 검증:
   - `curl -I -H 'Host: dl.meowti.kr' http://127.0.0.1/instance.zip`
4. 외부 검증:
   - `curl -I https://dl.meowti.kr/instance.zip`

상세 절차는 `docs/runbook.md`를 따릅니다.
