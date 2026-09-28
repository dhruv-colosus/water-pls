import Image from "next/image";
import { LightRays } from "@/components/ui/light-rays";
import Link from "next/link";
import Features from "./features";
import NotchDemo from "./notch-demo";
import SiteHeader from "./site-header";
import release from "./release.json";

const github = "https://github.com/dhruv-colosus/water-pls";
const download = release.download;

function Apple() {
  return (
    <svg viewBox="0 0 24 24" fill="currentColor" aria-hidden="true">
      <path d="M17.1 12.7c0-2 1.6-3 1.7-3.1-1-1.5-2.6-1.7-3.2-1.7-1.4-.2-2.6.8-3.3.8-.7 0-1.7-.8-2.8-.7-1.5 0-2.8.8-3.6 2.1-1.5 2.6-.4 6.5 1.1 8.6.7 1 1.5 2.1 2.6 2 1.1 0 1.5-.7 2.9-.7 1.3 0 1.7.7 2.9.7s1.9-1 2.6-2c.8-1.2 1.2-2.4 1.2-2.5-.1 0-2.1-.8-2.1-3.5ZM14.9 6.5c.6-.8 1.1-1.9 1-3-.9 0-2 .6-2.7 1.4-.6.7-1.2 1.8-1 2.9 1 .1 2.1-.5 2.7-1.3Z" />
    </svg>
  );
}

function DownloadButton() {
  return (
    <a className="button primary" href={download} download>
      <Apple /> Download for Mac <span className="button-divider" /> Free
    </a>
  );
}

export default function Home() {
  return (
    <>
      <div className="top-light-rays" aria-hidden="true">
        <LightRays count={5} color="rgba(90, 190, 225, 0.22)" blur={24} speed={18} length="620px" />
      </div>
      <a className="skip-link" href="#main">
        Skip to content
      </a>
      <SiteHeader>
        <Link className="brand" href="/" aria-label="Water, pls home" target="_blank" rel="noopener noreferrer">
          <Image src="/icon.png" width={28} height={28} alt="" />
          <span>Water, pls<span className="brand-dot">.</span></span>
        </Link>
        <nav aria-label="Main navigation">
          <a href="#features" target="_blank" rel="noopener noreferrer">Features</a>
          <a href={github} target="_blank" rel="noopener noreferrer">GitHub</a>
        </nav>
        <DownloadButton />
      </SiteHeader>
      <main id="main">
        <section className="hero" aria-labelledby="hero-title">
          <div className="hero-copy wrap">
            <h1 id="hero-title">
              Your daily reminder
              <br />
              to drink water.
            </h1>
            <p className="intro">
              A gentle nudge from your MacBook notch.
              <br className="desktop-break" /> One click to log a glass. Right back to your day.
            </p>
            <div className="actions">
              <DownloadButton />
              <a className="button secondary" href={github} target="_blank" rel="noopener noreferrer">
                <svg
                  viewBox="0 0 24 24"
                  fill="none"
                  stroke="currentColor"
                  strokeWidth="1.6"
                  aria-hidden="true"
                >
                  <path d="m12 3 2.8 5.7 6.3.9-4.6 4.5 1.1 6.3-5.6-3-5.6 3 1.1-6.3L3 9.6l6.2-.9Z" />
                </svg>
                Star on GitHub
              </a>
            </div>
            <p className="platform-note">
              macOS 14+ <span>·</span> Apple silicon <span>·</span> No account
              needed
            </p>
          </div>
          <div className="demo-stage wrap">
            <NotchDemo />
          </div>
          <div className="trust-strip wrap">
            <span>
              <span aria-hidden="true">⌘</span> Made for your Mac
            </span>
            <span>
              <span aria-hidden="true">◉</span> Your data stays yours
            </span>
            <span>
              <span aria-hidden="true">♡</span> Free. Just because.
            </span>
          </div>
        </section>
        <Features />
        <section className="closing wrap" aria-labelledby="closing-title">
          <Image src="/icon.png" width={52} height={52} alt="" />
          <h2 id="closing-title">
            Your next good habit
            <br />
            starts with a sip.
          </h2>
          <p>Let your Mac remember. You just bring the water.</p>
          <a className="button primary" href={download} download>
            <Apple /> Download for Mac
          </a>
          <span className="closing-note">Free to use. Open for everyone.</span>
        </section>
      </main>
      <footer className="site-footer wrap">
        <Link className="brand" href="/" target="_blank" rel="noopener noreferrer">
          <Image src="/icon.png" width={22} height={22} alt="" />
          Water, pls.
        </Link>
        <span>A little care, built into your day.</span>
        <a href={github} target="_blank" rel="noopener noreferrer">
          Made in the open
        </a>
      </footer>
    </>
  );
}
