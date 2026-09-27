"use client";

import { useEffect, useRef, useState, type ReactNode } from "react";
import styles from "./site-header.module.css";

export default function SiteHeader({ children }: { children: ReactNode }) {
  const marker = useRef<HTMLDivElement>(null);
  const [compact, setCompact] = useState(false);

  useEffect(() => {
    const observer = new IntersectionObserver(([entry]) => {
      setCompact(!entry.isIntersecting);
    });
    if (marker.current) observer.observe(marker.current);
    return () => observer.disconnect();
  }, []);

  return (
    <>
      <div ref={marker} className={styles.marker} aria-hidden="true" />
      <div className={styles.space}>
        <header className={styles.header} data-compact={compact}>
          {children}
        </header>
      </div>
    </>
  );
}
