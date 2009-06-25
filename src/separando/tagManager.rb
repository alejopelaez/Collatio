require 'gtk2'

class Tag
  attr_reader :s_index, :f_index
  attr_accessor :info
  def initialize s_index, f_index, info
    @s_index = s_index
    @f_index = f_index
    @info = info
  end
end

class TagType
  attr_reader :tags, :tag
  def initialize name, color
    @tag = Gtk::TextTag.new(name)
    @tag.background = color
  end

  def add_tag tag
    tags.insert tag
  end
end

class TagManager
  attr_reader :types

  def initialize
    type1 = TagType.new "tag1", "red"
    type2 = TagType.new "tag2", "green"
    type3 = TagType.new "tag3", "blue"
    type4 = TagType.new "tag4", "yellow"
    @types = [type1, type2, type3, type4]
  end

end
