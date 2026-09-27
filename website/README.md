# Water, pls website

Next.js App Router site for the Water, pls macOS app. This project lives alongside the Swift package and has its own npm dependencies and deployment.

## Run locally

```sh
cd website
npm ci
npm run dev
```

Open http://localhost:3000. Run `npm run lint` and `npm run build` before deploying.

## Structure

- `src/app/page.tsx`: landing page
- `src/app/layout.tsx`: shared layout and search metadata
- `src/app/globals.css`: responsive layout, typography, and visual styles
- `src/app/notch-demo.tsx`: interactive hydration reminder preview
- `public/`: web copies of app assets

The landing page has three sections: the hero with an interactive notch preview, three product benefits, and a download call to action. Figtree is self-hosted through `next/font`, with −3% tracking on large text and normal tracking on small text. Download links serve the real DMG from `public/downloads/`, using `src/app/release.json`. Run `./scripts/package-dmg.sh` from the repository root on macOS to regenerate the installer and metadata before a release; include both in the website deployment. The supplied droplet is used for the site icon and app bundle. See [the release guide](../docs/RELEASING.md) for Homebrew publishing steps. The preview only updates in-memory demo state.

Set the production domain in metadata and add a sitemap when deployment is configured.
