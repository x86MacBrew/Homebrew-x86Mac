class Oniguruma < Formula
  desc "Regular expressions library"
  homepage "https://github.com/kkos/oniguruma/"
  url "https://github.com/kkos/oniguruma/releases/download/v6.9.10/onig-6.9.10.tar.gz"
  sha256 "2a5cfc5ae259e4e97f86b68dfffc152cdaffe94e2060b770cb827238d769fc05"
  license "BSD-2-Clause"

  livecheck do
    skip "No longer developed or maintained"
  end

  # The stable release includes a generated configure script. Building it
  # directly avoids an Autotools bootstrap dependency on the first x86MacBrew
  # source-build target.
  def install
    system "./configure", "--disable-dependency-tracking", "--prefix=#{prefix}"
    system "make"
    system "make", "install"
  end

  test do
    assert_match prefix.to_s, shell_output("#{bin}/onig-config --prefix")
  end
end
