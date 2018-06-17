#!/usr/bin/env ruby
#
# ls [-al] [file...]

require 'etc'
require "./folder"
require './mode'

def filter_folder(file, opts)
  if !File.exist? file
    STDERR.puts "cannot access '#{file}': No such file or directory"
    # /bin/ls returns 2 on exit
    exit 2
  end

  if File.directory? file
    Folder.new(
      file,
      Dir.entries(file)
        .select {|filename| !filename.start_with?(".") || opts.include?('a')}
        .map {|filename| File.join(file, filename)})
  else
    Folder.new(file, [])
  end
end

def get_user(uid)
  Etc.getpwuid(uid).name
end

def get_group(gid)
  Etc.getgrgid(gid).name
end

def format_mtime(mtime)
  if(mtime > (Time.now - 6 * 30 * 24 * 60 * 60))
    mtime.strftime "%b %e %H:%M"
  else
    mtime.strftime "%b %e %Y"
  end
end

def long_list(file)
  stat = File.stat(file)

  "%s %s %s %s %d %s %s" %
    [format_mode(stat.mode),
     stat.nlink,
     get_user(stat.uid),
     get_group(stat.gid),
     stat.size,
     format_mtime(stat.mtime),
     File.basename(file)]
end

def format_file(file, opts)
  if opts.include?('l')
    long_list file
  else
    "%s\t" %  File.basename(file)
  end
end

def format_folder(folder, opts, showfolder)
  join_str = opts.include?('l') ? "\n" : ""

  "%s%s" % [
    showfolder ? "%s:\n" %folder.name : '',

    folder.contents
      .sort
      .map {|file| format_file(file, opts)}
      .join(join_str)
  ]
end

def get_options(argv)
  argv.select {|arg| arg.start_with?('-')}
      .flat_map {|arg| arg[1..-1].chars}
end

def get_folders(argv)
  argv.select {|arg| !arg.start_with?('-')}
end

options = get_options(ARGV)
folders = get_folders(ARGV)

puts "%s" %
  (folders.empty? ? ["."] : folders)
    .sort
    .map {|folder| filter_folder(folder, options)}
    .map {|folder| format_folder(folder, options, folders.size > 1)}
    .join("\n\n")
