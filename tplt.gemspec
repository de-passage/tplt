Gem::Specification.new do |s|
	s.name        = 'tplt'
	s.version     = '0.0.4'
	s.date        = '2016-10-30'
	s.summary     = "Template-based file generator"
	s.description = "Generate boilerplate code from templates. In development"
	s.authors     = ["Sylvain Leclercq"]
	s.email       = 'maisbiensurqueoui@gmail.com'
	s.files       = ["lib/tplt.rb", Dir.glob(File.join("templates", "*"))].flatten
	s.executables.concat ["tplt"]
	s.homepage    =
		'http://www.github.com/de-passage/tplt'
	s.license       = 'MIT'
end
