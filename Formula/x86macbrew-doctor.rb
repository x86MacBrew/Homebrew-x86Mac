class X86macbrewDoctor < Formula
  desc "Diagnose whether an Intel Mac meets x86MacBrew's support contract"
  homepage "https://github.com/x86MacBrew/homebrew-x86mac"
  url "https://github.com/x86MacBrew/Homebrew-x86Mac/releases/download/v0.2.0/x86macbrew-doctor-0.2.0.tar.gz"
  version "0.2.0"
  sha256 "0dec6a5a8b75762ae69b141a85f4df2b829cf9d3f82daca31c800a0bd92ebe3f"
  license "BSD-2-Clause"

  def install
    bin.install "bin/x86macbrew-doctor"
    (share/"x86macbrew").install "config/support.yml"
  end

  test do
    assert_match "usage: x86macbrew-doctor", shell_output("#{bin}/x86macbrew-doctor --help 2>&1", 0)
  end
end
