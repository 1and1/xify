require 'date'

Gem::Specification.new do |s|
  s.name        = 'xify'
  s.version     = '0.5.0'
  s.date        = Date.today.to_s
  s.summary     = 'Cross-post content from one service to another.'
  s.description = 'Cross-post content from one service to another.'
  s.license     = 'MIT'
  s.author      = 'Finn Glöe'
  s.email       = 'fgloee@united-internet.de'
  s.files       = Dir['lib/**/*.rb']
  s.executables << 'xify'

  s.add_runtime_dependency 'activesupport', '~> 5.2'
  s.add_runtime_dependency 'rufus-scheduler', '~> 3.4'
end
