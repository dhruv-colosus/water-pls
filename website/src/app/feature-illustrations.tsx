"use client";

import { useEffect, type ReactNode } from "react";
import {
  animate,
  motion,
  MotionConfig,
  useMotionValue,
  useReducedMotion,
  useTransform,
} from "motion/react";
import { Check, Coffee, Droplet, Moon, MousePointer2, Sun } from "lucide-react";
import GlassIcon from "@/components/glass-icon";
import { OrbitingCircles } from "@/components/ui/orbiting-circles";
import { Ripple } from "@/components/ui/ripple";
import styles from "./features.module.css";

const loop = { repeat: Infinity, ease: "easeInOut" } as const;

function Scene({ tone, children }: { tone: string; children: ReactNode }) {
  return (
    <MotionConfig reducedMotion="user">
      <div className={`${styles.visual} ${tone}`}>{children}</div>
    </MotionConfig>
  );
}

/** Notch expands, cursor logs a sip, notch tucks away. */
export function ReminderIllustration() {
  const cycle = { ...loop, duration: 6 };
  return (
    <Scene tone={styles.reminder}>
      <Ripple className={styles.ripple} mainCircleSize={90} numCircles={5} />
      <div className={styles.notchWrap}>
        <motion.div
          className={styles.notch}
          animate={{ width: [80, 236, 236, 80], height: [22, 82, 82, 22] }}
          transition={{ ...cycle, times: [0, 0.12, 0.8, 0.92] }}
        >
          <motion.div
            className={styles.notchBody}
            animate={{ opacity: [0, 0, 1, 1, 0, 0] }}
            transition={{ ...cycle, times: [0, 0.1, 0.18, 0.74, 0.8, 1] }}
          >
            <GlassIcon className={styles.notchGlass} />
            <span className={styles.bars}>
              <i />
              <i />
            </span>
            <motion.span
              className={styles.sipButton}
              animate={{ scale: [1, 1, 0.88, 1.08, 1] }}
              transition={{ ...cycle, times: [0, 0.47, 0.5, 0.56, 0.62] }}
            >
              <Check strokeWidth={3} />
            </motion.span>
          </motion.div>
        </motion.div>
        <motion.span
          className={styles.plusOne}
          animate={{ opacity: [0, 0, 1, 0], y: [0, 0, -16, -30] }}
          transition={{ ...cycle, times: [0, 0.5, 0.58, 0.72] }}
        >
          +250 ml
        </motion.span>
        <motion.span
          className={styles.cursor}
          animate={{
            x: [70, 70, 0, 0, 0, 40],
            y: [80, 80, 0, 0, 0, 60],
            opacity: [0, 0, 1, 1, 1, 0],
            scale: [1, 1, 1, 0.8, 1, 1],
          }}
          transition={{ ...cycle, times: [0, 0.2, 0.44, 0.5, 0.56, 0.72] }}
        >
          <MousePointer2 fill="currentColor" />
        </motion.span>
      </div>
    </Scene>
  );
}

/** Drops fall, the glass fills, then someone actually drinks it. */
export function ProgressIllustration() {
  const reduced = useReducedMotion();
  const level = useMotionValue(100);
  const ml = useTransform(level, [100, 46], [0, 750], { clamp: true });
  const label = useTransform(ml, (v) => `${Math.round(v / 10) * 10}`);

  useEffect(() => {
    if (reduced) return level.set(64);
    const controls = animate(level, [100, 100, 82, 82, 64, 64, 46, 46, 100], {
      ...loop,
      duration: 12,
      times: [0, 0.15, 0.2, 0.4, 0.45, 0.65, 0.7, 0.9, 1],
    });
    return () => controls.stop();
  }, [level, reduced]);

  return (
    <Scene tone={styles.progress}>
      <motion.span
        className={styles.drop}
        animate={{ y: [0, 78], opacity: [0, 1, 1, 0] }}
        transition={{ duration: 1.8, repeat: Infinity, repeatDelay: 1.2, ease: "easeIn" }}
      >
        <Droplet fill="currentColor" strokeWidth={0} />
      </motion.span>
      <svg className={styles.bigGlass} viewBox="0 0 100 130" aria-hidden="true">
        <defs>
          <clipPath id="glass-inside">
            <path d="M17 10h66l-7.6 103a7 7 0 0 1-7 6.5H31.6a7 7 0 0 1-7-6.5Z" />
          </clipPath>
          <linearGradient id="water" x1="0" y1="0" x2="0" y2="1">
            <stop offset="0" stopColor="#7fe0ff" />
            <stop offset="1" stopColor="#2aa9da" />
          </linearGradient>
        </defs>
        <g clipPath="url(#glass-inside)">
          <motion.g style={{ y: level }}>
            <g className={styles.wave}>
              <path
                d="M0 6c12-8 23 8 35 0s23 8 35 0 23 8 35 0 23 8 35 0 23 8 35 0V140H0Z"
                fill="url(#water)"
              />
            </g>
          </motion.g>
        </g>
        <path
          d="M14 6h72l-8 108a10 10 0 0 1-10 9H32a10 10 0 0 1-10-9Z"
          fill="#ffffff30"
          stroke="#1d2b33"
          strokeWidth="3.5"
          strokeLinejoin="round"
        />
        <path d="M26 20l5 74" stroke="#fff" strokeWidth="4" strokeLinecap="round" opacity=".7" />
      </svg>
      <span className={styles.mlChip}>
        <Droplet fill="currentColor" strokeWidth={0} />
        <motion.span>{label}</motion.span>
        <small>ml</small>
      </span>
    </Scene>
  );
}

/** Your day orbits around a gentle clock. */
export function PaceIllustration() {
  return (
    <Scene tone={styles.pace}>
      <div className={styles.orbit}>
        <OrbitingCircles radius={88} duration={28} iconSize={34}>
          <span className={styles.planet}><Sun /></span>
          <span className={styles.planet}><Coffee /></span>
          <span className={styles.planet}><Moon /></span>
        </OrbitingCircles>
        <OrbitingCircles radius={50} duration={16} iconSize={24} reverse>
          <span className={`${styles.planet} ${styles.water}`}><Droplet fill="currentColor" strokeWidth={0} /></span>
          <span className={`${styles.planet} ${styles.water}`}><Droplet fill="currentColor" strokeWidth={0} /></span>
        </OrbitingCircles>
        <span className={styles.clock}>
          <i className={styles.hourHand} />
          <i className={styles.minuteHand} />
        </span>
      </div>
    </Scene>
  );
}
