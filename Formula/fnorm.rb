class Fnorm < Formula
  desc "Fix Unicode normalization for filenames in the CLI"
  homepage "https://github.com/Capella87/FixNormalization"
  license "MIT"

  on_macos do
    on_arm do
      url "https://github.com/Capella87/FixNormalization/releases/download/v0.2.3/fnorm-v0.2.3-osx-arm64.zip"
      sha256 "c78f49b0ca3a56daba945edab6b951fbd399311537871de54dea48e687311f12"
    end
    on_intel do
      url "https://github.com/Capella87/FixNormalization/releases/download/v0.2.3/fnorm-v0.2.3-osx-x64.zip"
      sha256 "81c50e68fc7045103bf59c45590ce45d5554391c6207c20330977b94fc72e10e"
    end
  end

  on_linux do
    on_arm do
      url "https://github.com/Capella87/FixNormalization/releases/download/v0.2.3/fnorm-v0.2.3-linux-arm64.zip"
      sha256 "6206b7ea3e418dd7507e81ac553dbed76e8d48770471a0cd19765f8046379df1"
    end
    on_intel do
      url "https://github.com/Capella87/FixNormalization/releases/download/v0.2.3/fnorm-v0.2.3-linux-x64.zip"
      sha256 "8dd390857f0543f70625261c394df215f5f5d39fcfe39fca6f2dc72c5923a1df"
    end
  end

  def install
    # The archives are now flattened, so install the published app directory
    # directly into libexec and keep the full runtime payload together.
    libexec.install Dir["#{buildpath}/*"].reject { |p| p == buildpath/".DS_Store" }

    # The published app binary in the zip keeps the archive's non-executable
    # mode bits, so ensure the launcher itself is runnable before Homebrew wraps
    # it in a bin stub.
    chmod 0755, libexec/"fnorm"

    # macOS may attach quarantine attributes to downloaded binaries, and a
    # self-contained .NET app needs the entire payload to be clear of that flag
    # before it can be launched.
    system "xattr", "-dr", "com.apple.quarantine", libexec if OS.mac?

    # The launcher falls back to .NET host-muxer behaviour when it is invoked
    # through a relative path, so exec it by absolute path rather than symlink it.
    bin.write_exec_script libexec/"fnorm"
  end

  test do
    # fnorm exits non-zero after printing its version.
    assert_match version.to_s, shell_output("#{bin}/fnorm --version", 1)

    (testpath/"인.txt").write "test"
    system bin/"fnorm", "fix", "인.txt", "--form", "FormC"
    assert_path_exists testpath/"인.txt"
  end
end
