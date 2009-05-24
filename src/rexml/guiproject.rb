

#!/usr/bin/env ruby
#
# This file is gererated by ruby-glade-create-template 1.1.4.
#
require 'libglade2'
require 'rexml/document'
include REXML

class LibGlade
  include GetText

  attr :glade
  
  def initialize(path_or_data, root = nil, domain = nil, localedir = nil, flag = GladeXML::FILE)
    @doc = nil
    bindtextdomain(domain, localedir, nil, "UTF-8")
    @glade = GladeXML.new(path_or_data, root, domain, localedir, flag) {|handler| method(handler)}
    @treeview = @glade.get_widget('treeview')
    init_tree
    init_tree_signals
  end
  
  def init_tree
    #Removes all the columns from the tree view.
    @treeview.columns.each {|col| @treeview.remove_column(col)}
    
    unless @doc == nil
      root = @doc.root
      @treestore = Gtk::TreeStore.new(String, String)
      parent = @treestore.append(nil)
      parent[0] = root.name
      parent[1] = nil

      root.elements.each do |element|
        iter = @treestore.append(parent)
        iter[0] = element.name
        iter[1] = nil
        
        if element.name == 'PrinceText' && element.has_attributes?
          iter2 = @treestore.append(iter)
              iter2[0] = element.attributes['name']
              iter2[1] = element.attributes['path']
        else
          element.elements.each do |element2|
            iter2 = @treestore.append(iter)
              iter2[0] = element2.attributes['name']
              iter2[1] = element2.attributes['path']
          end
        end
      end
    end
    
    @treeview.model = @treestore
    renderer = Gtk::CellRendererText.new
    col = Gtk::TreeViewColumn.new("Project", renderer, :text => 0)
    @treeview.append_column(col)
  end
  
  # Initializes the signals for the treeview.
  def init_tree_signals
    # Creates the right click menu for the treeview
    menu = Gtk::Menu.new
    open = Gtk::MenuItem.new("Open")
      
    # Connects the menu items signals.
    open.signal_connect("activate") do 
      if iter = @treeview.selection.selected
      end
    end
    
    delete = Gtk::MenuItem.new("Delete")
    delete.signal_connect("activate") do 
      if iter = @treeview.selection.selected
        delete = Gtk::MessageDialog.new(@glade.get_widget("window1"), Gtk::Dialog::DESTROY_WITH_PARENT,
                                        Gtk::MessageDialog::QUESTION, Gtk::MessageDialog::BUTTONS_YES_NO, 'Are you sure?')
        delete.run do |response|
          if response == Gtk::Dialog::RESPONSE_YES
            if iter.parent[0] == 'Texts'
              delete_text iter[1] if iter[1]
            elsif iter.parent[0] == 'PrinceText'
              delete_prince
            end
            @treestore.remove(iter)
          end
            delete.destroy
        end
      end
    end
      
    menu.append(open)
    menu.append(delete)

    menu.show_all

    # Popup the menu on right click
    @treeview.signal_connect("button_press_event") do |widget, event|
      if event.kind_of? Gdk::EventButton and event.button == 3
          menu.popup(nil, nil, event.button, event.time)
      end
    end
  end
  
  # Saves the proyect in a .cproj file.
  def save
    file = File.new("#{@doc.root.attributes["path"]}","w")
    @doc.write(file, 3, false)
    file.close
  end
  
  # Creates a default file chooser dialog.
  def create_chooser
    chooser = Gtk::FileChooserDialog.new("Open file", @glade.get_widget("window1"),
                                          Gtk::FileChooser::ACTION_OPEN,
                                          nil,
                                          [Gtk::Stock::CANCEL, Gtk::Dialog::RESPONSE_CANCEL],
                                          [Gtk::Stock::OPEN, Gtk::Dialog::RESPONSE_ACCEPT])
  end
  
  # Opens a file chooser dialog, from where the user select the desired file.
  # Then it adds the prince to the project.
  def addText_press_event(widget, arg0)
    unless @doc == nil
      chooser = create_chooser

      chooser.run do |response|
        if response == Gtk::Dialog::RESPONSE_ACCEPT
          add_text chooser.filename
          chooser.destroy
        elsif response == Gtk::Dialog::RESPONSE_CANCEL
          chooser.destroy
        else
          chooser.destroy
        end
      end
    else
      show_error 'You must open a project first!'
    end
  end
  
  def open_press_event(widget, arg0)
    chooser = create_chooser
    chooser.run do |response|
      if response == Gtk::Dialog::RESPONSE_ACCEPT
        open chooser.filename
        init_tree
        chooser.destroy
      elsif response == Gtk::Dialog::RESPONSE_CANCEL
        chooser.destroy
      else
        chooser.destroy
      end
    end
  end
  
  def delete_press_event(widget, arg0)
    unless @doc == nil
      delete = Gtk::MessageDialog.new(@glade.get_widget("window1"), Gtk::Dialog::DESTROY_WITH_PARENT,
                                     Gtk::MessageDialog::QUESTION, Gtk::MessageDialog::BUTTONS_YES_NO, 'Are you sure?')
      delete.run do |response|
        if response == Gtk::Dialog::RESPONSE_YES
          deleteproject
          delete.destroy
        elsif response == Gtk::Dialog::RESPONSE_NO
          delete.destroy
        else
          delete.destroy
        end
      end
    else
      show_error 'No project is currently open'
    end
  end
  
  # Opens an input dialog box to enter the project name, if the user press ok,
  # the createproject function is called, otherwise the dialog is destroyed.
  def on_create_event(widget, arg0)
    dialog = Gtk::Dialog.new("Enter project name", @glade.get_widget("window1"),
                              Gtk::Dialog::DESTROY_WITH_PARENT,
                              [Gtk::Stock::OK, Gtk::Dialog::RESPONSE_ACCEPT],
                              [Gtk::Stock::CANCEL, Gtk::Dialog::RESPONSE_CANCEL])
    dialog.set_default_size(260,50)
    # Add the text entry to the box
    entry = Gtk::Entry.new
    entry.show
    dialog.vbox.add(entry)
    dialog.run do |response|
      if response == Gtk::Dialog::RESPONSE_ACCEPT && entry.text != ''
        create_project entry.text
        dialog.destroy
      elsif response == Gtk::Dialog::RESPONSE_CANCEL
        dialog.destroy
      else
        dialog.destroy
      end
    end
  end
  
  def window1_destroy_event(widget, arg0)
    Gtk.main_quit
  end
  
  # Opens a file chooser dialog, from where the user select the desired file.
  # Then it adds the prince to the project.
  def addPrince_press_event(widget, arg0)
    unless @doc == nil
      chooser = create_chooser

      chooser.run do |response|
        if response == Gtk::Dialog::RESPONSE_ACCEPT
          add_prince chooser.filename
          chooser.destroy
        elsif response == Gtk::Dialog::RESPONSE_CANCEL
          chooser.destroy
        else
          chooser.destroy
        end
      end
    else
      show_error 'You must open a project first!'
    end
  end
  
  # Opens the desired proyect
  def open name
    begin
      @doc = Document.new(File.new(name))
      puts "#{File.basename(name)} was open succesfully\n"
    rescue
      show_error "The file doesn't exist"
    end
  end
  
  # Creates an empty project
  def create_project name, path=File.expand_path('')
    @doc = Document.new
    @doc << XMLDecl.new
    @doc.add_element "Project", {"name" => name, "path" => "#{path}/#{name}.cproj"}

    root = @doc.root
    root.add_element "PrinceText"
    root.add_element "Texts"
    #Updates the tree view
    init_tree
    save

    #Puts the project path.
    puts "#{name} created\n"
  end
  
  # Adds the specified prince text to the project 
  def add_prince name
    if File.exist?(name)
      filename = File.basename(name)
      filepath = File.expand_path(name)
      element = @doc.root.elements["PrinceText"]
      if element.has_attributes?
        element.attributes["name"] = filename
        element.attributes["path"] = filepath
      else
        element.add_attribute "name", filename
        element.add_attribute "path", filepath
      end
      
      #updates the treestore
      iter = @treestore.get_iter("0:0")
      
      if (iter2 = iter.first_child)
        iter2[0] = filename
        iter2[1] = filepath
      else
        iter2 = @treestore.append(iter)
        iter2[0] = filename
        iter2[1] = filepath
      end
      
      save
      puts "#{File.expand_path(name)} was added to project"
    else
      puts "The file doesn't exists"
    end
  end
  
  # Adds the specified text to the project
  def add_text name
    if File.exist?(name)
      if (@doc.root.elements["Texts/Text[@name='#{File.basename(name)}']"] == nil)
        filename = File.basename(name)
        filepath = File.expand_path(name)
        element = Element.new "Text"
        element.add_attribute "name", filename
        element.add_attribute "path", filepath

        @doc.root.elements["Texts"].add_element element 
        
        #updates the treestore
        iter = @treestore.get_iter("0:1")
        iter2 = @treestore.append(iter)
        iter2[0] = filename
        iter2[1] = filepath

        save
        puts "#{File.expand_path(name)} was added to project"
      else
        puts "The text is already in the project"
      end
    else
      puts "The file doesn't exists"
    end
  end

  # Erases the project
  def deleteproject
    file = @doc.root.attributes['path']
    if File.exist?(file)
      File.delete(file)
      #erases the document and the treeview data
      @doc = nil
      @treestore.clear
      puts "#{file} has been removed"
    else
      puts "'The file doesn't exist"
    end
  end
  
  # Erases the prince text
  def delete_prince
    element = @doc.root.elements["PrinceText"]
    if element.has_attributes?
      element.delete_attribute "name"
      element.delete_attribute "path" 
      save
      puts "The prince text has been removed"
    else
      puts "The project doesn't have a prince text"
    end
  end
  
  # Deletes the specified text from the project
  def delete_text name
    unless @doc.root.elements["Texts/Text[@name='#{File.basename(name)}']"] == nil
      @doc.root.elements.delete("Texts/Text[@name='#{File.basename(name)}']")
      save
    else
      puts "The text is not in the project"
    end
  end
  
  # Pops up an error message with the specified error message.
  # The default error is Error!
  def show_error error='Error!'
    error = Gtk::MessageDialog.new(@glade.get_widget("window1"), Gtk::Dialog::DESTROY_WITH_PARENT,
                                   Gtk::MessageDialog::ERROR, Gtk::MessageDialog::BUTTONS_CLOSE, error)
    error.run
    error.destroy
  end
  
end

# Main program
if __FILE__ == $0
  # Set values as your own application. 
  PROG_PATH = "lib.glade"
  PROG_NAME = "YOUR_APPLICATION_NAME"
  LibGlade.new(PROG_PATH, nil, PROG_NAME)
  Gtk.main
end
