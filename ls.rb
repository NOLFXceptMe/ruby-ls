#!/usr/bin/env ruby
#
# ls [-a] [file...]

options = ARGV.select {|arg| arg.start_with?('-')}
files = ARGV.select {|arg| !arg.start_with?('-')}

def filter_folder(file, opts)
  if File.directory? file
    Dir.entries(file)
        .select {|filename| !filename.start_with?(".") || opts.include?('-a')}
  else
    [file]
  end
end

files
    .flat_map {|file| filter_folder(file, options)}
    .each {|filename| puts filename}
