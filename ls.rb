#!/usr/bin/env ruby
#
# ls [-Aal] [file...]

require 'etc'
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
        .map {|name, contents| format_folder(name, contents)}
        .join("\n\n")
  end

  private

  # Member functions
  def long_list?
    @opts.include?("l") || @opts.include?("g") || @opts.include?("o")
  end

  def show_group?
    @opts.include?("l") || @opts.include?('g')
  end

  def show_user?
    @opts.include?("l") || @opts.include?('o')
  end

  def show_hidden?
    @opts.include?("a") || show_almost_all?
  end

  # not exactly POSIX here
  def show_almost_all?
    @opts.include?("A")
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
      [
        file,
        Dir.entries(file)
          .select {|filename| !filename.start_with?(".") || show_hidden? }
          .select {|filename| !(filename.eql?(".") || filename.eql?("..")) || !show_almost_all? }
          .map {|filename| File.join(file, filename)}
      ]
    else
      [file, []]
    end
  end

  def format_folder(name, contents)
    join_str = long_list? ? "\n" : ""

    "%s%s" % [
      multi_folder? ? "%s:\n" %name : '',

      contents
        .sort
        .map {|file| format_file(file)}
        .join(join_str)
    ]
  end

  def format_file(file)
    if long_list?
      long_list file, show_user?, show_group?
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
