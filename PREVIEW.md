# Preview server

`devserver` is this repo's local preview/dev-link server. It opens a bounded
link from the dev sandbox to your laptop so preview requests are served from
inside the sandbox environment.

## Usage

```bash
./devserver            # foreground; runs for up to 80 minutes, then exits
# or
./scripts/preview.sh
```

While it is running it prints `preview link ready` and serves preview requests
until the link closes. No configuration is required.
