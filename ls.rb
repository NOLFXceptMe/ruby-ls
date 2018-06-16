#!/usr/bin/env ruby
#
# ls [-a] [file...]

require 'etc'

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
        .map {|filename| File.join(file, filename)}
  else
    [file]
  end
end

def format_mode(mode)
  mode
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

  "%s %s %s %s %d %s %s\n" %
    [format_mode(stat.mode),
     stat.nlink,
     get_user(stat.uid),
     get_group(stat.gid),
     stat.size,
     format_mtime(stat.mtime),
     File.basename(file)]
end

def format_file(file, opts)
  if opts.include?('-l')
    long_list(file)
  else
    file
  end
end

(files.empty? ? ["."] : files)
    .flat_map {|file| filter_folder(file, options)}
    .map {|file| format_file(file, options)}
    .each {|filename| puts filename}
