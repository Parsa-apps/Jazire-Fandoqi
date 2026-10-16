import com.android.apksig.ApkVerifier;
import java.io.File;
import java.nio.file.Files;
import java.nio.file.Path;
import java.security.MessageDigest;
import java.security.cert.X509Certificate;
import java.util.HexFormat;
import java.util.List;
import java.util.Locale;

/** Run with the Android SDK's apksigner.jar on the JDK 17 classpath.
 * Use the verifier's certificate API instead of SDK-dependent console labels.
 * Only public certificate information is printed; no keystore/password is read.
 */
public final class VerifyApkSigner {
    public static void main(String[] args) {
        try {
            if (args.length != 2) {
                throw new IllegalArgumentException("Expected APK and release certificate SHA-256 file");
            }
            String expected = Files.readString(Path.of(args[1])).trim().toLowerCase(Locale.ROOT);
            if (!expected.matches("[0-9a-f]{64}")) {
                throw new IllegalArgumentException("Configured release certificate digest is malformed");
            }
            ApkVerifier.Result result = new ApkVerifier.Builder(new File(args[0])).build().verify();
            if (!result.isVerified()) {
                throw new IllegalArgumentException("APK signature verification failed: " + result.getErrors());
            }
            List<X509Certificate> signers = result.getSignerCertificates();
            if (signers.size() != 1) {
                throw new IllegalArgumentException("Expected one release signer, found " + signers.size());
            }
            X509Certificate signer = signers.get(0);
            String actual = HexFormat.of().formatHex(
                    MessageDigest.getInstance("SHA-256").digest(signer.getEncoded()));
            if (!actual.equals(expected)) {
                throw new IllegalArgumentException("APK signer does not match the configured release keystore");
            }
            String subject = signer.getSubjectX500Principal().getName();
            if (subject.toLowerCase(Locale.ROOT).contains("cn=android debug")) {
                throw new IllegalArgumentException("Android debug certificate is not a production signer");
            }
            // Stable format consumed by verify_production_apk.py, not copied
            // from the apksigner command's changing human-readable output.
            System.out.println("Signer #1 certificate DN: " + subject);
            System.out.println("Signer #1 certificate SHA-256 digest: " + actual);
        } catch (Exception error) {
            System.err.println("::error::Production APK signer rejected: " + error.getMessage());
            System.exit(1);
        }
    }
}
