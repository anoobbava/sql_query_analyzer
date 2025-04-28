# sql_query_analyzer.gemspec
Gem::Specification.new do |spec|
  spec.name          = "sql_query_analyzer"
  spec.version       = SqlQueryAnalyzer::VERSION
  spec.authors       = ["Anoob Bava"]
  spec.email         = ["anoob.bava@gmail.com"]

  spec.summary       = "Explain ActiveRecord queries and get optimization suggestions."
  spec.description   = "A Ruby on Rails gem that analyzes SQL queries and suggests optimizations like missing indexes, inefficient sorts, and risky joins."
  spec.homepage      = "https://github.com/anoobbava/sql_query_analyzer"
  spec.license       = "MIT"

  spec.files         = Dir["lib/**/*.rb"]
  spec.require_paths = ["lib"]

  spec.add_dependency "activerecord"
  spec.add_dependency "activesupport"

  spec.add_development_dependency "rspec"
end
