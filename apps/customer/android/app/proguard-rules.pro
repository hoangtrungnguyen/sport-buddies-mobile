# okhttp references optional TLS providers (BouncyCastle, Conscrypt, OpenJSSE)
# that are not on the classpath. R8 full-mode fails the build on these missing
# classes unless told to ignore them — okhttp falls back to the platform TLS
# at runtime, so they are safe to suppress.
# (Matches the rules R8 emits in build/outputs/mapping/release/missing_rules.txt)
-dontwarn org.bouncycastle.jsse.**
-dontwarn org.conscrypt.**
-dontwarn org.openjsse.**
