# fomoshield.app — the website

Static files served by nginx on the same Hetzner box as the backend
(SSH alias `scanco-backend`), document root `/var/www/fomoshield-app`.
No build step, no framework: what is in this directory is what is served.

## What is here

| Path | Served at | Notes |
|---|---|---|
| `index.html` | `/` | Landing page. English copy lives in the HTML itself so search engines and link previews get real text. |
| `assets/site.css` | `/assets/site.css` | Palette is the app's own Black & White theme — values and their source file are named in the CSS header. |
| `assets/i18n.js` | `/assets/i18n.js` | Russian copy + the EN/RU switch. Remembers the choice in `localStorage`, defaults to the browser language. |
| `assets/shots/*.jpg` | `/assets/shots/…` | Play Store screenshots from 2026-09-19, cropped of the status/navigation bars and resized to 480px wide. Originals stay in `docs/store_assets/screenshots/`. |
| `assets/icon.png`, `assets/og.png` | `/assets/…` | Favicon and link-preview image, derived from the Play Store icon and feature graphic. |
| `legal/*/index.html` | `/privacy`, `/terms`, `/premium`, `/delete-account` | **Pulled from the live server 2026-09-27.** These pages existed for months with no copy in any repository; this is their first version control. |
| `nginx-fomoshield.conf.current` | — | The live config as it was on 2026-09-27, for reference. |
| `nginx-fomoshield.conf.proposed` | — | The same config plus the two locations the landing page needs. |

## Editing the copy

English is in `index.html`; Russian is in `assets/i18n.js`, keyed by the
`data-i18n` attribute on each element. **Change both** — an element whose
key is missing from the Russian dictionary silently keeps its English text
when a visitor switches language.

## Deploying

The landing page needs an nginx change as well as files: the live config
ends in `location / { return 404; }`, which is why `/` 404s today and why
`/assets/…` would 404 too. Both new locations are in the proposed config.

```sh
# 1. files
scp -r index.html assets scanco-backend:/tmp/site-upload/
ssh scanco-backend 'sudo cp -r /tmp/site-upload/* /var/www/fomoshield-app/'

# 2. nginx (back up first, test before reloading)
scp nginx-fomoshield.conf.proposed scanco-backend:/tmp/
ssh scanco-backend 'sudo cp /etc/nginx/sites-enabled/fomoshield-app /root/fomoshield-app.bak && \
                    sudo cp /tmp/nginx-fomoshield.conf.proposed /etc/nginx/sites-enabled/fomoshield-app && \
                    sudo nginx -t && sudo systemctl reload nginx'

# 3. verify — the four legal pages must still answer 200
for p in "" privacy terms premium delete-account assets/site.css; do
  curl -s -o /dev/null -w "$p %{http_code}\n" "https://fomoshield.app/$p"
done
```

## Checking changes locally

```sh
cd site && python3 -m http.server 8777   # then open http://localhost:8777/
```
