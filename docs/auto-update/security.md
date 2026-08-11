# Security Analysis — PAT Token

## Token Scope

```
Type: Fine-grained Personal Access Token (PAT)
Resource: vofka198119-code/fomoshield
Permission: Contents → Read-only
```

## What the Token CAN Do

| Action | Risk Level |
|--------|------------|
| Read repository files (source code, docs, etc.) | 🟢 Low — code is already distributed as APK |
| List and download releases | 🟢 Low — releases are meant to be downloaded |
| Read commit history | 🟢 Low — not sensitive |
| Read pull requests, issues | 🟢 Low — public development activity |

## What the Token CANNOT Do

| Action | Blocked by |
|--------|------------|
| Push to the repo | `Contents: Read-only` |
| Delete releases, tags, branches | `Contents: Read-only` |
| Access other repos | Scoped to this repo only |
| Access organization resources | Scoped to this repo only |
| Modify issues, PRs, wiki | `Contents: Read-only` |
| Access user data, SSH keys, etc. | Not in PAT scope |

## Attack Vectors

### 1. APK Decompilation

**Threat**: Attacker decompiles the APK, extracts the token string.

**Impact**: 🟢 Minimal. Token can only READ this repo. Attacker gains nothing they can't already get by installing the app legitimately.

**Mitigation**: Already mitigated by minimal scope. Even with the token, the attacker cannot:
- Push malicious code
- Replace releases
- Access any other repository
- Access any user data

### 2. Man-in-the-Middle (MITM)

**Threat**: Intercept the HTTPS request to `api.github.com` and steal the token.

**Impact**: 🟢 Minimal (same as above).

**Mitigation**: GitHub API enforces HTTPS. Certificate pinning would add extra security but is overkill for a read-only token.

### 3. Token Leak via Git History

**Threat**: Someone accidentally commits the token to the repository.

**Impact**: 🔴 High — token is exposed in source control history.

**Mitigation**: 
- Token is NEVER in source code — it's injected at build time via `--dart-define`
- Token lives ONLY in GitHub Actions secrets (encrypted at rest)
- If leaked, revoke and regenerate immediately

### 4. Token Expiration

**Threat**: PAT expires, app silently fails to check for updates.

**Impact**: 🟡 Medium — users don't get update notifications.

**Mitigation**: Set long expiration (1 year recommended). The `UpdateService` fails silently (no crash, no error dialog). Rotation procedure:
1. Generate new PAT
2. Update `RELEASE_READ_TOKEN` in repo secrets
3. Next release rebuild will embed new token

## Best Practices

- ✅ **Minimal scope**: `Contents: Read` only, single repo
- ✅ **Not in source code**: Injected at build time via CI/CD
- ✅ **Stored encrypted**: GitHub Actions secrets are encrypted at rest
- ✅ **Fails silently**: No error surfaced to user if API call fails
- ✅ **Token guard**: `if (_token.isNotEmpty)` prevents 401 errors during local dev when token is not set
- ✅ **No token logging**: Dio `LogInterceptor` is configured with `requestBody: false` and `responseBody: false` — the `Authorization` header is never printed to logs
- ⚠️ **Rotation**: Rotate yearly or if suspected leaked
- ⚠️ **Monitor**: GitHub audit log shows PAT usage — review periodically

## Rotation Procedure

```bash
# 1. Generate new PAT at github.com → Settings → Developer settings → PATs
# 2. Update repo secret
#    Repo → Settings → Secrets → Actions → RELEASE_READ_TOKEN → Update
# 3. Revoke old PAT at github.com → Settings → Developer settings → PATs
# 4. New builds will automatically use the new token
```

No code changes needed — the `--dart-define=GITHUB_TOKEN=...` in CI/CD pulls from the secret at build time.

## Alternative Considered: Supabase Edge Function

**Approach**: Token stays on Supabase server. App calls Supabase Function → Function proxies to GitHub API.

**Rejected because**:
- Adds Supabase Edge Function dependency
- Adds latency (supabase → github API extra hop)
- Same effective security (read-only token either way)
- More moving parts to maintain

The read-only PAT is the simplest approach with acceptable risk for a read-only operation.
