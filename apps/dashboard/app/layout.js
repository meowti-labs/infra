export const metadata = {
  title: "Sunlit Dashboard",
  description: "Minecraft Ops + Dashboard MVP"
};

export default function RootLayout({ children }) {
  return (
    <html lang="ko">
      <body style={{ margin: 0, fontFamily: "-apple-system, BlinkMacSystemFont, Segoe UI, sans-serif", background: "#f4f8f6", color: "#163326" }}>
        {children}
      </body>
    </html>
  );
}
