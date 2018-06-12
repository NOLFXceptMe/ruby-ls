#!/usr/bin/env ruby
#
# ls [-a] [file...]

options = ARGV.select {|arg| arg.start_with?('-')}
files = ARGV.select {|arg| !arg.start_with?('-')}

def filter_folder(file, opts)
  if !File.exist? file
    STDERR.puts "cannot access '#{file}': No such file or directory"
    # /bin/ls returns 2 on exit
    exit 2
  end

  if File.directory? file
    Dir.entries(file)
        .select {|filename| !filename.start_with?(".") || opts.include?('-a')}
  else
    [file]
  end
end

(files.empty? ? ["."] : files)
    .flat_map {|file| filter_folder(file, options)}
    .each {|filename| puts filename}
