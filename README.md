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
make build      # build with the version pinned in package.json
make test       # build + smoke test (prints playwright/node versions)
make shell      # interactive bash inside the image
make version    # print the pinned playwright version
make help       # list all targets
```

## Versioning

The `playwright` dependency in [`package.json`](./package.json) is the single
source of truth for the Playwright version baked into the image (pinned to an
exact version). The `Makefile` and CI both read it with `jq` and pass it as the
`PLAYWRIGHT_VERSION` Docker build-arg.

[Dependabot](./.github/dependabot.yml) watches this pin and opens a PR when a
newer Playwright is published (it also keeps the GitHub Actions and the
`node:24-trixie` base image up to date).

### Cutting a release

1. Bump the `playwright` pin in `package.json` (e.g., `1.59.1` → `1.60.0`) —
   or merge the Dependabot PR that does it — and commit.
2. Tag the commit with a matching `vX.Y.Z` tag:

    ```sh
    git tag v1.60.0
    git push origin v1.60.0
    ```

3. The `release` workflow validates that the tag matches the `package.json`
   pin, builds multi-arch, pushes to GHCR with tags `1.60.0`, `v1.60.0`, and
   `latest`, and creates a GitHub Release.

If the tag and the pin disagree, the release fails fast. Image revisions
on the same Playwright version (e.g., for a Dockerfile-only change) can be
released by appending a suffix: tag `v1.60.0-1` will publish image tag
`1.60.0-1` and update `latest` (the pin still reads `1.60.0`).
