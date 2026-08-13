## Phase 0 — Prerequisites (Manual, One-Time)

### Step 0a: Create Fine-Grained PAT

1. Go to GitHub → Settings → Developer settings → Personal access tokens → Fine-grained tokens
2. **Resource owner**: `vofka198119-code`
3. **Repository**: `vofka198119-code/fomoshield` (single repo)
4. **Permissions**: `Contents: Read-only`
5. Copy the generated token (`github_pat_...`).

### Step 0b: Store as Repository Secret

1. Go to repo → Settings → Secrets and variables → Actions
2. New repository secret: **Name** = `RELEASE_READ_TOKEN`, **Value** = the PAT from 0a.