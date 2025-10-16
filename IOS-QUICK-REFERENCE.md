# iOS Shortcuts - Quick Reference Card

**Save this to your phone for quick access!**

---

## 🚀 Build Something

**URL**: `http://192.168.5.76:3100/build`

**Method**: POST

**Body**:
```json
{
  "idea": "Build me a [your idea here]"
}
```

---

## 📱 iOS Shortcut Setup (2 minutes)

1. **Ask for Input**
   - Prompt: "What do you want to build?"

2. **Get Contents of URL**
   - URL: `http://192.168.5.76:3100/build`
   - Method: POST
   - Headers: `Content-Type: application/json`
   - Body: `{"idea":"[Provided Input]"}`

3. **Show Result**
   - Display the response

**Done!** Run it and type your idea.

---

## 💡 Example Ideas

Copy-paste these:

```
Build me a button component
```

```
Create a user profile card with avatar and bio
```

```
Make a responsive navigation bar
```

```
Build a todo list with add, delete, and complete
```

```
Create a login form with email validation
```

---

## 📊 Check Status

**URL**: `http://192.168.5.76:3100/workflow/[workflowId]`

**Tip**: Save the workflowId from the build response!

---

## ⚡ Quick Tests

**Health Check**:
```
http://192.168.5.76:3100/health
```

**See All Workflows**:
```
http://192.168.5.76:3100/inbox
```

---

## 🐛 Troubleshooting

**Can't connect?**
- Check WiFi (must be on same network)
- Test health URL in Safari first

**Nothing happening?**
- Pollers may be stopped
- Check back in 15 minutes

---

## 🎯 What You Get

**After ~15 minutes**:
- ✅ Fully implemented component
- ✅ TypeScript + React
- ✅ Tested and ready to use

**Check results**:
```bash
cd ~/pinkyandbrain/workflow-output/
```

---

## 🔥 Pro Tips

1. **Be specific** - "Button with icon and loading state" > "Button"
2. **Use description field** for extra details
3. **Save workflowIds** to track multiple builds
4. **Build while commuting** - it's done when you arrive!

---

**Network**: `192.168.5.76:3100`
**Endpoint**: `/build`
**Method**: POST
**Response**: ~15 minutes

**Build from anywhere! 📱→🧠⚡**
