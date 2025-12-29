# Slash Command Plugin & Landing Page Implementation Plan

## Overview

Create and publish the `slash-command` Claude Code plugin to GitHub, and build a minimal landing page at www.slash-command.com using Next.js 16 with the Entourage design system aesthetic.

## Two Deliverables

1. **Plugin**: `slash-command` published to GitHub as a public Claude Code plugin
2. **Landing Page**: Next.js 16 site at `/Users/ia/Documents/code/@personal/slash-command`

---

## Phase 1: Create Plugin Structure

### Overview
Create the plugin directory with proper structure, excluding `nextjs-check-structure` command.

### Changes Required:

#### 1. Create Plugin Directory
**Location**: `/Users/ia/Documents/code/@personal/slash-command-plugin/`

```
slash-command-plugin/
├── .claude-plugin/
│   └── plugin.json
├── commands/              # 11 commands (excluding nextjs-check-structure)
├── agents/                # 6 agents
├── scripts/               # 3 utility scripts
└── README.md
```

#### 2. Plugin Manifest
**File**: `.claude-plugin/plugin.json`

```json
{
  "name": "slash-command",
  "version": "1.0.0",
  "description": "Planning, implementation, and documentation workflow for software development with Claude Code",
  "author": {
    "name": "ia",
    "url": "https://slash-command.com"
  },
  "homepage": "https://slash-command.com",
  "repository": "https://github.com/ii-vo/slash-command",
  "license": "MIT",
  "keywords": ["workflow", "planning", "documentation", "handoffs", "claude-code"]
}
```

#### 3. Commands to Include (11 total)
- `commit.md`
- `create_handoff.md`
- `create_plan.md`
- `create_plan_no_thoughts.md`
- `describe_pr.md`
- `implement_in_worktree.md`
- `implement_plan.md`
- `iterate_plan.md`
- `research_codebase.md`
- `resume_handoff.md`
- `validate_plan.md`

**Excluded**: `nextjs-check-structure.md`

#### 4. Agents to Include (6 total)
- `codebase-analyzer.md`
- `codebase-locator.md`
- `codebase-pattern-finder.md`
- `notes-analyzer.md`
- `notes-locator.md`
- `web-search-researcher.md`

#### 5. Scripts to Include
- `spec_metadata.sh`
- `create_worktree.sh`
- `cleanup_worktree.sh`

### Success Criteria:

#### Automated Verification:
- [x] Plugin directory exists with correct structure
- [x] `plugin.json` is valid JSON
- [x] All 11 commands copied
- [x] All 6 agents copied
- [x] All 3 scripts copied and executable

#### Manual Verification:
- [ ] Test plugin locally: `claude --plugin-dir ./slash-command-plugin`

---

## Phase 2: Publish Plugin to GitHub

### Overview
Initialize git repo and push to GitHub as public repository.

### Changes Required:

#### 1. Initialize Repository
```bash
cd /Users/ia/Documents/code/@personal/slash-command-plugin
git init
git add .
git commit -m "Initial commit: slash-command plugin v1.0.0"
```

#### 2. Create GitHub Repository
```bash
gh repo create ii-vo/slash-command --public --source=. --description "Claude Code plugin for planning, implementation, and documentation workflows"
git push -u origin main
```

#### 3. Add GitHub Topics
- `claude-code`
- `claude-code-plugin`
- `developer-tools`
- `workflow`

### Success Criteria:

#### Automated Verification:
- [x] Repository exists: `gh repo view ii-vo/slash-command`
- [x] All files pushed to main branch

#### Manual Verification:
- [ ] Plugin installable: `/plugin marketplace add ii-vo/slash-command`

---

## Phase 3: Create Landing Page Project

### Overview
Initialize Next.js 16 project with Tailwind CSS v4, following Entourage design system.

### Changes Required:

#### 1. Create Next.js Project
**Location**: `/Users/ia/Documents/code/@personal/slash-command/`

```bash
cd /Users/ia/Documents/code/@personal
npx create-next-app@latest slash-command --typescript --tailwind --eslint --app --src-dir --import-alias "@/*"
```

#### 2. Project Structure
```
slash-command/
├── src/
│   ├── app/
│   │   ├── layout.tsx        # Root layout with fonts, metadata
│   │   ├── page.tsx          # Landing page
│   │   ├── globals.css       # Tailwind + custom styles
│   │   └── favicon.ico
│   ├── components/
│   │   ├── PlusCorner.tsx    # Plus corner decoration
│   │   ├── Hero.tsx          # Hero section
│   │   ├── Workflow.tsx      # ASCII flowchart section
│   │   └── Footer.tsx        # Simple footer
│   └── lib/
│       └── fonts.ts          # Font configuration
├── public/
│   └── og-image.png          # Open Graph image
├── tailwind.config.ts
├── next.config.ts
└── package.json
```

### Success Criteria:

#### Automated Verification:
- [x] Project created with Next.js
- [ ] Project builds: `npm run build`
- [ ] No TypeScript errors: `npm run lint`

---

## Phase 4: Implement Landing Page

### Overview
Build minimal landing page with hero, workflow diagram, and install CTA.

### Design Specs (from Entourage Design System):
- **Aesthetic**: Technical Blueprint — sharp corners, monochrome, plus corners
- **Fonts**: Switzer (sans), Geist Mono (mono)
- **Colors**: Black/white with zinc accents
- **Radius**: 0px (sharp corners)

### Changes Required:

#### 1. Root Layout
**File**: `src/app/layout.tsx`

```tsx
import type { Metadata } from "next";
import { Switzer, GeistMono } from "@/lib/fonts";
import "./globals.css";

export const metadata: Metadata = {
  metadataBase: new URL("https://slash-command.com"),
  title: {
    default: "Slash Command — Claude Code Plugin",
    template: "%s | Slash Command",
  },
  description: "Planning, implementation, and documentation workflow for software development with Claude Code",
  keywords: ["Claude Code", "plugin", "workflow", "planning", "AI development"],
  authors: [{ name: "ia" }],
  openGraph: {
    title: "Slash Command",
    description: "Claude Code plugin for structured development workflows",
    url: "https://slash-command.com",
    siteName: "Slash Command",
    locale: "en_US",
    type: "website",
  },
  twitter: {
    card: "summary_large_image",
    title: "Slash Command",
    description: "Claude Code plugin for structured development workflows",
  },
  robots: {
    index: true,
    follow: true,
  },
};

export default function RootLayout({ children }: { children: React.ReactNode }) {
  return (
    <html lang="en" className={`${Switzer.variable} ${GeistMono.variable}`}>
      <body className="bg-white dark:bg-black text-black dark:text-white antialiased">
        {children}
      </body>
    </html>
  );
}
```

#### 2. Landing Page Structure
**File**: `src/app/page.tsx`

```tsx
export default function Home() {
  return (
    <main className="min-h-screen">
      <Hero />
      <Workflow />
      <Install />
      <Footer />
    </main>
  );
}
```

#### 3. Hero Section
- Large headline: "Slash Command"
- Subhead: "Structured workflows for Claude Code"
- Brief description (1-2 lines)
- CTA: "View on GitHub" button

#### 4. Workflow Section
- ASCII-style flowchart showing the development lifecycle
- Mobile: Vertical stack
- Desktop: Horizontal flow
- Use monospace font for ASCII art

```
┌──────────┐   ┌──────────┐   ┌──────────┐   ┌──────────┐
│ RESEARCH │ → │   PLAN   │ → │ IMPLEMENT│ → │ DELIVER  │
└──────────┘   └──────────┘   └──────────┘   └──────────┘
```

#### 5. Install Section
- Simple install command in monospace
- Copy button (optional)

```
/plugin install slash-command@ii-vo
```

#### 6. Footer
- Minimal: "Built for Claude Code" + GitHub link

### Success Criteria:

#### Automated Verification:
- [ ] Build succeeds: `npm run build`
- [ ] Lighthouse SEO score > 90
- [ ] No accessibility errors

#### Manual Verification:
- [ ] Responsive on mobile (< 640px)
- [ ] Responsive on desktop (> 1024px)
- [ ] Dark mode works
- [ ] Plus corners display correctly

---

## Phase 5: Deploy to Vercel

### Overview
Connect to Vercel, configure domain, deploy.

### Changes Required:

#### 1. Initialize Vercel
```bash
cd /Users/ia/Documents/code/@personal/slash-command
vercel link
```

#### 2. Configure Domain
- Add `slash-command.com` in Vercel dashboard
- Add `www.slash-command.com` redirect

#### 3. Environment Variables
None required for static site.

#### 4. Deploy
```bash
vercel --prod
```

### Success Criteria:

#### Automated Verification:
- [ ] Deployment succeeds
- [ ] Site accessible at https://slash-command.com

#### Manual Verification:
- [ ] Domain resolves correctly
- [ ] HTTPS working
- [ ] Meta tags render in social previews

---

## Summary

| Phase | Deliverable | Location |
|-------|-------------|----------|
| 1 | Plugin structure | `@personal/slash-command-plugin/` |
| 2 | GitHub repo | `github.com/ii-vo/slash-command` |
| 3 | Next.js project | `@personal/slash-command/` |
| 4 | Landing page | Same as above |
| 5 | Live site | https://slash-command.com |

## File Count

| Component | Count |
|-----------|-------|
| Plugin Commands | 11 |
| Plugin Agents | 6 |
| Plugin Scripts | 3 |
| Landing Page Components | 4-5 |

---

## Open Questions Resolved

1. **Plugin location**: Separate from landing page (`slash-command-plugin/` vs `slash-command/`)
2. **GitHub username**: `ii-vo`
3. **Excluded command**: `nextjs-check-structure.md` not included in plugin
