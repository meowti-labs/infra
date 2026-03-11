const cardStyle = {
  background: "#ffffff",
  border: "1px solid #d7e3dc",
  borderRadius: "14px",
  padding: "18px",
  boxShadow: "0 8px 24px rgba(8, 34, 22, 0.06)"
};

export default function Page() {
  return (
    <main style={{ maxWidth: 880, margin: "0 auto", padding: "36px 20px 56px" }}>
      <h1 style={{ marginBottom: 8 }}>Sunlit Valley Dashboard (MVP)</h1>
      <p style={{ marginTop: 0, color: "#335847" }}>
        10초 온보딩을 위한 최소 동선: 다운로드 → 문서 확인 → 디스코드 입장
      </p>

      <section style={{ ...cardStyle, marginTop: 18 }}>
        <h2 style={{ marginTop: 0 }}>빠른 시작</h2>
        <ol>
          <li>
            Prism 인스턴스 다운로드: <a href="https://dl.meowti.kr/instance.zip">instance.zip</a>
          </li>
          <li>
            운영/점검 문서 확인: <a href="https://github.com/meowti-labs/infra/tree/main/docs">docs</a>
          </li>
          <li>디스코드 합류 후 화이트리스트 신청</li>
        </ol>
      </section>

      <section style={{ ...cardStyle, marginTop: 14 }}>
        <h2 style={{ marginTop: 0 }}>서버 정보</h2>
        <p style={{ marginBottom: 8 }}>서버 주소: <code>mc.meowti.kr</code></p>
        <p style={{ margin: 0, color: "#335847" }}>상태 API/인증은 다음 스토리에서 연동합니다.</p>
      </section>
    </main>
  );
}
