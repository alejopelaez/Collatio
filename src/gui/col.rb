#!/usr/bin/env ruby
#
# This file is gererated by ruby-glade-create-template 1.1.4.
#
require 'libglade2'

class CollatioGlade
  include GetText

  attr :glade
  
  # Creates tooltips.
  def create_tooltips
    @tooltip = Gtk::Tooltips.new
    @glade['new_project_btn'].set_tooltip(@tooltip, _('Creates a new collatio project'))
    @glade['open_project_button'].set_tooltip(@tooltip, _('Opens a Collatio project'))
    @glade['save_project_as_btn'].set_tooltip(@tooltip, _('Saves current project with a different name'))
    @glade['add_prince_file'].set_tooltip(@tooltip, _('Adds the Prince File to the project'))
    @glade['add_file_btn'].set_tooltip(@tooltip, _('Adds a comparison file to the project'))
    @glade['remove_file_btn'].set_tooltip(@tooltip, _('Removes files from the project'))
  end
  def initialize(path_or_data, root = nil, domain = nil, localedir = nil, flag = GladeXML::FILE)
    bindtextdomain(domain, localedir, nil, "UTF-8")
    @glade = GladeXML.new(path_or_data, root, domain, localedir, flag) {|handler| method(handler)}
    
    create_tooltips
  end
  
  def save_project_as(widget)
    puts "save_project_as() is not implemented yet."
  end
  def add_file(widget)
    puts "add_file() is not implemented yet."
  end
  def open_project(widget)
    puts "open_project() is not implemented yet."
  end
  def new_project(widget)
    puts "new_project() is not implemented yet."
  end
  def on_delete_project(widget)
    puts "on_delete_project() is not implemented yet."
  end
  def save_project(widget)
    puts "save_project() is not implemented yet."
  end
  def remove_file(widget)
    puts "remove_file() is not implemented yet."
  end
  def about(widget)
    puts "about() is not implemented yet."
  end
  def quit(widget)
    Gtk.main_quit
  end
  def add_prince_file(widget)
    puts "add_prince_file() is not implemented yet."
  end
end

# Main program
if __FILE__ == $0
  # Set values as your own application. 
  PROG_PATH = "collatio.glade"
  PROG_NAME = "YOUR_APPLICATION_NAME"
  CollatioGlade.new(PROG_PATH, nil, PROG_NAME)
  Gtk.main
end
