class Pianobar < Formula
  desc "Command-line player for https://pandora.com"
  homepage "https://github.com/PromyLOPh/pianobar/"
  url "https://6xq.net/pianobar/pianobar-2017.08.30.tar.bz2"
  sha256 "ec14db6cf1a7dbc1d8190b5ca0d256021e970587bcdaeb23904d4bca71a04674"
  head "https://github.com/PromyLOPh/pianobar.git"

  bottle do
    cellar :any
    sha256 "327b53a2b9e2fd6824d0c854b5ea411b29b07ba5804b443c453aee05a86e36d4" => :sierra
    sha256 "ea582da39bf90a0122d74678cdf82349af53adcbab48ff5bd2d57c64ca16150f" => :el_capitan
    sha256 "41d44c9f1680fa404639ae9b907df30bbb019b1628454e8d77eba95af6a1a883" => :yosemite
    sha256 "406d403ca6f2818fe073a504f3de5e10721b2820a58dd664ebb482eb12f0b341" => :x86_64_linux
  end

  depends_on "pkg-config" => :build
  depends_on "libao"
  depends_on "mad"
  depends_on "faad2"
  depends_on "gnutls"
  depends_on "libgcrypt"
  depends_on "json-c"
  depends_on "ffmpeg"

  def install
    # Discard Homebrew's CFLAGS as Pianobar reportedly doesn't like them
    ENV["CFLAGS"] = "-O2 -DNDEBUG " +
                    # Or it doesn't build at all
                    "-std=c99 " +
                    # build if we aren't /usr/local'
                    "#{ENV.cppflags} #{ENV.ldflags}"
    system "make", "PREFIX=#{prefix}"
    system "make", "install", "PREFIX=#{prefix}"

    prefix.install "contrib"
  end
end
