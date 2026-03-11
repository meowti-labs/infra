const quickLinks = [
  { label: "Instance 다운로드", href: "https://dl.meowti.kr/instance.zip", helper: "Prism Launcher에 바로 가져오기" },
  { label: "온보딩 가이드", href: "https://github.com/meowti-labs/infra/blob/main/docs/dashboard-guide.md", helper: "10초 가입 동선 + 운영 체크" },
  { label: "운영 문서", href: "https://github.com/meowti-labs/infra/tree/main/docs", helper: "runbook / security / architecture" }
];

const steps = [
  {
    title: "Instance 다운로드",
    text: "instance.zip을 내려받아 Prism Launcher에서 import 준비를 합니다."
  },
  {
    title: "Prism Launcher import",
    text: "Add Instance -> Import from zip으로 모드팩 인스턴스를 생성합니다."
  },
  {
    title: "서버 접속",
    text: "서버 주소 mc.meowti.kr 등록 후, 디스코드 화이트리스트 승인 뒤 접속합니다."
  }
];

const faqs = [
  {
    q: "Java 버전은 무엇을 써야 하나요?",
    a: "운영 표준은 Java 21 기준입니다. Launcher 자동 설치를 권장합니다."
  },
  {
    q: "RAM은 얼마나 할당해야 하나요?",
    a: "최소 4GB, 권장 6GB 이상입니다. 플레이 스타일에 따라 추가 조정하세요."
  },
  {
    q: "화면에 예전 ok 응답이 보이면 어떻게 하나요?",
    a: "강력 새로고침(Cmd+Shift+R 또는 Ctrl+F5) 후 재확인하고, 필요 시 nginx reload를 수행합니다."
  }
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

      <section className="step-wrap">
        <h2>3단계 온보딩</h2>
        <div className="step-grid">
          {steps.map((step, idx) => (
            <article key={step.title} className="step-card">
              <span className="step-number">{idx + 1}</span>
              <h3>{step.title}</h3>
              <p>{step.text}</p>
            </article>
          ))}
        </div>
      </section>

      <section className="grid two-up">
        <article className="info-card">
          <h2>운영 상태</h2>
          <ul>
            <li>다운로드 도메인: <code>dl.meowti.kr</code></li>
            <li>대시보드 도메인: <code>dashboard.meowti.kr</code></li>
            <li>API 도메인: <code>api.meowti.kr</code></li>
          </ul>
          <p className="muted">실시간 상태 API 연결(online/players/version/updatedAt)은 다음 Story에서 연동합니다.</p>
        </article>

        <article className="info-card">
          <h2>자주 묻는 질문</h2>
          <div className="faq-list">
            {faqs.map((item) => (
              <details key={item.q} className="faq-item">
                <summary>{item.q}</summary>
                <p>{item.a}</p>
              </details>
            ))}
          </div>
        </article>
      </section>
    </main>
  );
}
