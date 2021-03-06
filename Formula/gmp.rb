class Gmp < Formula
  desc "GNU multiple precision arithmetic library"
  homepage "https://gmplib.org/"
  url "https://gmplib.org/download/gmp/gmp-6.1.1.tar.xz"
  mirror "https://ftp.gnu.org/gnu/gmp/gmp-6.1.1.tar.xz"
  sha256 "d36e9c05df488ad630fff17edb50051d6432357f9ce04e34a09b3d818825e831"

  bottle do
    cellar :any
    rebuild 1
    sha256 "cd4a916966007092af477a76655cc1f66546d00bf5e581a5dfef334f8436aeb0" => :sierra
    sha256 "01b24de832db7aa24ee14159feb5a16e0e3e18932e6f38d221331bb45feb6a1a" => :el_capitan
    sha256 "3752709f0bab1999fa9d5407bcd3135a873b48fc34d5e6ea123fd68c4cf3644d" => :yosemite
    sha256 "a9b92c1ac7cc79df39c5bf7f3c2b0abeb26b9bc417c13d55e3628058aaaa301c" => :x86_64_linux # glibc 2.19
  end

  option :cxx11

  def install
    ENV.cxx11 if build.cxx11?
    args = %W[--prefix=#{prefix} --enable-cxx]
    if OS.mac?
      args << "--build=core2-apple-darwin#{`uname -r`.to_i}" if build.bottle?
    else
      args << "ABI=32" if Hardware::CPU.intel? && Hardware::CPU.is_32_bit?
    end
    system "./configure", *args
    system "make"
    system "make", "check"
    system "make", "install"
  end

  test do
    (testpath/"test.c").write <<-EOS.undent
      #include <gmp.h>
      #include <stdlib.h>

      int main() {
        mpz_t i, j, k;
        mpz_init_set_str (i, "1a", 16);
        mpz_init (j);
        mpz_init (k);
        mpz_sqrtrem (j, k, i);
        if (mpz_get_si (j) != 5 || mpz_get_si (k) != 1) abort();
        return 0;
      }
    EOS
    system ENV.cc, "test.c", "-L#{lib}", "-lgmp", "-o", "test"
    system "./test"
  end
end
