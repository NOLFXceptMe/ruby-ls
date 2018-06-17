#!/usr/bin/env ruby

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
