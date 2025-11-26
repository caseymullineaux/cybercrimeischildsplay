# VS Code Debugger - Quick Setup

## 🚀 In 3 Steps

### 1. Stop Docker
```bash
docker compose down
```

### 2. Install Dependencies
```bash
pip3 install -r requirements.txt
python3 init_db.py
```

### 3. Start Debugging
Press **F5** in VS Code

---

## ✅ Configuration Files Created

- `.vscode/launch.json` - Debug configurations
- `.vscode/settings.json` - Python settings
- `.env` - Flask environment variables
- `docs/DEBUGGING.md` - Complete guide

---

## 🎯 Debug Configurations Available

1. **Python: Flask** - Standard debugging (recommended)
2. **Python: Flask (with reload)** - Auto-reload on changes
3. **Python: Direct app.py** - Direct Python execution
4. **Python: Current File** - Debug any open file

Select from dropdown in Debug panel (Cmd+Shift+D)

---

## 🐛 Set Breakpoints

1. Click in left margin (gutter) next to line numbers
2. Red dot = breakpoint
3. Press F5 to start
4. Visit http://localhost:5000
5. Debugger pauses at breakpoint

---

## ⌨️ Key Controls

- **F5** - Start/Continue
- **F10** - Step Over (next line)
- **F11** - Step Into (enter function)
- **Shift+F11** - Step Out (exit function)
- **Shift+F5** - Stop
- **F9** - Toggle breakpoint

---

## 💡 Debug SQLi Demo

1. Set breakpoint in `check_status()` at line ~186
2. Press F5
3. Visit: `http://localhost:5000/status?id=1 OR 1=1--`
4. Inspect variables in left panel
5. Watch SQL query construction

---

## 💡 Debug XSS Demo

1. Set breakpoint in `search()` at line ~171
2. Press F5
3. Visit: `http://localhost:5000/search?q=<script>alert('XSS')</script>`
4. Inspect `query` variable
5. Step through to template rendering

---

## 🔧 Troubleshooting

### Port 5000 in use?
```bash
docker compose down
# or
lsof -ti:5000 | xargs kill -9
```

### Module not found?
```bash
pip3 install -r requirements.txt
```

### Database locked?
```bash
rm typo_payments.db
python3 init_db.py
```

---

## 📚 Full Documentation

See `docs/DEBUGGING.md` for complete guide with examples, tips, and advanced debugging techniques.

---

**Ready!** Press F5 and start debugging! 🎉
