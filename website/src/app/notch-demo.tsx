"use client";

import { useState } from "react";

export default function NotchDemo() {
  const [amount, setAmount] = useState(250);
  const [total, setTotal] = useState(750);
  const [state, setState] = useState<"ready" | "logged" | "later">("ready");
  return (
    <div className="demo-shell">
      <div className="demo-topline">
        <span>
          <span className="live-dot" /> A little nudge, right on cue
        </span>
        <span>
          TRY IT BELOW <span aria-hidden="true">↘</span>
        </span>
      </div>
      <div className="desktop-preview">
        <div className="desktop-menubar" aria-hidden="true">
          <span>
            ● &nbsp; Finder{" "}
            <span className="menu-extras">
              &nbsp; File &nbsp; Edit &nbsp; View
            </span>
          </span>
          <span>◒ &nbsp; ⌁ &nbsp; Mon 9:41 AM</span>
        </div>
        <div className="notch-stem" />
        <div className="notch-panel">
          <div className="notch-heading">
            <svg viewBox="0 0 40 52" fill="none" aria-hidden="true">
              <path
                d="M6 4h28l-3 41a4 4 0 0 1-4 4H13a4 4 0 0 1-4-4L6 4Z"
                stroke="#dbe6ed"
                strokeWidth="2.6"
              />
              <path
                d="M8 21c8-6 15 7 24 1l-2 21a3 3 0 0 1-3 3H13a3 3 0 0 1-3-3Z"
                fill="#46c5ee"
                fillOpacity=".28"
              />
              <path
                d="M8 21c8-6 15 7 24 1"
                stroke="#55d7ff"
                strokeWidth="2.5"
              />
            </svg>
            <div aria-live="polite">
              <strong>
                {state === "logged"
                  ? "A little sip. A little better."
                  : state === "later"
                    ? "All good. Take your time."
                    : "Water you waiting for?"}
              </strong>
              <span>
                {state === "later"
                  ? "We’ll catch you in a little while."
                  : `${total.toLocaleString("en-US")} ml logged today`}
              </span>
            </div>
            <span className="notch-tiny-drop" aria-hidden="true">
              ✧
            </span>
          </div>
          {state === "ready" ? (
            <>
              <div className="notch-actions">
                <button
                  onClick={() => {
                    setTotal((t) => t + amount);
                    setState("logged");
                  }}
                  className="drink-button"
                >
                  ✓ &nbsp; Drank {amount} ml
                </button>
                <button
                  className="later-button"
                  onClick={() => setState("later")}
                >
                  Later
                </button>
              </div>
              <div className="amount-options" aria-label="Glass size">
                {[100, 250, 500].map((value) => (
                  <button
                    key={value}
                    aria-pressed={amount === value}
                    onClick={() => setAmount(value)}
                  >
                    {value} ml
                  </button>
                ))}
                <span>One glass at a time.</span>
              </div>
            </>
          ) : (
            <button className="demo-reset" onClick={() => setState("ready")}>
              Try another sip <span aria-hidden="true">↻</span>
            </button>
          )}
        </div>
        <div className="desktop-message" aria-hidden="true">
          <span>A MOMENT FOR YOU</span>
          <p>
            Good work.
            <br />
            Don’t forget you.
          </p>
        </div>
        <div className="demo-label">
          <span className="label-dot" /> Interactive preview <span>·</span> Give
          the notch a try
        </div>
      </div>
      <div className="demo-bottomline">
        <span>A small addition to your Mac. A little more care for you.</span>
        <a href="#features">
          Meet Water, pls <span aria-hidden="true">↓</span>
        </a>
      </div>
    </div>
  );
}
