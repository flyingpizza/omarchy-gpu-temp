# GPU Temp

A [Omarchy](https://omarchy.org/) / [Hyprland](https://hypr.land/) status bar plugin that shows real-time GPU temperatures for all active NVIDIA GPUs.

Displays each GPU's temperature with color-coded heat levels, directly in your status bar. Toggle between Celsius and Fahrenheit from the plugin settings. Click to see a detail panel with per-GPU temperature bars.

## Features

- **Real-time monitoring** — Polls `nvidia-smi` every few seconds (configurable)
- **Color-coded temps** — Foreground/accent/urgent colors based on heat
- **C/F toggle** — Temperature unit selectable from the plugin settings
- **Detail panel** — Click for per-GPU names, temperatures, and meters
- **Multi-GPU support** — Shows every detected GPU in the bar and panel
- **Theme-aware** — Uses your Omarchy theme's colors
- **Graceful degradation** — Hidden when no NVIDIA GPUs are present

## Install

```bash
omarchy plugin add https://github.com/flyingpizza/omarchy-gpu-temp.git --enable
```

After installing, the plugin appears on the right side of your bar. Move it if needed:

```bash
# Center placement
omarchy bar move daitos.gpu-temp --section center --after omarchy.clock

# Left placement
omarchy bar move daitos.gpu-temp --section left --after omarchy.workspaces

# Right placement (default)
omarchy bar move daitos.gpu-temp --section right
```

## Requirements

- [Omarchy](https://omarchy.org/) Quattro with Quickshell
- An NVIDIA GPU with the `nvidia-smi` tool (driver installed)
- `python3` (standard library only)

## Configuration

Click the plugin in the bar to open settings:

| Setting | Default | Description |
|---------|---------|-------------|
| Temperature unit | `C` | Display unit: `C` or `F` |
| Refresh interval | `3` seconds | How often to poll nvidia-smi |

## Color Behavior

| Temperature | Color | Meaning |
|-------------|-------|---------|
| ≤ 70 °C | Foreground | Normal |
| 71–80 °C | Accent | Warm |
| > 80 °C | Urgent | Hot |

## Display Format

### Bar
```
🖥️ NVIDIA GeForce RTX 4090  68°C
```

Multi-GPU (one entry per GPU):
```
🖥️ NVIDIA GeForce RTX 4090  68°C  🖥️ NVIDIA T500  41°C
```

### Hover tooltip
```
NVIDIA GeForce RTX 4090  68°C
  ·  NVIDIA T500  41°C
```

### Click panel
```
GPU Temperatures
─────────────────
🖥️ NVIDIA GeForce RTX 4090  68°C
🖥️ NVIDIA T500  41°C
─────────────────
Click to close  ·  Click bar widget to refresh
```

## How It Works

1. A timer fires every 3 seconds (configurable)
2. The plugin runs `collect.py`, which calls `nvidia-smi --query-gpu=name,temperature.gpu --format=csv,noheader`
3. `collect.py` parses the CSV and prints JSON to stdout: `[{"name": "...", "tempC": 68.0}]`
4. `Model.js` parses the JSON into a snapshot, tracking the hottest GPU
5. The bar widget and detail panel render each GPU with its color-coded temperature

## Development

Run the collector directly to test:

```bash
python3 collect.py
```

Expected output (one JSON line, one entry per GPU):

```json
[{"name": "NVIDIA GeForce RTX 4090", "tempC": 68.0}]
```

If nvidia-smi is missing or no GPUs are present, the output is `[]`.

## Uninstall

```bash
omarchy plugin remove daitos.gpu-temp
```

## License

MIT

## Author

daitos
