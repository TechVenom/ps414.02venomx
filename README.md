<div align="center">

# ps414.02venomx

<img src="includes/assets/icons/ps4-venomx.svg" width="240" alt="PS4 VenomX Logo">

**PS4 14.02 exploit host: Slopkit userland + Afterglow kernel, loading GoldHEN.**

Based on [WebKitty](https://github.com/ArabPixel/WebKitty).

</div>

---

## What it is

For firmware **14.00 – 14.02**:

| Stage | What it does |
| :--- | :--- |
| **Slopkit** | WebKit userland exploit; gives arbitrary read/write (`window.p`) |
| **Afterglow** | Kernel stage; patches the kernel and opens the rwx/kexec gate |
| **GoldHEN** | Fetched from this host and injected in-process from a `.bin` |

The host selects **Slopkit Afterglow** automatically. Leave it selected.

## Run

### Hosted (no computer needed)

Open this in the PS4 browser:

**https://techvenom.github.io/ps414.02venomx/**

### Local

```bash
git clone https://github.com/TechVenom/ps414.02venomx.git
cd ps414.02venomx
sh serve.sh
```

Open `http://<computer-lan-ip>:8000/` in the PS4 browser — `http`, not `https`.

Use `serve.sh`, not a plain static server: the PS4 browser needs `.manifest` served as `text/cache-manifest`.

## Steps

1. The firmware line turns green and shows `14.0x`.
2. Keep **Slopkit Afterglow** selected and pick GoldHEN **2.4b18.14**.
3. Start the exploit and keep the page open while it runs.
4. If it fails **before** the kernel stage, reload and run again.
5. If the kernel stage was entered and failed, **reboot the console**.

## 14.02 notes

- GoldHEN **2.4b18.14** (default) or **2.4b18.13**; older versions are refused.
- **No `.elf` payloads** — Elf Loader (port 9021) is unsupported on 14.02.
- `.bin` payloads go through GoldHEN's binloader on port **9090**.
- On the hosted HTTPS page, 9090 payloads may be blocked as mixed content; use the local host for those.

## Credits

- **ArabPixel** — WebKitty.
- **m0zz** — Afterglow.
- **Jordy and Sonic-Iso** — Slopkit.
- GoldHEN team — GoldHEN.

Upstream documentation and the other exploit chains live in [WebKitty](https://github.com/ArabPixel/WebKitty).

AGPL-3.0-or-later — see [LICENSE](LICENSE).
