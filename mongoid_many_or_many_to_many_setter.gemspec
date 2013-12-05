Gem::Specification.new do |s|
  s.name        = 'mongoid_many_or_many_to_many_setter'
  s.version     = '0.0.1'
  s.date        = '2013-12-05'
  s.summary     = File.read("README.markdown").split(/===+/)[1].strip.split("\n")[0]
  s.description = s.summary
  s.authors     = ["David Chen"]
  s.email       = 'mvjome@gmail.com'
  s.homepage    = 'https://github.com/SunshineLibrary/mongoid_many_or_many_to_many_setter/'
  s.license     = 'MIT'

  s.add_dependency "mongoid"
  s.add_dependency "activesupport", "> 3.2"

  s.files = `git ls-files`.split("\n")
end
