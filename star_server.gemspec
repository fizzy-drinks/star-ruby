# frozen_string_literal: true

Gem::Specification.new do |spec|
  spec.name = "star_server"
  spec.version = "0.1.0"
  spec.authors = ["chikorito"]
  spec.email = ["me@chikorito.land"]

  spec.summary = "Simple structured model-view DSL for HTTP servers and command line apps."
  # spec.description = "TODO: Write a longer description or delete this line."
  spec.homepage = "https://github.com/fizzy-drinks/star_server"
  spec.license = "MIT"
  spec.required_ruby_version = ">= 3.0.0"

  # spec.metadata["allowed_push_host"] = "TODO: Set to your gem server 'https://example.com'"

  spec.metadata["homepage_uri"] = spec.homepage
  spec.metadata["source_code_uri"] = spec.homepage
  # spec.metadata["changelog_uri"] = "TODO: Put your gem's CHANGELOG.md URL here."

  # Specify which files should be added to the gem when it is released.
  # The `git ls-files -z` loads the files in the RubyGem that have been added into git.
  spec.files = Dir.glob("{bin,lib}/**/*")
  spec.bindir = "bin"
  spec.executables = spec.files.grep(%r{\Abin/}) { |f| File.basename(f) }
  spec.require_paths = [File.absolute_path("lib", __dir__), File.absolute_path("lib/database_adapter", __dir__)]

  # Uncomment to register a new dependency of your gem
  # spec.add_dependency "example-gem", "~> 1.0"

  # For more information and examples about making a new gem, check out our
  # guide at: https://bundler.io/guides/creating_gem.html
end
