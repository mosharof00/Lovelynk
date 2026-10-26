# Phase 9: Subscriptions Setup & Configuration Guide
## Complete Step-by-Step Runbook for App Store Connect, RevenueCat & Supabase

---

### Overview & Pricing Confirmed with Client

| Plan | Product ID | Duration | Price (GBP) | Free Trial | Auto-Converts Currencies? |
| :--- | :--- | :--- | :--- | :--- | :--- |
| **Monthly** | `lovelynk_monthly` | 1 Month | **£6.99 / month** | **7 Days** | Yes (Apple auto-converts to USD, EUR, etc.) |
| **Yearly (Best Value)** | `lovelynk_yearly` | 1 Year | **£29.99 / year** | **7 Days** | Yes (Apple auto-converts to USD, EUR, etc.) |

> [!IMPORTANT]
> **Couple-Shared Subscription Rule**:
> Only **1 partner** in a couple pays. As soon as Partner A starts the 7-day trial or subscribes, their active partner (Partner B) automatically inherits full LoveLynk Plus access for free via our Supabase backend and Realtime sync!

---

## Step 1: App Store Connect — Agreements & Tax Forms Status

In **App Store Connect $\rightarrow$ Business $\rightarrow$ Agreements**:

1. **Banking Updates (Wise Payments Ltd)**:
   - Status currently shows `Processing` with banner *"Your banking updates are processing, and you should see the changes in 24 hours."*
   - This is normal Apple banking verification. It usually turns active within 24 hours.
2. **Tax Forms**:
   - `U.S. Substitute Form W-8BEN-E`: Already **Active** ✅.
   - `U.S. Certificate of Foreign Status of Beneficial Owner`: Shows `Missing Tax Info` with a blue link **"Add Tax Info"**.
   - **Action**: Have the client click **"Add Tax Info"** and complete the beneficial owner verification questions so the Paid Apps Agreement changes from `Pending User Info` $\rightarrow$ `Active`.
3. **Can you configure subscriptions right now?**
   - **YES!** You can create the subscription products, set prices, add the free trial, and set up RevenueCat immediately while banking verification finishes in the background.

---

## Step 2: App Store Connect — Create the 2 Subscriptions

Navigate to: **App Store Connect $\rightarrow$ Apps $\rightarrow$ LoveLynk $\rightarrow$ Subscriptions** (under Monetization).  
You already created the Subscription Group: **LoveLynk Plus**. Click into **LoveLynk Plus**.

### 2.1 Create Monthly Subscription (`lovelynk_monthly`)
1. In the **Subscriptions** section, click the blue **`Create`** button (or `+`).
2. Fill in:
   - **Reference Name**: `LoveLynk Plus Monthly`
   - **Product ID**: `lovelynk_monthly` *(Must match code exactly!)*
3. Click **Create**.
4. Set **Subscription Duration**: Select **`1 Month`**.
5. Set **Subscription Prices**:
   - Click **Add Pricing**.
   - Base Currency: Select **United Kingdom (GBP £)**.
   - Price: Select **`£6.99`**.
   - Apple will automatically calculate equivalent prices across all 175 countries/currencies. Click **Next** $\rightarrow$ **Save**.
6. Set **Introductory Offer (7-Day Free Trial)**:
   - Scroll to **Introductory Offers** $\rightarrow$ Click **`+`** (or Add Introductory Offer).
   - Countries/Regions: Select **All Countries or Regions**.
   - Dates: Select **No End Date** (start immediately).
   - Type of Offer: Select **Free Trial**.
   - Duration: Select **`7 Days`**.
   - Click **Done** / **Save**.
7. Set **App Store Localization**:
   - Under **Subscription Display Name**:
     - **Display Name**: `LoveLynk Plus Monthly`
     - **Description**: `Unlock all widgets, rich interactions, and custom styles for you and your partner.`
   - Click **Save**.

---

### 2.2 Create Yearly Subscription (`lovelynk_yearly`)
1. Go back to Subscription Group **LoveLynk Plus** $\rightarrow$ Click the **`+`** or **`Create`** button.
2. Fill in:
   - **Reference Name**: `LoveLynk Plus Yearly`
   - **Product ID**: `lovelynk_yearly` *(Must match code exactly!)*
3. Click **Create**.
4. Set **Subscription Duration**: Select **`1 Year`**.
5. Set **Subscription Prices**:
   - Click **Add Pricing**.
   - Base Currency: Select **United Kingdom (GBP £)**.
   - Price: Select **`£29.99`**.
   - Apple automatically populates all currencies. Click **Next** $\rightarrow$ **Save**.
6. Set **Introductory Offer (7-Day Free Trial)**:
   - Scroll to **Introductory Offers** $\rightarrow$ Click **`+`**.
   - Countries/Regions: Select **All Countries or Regions**.
   - Dates: Select **No End Date**.
   - Type of Offer: Select **Free Trial**.
   - Duration: Select **`7 Days`**.
   - Click **Done** / **Save**.
7. Set **App Store Localization**:
   - Under **Subscription Display Name**:
     - **Display Name**: `LoveLynk Plus Yearly`
     - **Description**: `Unlock all widgets, rich interactions, and custom styles for you and your partner with the best annual value.`
   - Click **Save**.

---

### 2.3 Set Subscription Group Localization & Hierarchy
1. Under **Display Name and Description** in the LoveLynk Plus group:
   - Click **Create**.
   - App Name: `LoveLynk`
   - Subscription Group Display Name: `LoveLynk Plus`
2. **Order of Subscriptions**:
   - Arrange with `LoveLynk Plus Yearly` at the top (Tier 1 / Highest Level) and `LoveLynk Plus Monthly` below it (Tier 2).

---

## Step 3: Generate App Store Connect In-App Purchase Key (`.p8`)

RevenueCat uses this key to validate receipts with Apple StoreKit 2 in real-time.

1. In **App Store Connect**, click the top tab **Users and Access**.
2. Click the **Integrations** tab (or **Keys**).
3. Under the left menu, select **In-App Purchase**.
4. Click **Generate In-App Purchase Key** (or `+`).
5. Name: `LoveLynk RevenueCat IAP Key`.
6. Click **Generate**.
7. **Important**:
   - Note the **Key ID** (e.g. `ABC123XYZ4`).
   - Note the **Issuer ID** (at the top of the page, e.g. `69a6de80-....`).
   - Click **Download API Key** and save the `.p8` file (Apple only lets you download this once!).

---

## Step 4: Configure RevenueCat Dashboard

1. **Sign in / Create Account**: Go to [app.revenuecat.com](https://app.revenuecat.com) and create project: **LoveLynk**.
2. **Add iOS App**:
   - Project Settings $\rightarrow$ **Apps** $\rightarrow$ Click **+ New App** $\rightarrow$ Select **Apple App Store**.
   - App Name: `LoveLynk iOS`
   - Bundle ID: `com.lovelynk.ios`
   - In-App Purchase Key configuration:
     - Upload your `.p8` file downloaded in Step 3.
     - Enter the **Key ID**.
     - Enter the **Issuer ID**.
   - Click **Save**.
3. **Create Entitlement**:
   - Go to **Project Settings $\rightarrow$ Entitlements** $\rightarrow$ Click **+ New**.
   - Identifier: `plus`
   - Description: `LoveLynk Plus (Widgets & Premium Features)`
   - Click **Add**.
4. **Attach Products**:
   - Go to **Project Settings $\rightarrow$ Products** $\rightarrow$ Click **+ New**.
   - Product 1:
     - Identifier: `lovelynk_monthly`
     - App: Select `LoveLynk iOS`
     - Attach to Entitlement: `plus`
   - Product 2:
     - Identifier: `lovelynk_yearly`
     - App: Select `LoveLynk iOS`
     - Attach to Entitlement: `plus`
5. **Create Offering**:
   - Go to **Project Settings $\rightarrow$ Offerings** $\rightarrow$ Click **+ New Offering**.
   - Identifier: `default`
   - Description: `Standard Paywall Offering`
   - Inside the `default` offering, click **+ Add Package**:
     - Package 1: Type `Monthly ($rc_monthly)` $\rightarrow$ attach product `lovelynk_monthly`.
     - Package 2: Type `Annual ($rc_annual)` $\rightarrow$ attach product `lovelynk_yearly`.
   - Make sure this offering is marked as **Current**.
6. **Set Up Supabase Webhook**:
   - Go to **Project Settings $\rightarrow$ Integrations** $\rightarrow$ Click **+ Webhooks**.
   - Webhook URL:
     `https://yvfolpaqchdmqdluprpo.supabase.co/functions/v1/revenuecat-webhook`
   - Authorization Header:
     `Bearer your_secure_random_token_here` (e.g. generate a 32-character secret string).
   - Note this secret string, because you will set it in Supabase in Step 5!
7. **Copy Public iOS API Key**:
   - Go to **Project Settings $\rightarrow$ API Keys**.
   - Copy the key starting with `appl_...` (e.g. `appl_xxxxxxxxxxxxxxxxxxxx`).

---

## Step 5: Configure Supabase & Flutter App

### 5.1 Set Supabase Edge Function Secret
Run via Supabase CLI or in the Supabase Dashboard ($\rightarrow$ Project Settings $\rightarrow$ Edge Functions $\rightarrow$ Secrets):
```bash
npx supabase secrets set REVENUECAT_WEBHOOK_AUTH=your_secure_random_token_here --project-ref yvfolpaqchdmqdluprpo
```

### 5.2 Put RevenueCat Public Key in Flutter
In [lib/app/core/config/app_config.dart](file:///Users/mosharof/projects/bulkretail/lib/app/core/config/app_config.dart#L35):
```dart
static const revenueCatAppleApiKey = 'appl_YOUR_REVENUECAT_KEY_HERE';
```

---

## Step 6: End-to-End Verification & Sandbox Testing

1. **Create Sandbox Tester in App Store Connect**:
   - Users and Access $\rightarrow$ Sandbox $\rightarrow$ **Test Accounts** $\rightarrow$ Click `+`.
   - Create a test account (e.g. `tester1@lovelynk.com`).
2. **On your physical iPhone / Simulator**:
   - Go to iOS **Settings $\rightarrow$ App Store $\rightarrow$ Sandbox Account** $\rightarrow$ Sign in with `tester1@lovelynk.com`.
3. **Test the Purchase Flow**:
   - Open LoveLynk on the test phone.
   - Tap any locked widget or go to Settings $\rightarrow$ Subscribe.
   - Notice the paywall shows live localized pricing (`£6.99/mo` or `£29.99/yr`) with **"7 Days Free"**.
   - Tap **"Start 7-Day Free Trial"** and confirm Face ID / Sandbox password.
4. **Verify Couple Sharing**:
   - Have the partner's phone open (connected via pairing code).
   - Within 3–5 seconds of the purchase completing, Supabase Realtime delivers `access.changed`.
   - Partner's widgets unlock immediately without requiring them to pay!
   - In Profile, Partner sees: **"LoveLynk Plus (via Partner)"**.
