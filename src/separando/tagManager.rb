require 'tag' 

class TagManager
  attr_reader :tags

  def initialize
    tag1 = Tag.new "tag1", 1
    tag2 = Tag.new "tag2", 2
    tag3 = Tag.new "tag3", 3
    tag4 = Tag.new "tag4", 4
    @tags = {tag1, tag2, tag3, tag4}
    @curr_id = 5
  end

end
