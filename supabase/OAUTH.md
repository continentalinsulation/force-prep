# Sign in with Apple and Google

The buttons are in the app already. They work as soon as the provider is switched on in Supabase. Nothing in the app needs to change.

## Google (15 minutes)
1. console.cloud.google.com → create a project "Evolution" → APIs & Services → OAuth consent screen (External, app name Evolution, your email) → Credentials → Create credentials → OAuth client ID → Web application.
2. Authorized redirect URI: `https://pymszovaxpvzsprmcbjf.supabase.co/auth/v1/callback`
3. Copy the Client ID and Client secret.
4. Supabase dashboard → Authentication → Providers → Google → enable, paste both → Save.

## Apple (30 minutes, needs the developer account)
1. developer.apple.com → Certificates, Identifiers & Profiles → Identifiers → + → Services IDs → identifier `ca.evolutionapp.evolution.signin`, description Evolution Sign In. Enable "Sign In with Apple", Configure: primary App ID = `ca.evolutionapp.evolution`, domain `pymszovaxpvzsprmcbjf.supabase.co`, return URL `https://pymszovaxpvzsprmcbjf.supabase.co/auth/v1/callback`.
2. Keys → + → name "Evolution Sign In", tick Sign In with Apple, configure with the primary App ID → download the .p8 once. Note the Key ID and your Team ID (95S36DM28S).
3. Supabase → Authentication → Providers → Apple → enable. Client ID = the Services ID (`ca.evolutionapp.evolution.signin`). Secret key: generate it from the .p8 using Supabase's helper (they link a generator on that page) — it expires every 6 months, set a reminder.
4. Also tick "Sign In with Apple" on the App ID `ca.evolutionapp.evolution` itself so the native app is allowed to use it.

## Redirects
Supabase → Authentication → URL configuration → add `https://continentalinsulation.github.io/force-prep/` to Redirect URLs (the app sends users back there after sign-in and after a password reset).

Do not paste any secret into chat; they go straight into the Supabase dashboard.
