# VS Code Debugging Guide

This guide explains how to debug the Typo Payments demo application in VS Code.

## 🚀 Quick Start

1. **Stop Docker container** (if running):
   ```bash
   docker compose down
   ```

2. **Open VS Code** in the project directory:
   ```bash
   code /Users/cmullineaux/source/vuln_slam_demo
   ```

3. **Install dependencies locally**:
   ```bash
   pip3 install -r requirements.txt
   ```

4. **Press F5** or go to Run → Start Debugging

5. **Select** "Python: Flask" configuration

6. Application will start at **http://localhost:5000**

---

## 🐛 Debug Configurations

### 1. Python: Flask (Recommended)
- **Use**: Standard Flask debugging
- **Features**: 
  - Runs on port 5000
  - No auto-reload (better for debugging)
  - Breakpoints work perfectly
  - Jinja template debugging enabled
- **How to use**: Press F5, select this option

### 2. Python: Flask (with reload)
- **Use**: When you want auto-reload on file changes
- **Features**: 
  - Auto-reloads on code changes
  - May restart debugger on changes
- **Note**: Breakpoints may disconnect on reload

### 3. Python: Direct app.py
- **Use**: Run app.py directly (not through Flask CLI)
- **Features**: 
  - Direct execution
  - Good for debugging startup issues
- **How to use**: Select from debug dropdown

### 4. Python: Current File
- **Use**: Debug any Python file (init_db.py, reset_db.py, etc.)
- **Features**: 
  - Runs whatever file is currently open
  - Good for testing database scripts

---

## 📁 Configuration Files Created

### `.vscode/launch.json`
Defines debug configurations. You can select different configurations from the debug dropdown.

### `.vscode/settings.json`
VS Code Python and workspace settings:
- Sets Python interpreter path
- Configures Jinja template support
- Hides Python cache files
- Disables auto-formatting (for demo code)

### `.env`
Flask environment variables:
- `FLASK_APP=app.py`
- `FLASK_ENV=development`
- `FLASK_DEBUG=1`

---

## 🔧 Setup Steps

### 1. Install Python Dependencies

**Option A: System-wide**
```bash
pip3 install -r requirements.txt
```

**Option B: Virtual Environment (Recommended)**
```bash
# Create virtual environment
python3 -m venv venv

# Activate it
source venv/bin/activate  # macOS/Linux
# or
.\venv\Scripts\activate  # Windows

# Install dependencies
pip install -r requirements.txt
```

### 2. Initialize Database
```bash
python3 init_db.py
```

### 3. Start Debugging
Press **F5** or click the green play button in the debug panel.

---

## 🎯 Setting Breakpoints

### In Python Code
1. Click in the left margin (gutter) next to line numbers
2. Red dot appears = breakpoint set
3. Press F5 to start debugging
4. Code will pause when breakpoint is hit

### Example: Debug Search Function
1. Open `app.py`
2. Go to line ~171 (inside `search()` function)
3. Click gutter to add breakpoint
4. Run debugger
5. Visit http://localhost:5000/search?q=test
6. Debugger will pause at breakpoint

### In Jinja Templates
1. Open any `.html` file in `templates/`
2. Set breakpoints on template logic
3. Works with `"jinja": true` in launch.json

---

## 🔍 Debug Features

### Inspect Variables
When paused at a breakpoint:
- **Variables panel** (left sidebar): See all local variables
- **Hover over variables** in code: See their values
- **Watch panel**: Add expressions to monitor

### Debug Console
- Bottom panel when debugging
- Type Python expressions to evaluate
- Examples:
  ```python
  query
  current_user.id
  len(results)
  conn.execute("SELECT * FROM users").fetchall()
  ```

### Call Stack
- See the full function call chain
- Click frames to inspect different levels
- Useful for understanding request flow

### Step Controls
- **Continue (F5)**: Run to next breakpoint
- **Step Over (F10)**: Execute current line, don't enter functions
- **Step Into (F11)**: Enter function calls
- **Step Out (Shift+F11)**: Exit current function
- **Restart (Ctrl+Shift+F5)**: Restart debugger
- **Stop (Shift+F5)**: Stop debugging

---

## 🐞 Debugging Common Issues

### Issue: "Module flask not found"
**Solution**: Install dependencies
```bash
pip3 install -r requirements.txt
```

### Issue: "Port 5000 already in use"
**Solution**: Stop Docker container
```bash
docker compose down
```

Or kill process on port 5000:
```bash
lsof -ti:5000 | xargs kill -9
```

### Issue: "Database locked"
**Solution**: Close any other connections or recreate DB
```bash
rm typo_payments.db
python3 init_db.py
```

### Issue: Breakpoints not hitting
**Solution**: 
1. Make sure you selected "Python: Flask" config
2. Check breakpoint is not grayed out
3. Ensure file is saved
4. Try "Restart Debugging"

### Issue: Can't see template variables
**Solution**: Make sure `"jinja": true` is in launch.json (already set)

---

## 💡 Debugging Workflow Examples

### Debug SQL Injection
1. Set breakpoint at line ~186 (`check_status()` function)
2. Start debugger (F5)
3. Visit: http://localhost:5000/status?id=1
4. Inspect `payment_id` variable
5. Step through SQL query construction
6. Watch how string formatting works
7. Try SQLi payload: `?id=1 OR 1=1--`
8. See how query becomes vulnerable

### Debug XSS
1. Set breakpoint at line ~171 (`search()` function)
2. Start debugger
3. Visit: http://localhost:5000/search?q=<script>alert('XSS')</script>
4. Inspect `query` variable
5. Step to `render_template()`
6. See how unsanitized input reaches template

### Debug Authentication
1. Set breakpoint in `login()` function
2. Try logging in
3. Inspect `username`, `password` variables
4. Step through `check_password_hash()`
5. Watch session cookie creation

### Debug Admin Functions
1. Set breakpoint in `toggle_admin()` function
2. Start debugger
3. Login as admin
4. Try toggling admin privileges
5. Watch database updates

---

## 🎓 Learning with Debugger

### Understand Request Flow
1. Set breakpoint at `@app.route("/search")`
2. Make request
3. Step through entire function
4. See Flask internals

### Inspect Database Queries
1. Set breakpoint before `conn.execute()`
2. Check query string in Variables panel
3. Step over execution
4. Inspect `results`

### Watch Template Rendering
1. Set breakpoint at `render_template()`
2. Inspect template variables
3. Step into to see Jinja2 processing

---

## 🔄 Debugging vs Docker

### When to Use Debugger
✅ Active development  
✅ Understanding code flow  
✅ Finding bugs  
✅ Learning how app works  
✅ Testing specific scenarios  

### When to Use Docker
✅ Demonstrating to others  
✅ Production-like environment  
✅ Easy deployment  
✅ Consistent environment  
✅ Quick demos  

### Running Both
You can switch between them:

**Stop Docker, Start Debugger:**
```bash
docker compose down
# Press F5 in VS Code
```

**Stop Debugger, Start Docker:**
```bash
# Press Shift+F5 in VS Code
docker compose up
```

---

## ⌨️ Keyboard Shortcuts

| Action | macOS | Windows/Linux |
|--------|-------|---------------|
| Start Debugging | F5 | F5 |
| Stop Debugging | Shift+F5 | Shift+F5 |
| Restart | Cmd+Shift+F5 | Ctrl+Shift+F5 |
| Step Over | F10 | F10 |
| Step Into | F11 | F11 |
| Step Out | Shift+F11 | Shift+F11 |
| Continue | F5 | F5 |
| Toggle Breakpoint | F9 | F9 |
| Show Debug Console | Cmd+Shift+Y | Ctrl+Shift+Y |

---

## 📝 Tips & Tricks

### Conditional Breakpoints
Right-click breakpoint → Edit Breakpoint → Add condition
```python
# Only break when query contains 'admin'
'admin' in query

# Only break for specific user
current_user.id == 1
```

### Log Points
Right-click gutter → Add Logpoint
```python
Query: {query}, User: {current_user.id}
```
Logs to Debug Console without stopping execution.

### Debug Configuration Variables
In launch.json, you can use:
- `${workspaceFolder}` - Project root
- `${file}` - Current file
- `${fileBasename}` - Current filename

### Hot Reload Configuration
If you want code changes to reload automatically, use "Python: Flask (with reload)" configuration.

### Debug External Requests
Use breakpoints + tools like:
- Browser DevTools
- Burp Suite
- Postman
- curl

---

## 🎯 Demo-Specific Debugging

### Debugging SQL Injection Demo
```python
# In check_status() function
# Set breakpoint at query construction
query = f"SELECT * FROM payments WHERE id = {payment_id} AND user_id = {current_user.id}"

# Watch Variables:
# - payment_id (shows injection payload)
# - query (shows constructed SQL)
# - payment (shows query results)
```

### Debugging XSS Demo
```python
# In search() function
# Set breakpoint at template render
return render_template("search.html", query=query, results=results)

# Watch Variables:
# - query (contains XSS payload)
# - results (database results)

# Then check templates/search.html
# See how {{ query|safe }} renders
```

### Debugging Admin Functions
```python
# In toggle_admin() function
# Watch privilege changes in real-time
new_status = 0 if user["is_admin"] else 1

# Variables to watch:
# - user_id
# - user (before change)
# - new_status
# - user (after database update)
```

---

## 🚨 Troubleshooting

### Debugger Won't Start
1. Check Python extension is installed
2. Verify Python interpreter: Cmd+Shift+P → "Python: Select Interpreter"
3. Check no syntax errors in app.py
4. Ensure dependencies installed

### Breakpoints Ignored
1. Save file first
2. Check it's not a comment line
3. Verify "justMyCode": false in launch.json
4. Restart debugger

### Can't Access localhost:5000
1. Check debugger is running
2. Look for "Running on http://0.0.0.0:5000" in terminal
3. Try http://127.0.0.1:5000
4. Check firewall settings

### Database Issues
```bash
# Recreate database
rm typo_payments.db
python3 init_db.py
```

---

## 📚 Additional Resources

- [VS Code Python Debugging](https://code.visualstudio.com/docs/python/debugging)
- [Flask Debug Mode](https://flask.palletsprojects.com/en/2.3.x/debugging/)
- [Debugpy Documentation](https://github.com/microsoft/debugpy)

---

## ✅ Quick Checklist

Before starting debugging:

- [ ] Docker container stopped (`docker compose down`)
- [ ] Python dependencies installed (`pip3 install -r requirements.txt`)
- [ ] Database initialized (`python3 init_db.py`)
- [ ] VS Code Python extension installed
- [ ] Python interpreter selected
- [ ] Open project folder in VS Code
- [ ] `.vscode/launch.json` exists
- [ ] Press F5 to start

**You're ready to debug!** 🎉

---

**Pro Tip**: Keep Docker for demos, use debugger for development and learning!
