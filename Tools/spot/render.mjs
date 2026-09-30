// Photographs the 3D pig a frame at a time.
//
// Serves the repository over a local port (a module page cannot import from file://),
// opens pig.html under headless Chromium, and for each film asks the page for every
// thirtieth of a second in turn, screenshotting the whole stage — the picture and the
// name and sign laid over it — into out/<film>/frame_0001.png and so on. Writes
// out/beats.json beside them: each film's length and the noises it wants and when, for
// the workflow's ffmpeg.
//
//   node render.mjs [--out DIR] [--film open|end] [--scale 0.35] [--every 6]
//
// --scale renders the stage smaller for a quick look, --every skips frames for the same
// reason; the workflow runs it plain, at 1080 by 1920 and every frame.

import { createServer } from "node:http";
import { readFile, mkdir, writeFile } from "node:fs/promises";
import { extname, join, resolve, dirname } from "node:path";
import { fileURLToPath } from "node:url";
import { chromium } from "playwright";

const here = dirname(fileURLToPath(import.meta.url));
const root = resolve(here, "..", "..");
const args = Object.fromEntries(
  process.argv.slice(2).map((a, i, all) => (a.startsWith("--") ? [a.slice(2), all[i + 1]] : null)).filter(Boolean)
);
const out = resolve(args.out ?? join(here, "out"));
const only = args.film;
const scale = Number(args.scale ?? 1);
const every = Number(args.every ?? 1);
const fps = 30;

const types = { ".html": "text/html", ".js": "text/javascript", ".png": "image/png", ".woff2": "font/woff2" };
const server = createServer(async (req, res) => {
  try {
    const path = join(root, decodeURIComponent(new URL(req.url, "http://x").pathname));
    if (!path.startsWith(root)) throw new Error("outside");
    const body = await readFile(path);
    res.writeHead(200, { "content-type": types[extname(path)] ?? "application/octet-stream" });
    res.end(body);
  } catch {
    res.writeHead(404); res.end();
  }
});
await new Promise((r) => server.listen(0, "127.0.0.1", r));
const port = server.address().port;

const browser = await chromium.launch({
  args: ["--use-angle=swiftshader", "--enable-unsafe-swiftshader", "--ignore-gpu-blocklist"]
});
const page = await browser.newPage({
  viewport: { width: Math.round(1080 * scale), height: Math.round(1920 * scale) },
  deviceScaleFactor: 1
});
page.on("pageerror", (e) => { console.error("page error:", e.message); process.exitCode = 1; });
await page.goto(`http://127.0.0.1:${port}/Tools/spot/pig.html`);
await page.evaluate(() => window.spot.ready);
if (scale !== 1) await page.evaluate((s) => { document.getElementById("stage").style.transform = `scale(${s})`; }, scale);

const segments = await page.evaluate(() => window.spot.segments());
await mkdir(out, { recursive: true });
await writeFile(join(out, "beats.json"), JSON.stringify({ fps, films: segments }, null, 2));

for (const [name, film] of Object.entries(segments)) {
  if (only && name !== only) continue;
  const dir = join(out, name);
  await mkdir(dir, { recursive: true });
  const frames = Math.round(film.length * fps);
  const started = Date.now();
  for (let i = 0; i < frames; i += every) {
    await page.evaluate(([n, t]) => window.spot.render(n, t), [name, i / fps]);
    await page.screenshot({ path: join(dir, `frame_${String(i + 1).padStart(4, "0")}.png`), clip: { x: 0, y: 0, width: 1080 * scale, height: 1920 * scale } });
  }
  console.log(`${name}: ${Math.ceil(frames / every)} frames in ${((Date.now() - started) / 1000).toFixed(1)}s`);
}

await browser.close();
server.close();
