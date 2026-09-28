"use client";

import { useState } from "react";
import GlassIcon from "@/components/glass-icon";

export default function NotchDemo() {
  const [amount, setAmount] = useState(250);
  const [total, setTotal] = useState(750);
  const [state, setState] = useState<"ready" | "logged" | "later">("ready");
  return (
    <div className="demo-shell">
      <div className="desktop-preview" aria-label="Interactive Mac water reminder preview">
        <div className="desktop-menubar" aria-hidden="true">
          <div className="menu-left">
            <svg viewBox="0 0 24 24" fill="currentColor"><path d="M17.1 12.7c0-2 1.6-3 1.7-3.1-1-1.5-2.6-1.7-3.2-1.7-1.4-.2-2.6.8-3.3.8-.7 0-1.7-.8-2.8-.7-1.5 0-2.8.8-3.6 2.1-1.5 2.6-.4 6.5 1.1 8.6.7 1 1.5 2.1 2.6 2 1.1 0 1.5-.7 2.9-.7 1.3 0 1.7.7 2.9.7s1.9-1 2.6-2c.8-1.2 1.2-2.4 1.2-2.5-.1 0-2.1-.8-2.1-3.5ZM14.9 6.5c.6-.8 1.1-1.9 1-3-.9 0-2 .6-2.7 1.4-.6.7-1.2 1.8-1 2.9 1 .1 2.1-.5 2.7-1.3Z" /></svg>
            <b>Finder</b>
            <span className="menu-extras">File</span><span className="menu-extras">Edit</span><span className="menu-extras">View</span><span className="menu-extras">Go</span><span className="menu-extras">Window</span><span className="menu-extras">Help</span>
          </div>
          <div className="menu-right">
            <svg className="menu-extras" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="1.5"><rect x="2" y="7" width="17" height="10" rx="2"/><path d="M21 10v4"/><path d="M5 10h11v4H5Z" fill="currentColor" stroke="none"/></svg>
            <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="1.8" strokeLinecap="round"><path d="M3 9a14 14 0 0 1 18 0M6 12a9 9 0 0 1 12 0M9 15a4 4 0 0 1 6 0"/><circle cx="12" cy="18" r="1" fill="currentColor" stroke="none"/></svg>
            <svg className="menu-extras" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="1.8"><circle cx="10" cy="10" r="5"/><path d="m14 14 5 5"/></svg>
            <span>Mon 9:41 AM</span>
          </div>
        </div>
        <div className="notch-stem" />
        <div className="notch-panel">
          <div className="notch-content">
          <div className="notch-heading">
            <GlassIcon />
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
              Try another sip
            </button>
          )}
          </div>
        </div>
      </div>
    </div>
  );
}
