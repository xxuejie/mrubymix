Gem::Specification.new do |s|
  s.name        = 'mrubymix'
  s.version     = '0.0.1'
  s.summary     = 'mruby source code preprocessor'
  s.description = 'mrubymix preprocesses mruby source code using Rails asset pipeline-like syntax'
  s.author      = 'Xuejie Xiao'
  s.email       = 'xxuejie@gmail.com'
  s.files       = ['bin/mrubymix', 'lib/mrubymix.rb']
  s.bindir      = 'bin'
  s.executables << 'mrubymix'
  s.homepage    = 'https://github.com/xxuejie/mrubymix'
  s.license     = 'MIT'
end
