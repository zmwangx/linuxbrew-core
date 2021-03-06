class CodesignRequirement < Requirement
  include FileUtils
  fatal true

  satisfy(:build_env => false) do
    mktemp do
      cp "/usr/bin/false", "llvm_check"
      quiet_system "/usr/bin/codesign", "-f", "-s", "lldb_codesign", "--dryrun", "llvm_check"
    end
  end

  def message
    <<-EOS.undent
      lldb_codesign identity must be available to build with LLDB.
      See: https://llvm.org/svn/llvm-project/lldb/trunk/docs/code-signing.txt
    EOS
  end
end

class Llvm < Formula
  desc "Next-gen compiler infrastructure"
  homepage "https://llvm.org/"

  stable do
    url "https://llvm.org/releases/4.0.1/llvm-4.0.1.src.tar.xz"
    sha256 "da783db1f82d516791179fe103c71706046561f7972b18f0049242dee6712b51"

    resource "clang" do
      url "https://llvm.org/releases/4.0.1/cfe-4.0.1.src.tar.xz"
      sha256 "61738a735852c23c3bdbe52d035488cdb2083013f384d67c1ba36fabebd8769b"
    end

    resource "clang-extra-tools" do
      url "https://llvm.org/releases/4.0.1/clang-tools-extra-4.0.1.src.tar.xz"
      sha256 "35d1e64efc108076acbe7392566a52c35df9ec19778eb9eb12245fc7d8b915b6"
    end

    resource "compiler-rt" do
      url "https://llvm.org/releases/4.0.1/compiler-rt-4.0.1.src.tar.xz"
      sha256 "a3c87794334887b93b7a766c507244a7cdcce1d48b2e9249fc9a94f2c3beb440"
    end

    # Only required to build & run Compiler-RT tests on macOS, optional otherwise.
    # https://clang.llvm.org/get_started.html
    resource "libcxx" do
      url "https://llvm.org/releases/4.0.1/libcxx-4.0.1.src.tar.xz"
      sha256 "520a1171f272c9ff82f324d5d89accadcec9bc9f3c78de11f5575cdb99accc4c"
    end

    resource "libcxxabi" do
      url "https://llvm.org/releases/4.0.1/libcxxabi-4.0.1.src.tar.xz"
      sha256 "8f08178989a06c66cd19e771ff9d8ca526dd4a23d1382d63e416c04ea9fa1b33"
    end

    resource "libunwind" do
      url "https://llvm.org/releases/4.0.1/libunwind-4.0.1.src.tar.xz"
      sha256 "3b072e33b764b4f9b5172698e080886d1f4d606531ab227772a7fc08d6a92555"
    end

    resource "lld" do
      url "https://llvm.org/releases/4.0.1/lld-4.0.1.src.tar.xz"
      sha256 "63ce10e533276ca353941ce5ab5cc8e8dcd99dbdd9c4fa49f344a212f29d36ed"
    end

    resource "lldb" do
      url "https://llvm.org/releases/4.0.1/lldb-4.0.1.src.tar.xz"
      sha256 "8432d2dfd86044a0fc21713e0b5c1d98e1d8aad863cf67562879f47f841ac47b"
    end

    resource "openmp" do
      url "https://llvm.org/releases/4.0.1/openmp-4.0.1.src.tar.xz"
      sha256 "ec693b170e0600daa7b372240a06e66341ace790d89eaf4a843e8d56d5f4ada4"
    end

    resource "polly" do
      url "https://llvm.org/releases/4.0.1/polly-4.0.1.src.tar.xz"
      sha256 "b443bb9617d776a7d05970e5818aa49aa2adfb2670047be8e9f242f58e84f01a"
    end
  end

  bottle do
    cellar :any
    rebuild 1
    sha256 "109ea0b2b78a44b2256ebb9b2d5966185e7b6a8045cc6dbcea85fab1051ea2a4" => :sierra
    sha256 "f3be215d6e8f41504add8b09ac97d695b988d333266ff163fc2c53405a468a38" => :el_capitan
    sha256 "8ec98b7eaf1de2dca1e2a10caa3edd2cace088185257e7bb39fe068713bf5121" => :yosemite
    sha256 "88aafc74a822773ef3bde85e45d1c4b68ef48aac7be41403a2d2f11971bef37f" => :x86_64_linux # glibc 2.19
  end

  pour_bottle? do
    default_prefix = BottleSpecification::DEFAULT_PREFIX
    reason "The bottle needs to be installed into #{default_prefix}."
    satisfy { OS.mac? || HOMEBREW_PREFIX.to_s == default_prefix }
  end

  head do
    url "https://llvm.org/git/llvm.git"

    resource "clang" do
      url "https://llvm.org/git/clang.git"
    end

    resource "clang-extra-tools" do
      url "https://llvm.org/git/clang-tools-extra.git"
    end

    resource "compiler-rt" do
      url "https://llvm.org/git/compiler-rt.git"
    end

    resource "libcxx" do
      url "https://llvm.org/git/libcxx.git"
    end

    resource "libcxxabi" do
      url "http://llvm.org/git/libcxxabi.git"
    end

    resource "libunwind" do
      url "https://llvm.org/git/libunwind.git"
    end

    resource "lld" do
      url "https://llvm.org/git/lld.git"
    end

    resource "lldb" do
      url "https://llvm.org/git/lldb.git"
    end

    resource "openmp" do
      url "https://llvm.org/git/openmp.git"
    end

    resource "polly" do
      url "https://llvm.org/git/polly.git"
    end
  end

  keg_only :provided_by_osx

  option "without-compiler-rt", "Do not build Clang runtime support libraries for code sanitizers, builtins, and profiling"
  if OS.mac?
    option "without-libcxx", "Do not build libc++ standard library"
  else
    option "with-libcxx", "Build libc++ standard library"
  end
  option "with-toolchain", "Build with Toolchain to facilitate overriding system compiler"
  option "with-lldb", "Build LLDB debugger"
  option "with-python", "Build bindings against custom Python"
  option "with-shared-libs", "Build shared instead of static libraries"
  option "without-libffi", "Do not use libffi to call external functions"

  # https://llvm.org/docs/GettingStarted.html#requirement
  depends_on "libffi" => :recommended

  # for the 'dot' tool (lldb)
  depends_on "graphviz" => :optional

  depends_on "ocaml" => :optional
  if build.with? "ocaml"
    depends_on "opam" => :build
    depends_on "pkg-config" => :build
  end

  unless OS.mac?
    depends_on "gcc" # <atomic> is provided by gcc
    depends_on "glibc" => (GlibcRequirement.system_version.to_f >= 2.19) ? :optional : :recommended
    depends_on "binutils" # needed for gold and strip
    depends_on "libedit" # llvm requires <histedit.h>
    depends_on "ncurses"
    depends_on "libxml2"
    depends_on "python" if build.with?("python") || build.with?("lldb")
    depends_on "zlib"
    needs :cxx11
  end

  if MacOS.version <= :snow_leopard
    depends_on :python
  else
    depends_on :python => :optional
  end
  depends_on "cmake" => :build

  if build.with? "lldb"
    depends_on "swig" if MacOS.version >= :lion || !OS.mac?
    depends_on CodesignRequirement if OS.mac?
  end

  # According to the official llvm readme, GCC 4.7+ is required
  fails_with :gcc_4_0
  fails_with :gcc
  ("4.3".."4.6").each do |n|
    fails_with :gcc => n
  end

  def build_libcxx?
    build.with?("libcxx") || !MacOS::CLT.installed?
  end

  def install
    # Reduce memory usage below 4 GB for Circle CI.
    ENV["MAKEFLAGS"] = "-j5" if ENV["CIRCLECI"]

    # Apple's libstdc++ is too old to build LLVM
    ENV.libcxx if ENV.compiler == :clang

    (buildpath/"tools/clang").install resource("clang")
    unless OS.mac?
      # Add glibc to the list of library directories so that we won't have to do -L<path-to-glibc>/lib
      inreplace buildpath/"tools/clang/lib/Driver/ToolChains.cpp",
        "// Add the multilib suffixed paths where they are available.",
        "addPathIfExists(D, \"#{HOMEBREW_PREFIX}/opt/glibc/lib\", Paths);\n\n  // Add the multilib suffixed paths where they are available."
    end
    (buildpath/"tools/clang/tools/extra").install resource("clang-extra-tools")
    (buildpath/"projects/openmp").install resource("openmp")
    (buildpath/"projects/libcxx").install resource("libcxx") if build_libcxx?
    (buildpath/"projects/libcxxabi").install resource("libcxxabi") if build_libcxx? && !OS.mac?
    (buildpath/"projects/libunwind").install resource("libunwind")
    (buildpath/"tools/lld").install resource("lld")
    (buildpath/"tools/polly").install resource("polly")

    if build.with? "lldb"
      if build.with? "python"
        pyhome = `python-config --prefix`.chomp
        ENV["PYTHONHOME"] = pyhome
        dylib = OS.mac? ? "dylib" : "so"
        pylib = "#{pyhome}/lib/libpython2.7.#{dylib}"
        pyinclude = "#{pyhome}/include/python2.7"
      end
      (buildpath/"tools/lldb").install resource("lldb")

      # Building lldb requires a code signing certificate.
      # The instructions provided by llvm creates this certificate in the
      # user's login keychain. Unfortunately, the login keychain is not in
      # the search path in a superenv build. The following three lines add
      # the login keychain to ~/Library/Preferences/com.apple.security.plist,
      # which adds it to the superenv keychain search path.
      if OS.mac?
        mkdir_p "#{ENV["HOME"]}/Library/Preferences"
        username = ENV["USER"]
        system "security", "list-keychains", "-d", "user", "-s", "/Users/#{username}/Library/Keychains/login.keychain"
      end
    end

    if build.with? "compiler-rt"
      (buildpath/"projects/compiler-rt").install resource("compiler-rt")

      # compiler-rt has some iOS simulator features that require i386 symbols
      # I'm assuming the rest of clang needs support too for 32-bit compilation
      # to work correctly, but if not, perhaps universal binaries could be
      # limited to compiler-rt. llvm makes this somewhat easier because compiler-rt
      # can almost be treated as an entirely different build from llvm.
      ENV.permit_arch_flags
    end

    args = %w[
      -DLLVM_OPTIMIZED_TABLEGEN=ON
      -DLLVM_INCLUDE_DOCS=OFF
      -DLLVM_ENABLE_RTTI=ON
      -DLLVM_ENABLE_EH=ON
      -DLLVM_INSTALL_UTILS=ON
      -DWITH_POLLY=ON
      -DLINK_POLLY_INTO_TOOLS=ON
      -DLLVM_TARGETS_TO_BUILD=all
    ]
    args << "-DLIBOMP_ARCH=x86_64"
    args << "-DLLVM_BUILD_EXTERNAL_COMPILER_RT=ON" if build.with? "compiler-rt"
    args << "-DLLVM_CREATE_XCODE_TOOLCHAIN=ON" if build.with? "toolchain"

    if build.with? "shared-libs"
      args << "-DBUILD_SHARED_LIBS=ON"
      args << "-DLIBOMP_ENABLE_SHARED=ON"
    else
      args << "-DLLVM_BUILD_LLVM_DYLIB=ON"
    end

    args << "-DLLVM_ENABLE_LIBCXX=ON" if build_libcxx?
    args << "-DLLVM_ENABLE_LIBCXXABI=ON" if build_libcxx? && !OS.mac?

    if build.with?("lldb") && build.with?("python")
      args << "-DLLDB_RELOCATABLE_PYTHON=ON"
      args << "-DPYTHON_LIBRARY=#{pylib}"
      args << "-DPYTHON_INCLUDE_DIR=#{pyinclude}"
    end

    # Enable llvm gold plugin for LTO
    args << "-DLLVM_BINUTILS_INCDIR=#{Formula["binutils"].opt_include}" if OS.linux?

    if build.with? "libffi"
      args << "-DLLVM_ENABLE_FFI=ON"
      args << "-DFFI_INCLUDE_DIR=#{Formula["libffi"].opt_lib}/libffi-#{Formula["libffi"].version}/include"
      args << "-DFFI_LIBRARY_DIR=#{Formula["libffi"].opt_lib}"
    end

    # Help just-built clang++ find <atomic> (and, possibly, other header files). Needed for compiler-rt
    unless OS.mac?
      gccpref = Formula["gcc"].opt_prefix.to_s
      args << "-DGCC_INSTALL_PREFIX=#{gccpref}"
      args << "-DCMAKE_C_COMPILER=#{gccpref}/bin/gcc"
      args << "-DCMAKE_CXX_COMPILER=#{gccpref}/bin/g++"
      args << "-DCMAKE_CXX_LINK_FLAGS=-L#{gccpref}/lib64 -Wl,-rpath,#{gccpref}/lib64"
      args << "-DCLANG_DEFAULT_CXX_STDLIB=#{build.with?("libcxx")?"libc++":"libstdc++"}"
    end

    mktemp do
      if build.with? "ocaml"
        args << "-DLLVM_OCAML_INSTALL_PATH=#{lib}/ocaml"
        ENV["OPAMYES"] = "1"
        ENV["OPAMROOT"] = Pathname.pwd/"opamroot"
        (Pathname.pwd/"opamroot").mkpath
        system "opam", "init", "--no-setup"
        system "opam", "install", "ocamlfind", "ctypes"
        system "opam", "config", "exec", "--",
               "cmake", "-G", "Unix Makefiles", buildpath, *(std_cmake_args + args)
      else
        system "cmake", "-G", "Unix Makefiles", buildpath, *(std_cmake_args + args)
      end
      system "make"
      system "make", "install"
      system "make", "install-xcode-toolchain" if build.with?("toolchain") && OS.mac?
    end

    (share/"clang/tools").install Dir["tools/clang/tools/scan-{build,view}"]
    (share/"cmake").install "cmake/modules"
    inreplace "#{share}/clang/tools/scan-build/bin/scan-build", "$RealBin/bin/clang", "#{bin}/clang"
    bin.install_symlink share/"clang/tools/scan-build/bin/scan-build", share/"clang/tools/scan-view/bin/scan-view"
    man1.install_symlink share/"clang/tools/scan-build/man/scan-build.1"

    # install llvm python bindings
    (lib/"python2.7/site-packages").install buildpath/"bindings/python/llvm"
    (lib/"python2.7/site-packages").install buildpath/"tools/clang/bindings/python/clang"

    # Remove conflicting libraries.
    # libgomp.so conflicts with gcc.
    # libunwind.so conflcits with libunwind.
    rm [lib/"libgomp.so", lib/"libunwind.so"] if OS.linux?

    # Strip executables/libraries/object files to reduce their size
    unless OS.mac?
      system("strip", "--strip-unneeded", "--preserve-dates", *(Dir[bin/"**/*", lib/"**/*"]).select do |f|
        f = Pathname.new(f)
        f.file? && (f.elf? || f.extname == ".a")
      end)
    end
  end

  def caveats
    if build_libcxx?
      <<-EOS.undent
        To use the bundled libc++ please add the following LDFLAGS:
          LDFLAGS="-L#{opt_lib} -Wl,-rpath,#{opt_lib}"
      EOS
    end
  end

  test do
    assert_equal prefix.to_s, shell_output("#{bin}/llvm-config --prefix").chomp

    (testpath/"omptest.c").write <<-EOS.undent
      #include <stdlib.h>
      #include <stdio.h>
      #include <omp.h>

      int main() {
          #pragma omp parallel num_threads(4)
          {
            printf("Hello from thread %d, nthreads %d\\n", omp_get_thread_num(), omp_get_num_threads());
          }
          return EXIT_SUCCESS;
      }
    EOS

    system "#{bin}/clang", "-L#{lib}", "-fopenmp", "-nobuiltininc",
                           "-I#{lib}/clang/#{version}/include",
                           "omptest.c", "-o", "omptest", *ENV["LDFLAGS"].split
    testresult = shell_output("./omptest")

    sorted_testresult = testresult.split("\n").sort.join("\n")
    expected_result = <<-EOS.undent
      Hello from thread 0, nthreads 4
      Hello from thread 1, nthreads 4
      Hello from thread 2, nthreads 4
      Hello from thread 3, nthreads 4
    EOS
    assert_equal expected_result.strip, sorted_testresult.strip

    (testpath/"test.c").write <<-EOS.undent
      #include <stdio.h>

      int main()
      {
        printf("Hello World!\\n");
        return 0;
      }
    EOS

    (testpath/"test.cpp").write <<-EOS.undent
      #include <iostream>

      int main()
      {
        std::cout << "Hello World!" << std::endl;
        return 0;
      }
    EOS

    # Testing Command Line Tools
    if OS.mac? && MacOS::CLT.installed?
      libclangclt = Dir["/Library/Developer/CommandLineTools/usr/lib/clang/#{MacOS::CLT.version.to_i}*"].last { |f| File.directory? f }

      system "#{bin}/clang++", "-v", "-nostdinc",
              "-I/Library/Developer/CommandLineTools/usr/include/c++/v1",
              "-I#{libclangclt}/include",
              "-I/usr/include", # need it because /Library/.../usr/include/c++/v1/iosfwd refers to <wchar.h>, which CLT installs to /usr/include
              "test.cpp", "-o", "testCLT++"
      assert_includes MachO::Tools.dylibs("testCLT++"), "/usr/lib/libc++.1.dylib"
      assert_equal "Hello World!", shell_output("./testCLT++").chomp

      system "#{bin}/clang", "-v", "-nostdinc",
              "-I/usr/include", # this is where CLT installs stdio.h
              "test.c", "-o", "testCLT"
      assert_equal "Hello World!", shell_output("./testCLT").chomp
    end

    # Testing Xcode
    if MacOS::Xcode.installed?
      libclangxc = Dir["#{MacOS::Xcode.toolchain_path}/usr/lib/clang/#{DevelopmentTools.clang_version}*"].last { |f| File.directory? f }

      system "#{bin}/clang++", "-v", "-nostdinc",
              "-I#{MacOS::Xcode.toolchain_path}/usr/include/c++/v1",
              "-I#{libclangxc}/include",
              "-I#{MacOS.sdk_path}/usr/include",
              "test.cpp", "-o", "testXC++"
      assert_includes MachO::Tools.dylibs("testXC++"), "/usr/lib/libc++.1.dylib"
      assert_equal "Hello World!", shell_output("./testXC++").chomp

      system "#{bin}/clang", "-v", "-nostdinc",
              "-I#{MacOS.sdk_path}/usr/include",
              "test.c", "-o", "testXC"
      assert_equal "Hello World!", shell_output("./testXC").chomp
    end

    # link against installed libc++
    # related to https://github.com/Homebrew/legacy-homebrew/issues/47149
    if build_libcxx?
      system "#{bin}/clang++", "-v", "-nostdinc",
              "-std=c++11", "-stdlib=libc++",
              "-I#{MacOS::Xcode.toolchain_path}/usr/include/c++/v1",
              "-I#{libclangxc}/include",
              "-I#{MacOS.sdk_path}/usr/include",
              "-L#{lib}",
              "-Wl,-rpath,#{lib}", "test.cpp", "-o", "test"
      assert_includes MachO::Tools.dylibs("test"), "#{opt_lib}/libc++.1.dylib"
      assert_equal "Hello World!", shell_output("./test").chomp
    end
  end
end
