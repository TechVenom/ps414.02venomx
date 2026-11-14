<div align="center">

# ps414.02venomx

<img src="includes/assets/icons/ps4-venomx.svg" width="240" alt="PS4 VenomX Logo">

**A WebKitty fork for PlayStation 4 firmware 14.02 — Slopkit userland with the Afterglow kernel exploit.**

Based on [WebKitty](https://github.com/ArabPixel/WebKitty) by ArabPixel.

[![License: AGPL v3](https://img.shields.io/badge/License-AGPL_v3-blue.svg)](LICENSE)

[What runs](#what-runs-on-1402) • [Firmware](#supported-firmware) • [How to run](#how-to-run) • [Payloads](#payloads-and-ports) • [Troubleshooting](#troubleshooting) • [Credits](#credits)

</div>

---

## What runs on 14.02

This fork exists because firmware 14.00/14.02 needs its own kernel stage. The chain is:

| Stage | Implementation | Source |
| :--- | :--- | :--- |
| WebKit / userland | **Slopkit** — a JavaScript UAF turned into arbitrary read/write (`window.p`) in the WebProcess | `src/slopkit-afterglow/core.js`, `mem.js` |
| Kernel | **Afterglow** — self-contained kernel stage that patches the kernel and opens an `rwx` / kexec gate | `src/slopkit-afterglow/afterglow.js`, `ps4_offsets.js` |
| Payload | **GoldHEN** 2.4b18.14 (default) or 2.4b18.13, injected as a `.bin` | `includes/payloads/HEN/` |

How it behaves:

- The host detects the console and preselects **Slopkit Afterglow** for 14.00–14.02. Do not change the chain on 14.02 — the WebKit stage would run, then the kernel stage would refuse (or patch the wrong kernel).
- Afterglow is the kernel exploit itself, not a prelude to another one. It does not use the host's kernel offset table and does not chain into Lapse/Netctrl/Relapse.
- The WebKit stage is retried inside a single run (8 attempts by default; roughly one attempt in three lands). A 45-second watchdog shows a retry notice if the stage stalls.
- If the PS4 browser restores the exploit page by itself, the page refuses to run and sends you back to the landing page. Arming requires a click from the index page.

### 14.02 limitations

- **GoldHEN versions:** on 14.02 only **2.4b18.13** and **2.4b18.14** are accepted. Older versions are refused. On 14.00 the selector offers 2.4b18.14 and 2.4b18.12.
- **Elf Loader is not supported on 14.02.** `elfldr` is listed for 4.71–14.00 only (`includes/js/payloadsList.js`), so `.elf` payloads and port 9021 are unavailable here. Use `.bin` payloads through GoldHEN's binloader.

---

## Supported firmware

| WebKit / Userland | Kernel | Firmware |
| :--- | :---: | :--- |
| Have A Bad Time & Stack Uninitialized Read | Bpf Double Free | 4.50 – 5.07 |
| Bad Hoist | sleirsgoevy's kexploit | 6.70 – 6.72 |
| PSFree | Lapse | 7.00 – 9.60 |
| CSSFontFace | Lapse | 7.00 – 11.02 |
| CSSFontFace | Netctrl | 9.00 – 11.02 |
| Slopkit | Lapse | 10.00 – 12.02 |
| Slopkit | Netctrl | 12.50 – 13.00 |
| Slopkit | Relapse | 12.50 – 13.52 |
| **Slopkit** | **Afterglow** | **14.00 – 14.02** |

The other chains are inherited from WebKitty and are not the focus of this build. On 14.02 only Slopkit Afterglow is valid.

---

## How to run

### 1. Serve this folder from your computer

You need Python 3, and the PS4 and computer must be on the same LAN.

```bash
git clone https://github.com/TechVenom/ps414.02venomx.git
cd ps414.02venomx
sh serve.sh
```

`serve.sh` listens on port `8000` and prints the address to use:

```
webkitty (local) on http://192.168.x.x:8000/  (ctrl-c to stop)
```

Use a different port with:

```bash
PORT=8080 sh serve.sh
```

Use `serve.sh` rather than `python3 -m http.server`. The PS4 browser needs:

- `.manifest` served as `text/cache-manifest` (AppCache),
- `.bin` / `.elf` served as `application/octet-stream`,
- `no-store` on code, so a corrected file is never served from cache.

If your checkout does not have the executable bit, `sh serve.sh` works as-is. `./serve.sh` works only after `chmod +x serve.sh`.

### Hosted copy (no computer needed)

The same tree is published from this repository by GitHub Pages:

**https://techvenom.github.io/ps414.02venomx/**

Open that in the PS4 browser and follow the same steps. The 14.0x chain fetches GoldHEN from the same origin and injects it in-process, so no LAN server is involved. The page is HTTPS-only: extra payloads that talk to GoldHEN's binloader on port `9090` may be blocked as mixed content there, so use the `serve.sh` host for those.

### 2. Open the host on the PS4

1. Open the PS4 **Browser** and go to `http://<computer-lan-ip>:8000/` — use `http`, not `https`.
2. The firmware line should turn green and show `14.0x`.
3. Choose **GoldHEN** as the HEN flavor.
4. Choose GoldHEN **2.4b18.14** (or **2.4b18.13**). The selector refuses older versions on 14.02.
5. Leave **Exploit Chain** on **Slopkit Afterglow**. It is selected automatically for 14.00/14.02.

Optional settings on the same screen:

- **Update Cache** — caches the 14.0x manifest (`includes/caches/manifest/140x.manifest`) for faster/offline reloads.
- **Auto Jailbreak** — starts the chain after a short countdown.
- **Auto-Retry Jailbreak** — retries after an unsuccessful attempt.
- **Barebone Jailbreak Experience** — runs the chain in `exploit.html` with a minimal DOM and returns to the index afterwards.
- **Reload After a successful Jailbreak** — reloads the page once the chain reports success.

### 3. Run the exploit

Press the play button in the **Exploit** panel (or let Auto Jailbreak start it). Keep the page open while the log runs.

A successful run ends with the jailbreak-success message, and — when GoldHEN is injected — GoldHEN's own notification. The page can then be closed or reloaded according to your settings.

### 4. Load payloads

After GoldHEN is running:

- The payload grid sends `.bin` payloads to GoldHEN's binloader on **port 9090**.
- **Do not use `.elf` payloads or the Elf Loader on 14.02** (see the limitations above).
- To send payloads from a phone or another computer, open the same host URL on that device. Local-server mode shows the PS4 IP field and firmware selector; enter the PS4's LAN IP, pick 14.02, and use the payload grid.

### 5. If the run fails

- **Failure before the kernel stage** costs nothing — reopen the browser and run again. Within a run the host already retries the WebKit stage.
- **If the log shows the kernel stage was entered and then failed**, reboot the console before trying again. Do not just reload.
- **If the console becomes unresponsive**, power-cycle it and start over.

---

## Payloads and ports

| Service | Port | Works on 14.02 |
| :--- | :---: | :--- |
| GoldHEN binloader (`.bin`) | **9090** | Yes — use this |
| Elf Loader `elfldr` (`.elf`) | 9021 | No — limited to 14.00 and below |
| Legacy chain binloader | 9020 | No — belongs to the PSFree/BPF chains |

The `9020` listener referenced by older WebKitty documentation is the legacy in-chain binloader. It is not the payload path used by Afterglow on 14.02.

---

## Troubleshooting

| Symptom | Cause / fix |
| :--- | :--- |
| Page does not load on the PS4 | Use `http://<lan-ip>:8000/`, not `https`; check both devices are on the same subnet and the computer firewall allows the port. |
| Firmware line is orange/red or says unsupported | This build only has a stage for 14.00/14.02. Make sure you are in the PS4 browser, not a desktop browser. |
| `Update Cache` hangs or fails | Serve through `serve.sh`; a plain static server sends `.manifest` as `application/octet-stream` and AppCache refuses it. |
| Exploit fails or the page stalls | Reopen the browser and run again; the WebKit stage is probabilistic and already retries. After a kernel-stage failure, reboot. |
| Elf Loader / `.elf` payload does nothing | Expected on 14.02 — use `.bin` payloads through GoldHEN on 9090. |
| Redirected back to the index page | The browser restored the exploit page without a landing-page click; the guard refuses to run unattended. Start again from the index. |

---

## Repository layout

```
index.html                  Host UI
exploit.html                Minimal "Barebone" runner
serve.sh                    LAN host with the MIME types the PS4 browser expects
includes/js/                Host logic (firmware detection, chains, payloads, cache)
includes/payloads/          GoldHEN, bin and elf payloads
includes/caches/            Per-firmware AppCache pages and manifests
src/slopkit-afterglow/      Slopkit + Afterglow chain used by 14.00–14.02
src/kpatches/               Per-firmware GoldHEN patch sets
```

---

## Building the legacy bundle

`includes/js/jailbreak-legacy.js` is generated from `includes/js/jailbreak.js`:

```bash
npm install
npm run build
```

If you add a file that the 14.0x chain needs, add it to `includes/caches/manifest/140x.manifest` as well.

---

## Screenshots

<details>
<summary><b>Click here to view Screenshots & Previews</b></summary>
<br>

<table align="center" style="border: none;">
  <tr>
    <td align="center" style="border: none;">
      <img src="includes/assets/showcase/default-layout-1.png" width="350" alt="Default Layout: Initial Screen">
      <br>
      <b>Default Layout: Initial Screen</b>
    </td>
    <td align="center" style="border: none;">
      <img src="includes/assets/showcase/default-layout-2.png" width="350" alt="Default Layout: Exploit Screen">
      <br>
      <b>Default Layout: Exploit Screen</b>
    </td>
  </tr>
  <tr>
    <td align="center" style="border: none;">
      <img src="includes/assets/showcase/compact-layout.png" width="350" alt="Compact Layout (Combined)">
      <br>
      <b>Compact Layout (Combined)</b>
    </td>
    <td align="center" style="border: none;">
      <img src="includes/assets/showcase/compact-layout-vibrant.png" width="350" alt="Compact Layout (Combined, Vibrant)">
      <br>
      <b>Compact Layout (Vibrant)</b>
    </td>
  </tr>
  <tr>
    <td align="center" style="border: none;">
      <img src="includes/assets/showcase/settings-vibrant.png" width="350" alt="Settings">
      <br>
      <b>Settings</b>
    </td>
    <td align="center" style="border: none;">
      <img src="includes/assets/showcase/about-vibrant.png" width="350" alt="About">
      <br>
      <b>About</b>
    </td>
  </tr>
  <tr>
    <td align="center" style="border: none;">
      <img src="includes/assets/showcase/customization-vibrant.png" width="350" alt="Customization">
      <br>
      <b>Customization</b>
    </td>
    <td align="center" style="border: none;">
      <img src="includes/assets/showcase/about-catppuccino.png" width="350" alt="About Catppuccino">
      <br>
      <b>About Catppuccino</b>
    </td>
  </tr>
  <tr>
    <td align="center" style="border: none;">
      <img src="includes/assets/showcase/catppuccino-layout-1.png" width="350" alt="Catppuccino">
      <br>
      <b>Catppuccino: Initial Screen</b>
    </td>
    <td align="center" style="border: none;">
      <img src="includes/assets/showcase/catppuccino-layout-2.png" width="350" alt="Catppuccino">
      <br>
      <b>Catppuccino: Exploit Screen</b>
    </td>
  </tr>
</table>

</details>

---

## Contribution

- Translations live in [`includes/js/languages`](includes/js/languages).
- New or modified host features belong in `includes/js`.
- If your PR edits `includes/js/jailbreak.js`, regenerate `jailbreak-legacy.js` with `npm install && npm run build`.
- If your PR adds a file used by a chain, add it to the matching `includes/caches/manifest/*.manifest`.
- Report bugs via [issues](https://github.com/TechVenom/ps414.02venomx/issues).

---

## Credits

- **abc** — PSFree userland and Lapse kernel exploits.
- **Al-Azif** — modular PSFree Lapse and AIO workaround implementations.
- **anonymous** — PS4 firmware kernel dumps.
- **Dr.Yenyen** — intensive multi-firmware testing.
- **Egycnq** — porting Netctrl to Slopkit.
- **Feyzee61** — PSFree Lapse bundle and 6.7x exploit implementations.
- **Fire30** — Bad Hoist userland exploit.
- **GattoDev** — WebKitty logo.
- **Jordy and Sonic-Iso** — original Slopkit project.
- **Nathan Fargo and ufm42** — CSSFontFace userland exploit.
- **Payload developers** — their payloads.
- **Nazky** — first host I took a peek at.
- **qwertyoruiopz** — BPF double free.
- **Raw Game** — PS4 port of Slopkit Lapse/Netctrl and Slopkit Relapse.
- **sleirsgoevy** — 6.7x kernel exploit.
- **TheFlow** — Netctrl kernel exploit.
- **ufm42** — CSSFontFace Netctrl and Lapse implementations.
- **m0zz** — Slopkit Afterglow source.
- **ArabPixel** — WebKitty, which this fork is built on.

Check the appropriate files for any **extra** contributors.

---

## License

AGPL-3.0-or-later (see [LICENSE](LICENSE)). Parts of this repository belong to the group `anonymous`; anonymous contributors are referred to as "anonymous" as well.
