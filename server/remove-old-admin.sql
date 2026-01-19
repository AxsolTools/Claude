-- ==========================================
-- REMOVE OLD ADMIN WALLET ONLY
-- ==========================================

-- Delete the old admin wallet
DELETE FROM public.licenses 
WHERE wallet = '3sxAez3yght687RKUAjN3qRxHtY12YmLJL2vBLtdM8L';

-- Verify only new admin remains
SELECT 
  wallet,
  plan,
  activated_at,
  expires_at,
  CASE 
    WHEN expires_at IS NULL THEN 'NEVER EXPIRES (Admin)'
    ELSE 'ACTIVE'
  END as status
FROM public.licenses
WHERE plan = 'admin';

-- Should only show:
-- 7L9MouKjHkDaCyLsLWRgPPGsW8rT98Wdgs6BjhTQDH4L
