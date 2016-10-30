require "thor"

def recursive_each arr = ["."], path = "", &blck
	arr.each do |b|
		e = path + b 
		if File.directory? e
			recursive_each(Dir.entries(e).select{ |d| d !~ /\A\./ }, "#{e}/", &blck)
		elsif File.file? e
			blck.call e
		end
	end
end

class Tmplt < Thor
	desc "gemspec", "create a default gemspec file"
	option :'no-description', aliases: "-d", type: :boolean, default: false
	option :name, default: File.basename(Dir.getwd)
	option :licence, default: "MIT"
	def gemspec()
		name = options['name'] 
		gname = "#{name}.gemspec"
		raise "File already exists" if FileTest::exist? gname
		desc, summ = nil
		unless options[:'no-description']
			print "Summary: "
			summ = $stdin.gets.strip
			puts "Description (type EOS on a new line to complete the input):"
			desc = []
			while (i = $stdin.gets).strip != "EOS"
				desc << i.strip
			end
			desc = desc.length > 0 ? desc.join("\n") : summ
		end

		files = []
		recursive_each ["lib"] do |f|
			files << f unless f =~ /\A\./
		end

		bins = Dir.entries("bin").select { |d| d !~ /\A\./ } if FileTest::exist? "bin"

		File.open(gname, "w") do |f|
			f << <<~EOS
	Gem::Specification.new do |s|
		s.name        = '#{name}'
		s.version     = '0.0.0'
		s.date        = '#{Time.now.to_s.scan(/\A\S*/)[0]}'
		s.summary     = "#{summ}"
		s.description = "#{desc}"
		s.authors     = ["Sylvain Leclercq"]
		s.email       = 'maisbiensurqueoui@gmail.com'
		s.files       = #{files.inspect}
		s.executables.concat #{bins.inspect}
		s.homepage    =
			'http://www.github.com/de-passage/#{name}'
		s.license       = '#{options[:licence]}'
	end
			EOS
		end
	end
end
