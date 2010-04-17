Gem::Specification.new do |gem|
  gem.name    = 'guestlist'
  gem.version = '0.0.1'
  gem.date    = Date.today.to_s
  
  gem.summary = "Simple authentication using Github credentials."
  gem.description = "Simple authentication using Github credentials."
  
  gem.authors  = ['Jeff Kreeftmeijer']
  gem.email    = 'jeff@kreeftmeijer.nl'
  gem.homepage = 'http://github.com/jeffkreeftmeijer/guestlist'
                  
  gem.files = Dir['{lib,spec}/**/*', 'README*', 'LICENSE*'] & `git ls-files -z`.split("\0")
  
  gem.add_dependency('httparty', '>= 0.5.2')
  gem.add_development_dependency('rspec', '>= 1.3.0')
end
