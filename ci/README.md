# ci/ — فایل workflow پیشنهادی (H3)

## این پوشه چیست؟

`build-apk.proposed.yml` نسخه‌ی آماده‌ی `.github/workflows/build-apk.yml` است که
موارد H3 (حرفه‌ای‌سازی CI/CD) روی آن اعمال شده.

این فایل عمداً **بیرون از `.github/workflows/`** قرار گرفته چون توکن عامل
(GitHub App) مجوز `workflows` ندارد و push روی آن مسیر با `remote rejected` رد می‌شود.

## نحوه‌ی اعمال

```bash
cp ci/build-apk.proposed.yml .github/workflows/build-apk.yml
git add .github/workflows/build-apk.yml
git commit -m "ci: add analyze/test, split-per-abi + universal APK, obfuscation (H3)"
git push origin arena/019ffc40-kudake-iran
```

پس از اعمال و سبز شدن CI، این پوشه (`ci/`) را می‌توان حذف کرد.

## تغییرات نسبت به فایل فعلی

| # | تغییر | چرا |
|---|---|---|
| 1 | افزودن مرحله‌ی `flutter analyze --no-fatal-infos` | کشف زودهنگام خطاهای استاتیک. در اولین اجرا `continue-on-error: true` است تا وضعیت موجود دیده شود بدون قرمز شدن CI. |
| 2 | افزودن مرحله‌ی `flutter test` با مسیرهای صریح | اجرای ۲۲ تست headless. `test/integration_test/` عمداً کنار گذاشته شده چون به دستگاه/امولاتور نیاز دارد. |
| 3 | APK یونیورسال با `--obfuscate --split-debug-info` | حفظ خروجی تک‌فایل برای تست دستی، با کد مبهم‌سازی‌شده. |
| 4 | افزودن بیلد `--split-per-abi` | خروجی قابل انتشار؛ حدود ۳۵–۴۰٪ کاهش حجم به‌ازای هر ABI. |
| 5 | بازنویسی `Verify release signing` به حلقه روی همه‌ی APKها | مسیر `app-release.apk` زیر split عوض می‌شود؛ حالا یونیورسال + هر سه ABI بررسی می‌شوند و حداقل‌شمارش (`COUNT >= 2`) از سکوت خطا جلوگیری می‌کند. |
| 6 | افزودن `--obfuscate` به بیلد AAB | یکسان‌سازی سطح مبهم‌سازی بین APK و AAB. |
| 7 | مرحله‌ی `Report artifact sizes` | نوشتن جدول حجم خروجی‌ها در Job Summary برای مقایسه‌ی قبل/بعد. |
| 8 | آرتیفکت جدید `..._apk_universal` | جدا از آرتیفکت split تا هر دو در دسترس باشند. |
| 9 | آرتیفکت جدید `..._debug_symbols` (نگهداری ۹۰ روز) | بدون سمبل‌ها، stack trace نسخه‌ی obfuscate‌شده غیرقابل خواندن است. |
| 10 | `if-no-files-found: error` روی همه‌ی آپلودها | جلوگیری از آرتیفکت خالی در صورت تغییر مسیر خروجی. |

## آنچه تغییر **نکرده**

- هیچ فایل `.dart` — طبق قانون پروژه.
- امضای release از GitHub Secrets (`KEYSTORE_B64`, `KEYSTORE_PASSWORD`, alias `fandoghi`) — دست‌نخورده.
- keystore همچنان کامیت نمی‌شود (`.gitignore` خطوط ۱۹–۲۱).
- گیت `if: ${{ env.KEYSTORE_B64 != '' }}` روی مراحل امضا — دست‌نخورده.
- نسخه‌ی Flutter (`3.24.3`)، Java 17، تریگرها، `pubspec.yaml`، gradle، assets.

## نکته‌ی امنیتی درباره‌ی سمبل‌ها

`--split-debug-info` خروجی را زیر `build/symbols/` می‌نویسد و `build/` در
`.gitignore` هست، پس سمبل‌ها هرگز کامیت نمی‌شوند — فقط به‌عنوان آرتیفکت CI
آپلود می‌شوند.
