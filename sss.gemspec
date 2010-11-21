Gem::Specification.new do |s|
  s.name = 'sss'
  s.version = "0.0.1"
  s.summary = %{Simple CLI interface for copying files to S3.}
  s.date = "2010-11-21"
  s.author = "Cyril David"
  s.email = "cyx@pipetodevnull.com"
  s.homepage = "http://github.com/cyx/sss"

  s.specification_version = 2 if s.respond_to? :specification_version=

  s.files = ["lib/sss.rb", "README", "test/sss_test.rb"]

  s.require_paths = ['lib']

  s.add_dependency "clap"
  s.add_dependency "aws-s3"
  s.add_development_dependency "cutest"
  s.has_rdoc = false
  s.executables.push "sss"
end

