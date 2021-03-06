class Logstash < Formula
  desc "Tool for managing events and logs"
  homepage "https://www.elastic.co/products/logstash"

  stable do
    url "https://download.elastic.co/logstash/logstash/logstash-2.3.2.tar.gz"
    sha256 "b3c9d943fa273c8087386736ef6809df9c5959bab870a6ab4723f58d48dd38c1"
    depends_on :java => "1.7+"
  end

  devel do
    url "https://download.elastic.co/logstash/logstash/logstash-5.0.0-alpha2.tar.gz"
    sha256 "575615d7d0e6b5dbf8805dc0a7420753e093ddd6f14cbe3229f73fb5eae14d80"
    version "5.0.0-alpha2"
    depends_on :java => "1.8"
  end

  head do
    url "https://github.com/elastic/logstash.git"
    depends_on :java => "1.8"
  end

  bottle :unneeded

  def install
    if build.head?
      # Build the package from source
      system "rake", "artifact:tar"
      # Extract the package to the current directory
      mkdir "tar"
      system "tar", "--strip-components=1", "-xf", Dir["build/logstash-*.tar.gz"].first, "-C", "tar"
      cd "tar"
    end

    inreplace %w[bin/logstash], %r{^\. "\$\(cd `dirname \$SOURCEPATH`\/\.\.; pwd\)\/bin\/logstash\.lib\.sh\"}, ". #{libexec}/bin/logstash.lib.sh"
    inreplace %w[bin/logstash-plugin], %r{^\. "\$\(cd `dirname \$0`\/\.\.; pwd\)\/bin\/logstash\.lib\.sh\"}, ". #{libexec}/bin/logstash.lib.sh"
    inreplace %w[bin/logstash.lib.sh], /^LOGSTASH_HOME=.*$/, "LOGSTASH_HOME=#{libexec}"
    libexec.install Dir["*"]
    bin.install_symlink libexec/"bin/logstash"
    bin.install_symlink libexec/"bin/logstash-plugin"
  end

  def caveats; <<-EOS.undent
    Please read the getting started guide located at:
      https://www.elastic.co/guide/en/logstash/current/getting-started-with-logstash.html
    EOS
  end

  test do
    (testpath/"simple.conf").write <<-EOS.undent
      input { stdin { type => stdin } }
      output { stdout { codec => rubydebug } }
    EOS

    output = pipe_output("#{bin}/logstash -f simple.conf", "hello world\n")
    assert_match /hello world/, output
  end
end
