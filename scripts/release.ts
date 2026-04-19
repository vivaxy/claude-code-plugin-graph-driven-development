import { execSync } from "node:child_process";
import { type Dirent, readdirSync, readFileSync, writeFileSync } from "node:fs";
import { join } from "node:path";

type BumpType = "major" | "minor" | "patch";

interface PluginJson {
  name: string;
  version: string;
  [key: string]: unknown;
}

interface MarketplacePlugin {
  name: string;
  version: string;
  [key: string]: unknown;
}

interface MarketplaceJson {
  plugins: MarketplacePlugin[];
  [key: string]: unknown;
}

const rawBumpType = process.argv[2] ?? "patch";
if (!["major", "minor", "patch"].includes(rawBumpType)) {
  console.error(`Unknown bump type: ${rawBumpType}. Use major, minor, or patch.`);
  process.exit(1);
}
const bumpType = rawBumpType as BumpType;

function bumpVersion(version: string, type: BumpType): string {
  const [major, minor, patch] = version.split(".").map(Number);
  if (type === "major") return `${major + 1}.0.0`;
  if (type === "minor") return `${major}.${minor + 1}.0`;
  return `${major}.${minor}.${patch + 1}`;
}

function exec(cmd: string): string {
  return execSync(cmd, { encoding: "utf8" }).trim();
}

function run(cmd: string): void {
  execSync(cmd, { stdio: "inherit" });
}

function hasChanges(pluginName: string, currentVersion: string): boolean {
  const tag = `${pluginName}-v${currentVersion}`;
  try {
    const diff = exec(`git diff ${tag} HEAD -- plugins/${pluginName}/`);
    return diff.length > 0;
  } catch {
    return true;
  }
}

const pluginDirs = readdirSync("plugins", { withFileTypes: true })
  .filter((d: Dirent) => d.isDirectory())
  .map((d: Dirent) => d.name);

const marketplacePath = ".claude-plugin/marketplace.json";
const marketplace: MarketplaceJson = JSON.parse(readFileSync(marketplacePath, "utf8"));

let anyReleased = false;

for (const pluginName of pluginDirs) {
  const pluginJsonPath = join("plugins", pluginName, ".claude-plugin", "plugin.json");
  const pluginJson: PluginJson = JSON.parse(readFileSync(pluginJsonPath, "utf8"));

  if (!hasChanges(pluginName, pluginJson.version)) {
    console.log(`${pluginName}: no changes since ${pluginName}-v${pluginJson.version}, skipping.`);
    continue;
  }

  const newVersion = bumpVersion(pluginJson.version, bumpType);
  const newTag = `${pluginName}-v${newVersion}`;
  console.log(`${pluginName}: ${pluginJson.version} → ${newVersion}`);

  pluginJson.version = newVersion;
  writeFileSync(pluginJsonPath, JSON.stringify(pluginJson, null, 2) + "\n");

  const entry = marketplace.plugins.find((p) => p.name === pluginName);
  if (!entry) {
    console.error(`No marketplace entry found for plugin: ${pluginName}`);
    process.exit(1);
  }
  entry.version = newVersion;
  writeFileSync(marketplacePath, JSON.stringify(marketplace, null, 2) + "\n");

  run(`git add ${pluginJsonPath} ${marketplacePath}`);
  run(`git commit -m "chore(${pluginName}): release v${newVersion}"`);
  run(`git tag ${newTag}`);
  run("git push");
  run("git push --tags");

  console.log(`Released ${newTag}`);
  anyReleased = true;
}

if (!anyReleased) {
  console.log("No plugins to release.");
}
