# Contributing

Thanks for wanting to contribute to GPU Temp!

## Submitting Issues

- Check existing issues before filing a new one
- Include your GPU model, driver version, and Omarchy version
- For data or display problems, include the output of `python3 collect.py`

## Submitting Pull Requests

1. Fork the repo and create a branch
2. Edit files directly
3. Test with `python3 collect.py`
4. Submit a pull request with a short description of the change

## Code Style

- Follow the existing plugin conventions (see the standard omarchy plugin structure: `manifest.json`, `BarWidget.qml`, `Panel.qml`, `Model.js`, `collect.py`)
- Python: standard library only, no dependencies
- JavaScript: ES5 compatible (for Quickshell compatibility)
- QML: follow Quickshell conventions
- Comments: explain WHY not WHAT

## Testing

Run the collector locally:
```bash
python3 collect.py
```

Check the output is valid JSON: an array of `{"name": ..., "tempC": ...}` objects (one per GPU), or `[]` if no NVIDIA GPUs are present.

## License

By contributing, you agree to license your work under MIT.
