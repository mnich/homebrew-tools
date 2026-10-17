class Toavif < Formula
  desc "Multi-threaded CLI for batch conversion of JPG/PNG images to AVIF"
  homepage "https://github.com/mnich/toavif"
  url "https://github.com/mnich/toavif/archive/refs/tags/v1.0.0.tar.gz"
  sha256 "9393855dd2ae71e9568b9707c62e2f8a677467bc081164a692df770d0605adcb"
  license "MIT"

  # Official libavif package, provides avifenc
  depends_on "libavif"

  def install
    bin.install "toavif"
  end

  test do
    assert_match version.to_s, shell_output("#{bin}/toavif --version")
    system bin/"toavif", "--help"
  end
end
