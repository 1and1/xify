Gem::Specification.new do |s|
  s.name        = 'xify'
  s.version     = '0.2.0'
  s.date        = '2018-05-11'
  s.summary     = 'Cross-post content from one service to another.'
  s.description = 'Cross-post content from one service to another.'
  s.author      = 'Finn Glöe'
  s.email       = 'fgloee@united-internet.de'
  s.files       = Dir['lib/**/*.rb']
  s.executables << 'xify'

  s.add_runtime_dependency 'metybur'
end
