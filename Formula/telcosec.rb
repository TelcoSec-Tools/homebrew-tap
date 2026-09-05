# typed: false
# frozen_string_literal: true

class Telcosec < Formula
  desc "Unified CLI for Telecom Security, SDR Diagnostics, and 5G SA Operations"
  homepage "https://chisel.telcosec.net"
  url "https://github.com/TelcoSec-Tools/telcosec-cli/archive/refs/tags/v3.0.1.tar.gz"
  sha256 "ac35e46ca3a1c31f53b111f73e47db85ba3fdeec90daafba9b26c75caa9048d6"
  license "Apache-2.0"
  head "https://github.com/TelcoSec-Tools/telcosec-cli.git", branch: "main"

  livecheck do
    url :stable
    strategy :github_latest
  end

  depends_on "go" => :build

  def install
    commit = build.head? ? Utils.git_short_head : "homebrew"
    build_date = time.iso8601
    ldflags = %W[
      -s -w
      -X main.Version=#{version}
      -X main.GitCommit=#{commit}
      -X main.BuildDate=#{build_date}
    ]

    system "go", "build", *std_go_args(ldflags: ldflags, output: bin/"telcosec"), "./cmd/telcosec"

    # Install symlink alias telcochisel -> telcosec
    bin.install_symlink "telcosec" => "telcochisel"

    # Install shell completions
    bash_completion.install "completions/telcosec.bash" => "telcosec"
    zsh_completion.install "completions/_telcosec" => "_telcosec"
    fish_completion.install "completions/telcosec.fish" => "telcosec.fish"

    # Install Section 1 UNIX manual pages
    man1.install "docs/man/telcosec.1"
    man1.install_symlink "telcosec.1" => "telcochisel.1"
  end

  test do
    assert_match "TelcoSec Unified Operator CLI", shell_output("#{bin}/telcosec version")
    assert_match "Usage:", shell_output("#{bin}/telcosec help")
  end
end
