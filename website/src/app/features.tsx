import type { ComponentType } from "react";
import { GlowingEffect } from "@/components/ui/glowing-effect";
import {
  PaceIllustration,
  ProgressIllustration,
  ReminderIllustration,
} from "./feature-illustrations";
import styles from "./features.module.css";

type Feature = {
  title: string;
  body: string;
  Illustration: ComponentType;
};

const features: Feature[] = [
  {
    title: "Stay in your flow",
    body: "A gentle reminder slides out of your notch. Take a sip, log it, carry on.",
    Illustration: ReminderIllustration,
  },
  {
    title: "Make every glass count",
    body: "Log a drink in one click and watch your day fill up, glass by glass.",
    Illustration: ProgressIllustration,
  },
  {
    title: "On your time",
    body: "Set your own pace and goal. Reminders rest when you’re away or done.",
    Illustration: PaceIllustration,
  },
];

export default function Features() {
  return (
    <section className={styles.features} id="features" aria-labelledby="features-title">
      <p className={styles.eyebrow}>LESS FRICTION. MORE WATER.</p>
      <h2 id="features-title" className={styles.title}>
        A little reminder.
        <br />A good habit in the making.
      </h2>
      <p className={styles.intro}>
        Thoughtfully small. Quietly helpful. Right where you need it.
      </p>
      <div className={styles.grid}>
        {features.map(({ title, body, Illustration }) => (
          <article key={title} className={styles.card}>
            <div className={styles.frame} aria-hidden="true">
              <GlowingEffect disabled={false} proximity={80} spread={36} borderWidth={2} inactiveZone={0.2} />
              <Illustration />
            </div>
            <h3>{title}</h3>
            <p>{body}</p>
          </article>
        ))}
      </div>
    </section>
  );
}
