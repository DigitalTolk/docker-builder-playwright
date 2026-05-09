# docker-builder-playwright

Pre-built [Playwright](https://playwright.dev/) image — `chromium` + `webkit`
on top of `node:24-trixie` — published to GHCR for use as a base image in
GitHub Actions of downstream projects, so each consumer doesn't have to
reinstall browsers and OS deps on every CI run.

## Image

```
ghcr.io/digitaltolk/docker-builder-playwright:<playwright-version>
ghcr.io/digitaltolk/docker-builder-playwright:latest
```

Multi-arch: `linux/amd64`, `linux/arm64`.

## Usage in a downstream GitHub Actions workflow

```yaml
jobs:
  e2e:
    runs-on: ubuntu-latest
    container:
      image: ghcr.io/digitaltolk/docker-builder-playwright:1.59.1
    steps:
      - uses: actions/checkout@v4
      - run: npm ci
      - run: npx playwright test
```

Browsers are pre-installed at `/ms-playwright` (`PLAYWRIGHT_BROWSERS_PATH`),
so no `playwright install` step is needed at runtime.

## Local development

```sh
make build      # build with the version pinned in .playwright-version
make test       # build + smoke test (prints playwright/node versions)
make shell      # interactive bash inside the image
make version    # print the pinned playwright version
make help       # list all targets
```

## Versioning

[`.playwright-version`](./.playwright-version) is the single source of truth
for the Playwright version baked into the image. The `Makefile` and CI both
read it and pass it as the `PLAYWRIGHT_VERSION` Docker build-arg.

### Cutting a release

1. Bump `.playwright-version` (e.g., `1.59.1` → `1.60.0`) and commit.
2. Tag the commit with a matching `vX.Y.Z` tag:

    ```sh
    git tag v1.60.0
    git push origin v1.60.0
    ```

3. The `release` workflow validates that the tag matches
   `.playwright-version`, builds multi-arch, pushes to GHCR with tags
   `1.60.0`, `v1.60.0`, and `latest`, and creates a GitHub Release.

If the tag and the file disagree, the release fails fast. Image revisions
on the same Playwright version (e.g., for a Dockerfile-only change) can be
released by appending a suffix: tag `v1.60.0-1` will publish image tag
`1.60.0-1` and update `latest` (the file still reads `1.60.0`).
