# App Store & Google Play Screenshot & Feature Graphic Guide

> Comprehensive guidelines, technical specifications, and store policy restrictions for publishing **LoveLynk** on the **Apple App Store** and **Google Play Store**.

---

## 1. Why Custom Marketing Screenshots Matter

In app store publishing, there is a clear distinction between:
* **Raw Technical Screenshots:** Direct in-app screen grabs taken from a simulator or phone. Developers typically provide these as temporary placeholders.
* **Designed Marketing Screenshots / Feature Graphics (What LoveLynk Needs):** High-converting promotional banners featuring custom typography, brand color gradients (LoveLynk pinks/pastels), device mockups, and emotional value propositions (*e.g., "Feel close even when miles apart", "Real-time distance & touch", "Shared widgets on your home screen"*).

Because these graphics represent your brand identity, messaging, and marketing tone to potential subscribers, **they are best designed by the founder or a marketing graphic designer.**

---

## 2. Apple App Store Requirements (App Store Connect)

Apple has strict display size and formatting requirements. Uploading incorrect resolutions or images containing transparency will immediately fail validation.

### Required iPhone Display Sizes

| Display Category | Target Devices | Portrait Resolution | Landscape Resolution | Notes |
| :--- | :--- | :--- | :--- | :--- |
| **6.9" Super Retina (New)** | iPhone 16 Pro Max, iPhone 17 Pro Max | **`1320 × 2868 px`** | `2868 × 1320 px` | Apple's largest standard tier. |
| **6.7" Super Retina (Primary)** | iPhone 15 Pro Max, 14 Pro Max, 15 Plus, 16 Plus | **`1290 × 2796 px`** | `2796 × 1290 px` | **Mandatory** primary format. Downscales to smaller devices. |
| **6.5" Super Retina (Legacy)** | iPhone 11 Pro Max, XS Max, XR | **`1242 × 2688 px`** | `2688 × 1242 px` | Optional if 6.7" is provided (auto-scaled). |
| **5.5" Retina (Home Button)** | iPhone 8 Plus, 7 Plus, 6s Plus | **`1242 × 2208 px`** | `2208 × 1242 px` | Required if supporting older devices without notch. |

> [!TIP]
> **Production Best Practice:** Designing a full set at **`1290 × 2796 px`** (6.7") and **`1320 × 2868 px`** (6.9") is the gold standard. App Store Connect will automatically scale them down for smaller iPhones if specific sets are not provided.

### Technical File Specifications (Apple)
* **File Format:** High-quality **PNG** (24-bit or 32-bit RGB without alpha) or flattened **JPEG**.
* **Transparency:** **STRICTLY PROHIBITED.** Any image containing an alpha channel / transparent pixels will be rejected by App Store Connect.
* **Color Space:** **sRGB** or **Display P3**.
* **Resolution / DPI:** 72 DPI minimum.
* **Quantity:** Minimum **1** screenshot; Maximum **10** screenshots per device category. (Recommended: 4 to 6 strong slides).
* **Orientation:** Must be uniform across the set (all portrait or all landscape).

---

## 3. Google Play Console Requirements

Google Play allows more flexible aspect ratios than Apple, but has strict requirements regarding the **Feature Graphic** and editorial featuring rules.

### Phone Screenshots
* **Dimensions:** 
  * Minimum side: **320 px**
  * Maximum side: **3,840 px**
  * Recommended Standard: **`1080 × 1920 px`** (9:16) or **`1080 × 2400 px`** (20:9 modern Android).
* **Aspect Ratio:** The longest side must not be more than twice the shortest side ($\le 2:1$).
* **File Formats:** JPEG or 24-bit PNG (no alpha / transparency).
* **File Size:** Up to **8 MB** per image.
* **Quantity:** Minimum **2** screenshots required to submit; maximum **8** per device form factor.
* **Google Featuring Requirement:** To be eligible for editorial featuring and Google Play homepage promotions, you must upload **at least 4 high-resolution screenshots (1080p or higher)**.

### Feature Graphic (Mandatory on Google Play)
The Feature Graphic is the prominent promotional banner at the top of your Google Play Store listing.
* **Dimensions:** Exactly **`1024 × 500 px`** (non-negotiable).
* **Format:** JPEG or 24-bit PNG (no transparency).
* **Max File Size:** **15 MB**.
* **Critical Design Safe Zones:**
  * If a promo video is attached, Google Play automatically overlays a **large circular Play Button right in the dead-center**. Do not place critical text, logos, or faces in the center.
  * Keep core logos and text centered horizontally and vertically with generous padding from the edges.

---

## 4. Store Policies & Rejection Traps (What Will Get Rejected)

Both Apple (App Store Review Guideline 2.3) and Google (Google Play Metadata Policy) rigorously enforce guidelines on screenshot content.

### 🚫 Strict Prohibitions:
1. **Misleading Gameplay / Mock UI:** Screenshots must accurately reflect the **real in-app user experience**. You cannot display mock features, fake buttons, or capabilities that the app does not actually possess.
2. **Pricing & Promotional Claims:** Do NOT include phrases such as:
   * *"Free"*, *"50% Off"*, *"Best Value"* (Apple & Google forbid price claims in screenshots because prices vary by country and currency).
   * Claims of store ranking or awards: *"#1 Relationship App"*, *"Best App of 2026"*, *"Top Rated"*.
   * Download triggers: *"Download Now"*, *"Install Today"*.
3. **Cross-Platform References:**
   * Never show an Android device frame or mention *"Available on Google Play"* on the Apple App Store.
   * Never show an iPhone notch / Dynamic Island or mention *"iOS / App Store"* in Google Play screenshots.
4. **Messy Status Bars:** 
   * Avoid screenshots with low battery (e.g., 14%), messy notification clutter, or awkward time stamps.
   * Apple's official standard aesthetic uses **9:41 AM**, full Wi-Fi bars, and 100% battery.
5. **Transparency (Alpha Channels):** Ensure all exported PNG files have transparent backgrounds disabled (solid background colors or exported as standard non-alpha PNG / JPEG).

---

## 5. Recommended 5-Slide Narrative for LoveLynk

For a couples app like LoveLynk, the most effective 5-screenshot sequence is:

| Slide # | Visual Focus | Headline / Value Proposition |
| :---: | :--- | :--- |
| **Slide 1** | Home Screen & Distance Pill | **"Stay close, no matter the distance"**<br>*Real-time distance and live partner status.* |
| **Slide 2** | Interactive Widgets on iOS Lock & Home Screen | **"Your partner on your home screen"**<br>*Live countdowns, paired distance, and mood.* |
| **Slide 3** | Kisses & Heartbeat Touch Interactions | **"Send love in a single tap"**<br>*Real-time haptic kisses and heartbeats.* |
| **Slide 4** | Color & Widget Customization | **"Customise your shared space"**<br>*Pastel themes, nicknames, and anniversaries.* |
| **Slide 5** | Couple Milestone & Countdown Cards | **"Never miss a special moment"**<br>*Anniversaries, next visits, and daily affirmations.* |

---

## 6. Recommended Design Tools (Quick & Professional)

If you or a designer are creating the final marketing assets, these tools provide pre-made App Store compliant templates:

1. **[AppScreens.com](https://appscreens.com)**: Highly recommended. Automatically generates all required Apple (6.7", 6.9", 5.5") and Google Play (1080x1920, 1024x500) assets in one click.
2. **[Screenshots.pro](https://screenshots.pro)**: Modern 3D device mockups, panoramic backgrounds, and multi-device frames.
3. **[Figma](https://www.figma.com)**: Search Figma Community for *"App Store Screenshot Templates"* for complete typographic control.
4. **[Canva](https://www.canva.com)**: Pre-sized templates for *"App Store Screenshots"* and *"Google Play Feature Graphic"*.

---

## 7. How the Development Team Supports You

To make designing these screenshots easy:
* We can generate **clean, high-resolution source captures** directly from our iOS simulators (featuring clean data, 9:41 AM status bar, and 100% battery).
* You or your designer can drop these clean source captures directly into the device frames of your chosen marketing template.

