# COEN Fork Notes

This document describes the enhancements made in this fork of IANA's COEN project.

## Fork Overview

**Upstream**: https://github.com/iana-org/coen
**Fork Purpose**: Add modern CI/CD infrastructure and development tooling without modifying the core COEN ISO

## Key Principle

**All upstream files remain unchanged.** This fork only adds infrastructure files:
- `.github/workflows/*` - CI/CD automation
- `.github/dependabot.yml` - Dependency management
- `.devcontainer/*` - Development environment
- `.dockerignore` - Build optimization

**Never modify**: Dockerfile, Makefile, create-iso.sh, variables.sh, tools/

## Fork-Specific Enhancements

### 1. GitHub Actions CI/CD

#### docker-publish.yml
- **Purpose**: Automated container image builds and publishing
- **Features**:
  - Builds container images on push to main and tags
  - Publishes to GitHub Container Registry (ghcr.io)
  - Signs images with Cosign using GitHub OIDC
  - Verifies signatures before completion
  - Sets SOURCE_DATE_EPOCH from git commit for reproducibility
- **Key Changes**:
  - Uses `docker/build-push-action@v6`
  - Certificate verification supports both branches and tags
  - Supply chain security via Cosign signing

#### makefile.yml
- **Purpose**: Automated ISO builds for testing
- **Features**:
  - Runs on push, PR, and manual dispatch
  - Verifies ISO hash against SHA256SUMS
  - Uploads ISO as artifact with 7-day retention
- **Key Changes**:
  - Removed unusual script wrapper shell
  - Added hash verification step
  - Added artifact retention policy

### 2. Dependabot Configuration

Tracks updates for three ecosystems:
- **devcontainers**: Development container base image
- **github-actions**: GitHub Actions used in workflows
- **docker**: Dockerfile base image (Debian bookworm)

### 3. Development Environment

#### devcontainer.json
- **Purpose**: Standardized VS Code development environment
- **Features**:
  - Debian bookworm base matching upstream
  - Docker-in-Docker for building
  - GitHub CLI for workflow management
  - Useful VS Code extensions (Docker, ShellCheck, Shell Format)
  - Volume mount for apt cache
- **Security Notes**:
  - Runs as root (required for ISO building)
  - Privileged mode enabled (required for mounting, chroot, device nodes)
  - These are necessary for squashfs and ISO operations

#### setup.sh
- **Purpose**: Install build dependencies in devcontainer
- **Features**:
  - Proper error handling with set -euo pipefail
  - Verifies packages installed correctly
  - Creates symlinks to tools directory
  - Generates required locales
  - Uses latest Debian packages (dev env gets security updates)
- **Note**: Production builds use pinned DATE in variables.sh

### 4. Build Optimizations

#### .dockerignore
- Excludes unnecessary files from Docker build context
- Improves build performance
- Prevents sensitive file leakage
- Excludes: .git/, .github/, .devcontainer/, *.iso, editor files

## Reproducibility

### ISO Reproducibility
- Upstream handles via `variables.sh` (DATE=20240701)
- ISO hash: `78e1b1452d62b075d5658ac652ad6eeccf15a81d25d63f55b9fc983463ba91d4`
- Verified automatically in makefile.yml workflow

### Container Image Reproducibility
- docker-publish.yml sets SOURCE_DATE_EPOCH from git commit
- Note: Dockerfile doesn't currently use this (upstream limitation)
- Actual reproducibility handled by upstream's DATE variable

## Maintaining the Fork

### Syncing with Upstream

```bash
# Add upstream remote (one-time)
git remote add upstream https://github.com/iana-org/coen.git

# Fetch upstream changes
git fetch upstream

# Merge upstream changes (they won't conflict with fork files)
git merge upstream/main

# Push to fork
git push origin main
```

### Updating to New Upstream Release

1. Fetch and merge upstream tag
2. Test ISO builds (both make and GitHub Actions)
3. Verify ISO hash matches new upstream SHA256SUMS
4. Update documentation if needed
5. Create matching tag in fork

### Testing Changes

**Before pushing changes**:
```bash
# Test devcontainer setup
code .  # Open in VS Code, "Reopen in Container"
make all

# Test ISO build locally
make build && make run && make copy
sha256sum coen-*.iso  # Verify against SHA256SUMS

# Test Docker image build
docker build -t coen:test .
```

**After pushing**:
- Check GitHub Actions workflows pass
- Verify artifacts uploaded correctly
- Test that Cosign verification succeeds

## Security Considerations

### Supply Chain Security
- **Cosign signing**: All container images signed with keyless Cosign
- **OIDC verification**: Uses GitHub OIDC tokens for identity
- **SBOM**: Software Bill of Materials generation (planned)
- **Vulnerability scanning**: Trivy scanning (planned)

### Reproducibility
- ISO builds use pinned Debian snapshot (DATE=20240701)
- Expected hash in SHA256SUMS verified automatically
- Container images set SOURCE_DATE_EPOCH from git

### Privilege Requirements
Development environment requires:
- Root user (chroot, device nodes)
- Privileged mode (mounting, squashfs)
- Docker-in-Docker (container builds)

These are **necessary** for ISO building operations.

## Troubleshooting

### ISO Hash Mismatch
If makefile.yml reports hash mismatch:
1. Check if upstream changed DATE in variables.sh
2. Verify no local modifications to tools/
3. Ensure builds use same SOURCE_DATE_EPOCH
4. Check for non-deterministic files (should be cleaned by hooks)

### Cosign Verification Fails
If docker-publish.yml verification fails:
1. Check certificate-identity-regexp matches workflow path
2. Verify OIDC issuer is correct
3. Ensure image was pushed before verification
4. Check GitHub Actions permissions (id-token: write)

### Devcontainer Won't Start
If devcontainer fails to start:
1. Check Docker has privileged mode enabled
2. Verify tools/ directory exists
3. Check setup.sh for errors
4. Try rebuilding container (Command Palette > Rebuild Container)

### Build Not Reproducible
If builds produce different hashes:
1. Verify DATE variable matches upstream
2. Check SOURCE_DATE_EPOCH is set consistently
3. Ensure no local modifications
4. Verify hooks clean non-deterministic files

## Future Enhancements

Planned improvements (not yet implemented):
- [ ] SBOM generation with syft or cyclonedx
- [ ] Vulnerability scanning with Trivy
- [ ] SLSA provenance attestation
- [ ] Pin GitHub Actions to commit SHAs
- [ ] Move Cosign verification before push
- [ ] Multi-platform support (arm64)
- [ ] Automated reproducibility testing

## Questions?

For fork-specific issues: https://github.com/sheurich/coen/issues
For upstream COEN issues: https://github.com/iana-org/coen/issues

## License

This fork maintains the upstream ISC License.
Copyright ICANN - see LICENSE.md
