class Toavif < Formula
  desc "Multi-threaded CLI for batch conversion of JPG/PNG images to AVIF"
  homepage "https://github.com/mnich/toavif"
  url "https://github.com/mnich/toavif/archive/refs/tags/v1.1.0.tar.gz"
  sha256 "497896dedbcee7a25bdce76e90d6fc1e0bcb0d762cef8f9b9ab099da9f72798e"
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
