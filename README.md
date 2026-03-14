# StandupTimer 🐱

A minimal macOS menu bar app that reminds you to stand up and stretch.

![macOS 13+](https://img.shields.io/badge/macOS-13%2B-blue) ![Swift 5.9](https://img.shields.io/badge/Swift-5.9-orange) ![RAM ~5-10 MB](https://img.shields.io/badge/RAM-~5--10%20MB-green)

## Features

- **Menu bar countdown** — stretching cat icon with a 60-second countdown before each reminder
- **Silent notifications** — fun themed messages and cute illustrations (no annoying sounds)
- **1-click logging** — tap "Done!" on the notification or left-click the cat icon
- **Snooze** — re-notifies every 30 min if you ignore it
- **Sleep/wake aware** — timer resets on wake; sleep time isn't counted as sitting
- **Fully local** — zero network calls, zero cloud, zero external dependencies
- **Tiny footprint** — ~5-10 MB RAM, single Swift file

## Notification Themes

Each reminder comes with a random fun message from one of these themes:

🧍 Stand up · 💧 Drink water · 🦴 Lower back pain · 📋 Product management · 🎧 Vibe coding · 🚀 Startup · 🏈 American football · 🎉 Party people · 💰 Fintech · 🐱 Cats

## Install & Run

```bash
git clone https://github.com/janeyip-gif/local-standup-timer.git
cd local-standup-timer
chmod +x build.sh
./build.sh
open StandupTimer.app
```

Requires macOS 13+ and Swift 5.9+ (included with Xcode or Command Line Tools).

## Usage

| Action | How |
|--------|-----|
| **Log a standup** | Left-click the cat icon, or tap "Done!" on the notification |
| **Open settings** | Right-click the cat icon |
| **Change interval** | Right-click → "Set Interval..." |
| **View log** | Right-click → "View Log..." |
| **Quit** | Right-click → "Quit" |

### Menu Bar States

| State | Display |
|-------|---------|
| Timer running (>60s left) | 🐱 (cat icon) |
| Last 60 seconds | 🐱 `0:59` → `0:01` |
| Overdue / awaiting log | 🐱 `--:--` |

## Data Storage

All data lives in `~/Library/Application Support/StandupTimer/`:

- `config.json` — interval setting (default: 60 min)
- `standups.csv` — append-only log of standup timestamps

## Launch at Login

Add `StandupTimer.app` to **System Settings → General → Login Items**.

## License

MIT
