# Security

## 1) 시크릿 관리
- Git에는 `.env.example`만 커밋합니다.
- 실제 시크릿은 `/srv/shared/secrets`에 저장하고 파일 권한을 `640` 이하로 제한합니다.
- SSH key, TLS key, 토큰은 절대 레포에 추가하지 않습니다.

## 2) Git 커밋 금지 대상
- Minecraft 런타임 데이터(`world`, `logs`, `data`)
- 다운로드 산출물(`*.zip`, `instances/`, `meta/` 원본 파일)
- 인증서/키(`*.pem`, `*.key`, `*.crt`)

## 3) 노출 최소화
- 외부 노출은 프론트 nginx 포트로 제한합니다.
- RCON은 인터넷에 publish하지 않습니다(내부 네트워크 또는 로컬 관리 전용).
- 정적 파일 루트는 nginx에 read-only로 마운트합니다.

## 4) 배포 전 보안 체크
- `.env` 파일이 staging 대상에 포함되지 않았는지 확인
- `git status --short`로 민감 파일 추가 여부 확인
- `docker compose config`로 예상치 못한 포트 publish 확인
