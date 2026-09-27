import type { Metadata } from "next";
import { Figtree } from "next/font/google";
import "./globals.css";

const figtree = Figtree({
  subsets: ["latin"],
  display: "swap",
  variable: "--font-figtree",
});

export const metadata: Metadata = {
  title: "Water, pls — Water reminder app for Mac",
  description:
    "A gentle water reminder for macOS. Get a nudge from your MacBook notch, log a drink in one click, and track your daily progress locally.",
  applicationName: "Water, pls",
  openGraph: {
    title: "Water, pls — Water reminder app for Mac",
    description:
      "A little nudge to drink water, right from your MacBook notch.",
    type: "website",
  },
};

export default function RootLayout({ children }: LayoutProps<"/">) {
  return (
    <html lang="en" className={figtree.variable}>
      <body>{children}</body>
    </html>
  );
}
