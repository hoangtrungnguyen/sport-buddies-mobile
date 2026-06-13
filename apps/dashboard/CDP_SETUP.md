# Flutter Skill Screenshot Setup Guide

## Enable CDP for flutter_skill Screenshots

### Option 1: Use flutter_skill launch (Recommended)
```bash
cd /path/to/dashboard-app/apps/dashboard
flutter_skill launch . --vm-service-port=50000
```
Then in another terminal:
```bash
flutter_skill screenshot --output screenshot.png
```

### Option 2: Manual Chrome with CDP
```bash
# Stop any running Flutter processes
pkill -f "flutter run"

# Launch Chrome with remote debugging enabled
/Applications/Google\ Chrome.app/Contents/MacOS/Google\ Chrome \
  --remote-debugging-port=9222 \
  http://localhost:8090 &

# Start flutter_skill server pointing to that Chrome
flutter_skill serve http://localhost:8090

# In another terminal, take screenshot
flutter_skill screenshot --output screenshot.png
```

### Option 3: Flutter Web with DevTools
```bash
# Run with explicit VM service port

# Connect flutter_skill
flutter_skill serve http://localhost:8090
```

## Troubleshooting

**Error: "Chrome is running but remote debugging is not enabled"**
- Chrome must be launched with `--remote-debugging-port=9222`
- Or use `flutter_skill launch` which handles this automatically

**Port already in use (9222, 3000)?**
```bash
lsof -ti:9222 | xargs kill -9
lsof -ti:3000 | xargs kill -9
```

**Flask/socket errors?**
- Ensure no other flutter_skill processes are running
- Kill all chrome instances: `pkill -f chrome`
- Try different port: `flutter_skill serve http://localhost:8090 --cdp-port=9223`

## Quick Test
```bash
flutter_skill demo  # Try built-in demo (zero setup)
flutter_skill quickstart  # 30-second guided demo
```

## References
- https://pub.dev/packages/flutter_skill
- flutter_skill version: 0.9.36
- Chrome DevTools Protocol (CDP) required for screenshots
