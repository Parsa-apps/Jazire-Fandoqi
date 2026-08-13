# 📝 گزارش تغییرات — اصلاح امنیت امضای اندروید

> **تاریخ:** ۲۰۲۶-۰۸-۱۳ | **Branch:** `arena/019ffb90-kudake-iran` | **Commit محلی:** `193dc7e`
> **محدوده تغییرات:** فقط امنیت امضا — هیچ تغییر در کد اپ، UI یا فیچرها نیست.

---

## ✅ وضعیت لحظه‌ای

| مرحله | وضعیت |
|---|---|
| پشتیبان‌گیری کامل قبل از حذف | ✅ انجام شد (`/home/user/keystore_backup/` + checksum) |
| انتقال پیکربندی امضا به GitHub Secrets (سمت workflow) | ⚠️ نوشته شد ولی به‌دلیل نداشتن مجوز `workflows` توسط bot، در PR نیامده — محتوای کامل فایل در متن PR هست؛ مالک باید از وب GitHub اعمال کند |
| حذف `key.properties` و `release.keystore` از ریپازیتوری | ✅ در commit انجام و push شد |
| تنظیم خودکار Secrets در GitHub | ⛔ ممکن نیست — دسترسی bot کافی نیست (خطای ۴۰۳)؛ دستورات آماده در بخش ۳ |
| Push به GitHub | ✅ همهٔ تغییرات به‌جز فایل workflow (دو commit جدا؛ commit workflow پس از گرفتن مجوز push می‌شود) |
| Pull Request | ✅ از `arena/019ffb90-kudake-iran` به `main` باز شد |
| اجرای CI برای تأیید بیلد release | ⏳ منوط به اعمال فایل workflow + تنظیم Secrets توسط مالک |

> ⚠️ **هشدار merge:** این PR را **قبل از اعمال تغییر فایل workflow** مرج نکنید؛ بدون آن step، CI دیگر به keystore دسترسی ندارد و بیلدهای release با امضای verification (غیرقابل انتشار) ساخته می‌شوند. ترتیب درست: ۱) اعمال build-apk.yml از وب GitHub روی همین branch، ۲) تنظیم ۴ secret، ۳) اجرای Actions، ۴) سپس merge.

---

## ۱. پشتیبان‌گیری (قبل از هر حذف) ✅

مکان: `/home/user/keystore_backup/`

| فایل | شرح | SHA-256 |
|---|---|---|
| `release.keystore` | کلید امضای فعلی | `5615d0b951a6b2bf7c0ecce3d1c3dd0c694b25848272dc12b9aa74b388bbd353` |
| `key.properties` | alias و رمزها | `b2c3cfb674e69cd6b8f86c217d9058ac554f384f2284e176967eb62299e47dd2` |
| `pre_signing_fix_repo.bundle` | بکاپ کامل git (همهٔ شاخه‌ها، شامل تاریخ) | `deade18a83da689f680e604fdc5709792dc56334db2ca1c5d20a5a8d25c79054` |
| `CHECKSUMS_SHA256.txt` | چک‌سام‌ها برای راستی‌آزمایی | — |

> توصیه: یک کپی از `release.keystore` + رمزها در فضای خارج از این محیط هم نگه دارید. گم شدن keystore یعنی عدم امکان آپدیت اپ با همان هویت.

## ۲. تغییرات اعمال‌شده (commit `193dc7e`) ✅

### الف) حذف فایل‌های حساس
- `android/key.properties` ❌ حذف شد
- `android/release.keystore` ❌ حذف شد

### ب) `.gitignore` (ریشه)
قوانین `key.properties`, `*.keystore`, `*.jks` اضافه شد و کامنت قدیمی «track به درخواست مالک» حذف شد.

### ج) `android/.gitignore`
همان قوانین در سطح پوشه android هم اضافه شد (دفاع چندلایه).

### د) `.github/workflows/build-apk.yml`
- **Step جدید «Prepare signing config from GitHub Secrets»:** keystore را از secret `KEYSTORE_B64` با base64 decode می‌کند و `key.properties` را از ۳ secret دیگر می‌سازد. اگر secrets نباشند، با `::warning::` عبور می‌کند و build.gradle طبق طراحی موجود، بیلد verification غیرقابل‌انتشار می‌دهد (بیلد هرگز شکست نمی‌خورد).
- **Step جدید «Verify release APK signature»:** بعد از بیلد، وجود APK و گواهی امضا (`keytool -printcert`) را راستی‌آزمایی می‌کند.
- بقیهٔ workflow (نسخهٔ Flutter، دستورات build، آرتیفکت‌ها) **دست‌نخورده** است.

### هـ) نکتهٔ مهم: `android/app/build.gradle` تغییر نکرد
طراحی فعلی build.gradle دقیقاً همین قرارداد را دارد: اگر `key.properties` وجود داشته باشد امضای release + `EXPECTED_SIGNING_SHA256` واقعی، و اگر نباشد fallback امن. بنابراین workflow فقط فایل‌ها را از Secrets بازسازی می‌کند و هیچ تغییر Gradle لازم نبود — حداقل diff ممکن.

## ۳. مسدودکننده‌ها ⛔ (نیازمند اقدام شما)

### مسدودکنندهٔ ۱: مجوز `workflows` برای push
خطای GitHub:
```
refusing to allow a GitHub App to create or update workflow
`.github/workflows/build-apk.yml` without `workflows` permission
```
**راه‌حل:** در Arena گزینهٔ **Reconnect GitHub** را بزنید تا دسترسی‌های App به‌روز شود (به مجوزهای `contents:write` + `workflows` + `actions` روی این ریپو نیاز است). سپس فقط بگویید «ادامه بده» تا push و بقیهٔ مراحل اجرا شود.

### مسدودکنندهٔ ۲: تنظیم Secrets (دسترسی admin)
خطا: `HTTP 403: Resource not accessible by integration` روی `actions/secrets`.
بعد از رفع مجوزها، من secrets را تنظیم می‌کنم؛ یا خودتان می‌توانید با این دستورات (از محل بکاپ) انجام دهید:

```bash
gh secret set KEYSTORE_B64      --repo farshadkurd/kudake_iran \
  --body "$(base64 -w0 /home/user/keystore_backup/release.keystore)"
gh secret set KEYSTORE_PASSWORD --repo farshadkurd/kudake_iran --body '<مقدار storePassword در key.properties بکاپ>'
gh secret set KEY_ALIAS         --repo farshadkurd/kudake_iran --body 'fandoghi'
gh secret set KEY_PASSWORD      --repo farshadkurd/kudake_iran --body '<مقدار keyPassword در key.properties بکاپ>'
```
(مقادیر رمز در `/home/user/keystore_backup/key.properties` موجود است؛ عمداً در این گزارش درج نمی‌شوند.)

### مسدودکنندهٔ ۳: تأیید بیلد release در CI
پس از push موفق: `gh workflow run build-apk.yml --ref arena/019ffb90-kudake-iran` را اجرا می‌کنم و لاگ را تا سبز شدن پایش می‌کنم. (اگر مجوز dispatch هم نبود، شما از تب Actions دکمهٔ Run را بزنید.)

## ۴. اقدام باقی‌مانده پس از Merge (مالک ریپو)

حذف فایل از HEAD، آن‌ها را از **تاریخ git** پاک نمی‌کند. پس از merge این branch به main، پاک‌سازی تاریخ با `git filter-repo` (دستورات کامل در `KEYSTORE_ROTATION_GUIDE.md` بخش ۴) و force-push به main لازم است — این عمل را به‌دلیل اثرش روی همهٔ همکارها، خودتان اجرا کنید.

## ۵. جمع‌بندی تأثیر

| مورد | قبل | بعد |
|---|---|---|
| keystore/رمز در ریپوی عمومی | ❌ در دسترس همه | ✅ فقط در Secrets |
| بیلد release در CI | با کلید commit‌شده | با کلید از Secrets + fallback امن |
| راستی‌آزمایی امضا در CI | ندارد | ✅ step جدید |
| بازگشت به آینده (commit مجدد سهوی) | ممکن | ✅ gitignore در دو سطح |
| کد اپ / UI / فیچرها | — | **بدون هیچ تغییر** |
