#!/usr/bin/env ruby

LS_BLK_SZ = 512     #512 kB

def get_user(uid)
  Etc.getpwuid(uid).name
end

def get_group(gid)
  Etc.getgrgid(gid).name
end

def get_blocks(stat)
  stat.blocks * (stat.blksize / LS_BLK_SZ)
end

def format_mtime(mtime)
  if(mtime > (Time.now - 6 * 30 * 24 * 60 * 60))
    mtime.strftime "%b %e %H:%M"
  else
    mtime.strftime "%b %e %Y"
  end
end

def long_list(file, stat, show_user = false, show_group = false)

  format = "%s %s %s %s %d %s %s"

  format %
    [format_mode(stat.mode),
     stat.nlink,
     show_user ? get_user(stat.uid) : "\0",
     show_group ? get_group(stat.gid) : "\0",
     stat.size,
     format_mtime(stat.mtime),
     File.basename(file)]
end
