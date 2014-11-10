# Rakefile
require 'tilt'
require 'opal'

desc "Build the Opal runtime and corelib"
task :opaljs do
  opal = Opal::Builder.build('opal')

  File.open("lib/js/opal.js", "w+") do |out|
    out << opal.to_s
  end
end

desc "Build our app to ./lib/js/racer.js"
task :build => :opaljs do
  env = Opal::Environment.new
  env.append_path "src"

  File.open("lib/js/racer.js", "w+") do |out|
    out << env["racer"].to_s
  end
end
