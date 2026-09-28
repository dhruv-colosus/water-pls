"use client";

import type { AnchorHTMLAttributes, MouseEvent } from "react";

type ScrollLinkProps = Omit<AnchorHTMLAttributes<HTMLAnchorElement>, "href"> & {
  /** Element id to scroll to, or "top" for the top of the page. */
  to: string;
};

/**
 * In-page link that scrolls smoothly without leaving `#hash` in the URL.
 * Keeps a real href so no-JS, middle-click and "copy link" still work.
 */
export default function ScrollLink({ to, onClick, children, ...props }: ScrollLinkProps) {
  const href = to === "top" ? "/" : `#${to}`;

  function handleClick(event: MouseEvent<HTMLAnchorElement>) {
    onClick?.(event);
    // Let modified clicks (new tab, etc.) behave natively.
    if (event.defaultPrevented || event.metaKey || event.ctrlKey || event.shiftKey || event.button !== 0) return;
    const target = to === "top" ? null : document.getElementById(to);
    if (to !== "top" && !target) return;
    event.preventDefault();
    // No explicit `behavior`: inherits CSS scroll-behavior, which respects reduced motion.
    if (target) target.scrollIntoView();
    else window.scrollTo({ top: 0 });
    if (window.location.hash) history.replaceState(null, "", window.location.pathname);
  }

  return (
    <a href={href} onClick={handleClick} {...props}>
      {children}
    </a>
  );
}
