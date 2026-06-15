# Supabase Auth Test Report

**Test Date:** _____________  
**Tester:** _____________  
**Device:** iPhone _____ (iOS _____)  
**Build:** _____________

---

## ✅ Pre-Test Setup

- [ ] Filled `Config/Secrets.xcconfig` with real Supabase credentials
- [ ] Verified URL scheme `augur` in Xcode → Target → Info → URL Types
- [ ] Clean build performed (Cmd+Shift+K)
- [ ] Rebuild performed (Cmd+B)
- [ ] iPhone connected and trusted
- [ ] App installed on iPhone (Cmd+R)
- [ ] Safari test: `augur://test` opens app successfully

**Notes:**
```
[Any issues or observations during setup]
```

---

## Test 1: Sign Up

**Test Steps:**
1. Launch app on iPhone
2. Verify LoginView appears
3. Tap "Don't have an account? Sign Up"
4. Enter email: _________________________
5. Enter password: _________________________
6. Tap "Sign Up"

**Expected Results:**
- [ ] User is signed in
- [ ] Main app content appears
- [ ] Debug panel shows "Authenticated" state
- [ ] Debug panel shows correct email

**Actual Results:**
```
✅ PASS / ❌ FAIL

[Describe what happened]
```

**Screenshots:**
- [ ] Attached

---

## Test 2: Sign Out

**Test Steps:**
1. Open debug panel (top-right)
2. Tap to expand
3. Tap "Sign Out" button

**Expected Results:**
- [ ] LoginView appears
- [ ] Debug panel shows "Unauthenticated" state

**Actual Results:**
```
✅ PASS / ❌ FAIL

[Describe what happened]
```

---

## Test 3: Sign In

**Test Steps:**
1. Enter same email from Test 1
2. Enter same password from Test 1
3. Tap "Sign In"

**Expected Results:**
- [ ] User is signed in
- [ ] Main app appears
- [ ] Debug panel shows "Authenticated" state with correct email

**Actual Results:**
```
✅ PASS / ❌ FAIL

[Describe what happened]
```

---

## Test 4: Password Reset (CRITICAL - Option A)

### 4a. Request Reset Email

**Test Steps:**
1. Sign out (if signed in)
2. Tap "Forgot Password?"
3. Enter email: _________________________
4. Tap "Send Reset Link"

**Expected Results:**
- [ ] Success message appears: "Email Sent! Check your email..."
- [ ] No errors shown

**Actual Results:**
```
✅ PASS / ❌ FAIL

[Describe what happened]
```

**Time email requested:** _________

---

### 4b. Receive and Open Reset Email

**Test Steps:**
1. Open email app **on the iPhone**
2. Wait for Supabase password reset email
3. Open the email

**Expected Results:**
- [ ] Email arrives within 1-2 minutes
- [ ] Email contains reset link
- [ ] Link starts with `augur://auth-callback`

**Actual Results:**
```
✅ PASS / ❌ FAIL

[Describe what happened]

Time email arrived: _________
Link format: _________________________
```

**Screenshots:**
- [ ] Email screenshot attached

---

### 4c. Tap Reset Link (Deep Link Test)

**Test Steps:**
1. Tap the reset link in the email

**Expected Results:**
- [ ] App opens immediately
- [ ] UpdatePasswordView appears
- [ ] Debug panel shows "Password Recovery" state
- [ ] Debug panel shows last deep link URL (starts with `augur://auth-callback`)

**Actual Results:**
```
✅ PASS / ❌ FAIL

[Describe what happened]

Deep link URL (from debug panel):
_________________________
```

**Screenshots:**
- [ ] UpdatePasswordView screenshot
- [ ] Debug panel screenshot

---

### 4d. Set New Password

**Test Steps:**
1. Enter new password: _________________________
2. Enter same password in "Confirm Password"
3. Verify both checkmarks turn green
4. Tap "Update Password"

**Expected Results:**
- [ ] Both checkmarks turn green (password valid + passwords match)
- [ ] Success message appears: "Password Updated!"
- [ ] After ~2 seconds, main app appears
- [ ] Debug panel shows "Authenticated" state

**Actual Results:**
```
✅ PASS / ❌ FAIL

[Describe what happened]
```

---

### 4e. Verify New Password Works

**Test Steps:**
1. Sign out
2. Try to sign in with **old password**
3. Note the result
4. Sign in with **new password**

**Expected Results:**
- [ ] Old password: Error message (invalid credentials)
- [ ] New password: Success, user is signed in

**Actual Results:**
```
✅ PASS / ❌ FAIL

Old password result:
[Describe what happened]

New password result:
[Describe what happened]
```

---

## Test 5: Deep Link (Safari Direct Test)

**Test Steps:**
1. Open Safari on iPhone
2. Type in address bar: `augur://auth-callback`
3. Press Go

**Expected Results:**
- [ ] App opens
- [ ] Debug panel shows the URL in "Last Deep Link"

**Actual Results:**
```
✅ PASS / ❌ FAIL

[Describe what happened]
```

**Note:** This may show an error since there's no valid token, but confirms the URL scheme works.

---

## 🐞 Debug Panel Verification

**Throughout testing, verify debug panel:**
- [ ] Appears in top-right corner
- [ ] Can be expanded/collapsed by tapping
- [ ] Shows correct auth state at each stage
- [ ] Shows user email when authenticated
- [ ] Shows last deep link URL when deep links are opened
- [ ] "Sign Out" button works
- [ ] "Refresh Session" button works

**Issues observed:**
```
[Any issues with debug panel]
```

---

## 📊 Test Summary

### Tests Passed: _____ / 5

| Test | Status | Notes |
|------|--------|-------|
| Sign Up | ⬜ PASS / ⬜ FAIL | |
| Sign Out | ⬜ PASS / ⬜ FAIL | |
| Sign In | ⬜ PASS / ⬜ FAIL | |
| Password Reset | ⬜ PASS / ⬜ FAIL | |
| Deep Link (Safari) | ⬜ PASS / ⬜ FAIL | |

---

## 🚨 Issues Encountered

**Issue 1:**
```
Description:
Steps to reproduce:
Expected:
Actual:
Severity: Critical / High / Medium / Low
```

**Issue 2:**
```
Description:
Steps to reproduce:
Expected:
Actual:
Severity: Critical / High / Medium / Low
```

---

## 📝 Observations

**Positive:**
```
[What worked well]
```

**Improvements:**
```
[Suggestions for improvements]
```

**Performance:**
```
[Loading times, responsiveness, etc.]
```

---

## 🎯 Overall Assessment

**Status:** ⬜ All Tests Pass / ⬜ Some Failures / ⬜ Major Issues

**Ready for Production:** ⬜ Yes / ⬜ No / ⬜ With Fixes

**Recommendations:**
```
[Final recommendations]
```

---

## 🔗 Supabase Dashboard Check

**After testing, verify in Supabase Dashboard:**

1. **Auth → Users**
   - [ ] Test user appears in users list
   - [ ] Email is confirmed
   - [ ] Last sign in time is recent

2. **Auth → Logs**
   - [ ] Sign up event logged
   - [ ] Sign in events logged
   - [ ] Password reset event logged
   - [ ] Password update event logged

**Dashboard observations:**
```
[Any issues or observations from Supabase Dashboard]
```

---

## 📎 Attachments

**Screenshots:**
1. LoginView: _____
2. UpdatePasswordView: _____
3. Debug Panel: _____
4. Reset Email: _____
5. Success State: _____

**Console Logs:**
- [ ] Xcode console logs attached (copy relevant sections)

**Supabase Logs:**
- [ ] Dashboard logs exported (if any errors)

---

**Tester Signature:** _________________________  
**Date Completed:** _________________________
