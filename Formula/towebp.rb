class Towebp < Formula
  desc "Multi-threaded CLI for batch conversion of JPG/PNG images to WebP"
  homepage "https://github.com/mnich/towebp"
  url "https://github.com/mnich/towebp/archive/refs/tags/v1.0.0.tar.gz"
  sha256 "84104a6e38661f4dcd42079ac95c7680e4e61e9d64730fb00234f7a838195ecd"
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
