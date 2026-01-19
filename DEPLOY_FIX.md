# 🔧 ClaudeCash Deployment Fix Guide

## Issues Identified

1. ❌ **504 Gateway Timeout** - Production server crashed/not running
2. ❌ **Admin Wallet Access** - Not in database
3. ❌ **Payment Confirmation** - JSON parse error
4. ❌ **WebSocket Connection** - Can't connect to production

---

## 🚀 **IMMEDIATE FIX - Step by Step**

### Step 1: Fix Supabase Database

Run this SQL in your Supabase dashboard (https://supabase.com/dashboard):

```sql
-- Apply the schema
-- (Copy entire contents of server/supabase-licenses.sql)

-- OR just run this to add admin:
INSERT INTO public.licenses (wallet, plan, activated_at, expires_at, created_at)
VALUES (
  '3sxAez3yght687RKUAjN3qRxHtY12YmLJL2vBLtdM8L',
  'admin',
  NOW(),
  NULL,
  NOW()
)
ON CONFLICT (wallet) 
DO UPDATE SET 
  plan = 'admin',
  expires_at = NULL;
```

### Step 2: Check Production Environment Variables

Your Digital Ocean app needs these environment variables set:

**Critical:**
```
SUPABASE_URL=your_supabase_url
SUPABASE_SERVICE_ROLE_KEY=your_service_key
TRADING_WALLET_ADDRESS=3sxAez3yght687RKUAjN3qRxHtY12YmLJL2vBLtdM8L
```

**API Access (for token monitoring):**
```
PRIVY_COOKIES=your_cookies
HELIUS_API=your_helius_key
```

**Optional:**
```
ADMIN_WALLETS=3sxAez3yght687RKUAjN3qRxHtY12YmLJL2vBLtdM8L
```

### Step 3: Restart Production Server

In Digital Ocean App Platform:
1. Go to your app: claudecash-3arpi
2. Click **Settings** → **Components**
3. Click on your server component
4. Click **Force Rebuild and Deploy**

OR use the CLI:
```bash
doctl apps create-deployment YOUR_APP_ID
```

### Step 4: Check Logs

```bash
doctl apps logs YOUR_APP_ID --follow
```

Look for:
- ✅ "Server: http://..." - Server started
- ❌ "Supabase not configured" - Missing env vars
- ❌ Any crash errors

---

## 🔍 **DIAGNOSIS COMMANDS**

### Check if server is running:
```bash
curl https://claudecash-3arpi.ondigitalocean.app/api/status
```

### Check database connection:
```bash
curl -X POST https://claudecash-3arpi.ondigitalocean.app/api/auth/validate \
  -H "Content-Type: application/json" \
  -d '{"sessionToken":"test","deviceId":"test"}'
```

### Test WebSocket:
```bash
wscat -c wss://claudecash-3arpi.ondigitalocean.app/?public=true
```

---

## 🐛 **COMMON ISSUES & FIXES**

### Issue: "Supabase not configured"
**Fix:** Add SUPABASE_URL and SUPABASE_SERVICE_ROLE_KEY to environment variables

### Issue: "TRADING_WALLET_ADDRESS not configured"  
**Fix:** Add TRADING_WALLET_ADDRESS=3sxAez3yght687RKUAjN3qRxHtY12YmLJL2vBLtdM8L

### Issue: "License key not found"
**Fix:** Run the SQL insert from Step 1 above

### Issue: "Unexpected token '<', '<!DOCTYPE'..."
**Fix:** This means the server crashed. Check logs and restart.

### Issue: WebSocket keeps disconnecting
**Fix:** Ensure WebSocket upgrade is enabled in Digital Ocean app settings

---

## ✅ **VERIFICATION STEPS**

After deploying, test these endpoints:

1. **Health Check:**
   ```
   GET https://claudecash-3arpi.ondigitalocean.app/api/status
   ```
   Should return: `{ "authenticated": true/false, ... }`

2. **Admin Login:**
   - Go to https://claudecash-3arpi.ondigitalocean.app
   - Click "Activate License"
   - Enter: `3sxAez3yght687RKUAjN3qRxHtY12YmLJL2vBLtdM8L`
   - Select any plan
   - Click "Activate" (NOT "I Paid")
   - Should log you in immediately

3. **WebSocket:**
   - Open browser console
   - Should see: "WebSocket connection established"
   - Should see: "Client connected"

4. **Public Feed:**
   - Visit landing page (not logged in)
   - Should see: "Public WebSocket connected"
   - Should see list of tokens

---

## 📝 **LOCAL TESTING**

To test locally before deploying:

```bash
# Terminal 1 - Start server
npm run server

# Terminal 2 - Start client
npm run client

# Terminal 3 - Test admin login
curl -X POST http://localhost:3001/api/auth/activate \
  -H "Content-Type: application/json" \
  -d '{
    "wallet": "3sxAez3yght687RKUAjN3qRxHtY12YmLJL2vBLtdM8L",
    "plan": "admin",
    "deviceId": "test-device"
  }'
```

Should return:
```json
{
  "ok": true,
  "sessionToken": "...",
  "wallet": "3sxAez3yght687RKUAjN3qRxHtY12YmLJL2vBLtdM8L",
  "plan": "admin",
  "expiresAt": null
}
```

---

## 🔐 **PAYMENT TESTING**

For testing payment flow:

1. **Start Payment:**
   ```bash
   curl -X POST https://claudecash-3arpi.ondigitalocean.app/api/auth/payment/start \
     -H "Content-Type: application/json" \
     -d '{
       "wallet": "USER_WALLET",
       "plan": "week"
     }'
   ```

2. **User sends SOL** to the trading wallet

3. **Confirm Payment:**
   ```bash
   curl -X POST https://claudecash-3arpi.ondigitalocean.app/api/auth/payment/confirm \
     -H "Content-Type: application/json" \
     -d '{
       "wallet": "USER_WALLET",
       "plan": "week",
       "deviceId": "user-device"
     }'
   ```

---

## 🎯 **PRIORITY FIXES**

**RIGHT NOW:**
1. ✅ Add admin wallet to database (Step 1)
2. ✅ Restart production server (Step 3)
3. ✅ Verify with Step 2 of Verification

**NEXT:**
4. Check environment variables are set correctly
5. Monitor logs for any crashes
6. Test payment flow with a test transaction

---

## 📞 **GETTING HELP**

If still having issues, provide:
1. Digital Ocean app logs (last 50 lines)
2. Supabase dashboard screenshot (licenses table)
3. Browser console errors
4. Result of: `curl https://claudecash-3arpi.ondigitalocean.app/api/status`
