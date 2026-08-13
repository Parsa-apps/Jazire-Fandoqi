# 🔑 راهنمای چرخش کلید امضا و انتقال به Secrets

> **مکمل:** `CODE_REVIEW_REPORT.md` (یافتهٔ C1) و `CODE_REVIEW_DEEP_DIVE.md` (بخش A)
> **وضعیت فعلی (به درخواست شما):** هیچ فایلی در ریپازیتوری تغییر نکرده است؛ این سند «دستورالعمل اجرا» است. هر بخش که نیازمند تغییر کد/CI است با برچسب ⏳ مشخص شده تا بعداً اعمال شود.

---

## ۱. توصیف دقیق وضعیت

| واقعیت | وضعیت |
|---|---|
| مخزن `farshadkurd/kudake_iran` | **عمومی** (تأیید شده با `gh repo view --json isPrivate`) |
| `android/key.properties` | حاوی `storePassword` و `keyPassword` به‌صورت **متن ساده** — commit شده و در تاریخ git موجود |
| `android/release.keystore` | فایل باینری keystore — commit شده و قابل دانلود |
| CI (GitHub Actions) | بیلد release را با همین کلید امضا می‌کند و APK/AAB امضاشده را به‌عنوان artifact در همان مخزن عمومی آپلود می‌کند |
| کامنت `.gitignore` | «به درخواست مالک track می‌شوند… مخزن را خصوصی نگه دارید» — اما مخزن خصوصی نیست |

### مدل تهدید (چه کسی چه کاری می‌تواند بکند)

1. **جعل آپدیت:** مهاجم با همین کلید و `applicationId=com.parsaapps.amoozesh_fandoghi` یک APK مخرب امضا می‌کند و در سایت‌های دانلود APK فارسی/کانال‌های تلگرام به‌جای اپ شما توزیع می‌کند. اندروید آن را به‌عنوان «نسخهٔ جدید همان اپ» می‌پذیرد (اگر کاربر از منبع نامعتبر نصب کند).
2. **بی‌اثر شدن anti-tamper نسخه ۶.۳:** بررسی `EXPECTED_SIGNING_SHA256` فقط زمانی مهاجم را می‌گیرد که کلید متفاوتی داشته باشد. مهاجمی که کلید واقعی را دارد از این دروازه رد می‌شود (جزئیات: بخش A سند Deep Dive).
3. **سرقت هویت ناشر در بلندمدت:** حتی اگر امروز هیچ‌کس متوجه نشود، این کلید برای همیشه در تاریخ عمومی git (و هر clone/fork گرفته‌شده) باقی می‌ماند.

> ⚠️ **نکتهٔ مهم دربارهٔ حذف ساده:** پاک کردن فایل‌ها از «آخرین نسخهٔ» ریپو کافی نیست؛ هر کس به تاریخ commitها دسترسی دارد. فقط بازنویسی تاریخ (بخش ۴) یا فرضِ «کلید سوخته» (بخش ۳) چاره‌ساز است.

---

## ۲. اقدام فوریِ امروز (بدون هیچ تغییر کد)

- [ ] **مخزن را خصوصی کنید:** GitHub → Settings → Danger Zone → Change visibility → Private. این کار پنجرهٔ سوءاستفاده را فوراً می‌بندد و به شما زمان می‌دهد. (ریسک: badge لینک CI در README تا زمانی که خصوصی است برای بازدیدکنندگان لود نمی‌شود — مهم نیست.)
- [ ] اگر تا تکمیل مراحل، انتشار جدیدی در کافه‌بازار دارید، با همین وضع ادامه ندهید؛ هر نسخهٔ جدید با کلید لو رفته، سطح حمله را بزرگ‌تر می‌کند.

---

## ۳. تصمیم اصلی: چرخش کلید یا نگهداری آن؟

```
آیا اپ قبلاً با این کلید در کافه‌بازار «منتشر» شده است؟
│
├─ ❌ نه (هنوز منتشر نشده یا فقط تست داخلی)
│    → سناریوی A: چرخش کامل کلید (پیشنهاد قطعی — کم‌هزینه و بی‌ریسک)
│
└─ ✅ بله، در کافه‌بازار زنده است
     → سناریوی B: کلید قابل تعویض آسان نیست؛ مسیر ویژه (بخش ۳-۲)
```

### ۳-۱. سناریوی A — هنوز منتشر نشده (پیشنهاد ما)

کلید فعلی را **برای همیشه سوخته** فرض کنید و یک keystore جدید بسازید. ابزارش در خود پروژه هست:

```bash
# ابزار موجود پروژه:
tools/generate_release_keystore.sh
# یا مستقیم با keytool:
keytool -genkeypair -v \
  -keystore release.keystore.new \
  -alias fandoghi \
  -keyalg RSA -keysize 2048 -validity 10000 \
  -storepass '<رمز-قوی-جدید>' \
  -keypass  '<رمز-قوی-جدید>' \
  -dname "CN=Fandoghi, OU=ParsaApps, O=Parsa Apps, C=IR"
```

> رمز جدید را در هیچ فایلی از ریپو ننویسید (ادامهٔ بخش ۵).

### ۳-۲. سناریوی B — کلید در کافه‌بازار استفاده شده

امضای اپ اندرویدی پس از انتشار عملاً قابل تعویض خودکار نیست (مشابه Google Play). گزینه‌ها به ترتیب ترجیح:

1. **تماس با پشتیبانی کافه‌بازار** و درخواست «تغییر کلید امضا» یا راهنمای رسمی آن‌ها. برخی استورهای ایرانی برای حالت لو رفتن کلید رویهٔ دستی دارند؛ این را کتباً بپرسید و جواب را نگه دارید.
2. **انتشار مجدد به‌عنوان اپ جدید** با کلید تازه (package name جدید یا حذف نسخهٔ قدیم) — هزینه: از دست رفتن نصب‌ها/امتیازها. برای اپی که هنوز در فاز انتشار اولیه است قابل قبول است.
3. **ادامه با کلید فعلی (بدون چرخش):** فقط در صورتی که گزینه‌های ۱ و ۲ ممکن نباشند. در این حالت حداقل کارهای زیر الزامی است:
   - تاریخ git پاکسازی شود (تا کلید حداقل در جستجوی ساده پیدا نشود — هرچند fork/cloneهای قبلی را نمی‌توان پس گرفت)،
   - مخزن برای همیشه خصوصی بماند،
   - پایش فعال: هر ماه عبارت‌های «amoozesh_fandoghi apk» و نام اپ را در گوگل/تلگرام جستجو کنید تا نسخهٔ جعلی زودتر کشف شود،
   - پذیرش صریح این ریسک در مستندات (مثلاً افزودن یک بند به `SECURITY_AUDIT_REPORT.md`).

---

## ۴. پاک‌سازی تاریخ git (هر دو سناریو لازم است)

> ⚠️ بازنویسی تاریخ، هش commitها را عوض می‌کند. چون کار شما روی branchهای فعال است، این مرحله را زمانی اجرا کنید که PR بازِ مهمی ندارید یا آمادهٔ rebase هستید.

```bash
# ۱) نصب git-filter-repo (یک‌بار):
pip install git-filter-repo        # یا: brew install git-filter-repo

# ۲) پشتیبان‌گیری:
cd /path/to/kudake_iran
git bundle create ../kudake_backup.bundle --all

# ۳) حذف دو فایل از «کل تاریخ» همهٔ شاخه‌ها و تگ‌ها:
git filter-repo --invert-paths \
  --path android/key.properties \
  --path android/release.keystore

# ۴) force push همه‌چیز:
git push origin --force --all
git push origin --force --tags

# ۵) پاک‌سازی سمت GitHub تا نسخه‌های قدیمی قابل fetch نباشند:
#    - در GitHub: Settings → General → «Purge all caches» (در دسترس نباشد مهم نیست)
#    - یک issue/support ticket به GitHub برای پاک‌کردن cached views commitهای قدیمی بزنید
#      (لینک مستقیم commitهای حاوی فایل را ضمیمه کنید).
```

**راستی‌آزمایی:** بعد از force push، در یک clone کاملاً تازه اجرا کنید:
```bash
git clone --mirror <repo-url> audit.git && cd audit.git
git log --all --oneline -- android/key.properties android/release.keystore   # باید خالی باشد
```

> یادآوری صادقانه: هر clone که قبل از پاک‌سازی گرفته شده (شامل CI runnerها و کش‌ها) همچنان فایل را دارد. به همین دلیل در سناریوی A «چرخش کلید» راه‌حل اصلی است و پاک‌سازی تاریخ فقط بهداشت عمومی است.

---

## ۵. انتقال رمزها به GitHub Secrets ⏳ (تغییرات آینده — هنوز اعمال نشده)

### ۵-۱. ذخیرهٔ Secrets

```bash
gh secret set KEYSTORE_B64 --repo farshadkurd/kudake_iran \
  --body "$(base64 -w0 android/release.keystore.new)"
gh secret set KEYSTORE_PASSWORD  --repo farshadkurd/kudake_iran --body '<رمز>'
gh secret set KEY_ALIAS          --repo farshadkurd/kudake_iran --body 'fandoghi'
gh secret set KEY_PASSWORD       --repo farshadkurd/kudake_iran --body '<رمز>'
```
(keystore فایل باینری است؛ به‌صورت base64 در secret می‌رود.)

### ۵-۲. تغییر `key.properties` و `.gitignore` ⏳

`key.properties` دیگر نباید وجود داشته باشد؛ `android/.gitignore` هم اضافه کند:
```
key.properties
release.keystore
*.keystore
```

### ۵-۳. تغییر workflow ⏳ (`.github/workflows/build-apk.yml`)

الگویی که بعداً اعمال می‌شود (اسکلت پیشنهادی):

```yaml
      - name: Prepare signing config
        if: env.KEYSTORE_B64 != ''
        env:
          KEYSTORE_B64: ${{ secrets.KEYSTORE_B64 }}
        run: |
          echo "$KEYSTORE_B64" | base64 -d > android/release.keystore
          cat > android/key.properties <<EOF
          storeFile=release.keystore
          storePassword=${{ secrets.KEYSTORE_PASSWORD }}
          keyAlias=${{ secrets.KEY_ALIAS }}
          keyPassword=${{ secrets.KEY_PASSWORD }}
          EOF
```

> نکتهٔ مهمِ طراحی build.gradle فعلی شما: وقتی `key.properties` نباشد، بیلد release در CI با `allowVerificationSigning` (چون `GITHUB_ACTIONS=true`) به امضای **debug** ساخته می‌شود و `EXPECTED_SIGNING_SHA256` خالی می‌ماند — یعنی build.gradle از قبل برای حالت «بدون کلید در ریپو» طراحی شده و فقط secrets بالا جای خالی را پر می‌کند. این طراحی خوب را حفظ کنید.

### ۵-۴. تأیید امضای درست در CI ⏳

بعد از بیلد، این دو خط را به workflow اضافه کنید تا اگر امضا اشتباه بود CI قرمز شود:

```yaml
      - name: Verify signature digest
        run: |
          keytool -printcert -jarfile build/app/outputs/flutter-apk/app-release.apk \
            | grep -i "SHA256:" 
          # هش چاپ‌شده باید با tools/print_cert_sha256.sh روی keystore جدید یکی باشد
```

---

## ۶. چک‌لیست نهایی این عملیات

- [ ] مخزن خصوصی شد (همین امروز)
- [ ] تصمیم سناریوی A/B گرفته شد (بستگی به وضعیت انتشار در کافه‌بازار دارد)
- [ ] (A) keystore جدید ساخته شد و یک نسخهٔ بکاپ آفلاین امن از آن دارید — **گم شدن keystore یعنی دیگر هیچ‌وقت نمی‌توانید همان اپ را آپدیت کنید**
- [ ] تاریخ git با `git filter-repo` پاک و force push شد
- [ ] Clone تازه تأیید شد که فایل‌ها در تاریخ نیستند
- [ ] Secrets در GitHub ثبت شد و workflow از آن‌ها می‌خواند
- [ ] `EXPECTED_SIGNING_SHA256` بیلد release با هش گواهی جدید برابر است (`tools/print_cert_sha256.sh`)
- [ ] یک بیلد آزمایشی روی گوشی واقعی: اپ اجرا می‌شود، TamperBlockScreen نمی‌آید، خرید/پین/بکاپ کار می‌کنند
- [ ] (B) اگر کلید قدیمی نگه داشته شد: برنامهٔ پایش ماهانهٔ نسخه‌های جعلی ثبت شد
- [ ] یک بند «مدیریت اسرار بیلد» به `SECURITY_AUDIT_REPORT.md` یا `BUILD_INSTRUCTIONS.md` اضافه شد تا این اشتباه تکرار نشود

---

## ۷. قواعد بلندمدت (برای جلوگیری از تکرار)

1. هیچ secret/keystore هرگز وارد git نشود؛ حتی در ریپوی خصوصی. معیار ساده: اگر نمی‌توانید آن فایل را در یک توییت عمومی بگذارید، نباید در git باشد.
2. بیلد قابل انتشار فقط از CI با Secrets ساخته شود؛ بیلد محلی فقط برای توسعه.
3. در `pre-commit` یا CI یک grep سبک اضافه شود: جستجوی الگوهایی مثل `storePassword=` در فایل‌های staged (اسکریپت `tools/privacy_audit.sh` الگوی خوبی برای توسعهٔ این check است).
4. هر شش ماه یک‌بار: مرور دسترسی‌های ریپو + مرور artifactهای عمومی workflowها (یا حذفشان با `retention-days`).
