class MacRobber < Formula
  desc "Digital investigation tool"
  homepage "https://www.sleuthkit.org/mac-robber/"
  url "https://downloads.sourceforge.net/project/mac-robber/mac-robber/1.02/mac-robber-1.02.tar.gz"
  sha256 "5895d332ec8d87e15f21441c61545b7f68830a2ee2c967d381773bd08504806d"

  bottle do
    cellar :any_skip_relocation
    sha256 "160983c4988cb22bd68a0beeb48de91a8af3461722a42e65e523c4a6af08f444" => :sierra
    sha256 "0647670a38eb3ae5d8085ad1126f8d70b6e9ac99b086c0ec2f3301ac51ecdb3f" => :el_capitan
    sha256 "5e8b7656cafbab151ed82702cbd7e712ee30af62b6a6c031f9f440e95c174ed0" => :yosemite
    sha256 "87b8de3e43626713461398aac48d12a4b494c36b8da6cd4e6587d352fcb251fe" => :mavericks
    sha256 "5713286c509ff4ec129c2ab60ddd41fda7e9782ad2c36b92539853a12254cf1f" => :x86_64_linux # glibc 2.19
  end

  def install
    system "make", "CC=#{ENV.cc}", "GCC_OPT=#{ENV.cflags}"
    bin.install "mac-robber"
  end
end
