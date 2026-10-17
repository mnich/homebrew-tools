class Towebp < Formula
  desc "Multi-threaded CLI for batch conversion of JPG/PNG images to WebP"
  homepage "https://github.com/mnich/towebp"
  url "https://github.com/mnich/towebp/archive/refs/tags/v1.1.0.tar.gz"
  sha256 "40f5c7432f4ee72feecdc473ebb115a29d0927a6f9626b701aa45b1b2d2ffce2"
  license "MIT"

  # Official webp package, provides cwebp
  depends_on "webp"

  def install
    bin.install "towebp"
  end

  test do
    assert_match version.to_s, shell_output("#{bin}/towebp --version")
    system bin/"towebp", "--help"
  end
end
