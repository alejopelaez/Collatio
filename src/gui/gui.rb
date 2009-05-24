
#!/usr/bin/env ruby
#
# This file is gererated by ruby-glade-create-template 1.1.4.
#
require 'libglade2'
require 'rexml/document'
include REXML
include GetText

TITLE = "Colatio Builder"

class CollatioGlade

  attr :glade
  
  # Initializes the interface loading the glade file.
  def initialize(path_or_data, root = nil, domain = nil, localedir = nil, flag = GladeXML::FILE)
    bindtextdomain(domain, localedir, nil, "UTF-8")
    #@glade is the variable that contains all the widgets
    @glade = GladeXML.new(path_or_data, root, domain, localedir, flag) {|handler| method(handler)}
    create_tooltips
    
    #Table that will have the texts with the scroll windows
    @main_table = @glade.get_widget("main_table")
    
    #Tree view that shows the project
    @treeview = @glade.get_widget('treeview')
      
    #File selection diaglog. File name is where the file src will be stored for reading
    @doc = nil  #.cproj file
    
    #Array with the texts.
    @texts = []
    @scrolls = []
    @number_of_texts = 0
    
    #initializes the tree view and it signals
    init_tree
    init_tree_signals
  end
  
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
  
  
  #######################################
  #                                     #
  #  Tree View Control and Management.  #
  #                                     #
  #######################################
  
  
  # Initializes the tree view with the data stored in the .cproj file (@doc).
  def init_tree
    #Removes all the columns from the tree view.
    @treeview.columns.each {|col| @treeview.remove_column(col)}
    
    #Add the data to the @treestore model.
    unless @doc == nil
      root = @doc.root
      @treestore = Gtk::TreeStore.new(String, String)
      parent = @treestore.append(nil)
      parent[0] = root.attributes['name']
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
    
    #Adds the renderer to the tree view.
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
        if iter.parent[0] == 'PrinceText'
          show_prince_file iter[1]
        elsif iter.parent[0] == 'Texts'
          show_file iter[1]
        end
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
              @treestore.remove(iter)
            elsif iter.parent[0] == 'PrinceText'
              delete_prince
              @treestore.remove(iter)
            end
          end
            delete.destroy
        end
      end
    end
      
    menu.append(open)
    menu.append(delete)
    menu.show_all
    
    #Gets the doubleclicks
    @treeview.signal_connect("row-activated") do |view, path, column|
      if iter = view.model.get_iter(path)
        if iter.parent[0] == 'PrinceText'
          show_prince_file iter[1]
        elsif iter.parent[0] == 'Texts'
          show_file iter[1]
        end
      end
    end

    # Popup the menu on right click
    @treeview.signal_connect("button_press_event") do |widget, event|
      if event.kind_of? Gdk::EventButton and event.button == 3
          menu.popup(nil, nil, event.button, event.time)
      end
    end
  end
  
  
  #######################################
  #                                     #
  #    Table Control and Management.    #
  #                                     #
  #######################################
  
  # Builds the table depending on the number of texts to display.
  # Also ataches the texts to the table
  def build_table (number)
      @main_table.each{|child| @main_table.remove(child)}
      if number<=3
          @main_table.n_columns = number
          @main_table.n_rows = 1
          i = 0
          while i<number
            text = @texts[i]
            scrolled = @scrolls[i]
            if text == nil
                scrolled = Gtk::ScrolledWindow.new
                text = Gtk::TextView.new
                text.name = "txtNumber#{i+1}"
                text.editable = false
                scrolled.name = "scrollNumber#{i+1}"
                scrolled.add(text)
                scrolled.show_all
                @texts[i] = text
                @scrolls[i] = scrolled
            end
            @main_table.attach(scrolled,i,i+1,0,1)
            @main_table.show_all
            i+=1
          end
      else
      @main_table.n_rows = 2
      @main_table.n_columns = (number+1)/2
          i = 0
          fil = col = 0
          while i<number
              text = @texts[i]
              scrolled = @scrolls[i]
            if text == nil
                scrolled = Gtk::ScrolledWindow.new
                text = Gtk::TextView.new
                text.name = "txtNumber#{i+1}"
                scrolled.name = "scrollNumber#{i+1}"
                scrolled.add(text)
                scrolled.show_all
                @texts[i] = text
                @scrolls[i] = scrolled
            end
            #Fils the first row. The fil variable acts like a controller. When it changes, the row has changed.
            if (col < @main_table.n_columns && fil == 0)
              @main_table.attach(scrolled,col,col+1,0,1)
              col+=1
              if col==@main_table.n_columns  #All the columns have been filled. We change rows
                fil = 1; col = 0  #Restart the columns index
              end
            else #Second row statrs here
              @main_table.attach(scrolled,col,col+1,1,2)
              col+=1
            end
            @main_table.show_all
            i+=1
          end
        end
  end
  
  
  
  #######################################
  #                                     #
  #        Project Management.          #
  #                                     #
  #######################################
  
  # Event that happens when the user presses the save as button
  # Save project in a different file
  def save_project_as(widget)
      chooser = Gtk::FileChooserDialog.new("Save Project", @glade.get_widget("appWindow"),
                                          Gtk::FileChooser::ACTION_CREATE_FOLDER,
                                          nil,
                                          [Gtk::Stock::CANCEL, Gtk::Dialog::RESPONSE_CANCEL],
                                          [Gtk::Stock::SAVE, Gtk::Dialog::RESPONSE_ACCEPT])
                                        
    chooser.run do |response|
      if response == Gtk::Dialog::RESPONSE_ACCEPT
        filename = chooser.filename
        save
      end
      chooser.destroy
    end
  end
  
  #Saves the project progress to the .cproj file.
  #Method that is called when the save button is pressed
  def save_project
      unless @doc == nil
        file = File.new("#{@doc.root.attributes["name"]}.cproj","w")
        @doc.write(file, 3, false)
        file.close
      else
        show_error("\tThere is no active project.\nCan't save a non-existent project.", "Save Failure")
      end
  end
  
  # Event that happens when the user presses the new project button.
  # Opens a dialog to choose the destination folder.
  def new_project
    chooser = Gtk::FileChooserDialog.new("Open file", @glade.get_widget("appWindow"),
                                          Gtk::FileChooser::ACTION_CREATE_FOLDER,
                                          nil,
                                          [Gtk::Stock::CANCEL, Gtk::Dialog::RESPONSE_CANCEL],
                                          [Gtk::Stock::SAVE, Gtk::Dialog::RESPONSE_ACCEPT])
                                        
    chooser.run do |response|
      if response == Gtk::Dialog::RESPONSE_ACCEPT
        filename = chooser.filename
        create_project File.basename(filename), filename
      end
      chooser.destroy
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
  
  # Saves the proyect in a .cproj file.
  def save
    file = File.new("#{@doc.root.attributes["path"]}","w")
    @doc.write(file, 3, false)
    file.close
  end
  
  # Opens the desired proyect
  def open name
    begin
      @doc = Document.new(File.new(name))
      puts "#{File.basename(name)} was open succesfully\n"
    rescue
      show_error("The file doesn't exist", "File Not Found")
    end
  end
  
  # Event that happens when the user presses the open button.
  def open_project(widget)
    filter = Gtk::FileFilter.new
    filter.name = '.cproj'
    filter.add_pattern('*.cproj')
    chooser = create_chooser filter
    
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
  
  # Event that happens when the user presses the delete project button.
  # Deletes the currently open project.
  def on_delete_project(widget)
    delete = Gtk::MessageDialog.new(@glade.get_widget("appWindow"), Gtk::Dialog::DESTROY_WITH_PARENT,
                                        Gtk::MessageDialog::QUESTION, Gtk::MessageDialog::BUTTONS_YES_NO, 'Do you really want to delete the entire project?')
        delete.run do |response|
          if response == Gtk::Dialog::RESPONSE_YES
            deleteproject
          end
            delete.destroy
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
  
  
  
  
  #######################################
  #                                     #
  #       Prince Text Management.       #
  #                                     #
  #######################################
  
  # Displays the prince text. 
  # Receives the path as a parameter
  def show_prince_file name
    if(text = read_file name)
      prince_text = @texts[0]
      if prince_text == nil
          @number_of_texts += 1
          build_table(@number_of_texts)
          prince_text = @texts[0]
      end
      buffer = prince_text.buffer
      buffer.set_text(text)
      buffer.place_cursor(buffer.start_iter)
      prince_text.has_focus = true
      prince_text.visible = true
    else
      show_error("File Not Found", "File Not Found")
    end
  end
  
  # Opens a file chooser dialog to select the prince file
  # Returns the file path
  def get_prince_file (filter)
      chooser = create_chooser(filter)
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
      return chooser
  end
  
  # Event that happens when the user presses the Add Prince button.
  # Opens a file chooser dialog, from where the user select the desired file.
  # Then it adds the prince to the project.
  def add_prince_file(widget)
      unless @doc == nil
      if @doc.root.elements["PrinceText"].has_attributes?
          delete = Gtk::MessageDialog.new(@glade.get_widget("appWindow"), Gtk::Dialog::DESTROY_WITH_PARENT,
                                        Gtk::MessageDialog::QUESTION, Gtk::MessageDialog::BUTTONS_YES_NO, 'Do you really want to change the prince text?')
        delete.run do |response|
          if response == Gtk::Dialog::RESPONSE_YES
            filter = Gtk::FileFilter.new
            filter.name = '.in .rtf'
            filter.add_pattern('*.in')
            filter.add_pattern('*.rtf')
            get_prince_file filter
          end
            delete.destroy
        end
      else
        get_prince_file
     end
    else
      show_error 'You must create or open a project first!', 'Prince Text Error'
    end
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
  
  # Reads the contents of the specified file, and returns its text
  def read_file name
    return false if name.nil?
    if File.exists?(name)
      File.open(name){|f| f.readlines.join }
    else
      false
    end
  end
  
  # Creates a default file chooser dialog.
  def create_chooser filter=nil
    chooser = Gtk::FileChooserDialog.new("Open file", @glade.get_widget("appWindow"),
                                          Gtk::FileChooser::ACTION_OPEN,
                                          nil,
                                          [Gtk::Stock::CANCEL, Gtk::Dialog::RESPONSE_CANCEL],
                                          [Gtk::Stock::OPEN, Gtk::Dialog::RESPONSE_ACCEPT])
                                        
    if filter 
      chooser.add_filter(filter)  
    end
    chooser
  end
  
  
  # Puts the selected file on the table, and display it.
  # Receives the path as a parameter
  def show_file name
      if(texts = read_file(name))
      i = @texts.size
      if @number_of_texts <6
          @number_of_texts+=1
          build_table(@number_of_texts)
          @main_table.show_all 
      end
      if (i<6)
          text = @texts[i]
          buffer = text.buffer    
      else
          text = @texts[5]
      end      
      buffer.set_text(texts)
      buffer.place_cursor(buffer.start_iter)
      else
        show_error("File Not Found", "File Not Found")
      end
  end
  
  # Pops up an error message with the specified text. 
  # The default message is Error!
  def show_error(error='Error!', title="Error!")
    error = Gtk::MessageDialog.new(@glade.get_widget("appWindow"), Gtk::Dialog::DESTROY_WITH_PARENT,
                                   Gtk::MessageDialog::ERROR, Gtk::MessageDialog::BUTTONS_CLOSE, error)
                               
    error.title = title
    error.run
    error.destroy
  end
  
  ########################################################
  #### Handles the signals emitted by the main window ####
  ########################################################
  

  
  # 
  def remove_file(widget)
    puts "remove_file() is not implemented yet."
  end
  
  # Opens a widget with information about the project.
  def about(widget)
    Gnome::About.new(TITLE, VERSION ,
                     "Copyright (C) 2008 Universidad EAFIT",
                     "Colatio Builder",
                     ["Juan Guillermo Lalinde", "Federico Builes", "Alejandro Peláez", "Nicolás Hock"], ["Juan Guillermo Lalinde", "Federico Builes", "Alejandro Peláez", "Nicolás Hock"], nil).show
  end
  
  # Event triggered by a destroy or delete event 
  # Stops the application.
  def quit(widget)
    Gtk.main_quit
  end
  
  
  # Event that happens when the user presses the Add Text button.
  # Opens a file chooser dialog, from where the user select the desired file.
  # Then it adds the text to the project.
  def add_file(widget)
    unless @doc == nil
      filter = Gtk::FileFilter.new
      filter.name = '.in .rtf .txt'
      filter.add_pattern('*.in')
      filter.add_pattern('*.rtf')
      filter.add_pattern('*.txt')
      chooser = create_chooser filter
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
      show_error('You must open a project first!', "Project Error")
    end
  end

  ############################################################################
  ##### Methods below manage the project by manipalating the .cproj file #####
  ############################################################################
    
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

  
  
  # Deletes the specified text from the project
  def delete_text name
    unless @doc.root.elements["Texts/Text[@name='#{File.basename(name)}']"] == nil
      @doc.root.elements.delete("Texts/Text[@name='#{File.basename(name)}']")
      save
    else
      puts "The text is not in the project"
    end
  end
end

# Main program
if __FILE__ == $0
  # Set values as your own application. 
  PROG_PATH = "collatio.glade"
  PROG_NAME = "COLLATIO BUILDER"
  CollatioGlade.new(PROG_PATH, nil, PROG_NAME)
  Gtk.main
end
