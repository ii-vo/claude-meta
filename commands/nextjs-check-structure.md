---
description: Validate Next.js 16 project folder structure. Use when checking if a project follows the recommended src/, app/, features/, components/ architecture.
allowed-tools: Glob, Read, Bash(ls:*), Bash(find:*)
---

# Check Next.js 16 Folder Structure

Validate this project against the enforced Next.js 16 structure conventions.

## Current Project State

!`ls -la`
!`ls src/ 2>/dev/null || echo "No src/ directory"`
!`ls src/components/ 2>/dev/null || echo "No components/ directory"`

## Enforced Structure

```
.
├── next.config.ts
├── package.json
├── src/
│   ├── app/                       # Routing Layer ONLY
│   │   ├── (group)/               # Route groups (when needed)
│   │   ├── [slug]/                # Dynamic routes
│   │   ├── api/                   # Route handlers
│   │   ├── layout.tsx
│   │   └── global-error.tsx
│   ├── components/
│   │   ├── layout/                # Page-level layout components
│   │   │   ├── header/
│   │   │   │   ├── Header.tsx
│   │   │   │   └── index.ts
│   │   │   └── footer/
│   │   │       ├── Footer.tsx
│   │   │       └── index.ts
│   │   ├── sections/              # Page content blocks
│   │   │   ├── hero/
│   │   │   │   ├── Hero.tsx
│   │   │   │   └── index.ts
│   │   │   └── faq/
│   │   │       ├── FAQ.tsx
│   │   │       └── index.ts
│   │   ├── ui/                    # Design system primitives (protected)
│   │   ├── Icon.tsx               # Utility components at root
│   │   ├── Logo.tsx
│   │   └── ThemeToggle.tsx
│   ├── features/                  # Domain-driven business logic
│   │   └── auth/
│   │       ├── actions.ts         # Server Actions
│   │       └── components/
│   ├── lib/                       # Singletons & configs
│   ├── providers/                 # Client contexts
│   │   └── ThemeProvider.tsx
│   ├── instrumentation.ts         # Server startup (optional)
│   └── proxy.ts                   # Network boundary (optional)
```

## Enforced Conventions

### Component Organization
| Type | Location | Pattern |
|------|----------|---------|
| Layout (Header, Footer) | `components/layout/` | `layout/header/Header.tsx` + `index.ts` |
| Page Sections (Hero, FAQ) | `components/sections/` | `sections/hero/Hero.tsx` + `index.ts` |
| UI Primitives (Button, Card) | `components/ui/` | Protected, design system only |
| Utility (Icon, Logo, ThemeToggle) | `components/` root | Flat files, no subdirectory |
| Feature-specific | `features/{feature}/components/` | Co-located with feature |

### File Patterns
- Section/layout components use subdirectory pattern: `sections/hero/Hero.tsx` with `index.ts` for exports
- Utility components stay flat at `components/` root
- `ui/` directory is protected - only design system primitives

### Providers
- All client contexts go in `src/providers/`
- ThemeProvider, QueryClientProvider, etc. - NOT in components/

### Business Logic
- NO business logic in `app/` - routing only
- Domain logic goes in `features/{domain}/`
- Each feature has `actions.ts` (Server Actions) and `components/`

## Checks to Perform

1. **Root structure**: `next.config.ts`, `package.json`, `src/` exist
2. **src/ directories**: `app/`, `components/`, `lib/`, `providers/` exist
3. **components/ organization**:
   - `layout/` exists with subdirectory pattern
   - `sections/` exists with subdirectory pattern
   - `ui/` exists and contains only primitives
   - No page sections at `components/` root
4. **providers/**: Client contexts are here, not in `components/`
5. **app/**: Contains only routing files, no business logic
6. **features/**: Exists when business logic is needed

## Issues to Flag

| Issue | Severity | Fix |
|-------|----------|-----|
| No `src/` directory | ERROR | Code mixed with config |
| ThemeProvider in `components/` | WARN | Move to `providers/` |
| Section components at `components/` root | WARN | Move to `components/sections/{name}/` |
| Layout components at `components/` root | WARN | Move to `components/layout/{name}/` |
| Business logic in `app/` | ERROR | Move to `features/` |
| Missing `index.ts` in section/layout dirs | WARN | Add barrel export |
| Using `pages/` instead of `app/` | ERROR | Legacy router |
| `middleware.ts` instead of `proxy.ts` | WARN | Next.js 16 pattern |

## Output

Generate a markdown report:

```markdown
## Next.js 16 Structure Validation Report

### Summary
- Status: [PASS/WARN/FAIL]
- Score: X/Y checks passed

### Directory Structure
| Check | Status | Notes |
|-------|--------|-------|
| src/ exists | ✓/✗ | |
| components/layout/ | ✓/✗ | |
| components/sections/ | ✓/✗ | |
| components/ui/ | ✓/✗ | |
| providers/ | ✓/✗ | |
| features/ | ✓/✗/N/A | |

### Component Placement
| Component | Current Location | Expected | Status |
|-----------|-----------------|----------|--------|
| ... | ... | ... | ✓/✗ |

### Recommendations
- List files that need to move
- Suggest directory creation
- Note any violations
```
