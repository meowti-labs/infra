import "./globals.css";

export const metadata = {
  title: "Sunlit Dashboard",
  description: "Minecraft Ops + Dashboard MVP"
};

export default function RootLayout({ children }) {
  return (
    <html lang="ko">
      <body>{children}</body>
    </html>
  );
}
