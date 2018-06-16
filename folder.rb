#!/usr/bin/env ruby

class Folder
  attr_reader :name
  attr_reader :contents

  def initialize(name, contents)
    @name = name
    @contents = contents
  end
end
