class Minizip < Formula
  desc "C library for zip/unzip via zLib"
  homepage "http://www.winimage.com/zLibDll/minizip.html"
  url "https://zlib.net/zlib-1.2.11.tar.gz"
  sha256 "c3e5e9fdd5004dcb542feda5ee4f0ff0744628baf8ed2dd5d66f8ca1197cb1a1"

  bottle do
    cellar :any
    rebuild 1
    sha256 "8d4d3d12774a660c68be156caf804a9982d5d79204c66b0c3e56f3e92d0fe09b" => :sierra
    sha256 "a0f89a172ba19d62c331c083c94e91f575a66bb56438c1a9eb55b59fbc570598" => :el_capitan
    sha256 "c506cadbf592627a4a6c45de9d5a96fc5da8fe6115ea9a93ca95ec7d96bc115d" => :yosemite
    sha256 "07e97ea251d2e46192724b1ef68335cfb2baceaeee34fd26190af8f4412c67cc" => :x86_64_linux # glibc 2.19
  end

  depends_on "autoconf" => :build
  depends_on "automake" => :build
  depends_on "libtool" => :build
  depends_on "zlib" unless OS.mac?

  def install
    system "./configure", "--prefix=#{prefix}"
    system "make"

    cd "contrib/minizip" do
      # edits to statically link to libz.a
      inreplace "Makefile.am" do |s|
        s.sub! "-L$(zlib_top_builddir)", "$(zlib_top_builddir)/libz.a"
        s.sub! "-version-info 1:0:0 -lz", "-version-info 1:0:0"
        s.sub! "libminizip.la -lz", "libminizip.la"
      end if OS.mac?
      system "autoreconf", "-fi"
      system "./configure", "--prefix=#{prefix}"
      system "make", "install"
    end
  end

  def caveats
    <<-EOS.undent
      Minizip headers installed in 'minizip' subdirectory, since they conflict
      with the venerable 'unzip' library.
    EOS
  end
end
