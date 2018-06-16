#!/usr/bin/env ruby

S_IFIFO=0x1000
S_IFCHR=0x2000
S_IFDIR=0x4000
S_IFBLK=0x6000
S_IFREG=0x8000
S_IFLNK=0xa000

FIFO  = -> (mode) { mode & S_IFIFO  != 0}
CHR   = -> (mode) { mode & S_IFCHR  != 0}
DIR   = -> (mode) { mode & S_IFDIR  != 0}
BLK   = -> (mode) { mode & S_IFBLK  != 0}
REG   = -> (mode) { mode & S_IFREG  != 0}
LNK   = -> (mode) { mode & S_IFLNK  != 0}

def get_entry_type(mode)
  case mode
  when FIFO
    "p"
  when CHR
    "c"
  when DIR
    "d"
  when BLK
    "b"
  when REG
    "-"
  when LNK
    "l"
  else
    "\0"
  end
end

def format_perms(perm)
  "%c%c%c" % [
    (perm & 0x4) == 0 ? '-' : 'r',
    (perm & 0x2) == 0 ? '-' : 'w',
    (perm & 0x1) == 0 ? '-' : 'x'
  ]
end

def get_user_perms(mode)
  format_perms((mode & 0700) >> 6)
end

def get_group_perms(mode)
  format_perms((mode & 0070) >> 3)
end

def get_other_perms(mode)
  format_perms(mode & 0007)
end

def format_mode(mode)
  "%c\%s%s%s%c" % [
    get_entry_type(mode),
    get_user_perms(mode),
    get_group_perms(mode),
    get_other_perms(mode),
    "\0"
  ]
end

