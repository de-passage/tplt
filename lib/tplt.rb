require "thor"
require "erb"


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

module Config
	def self.load cfg
		unless(File.exist? cfg)
			puts "warning: no configuration file found" 
			return Hash.new { "Not configured" }
		end
		File.open(cfg) do |f| 
			f.map do |l| 
				m = l.match(/\s*(\w+):\s*(.+)/)
				m ? [m[1].to_sym, m[2]] : m
			end.compact.to_h.tap { |h| h.default = "Not configured" }
		end
	end
end

class Tmplt < Thor

	TEMPLATE_FOLDER = File.join(Gem.loaded_specs["tplt"].full_gem_path, "templates")
	CONFIG_FILE = File.join(Dir.home, ".tplt_rc") 
	
	CONFIG = Config.load(CONFIG_FILE)

	desc "gemspec", "create a default gemspec file"
	option :'no-description', aliases: "-d", type: :boolean, default: false
	option :name, default: File.basename(Dir.getwd)
	option :licence, default: "MIT"
	def gemspec()
		template_path = File.join(TEMPLATE_FOLDER, "gemspec.rb.erb")
		template = File.open(template_path) do |f| f.read end
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

		bins = Dir.entries("bin").select { |d| d !~ /\A\./ }.map{|e| "'bin/#{e}'"}.join(", ")  if FileTest::exist? "bin"

		context = Struct.new(:name, :version, :files, :summ, :desc, :options, :bins, :author, :email).new(name, "0.0.0", files, summ, desc, options, bins, CONFIG[:author], CONFIG[:email])
		context = context.instance_eval do binding end

		File.open(gname, "w") do |f|
			f << ERB.new(template).result(context)
		end

	end
end
