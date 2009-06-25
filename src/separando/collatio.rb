# Collatio Main Gui File
#
# Ruby-Glade-Template
#
require 'libglade2'
require 'project'
require 'treeV'
require 'tagManager'

PROG_NAME = TITLE = "Collatio Builder"
VERSION = "1.0"

class CollatioGlade
  include GetText
  attr :glade
  
  #################################################################
  #################################################################
  #          Methods created by the ruby-glade-template           #
  #       These methods will be triggered by the GUI buttons      #
  #################################################################
  #################################################################
  
  # Initializes the interface
  def initialize(path_or_data, root = nil, domain = nil, localedir = nil, flag = GladeXML::FILE)
    bindtextdomain(domain, localedir, nil, "UTF-8")
    @glade = GladeXML.new(path_or_data, root, domain, localedir, flag) {|handler| method(handler)}
    
    #Filters used on the choosers widgets
    @filter = Gtk::FileFilter.new
    @filter.name = 'Supported Files'
    @filter.add_pattern('*.in')
    @filter.add_pattern('*.rtf')
    @filter.add_pattern('*.xml')
    @filter.add_pattern('*.txt')

    @mainWindow = self

    #array with the texts
    @texts = []
    @scrolls = []
    @number_of_texts = 0

    # Manage the project
    @project = Project.new

    #Tag Manager
    @tagManager = TagManager.new
    
    #Manage the table and texts
    @main_table = @glade.get_widget('mainTable')

    #Manage the tree view
    @treeView = TreeV.new @project, @mainWindow
    @glade.get_widget('mainDiv').pack_start @treeView.view, false, false, 0
    @glade.get_widget('mainDiv').reorder_child @treeView.view, 0
    @glade.get_widget('mainDiv').show_all
  end

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

  # Event triggered by the open project button
  # Opens the specified .cproj project
  def open_project(widget)
    # Filter for the file chooser
    filter = Gtk::FileFilter.new
    filter.name = '.cproj'
    filter.add_pattern('*.cproj')

    # File chooser dialog
    chooser = create_chooser filter, Gtk::Stock::OPEN,"Choose a .cproj file" 

    # Check the user input
    chooser.run do |r|
      if r == Gtk::Dialog::RESPONSE_ACCEPT
        @project.open chooser.filename
        @treeView.create_tree @project
      end
      chooser.destroy
    end
  end
  
  # Event triggered by the New Project button
  # Creates a project with the specified prince text
  # and saves it in the specified folder
  def new_project(widget)
    prince = ""
    
    # File chooser dialog
    chooserPrince = create_chooser @filter, Gtk::Stock::OK, "Choose a prince text"

    # Check the user input
    chooserPrince.run do |r|
      if r == Gtk::Dialog::RESPONSE_ACCEPT
        prince = chooserPrince.filename
      else
        chooserPrince.destroy
        return
      end
    end
    chooserPrince.destroy
    
    # Folder choose dialog
    chooser_destiny = create_folder_chooser
    
    # Check the user input
    chooser_destiny.run do |r|
      if r == Gtk::Dialog::RESPONSE_ACCEPT
        filename = chooser_destiny.filename
        @project.create_project prince, File.basename(filename), filename
        @treeView.create_tree @project
      end
      chooser_destiny.destroy
    end
  end
  
  # Event triggered by the add text button
  # Adds a text to the project if it isn't already there
  def add_text(widget)
    # File chooser dialog
    chooser = create_chooser @filter, Gtk::Stock::ADD

    # Check the user input
    chooser.run do |r|
      if r == Gtk::Dialog::RESPONSE_ACCEPT
        @project.add_text chooser.filename
        @treeView.create_tree @project
      end
      chooser.destroy
    end

  end
  
  
  # TODO Save project and manage backups
  # Event triggered by the save button
  # Saves the project
  def save_project(widget)
    puts "save_project"
    file_chooser = create_chooser() #Custom filter can be made
    file_chooser.run do |response|
      if response==Gtk::Dialog::RESPONSE_ACCEPT
        file_chooser.destroy
        show_error("ACEPTAR!")
      else
        file_chooser.destroy
        show_error("NO FILE SELECTED")
      end
    end
  end
  
  # Event triggered by the about button
  # Shows some information about the project
  def about(widget)
    puts "about"
    Gnome::About.new(TITLE, VERSION ,
                     "Copyright (C) 2008 Universidad EAFIT",
                     "Colatio Builder",
                     ["Juan Guillermo Lalinde","Federico Builes","Alejandro Peláez","Nicolás Hock"],
                     ["Juan Guillermo Lalinde","Federico Builes","Alejandro Peláez","Nicolás Hock"],
                     nil).show
  end
  
  # Event triggered by the remove text button
  # Removes the specified text from the project if it is there
  def remove_text(widget)
    # File chooser dialog
    chooser = create_chooser @filter, Gtk::Stock::REMOVE, "Select the text to remove"

    # Check the user input
    chooser.run do |r|
      if r == Gtk::Dialog::RESPONSE_ACCEPT
        if @project.delete_text chooser.filename
          @treeView.create_tree @project
        end
      end
      chooser.destroy
    end
  end
  
  def quit(widget)
    puts "quit"
    Gtk.main_quit
  end
  
  #TODO 
  def save_as(widget)
    puts "save_as"
  end
  
  #################################################################
  #################################################################
  #                  Methods created by us                        #
  #       These methods will control the users interactivity      #
  #################################################################
  #################################################################
  
  # Creates a default file chooser dialog.
  # filter, is used if you want to specify a custom filter
  # icon is the icon used to choose a file, open a file, add file, etc
  # title is the title of the window
  def create_chooser filter=@filter, icon=Gtk::Stock::OPEN, title="Select file"
    
    chooser = Gtk::FileChooserDialog.new(title, @glade.get_widget("mainWindow"),
                                          Gtk::FileChooser::ACTION_OPEN,nil,
                                          [Gtk::Stock::CANCEL, Gtk::Dialog::RESPONSE_CANCEL],
                                          [icon, Gtk::Dialog::RESPONSE_ACCEPT])
      chooser.add_filter(filter) if filter
    chooser
  end

  # Creates a default folder chooser dialog.
  # icon is the icon used to choose a folder, open a folder, etc
  def create_folder_chooser icon=Gtk::Stock::SAVE
    
    chooser = Gtk::FileChooserDialog.new("Choose a folder", @glade.get_widget("mainWindow"),
                                          Gtk::FileChooser::ACTION_CREATE_FOLDER,nil,
                                          [Gtk::Stock::CANCEL, Gtk::Dialog::RESPONSE_CANCEL],
                                          [icon, Gtk::Dialog::RESPONSE_ACCEPT])
    chooser
  end
  
  # Pops up an error message with the specified text. 
  # The default message is Error!
  def show_error(error_message='Error!', title="Error!")
    error = Gtk::MessageDialog.new(@glade.get_widget("mainWindow"), 
                                   Gtk::Dialog::DESTROY_WITH_PARENT,
                                   Gtk::MessageDialog::ERROR, 
                                   Gtk::MessageDialog::BUTTONS_CLOSE, error_message)
    error.title = title
    error.run
    error.destroy
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
 
      #Populates the text view menu
      text.signal_connect("populate_popup") do |widget,menu|
        tagMenu  = Gtk::Menu.new
        
        @tagManager.types.collect.each do |t|
          temp = Gtk::MenuItem.new(t.tag.name)
          tagMenu.append(temp)
          temp.signal_connect('activate'){|w| tag_text(prince_text, t)}
        end
        tagMenu.append(Gtk::MenuItem.new("Create Tag"))
        subMenu = Gtk::MenuItem.new("Tags")
        subMenu.submenu = tagMenu
        
        #se esta removiendo cut, hay ke ver como hacer para ke no lo remueva la primera vez
        menu.remove(menu.children[0])
        menu.prepend(subMenu)
        menu.show_all
        menu.popup(nil, nil, 0, 0)
      end
      
      buffer.set_text(texts)
      buffer.place_cursor(buffer.start_iter)

      #Adds the text tags
      buffer.tag_table.each do |t|
        buffer.tag_table.remove(t)
      end
      @tagManager.types.collect.each do |t|
        buffer.tag_table.add(t.tag)
      end
    else
      show_error("File Not Found", "File Not Found")
    end
  end

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
      
      #Populates the text view menu
      prince_text.signal_connect("populate_popup") do |widget,menu|
        tagMenu  = Gtk::Menu.new
        
        @tagManager.types.collect.each.each do |t|
          temp = Gtk::MenuItem.new(t.tag.name)
          tagMenu.append(temp)
          temp.signal_connect('activate'){|w| tag_text(prince_text, t)}
        end
        tagMenu.append(Gtk::MenuItem.new("Create Tag"))
        subMenu = Gtk::MenuItem.new("Tags")
        subMenu.submenu = tagMenu
        
        #se esta removiendo cut, hay ke ver como hacer para ke no lo remueva la primera vez
        menu.remove(menu.children[0])
        menu.prepend(subMenu)
        menu.show_all
        menu.popup(nil, nil, 10, 0)
      end
      
      buffer = prince_text.buffer
      buffer.set_text(text)
      buffer.place_cursor(buffer.start_iter)
      prince_text.has_focus = true
      prince_text.visible = true

      #Adds the text tags
      buffer.tag_table.each do |t|
        buffer.tag_table.remove(t)
      end
      @tagManager.types.collect.each do |t|
        buffer.tag_table.add(t.tag)
      end
    else
      show_error("File Not Found", "File Not Found")
    end
  end

  # Tag the selected portion of the text with the desired tag
  def tag_text text_view, tag_type
    s, e = text_view.buffer.selection_bounds
    text_view.buffer.apply_tag(tag_type.tag, s, e)
  end
end

# Main program
if __FILE__ == $0
  # Set values as your own application. 
  PROG_PATH = "Collatio.glade"
  CollatioGlade.new(PROG_PATH, nil, PROG_NAME)
  Gtk.main
end
