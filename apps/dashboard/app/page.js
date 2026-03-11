const quickLinks = [
  { label: "Instance 다운로드", href: "https://dl.meowti.kr/instance.zip", helper: "Prism Launcher에 바로 가져오기" },
  { label: "온보딩 가이드", href: "https://github.com/meowti-labs/infra/blob/main/docs/dashboard-guide.md", helper: "10초 가입 동선 + 운영 체크" },
  { label: "운영 문서", href: "https://github.com/meowti-labs/infra/tree/main/docs", helper: "runbook / security / architecture" }
];

const checks = [
  "Prism Launcher에서 instance.zip을 import합니다.",
  "서버 주소 `mc.meowti.kr`를 복사해 멀티플레이에 등록합니다.",
  "디스코드에서 화이트리스트 승인 후 접속합니다."
];

export default function Page() {
  return (
    <main className="dashboard-shell">
      <section className="hero-panel">
        <p className="eyebrow">Minecraft Ops + Control Plane</p>
        <h1>Sunlit Valley Dashboard</h1>
        <p className="hero-copy">비전공자 기준 10초 온보딩을 목표로, 다운로드와 운영 점검 동선을 한 페이지로 정리했습니다.</p>
        <div className="server-pill">
          서버 주소 <strong>mc.meowti.kr</strong>
        </div>
      </section>

      <section className="grid two-up">
        {quickLinks.map((item) => (
          <a key={item.label} className="action-card" href={item.href} target="_blank" rel="noreferrer">
            <span className="action-title">{item.label}</span>
            <span className="action-helper">{item.helper}</span>
          </a>
        ))}
      </section>

      <section className="grid two-up">
        <article className="info-card">
          <h2>빠른 체크리스트</h2>
          <ol>
            {checks.map((item) => (
              <li key={item}>{item}</li>
            ))}
          </ol>
        </article>

        <article className="info-card">
          <h2>운영 상태</h2>
          <ul>
            <li>다운로드 도메인: <code>dl.meowti.kr</code></li>
            <li>대시보드 도메인: <code>dashboard.meowti.kr</code></li>
            <li>API 도메인: <code>api.meowti.kr</code></li>
          </ul>
          <p className="muted">실시간 상태 API 연결(online/players/version/updatedAt)은 다음 Story에서 연동합니다.</p>
        </article>
      </section>
    </main>
  );
}
