-- ==========================================
-- REPLACE OLD ADMIN WALLET WITH NEW ONE
-- ==========================================

-- Remove old admin wallet
DELETE FROM public.licenses 
WHERE wallet = '3sxAez3yght687RKUAjN3qRxHtY12YmLJL2vBLtdM8L';

-- Add new admin wallet
INSERT INTO public.licenses (wallet, plan, activated_at, expires_at, created_at)
VALUES (
  '7L9MouKjHkDaCyLsLWRgPPGsW8rT98Wdgs6BjhTQDH4L',
  'admin',
  NOW(),
  NULL,  -- Admin never expires
  NOW()
)
ON CONFLICT (wallet) 
DO UPDATE SET 
  plan = 'admin',
  expires_at = NULL,
  activated_at = NOW();

-- Verify the change
SELECT 
  wallet,
  plan,
  activated_at,
  expires_at,
  CASE 
    WHEN expires_at IS NULL THEN 'NEVER EXPIRES (Admin)'
    WHEN expires_at > NOW() THEN 'ACTIVE'
    ELSE 'EXPIRED'
  END as status
FROM public.licenses
WHERE plan = 'admin';
