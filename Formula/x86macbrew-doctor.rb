class X86macbrewDoctor < Formula
  desc "Diagnose whether an Intel Mac meets x86MacBrew's support contract"
  homepage "https://github.com/x86MacBrew/homebrew-x86mac"
  url "https://github.com/x86MacBrew/Homebrew-x86Mac/releases/download/v0.1.0/x86macbrew-doctor-0.1.0.tar.gz"
  version "0.1.0"
  sha256 "86fd451c72ff4691eceb0c683fcb6aa39dedc9b5107820c03ddd8150591515fb"
  license "BSD-2-Clause"

  def install
    bin.install "bin/x86macbrew-doctor"
    (share/"x86macbrew").install "config/support.yml"
  end

  test do
    assert_match "usage: x86macbrew-doctor", shell_output("#{bin}/x86macbrew-doctor --help 2>&1", 0)
  end
end
