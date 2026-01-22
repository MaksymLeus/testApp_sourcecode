# 09 — Releasing

This document describes the **release process** for the **hostinfo** web application, including versioning, Git workflow, CI/CD, and Docker publishing.

---

## 1. Versioning Strategy

hostinfo follows **Semantic Versioning** (SemVer):

```
MAJOR.MINOR.PATCH
```

- **MAJOR**: breaking changes
- **MINOR**: new features, backward-compatible
- **PATCH**: bug fixes, documentation, small improvements

Example:

```
v1.3.0 → new feature added
v1.3.1 → bug fix
v2.0.0 → breaking change
```

---

## 2. Git Workflow

1. **Main branch**: `main`  
   - Stable production-ready code
2. **Feature branches**: `feature/<name>`  
   - For new features
3. **Hotfix branches**: `hotfix/<name>`  
   - Critical bug fixes
4. **Release branches** (optional): `release/<version>`  

Commit messages follow **Conventional Commits**:

- `feat:` → new feature
- `fix:` → bug fix
- `chore:` → maintenance
- `docs:` → documentation update
- `refactor:` → code refactor
- `test:` → tests only
- `perf:` → performance improvement

This ensures **automatic versioning** during release.

---

## 3. Pre-Release Checklist

Before creating a release:

- ✅ All tests pass (`go test ./...`)
- ✅ Linting passed (`go vet ./...`, `golangci-lint`)
- ✅ Documentation updated
- ✅ Docker image builds successfully
- ✅ Changelog updated (if manual)

---

## 4. Semantic Release

The project uses **GitHub Actions + semantic release**:

- Workflow file: `.github/workflows/template-semantic-release.yml`
- Automatically determines next version from commit messages
- Creates GitHub release with changelog
- Tags release in Git

### 4.1 Triggering Release

Releases are triggered automatically on:

- `push` to `main`
- Manually via GitHub Actions `Run workflow` button

### 4.2 Example Commands (Local Dry-Run)

```bash
# Install semantic release CLI
npm install -g semantic-release @semantic-release/git

# Dry run
semantic-release --dry-run
```

This previews the next version and changelog without committing.

---

## 5. Docker Image Release

hostinfo Docker images are published to Docker Hub:

- **Registry**: [`maximleus/hostinfo`](https://hub.docker.com/r/maximleus/hostinfo)
- Multi-arch: `linux/amd64`, `linux/arm64`
- Base image: `golang:1.24-alpine`

### 5.1 Automated Build

GitHub Actions workflow: `.github/workflows/template-docker.yml`

- Builds Docker image on each release
- Tags image with SemVer version and `latest`
- Pushes image to Docker Hub

Example Docker tags:

```
maximleus/hostinfo:1.2.3
maximleus/hostinfo:latest
```

### 5.2 Manual Build & Push

```bash
# Build image
docker build -t hostinfo .

# Tag with version
docker tag hostinfo maximleus/hostinfo:1.2.3

# Push to Docker Hub
docker push maximleus/hostinfo:1.2.3
docker push maximleus/hostinfo:latest
```

---

## 6. Release Notes

- Generated automatically from commit messages
- Included in GitHub release
- Contains:
  - Features
  - Bug fixes
  - Chores
- Optional: additional manual notes

---

## 7. Rollback Strategy

- Docker: redeploy previous image (`docker tag ...`)
- Bare-metal: keep previous binary copy
- systemd: restart previous binary
- Kubernetes: rollback via `kubectl rollout undo deployment/hostinfo`

---

## 8. Post-Release Checklist

- ✅ Verify dashboard on production
- ✅ Confirm Docker image works
- ✅ Confirm semantic release tags pushed
- ✅ Update documentation references

---

## 9. References

- [Semantic Release](https://semantic-release.gitbook.io/)
- [Conventional Commits](https://www.conventionalcommits.org/)
- [Docker Hub](https://hub.docker.com/r/maximleus/hostinfo)

---

## License

MIT — see `LICENSE.md`.
