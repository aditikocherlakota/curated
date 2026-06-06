# Flatten Curated Repo Structure Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Move Swift project files from `Curated/` subfolder to repo root, removing outdated documentation.

**Architecture:** Use `git mv` to preserve file history while moving files. Remove old docs that don't match current project. Result: flat repo structure with Swift project at root.

**Tech Stack:** Git, Swift package structure

---

## Task 1: Move Swift package files to root

**Files:**
- Move: `Curated/Package.swift` → `Package.swift`
- Move: `Curated/README.md` → `README.md`
- Move: `Curated/Info.plist` → `Info.plist`

- [ ] **Step 1: Move Package.swift to root**

```bash
git mv Curated/Package.swift Package.swift
```

- [ ] **Step 2: Move README.md to root**

```bash
git mv Curated/README.md README.md
```

- [ ] **Step 3: Move Info.plist to root**

```bash
git mv Curated/Info.plist Info.plist
```

- [ ] **Step 4: Verify files exist at root**

```bash
ls -la Package.swift README.md Info.plist
```

Expected: All three files visible at repo root

- [ ] **Step 5: Commit**

```bash
git commit -m "feat: move Swift package files to repo root"
```

---

## Task 2: Move Sources and Resources directories

**Files:**
- Move: `Curated/Sources/` → `Sources/`
- Move: `Curated/Resources/` → `Resources/`

- [ ] **Step 1: Move Sources directory to root**

```bash
git mv Curated/Sources Sources
```

- [ ] **Step 2: Move Resources directory to root**

```bash
git mv Curated/Resources Resources
```

- [ ] **Step 3: Verify directory structure**

```bash
ls -la Sources/ Resources/
```

Expected: Both directories at root with their contents intact

- [ ] **Step 4: Commit**

```bash
git commit -m "feat: move Sources and Resources to repo root"
```

---

## Task 3: Remove outdated documentation and empty Curated folder

**Files:**
- Delete: `CLAUDE.md` (outdated Mistral AI design system)
- Delete: `DESIGN.md` (outdated Mistral AI design system)
- Delete: `Curated/` (now-empty folder)

- [ ] **Step 1: Remove outdated documentation files**

```bash
git rm CLAUDE.md DESIGN.md
```

- [ ] **Step 2: Remove now-empty Curated directory**

```bash
git rm -r Curated/
```

- [ ] **Step 3: Verify repo root structure**

```bash
ls -la
```

Expected output should show:
```
Package.swift
README.md
Info.plist
Sources/
Resources/
docs/
.git/
```

No CLAUDE.md, DESIGN.md, or Curated/ folder

- [ ] **Step 4: Commit**

```bash
git commit -m "feat: remove outdated docs and empty Curated folder"
```

---

## Task 4: Verify project integrity

**Files:**
- Verify: `Package.swift` references are correct
- Verify: File structure matches Swift package expectations

- [ ] **Step 1: Check Package.swift references correct paths**

```bash
cat Package.swift | grep -E 'path:|Sources|Resources'
```

Expected: Any path references should point to `Sources/` and `Resources/`, not `Curated/Sources/` etc.

- [ ] **Step 2: Verify Sources structure is intact**

```bash
find Sources -type f -name "*.swift" | head -10
```

Expected: Swift files from all subdirectories (App, Design, Models, Services, Views)

- [ ] **Step 3: Check final repo structure**

```bash
tree -L 2 -I '.git|docs'
```

Or if tree not available:

```bash
find . -maxdepth 2 -type d | grep -v '\.git' | sort
```

Expected: Clean root-level structure with Sources, Resources, Package.swift at top level

- [ ] **Step 4: Commit completion marker**

```bash
git log --oneline -4
```

Expected: Last 4 commits show the three restructure commits plus earlier work
