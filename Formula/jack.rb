# This now builds a version of JACKv1 which matches the current API
# for JACKv2. JACKv2 is not buildable on a number of macOS
# distributions, and the JACK team instead suggests installation of
# JACKOSX, a pre-built binary form for which the source is not available.
# If you require JACKv2, you should use that. Otherwise, this formula should
# operate fine.
# Please see https://github.com/Homebrew/homebrew/pull/22043 for more info
class Jack < Formula
  desc "Audio Connection Kit"
  homepage "http://jackaudio.org"
  url "http://jackaudio.org/downloads/jack-audio-connection-kit-0.125.0.tar.gz"
  sha256 "3517b5bff82139a76b2b66fe2fd9a3b34b6e594c184f95a988524c575b11d444"
  revision 1

  bottle do
    sha256 "0a993d32dd74ce014e0c0aa5a04e632a7e4bca7bc6ced4afa9a7d717cc893f06" => :sierra
    sha256 "abb9fc993cda86b4daf45f0d2a8c775716fec08fc016facd8151787ac06e60e4" => :el_capitan
    sha256 "de96b9c43cb77f57d42ba02c1373b31a421ec485eafe401c11cc27c8c8c1838f" => :yosemite
    sha256 "5ab5409b416b61fd92c1f5186b568a449ea86f3471c008d44995938dba3d4c87" => :x86_64_linux # glibc 2.19
  end

  depends_on "pkg-config" => :build
  depends_on "berkeley-db"
  depends_on "libsndfile"
  depends_on "libsamplerate"
  depends_on "util-linux" if OS.linux? # for libuuid

  def install
    # Makefile hardcodes Carbon header location
    inreplace Dir["drivers/coreaudio/Makefile.{am,in}"],
      "/System/Library/Frameworks/Carbon.framework/Headers/Carbon.h",
      "#{MacOS.sdk_path}/System/Library/Frameworks/Carbon.framework/Headers/Carbon.h"

    ENV["LINKFLAGS"] = ENV.ldflags
    system "./configure", "--prefix=#{prefix}"
    system "make", "install"
  end

  plist_options :manual => "jackd -d coreaudio"

  def plist; <<-EOS.undent
    <?xml version="1.0" encoding="UTF-8"?>
    <!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
    <plist version="1.0">
    <dict>
      <key>Label</key>
      <string>#{plist_name}</string>
      <key>WorkingDirectory</key>
      <string>#{prefix}</string>
      <key>ProgramArguments</key>
      <array>
        <string>#{opt_bin}/jackd</string>
        <string>-d</string>
        <string>coreaudio</string>
      </array>
      <key>RunAtLoad</key>
      <true/>
      <key>KeepAlive</key>
      <true/>
    </dict>
    </plist>
    EOS
  end

  test do
    assert_match version.to_s, shell_output("#{bin}/jackd --version")
  end
end
