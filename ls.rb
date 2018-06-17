#!/usr/bin/env ruby
#
# ls [-al] [file...]

require 'etc'
require "./folder"
require './mode'
require './util'

class Ls

  # Constructor
  def initialize(opts, files)
    @opts = opts
    @files = files
  end

  # ToString
  @override
  def to_s
      (@files.empty? ? ["."] : @files)
        .sort
        .map {|folder| filter_folder(folder)}
        .map {|folder| format_folder(folder, multi_folder?)}
        .join("\n\n")
  end

  private

  # Member functions
  def long_list?
    @opts.include?("l")
  end

  def show_hidden?
    @opts.include?("a")
  end

  def multi_folder?
    @files.size > 1
  end

  # Other functions
  def filter_folder(file)
    if !File.exist? file
      STDERR.puts "cannot access '#{file}': No such file or directory"
      # /bin/ls returns 2 on exit
      exit 2
    end

    if File.directory? file
      Folder.new(
        file,
        Dir.entries(file)
          .select {|filename| !filename.start_with?(".") || show_hidden? }
          .map {|filename| File.join(file, filename)})
    else
      Folder.new(file, [])
    end
  end

  def format_folder(folder, showfolder)
    join_str = long_list? ? "\n" : ""

    "%s%s" % [
      showfolder ? "%s:\n" %folder.name : '',

      folder.contents
        .sort
        .map {|file| format_file(file)}
        .join(join_str)
    ]
  end

  def format_file(file)
    if long_list?
      long_list file
    else
      "%s\t" %  File.basename(file)
    end
  end

end

def get_options(argv)
  argv.select {|arg| arg.start_with?('-')}
      .flat_map {|arg| arg[1..-1].chars}
end

def get_folders(argv)
  argv.select {|arg| !arg.start_with?('-')}
end

puts "%s" % Ls.new(get_options(ARGV), get_folders(ARGV))
