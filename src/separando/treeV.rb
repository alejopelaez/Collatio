require 'gtk2'
require 'project'
include REXML

# Class tree
# Controls the view
class TreeV
  attr_accessor :proj
  attr_reader :view, :treestore, :renderer


  # Contructor
  # initializes some variables
  # proj is the project with the information
  # window is the application main window
  def initialize proj=nil, window=nil
    @view = Gtk::TreeView.new
    @window = window
    # Creates the treestore, and renderer
    create_tree proj
    init_tree_signals
  end

  # Creates a new tree.
  # Doc is the project with the information that the tree will display
  def create_tree proj=nil
    @proj = proj
    doc = @proj.doc
    
    #Removes all the columns from the tree view.
    @view.columns.each {|col| @view.remove_column(col)}
    
    #Add the data to the @treestore model.
    unless doc == nil
      root = doc.root
      #The treestore has 4 attributes
      # 0 - The name
      # 1 - The path
      # 2 - Is prince or not?
      # 3 - Information on how to paint it (Weight or boldness)
      @treestore = Gtk::TreeStore.new(String, String, String, Integer)
      parent = @treestore.append(nil)
      parent[0] = root.attributes['name']
      parent[1] = nil
      parent[2] = nil
      parent[3] = 200
      
      root.elements.each do |element|
        iter = @treestore.append(parent)
        iter[0] = element.name
        iter[1] = nil
        iter[2] = nil
        iter[3] = 200
        
        element.elements.each do |element2|
          iter2 = @treestore.append(iter)
          iter2[0] = element2.attributes['name']
          iter2[1] = element2.attributes['path']
          
          if(element2.attributes['p'] == 'true')
            iter2[0] = "(Prince)#{iter2[0]}"
            iter2[2] = 'true'
            iter2[3] = 900
          else
            iter2[2] = 'false'
            iter2[3] = 200
          end
        end
      end
      
      #Adds the renderer to the tree view.
      @view.model = @treestore
      @renderer = Gtk::CellRendererText.new
      col = Gtk::TreeViewColumn.new("Project", @renderer, :text => 0, :weight => 3)
      @view.append_column(col)  
    end

    #Expand the tree
    view.expand_all
  end

  # Initializes the signals for the view.
  # This allows for right clicking on an object and choosing actions
  def init_tree_signals
    # Creates the right click menu for the view
    menu = Gtk::Menu.new
    open = Gtk::MenuItem.new("Open")
    delete = Gtk::MenuItem.new("Delete")
    
    # Connects the open signal.
    open.signal_connect("activate") do
      if iter = @view.selection.selected
        if iter.parent[0] == 'Texts'
          if iter[2] == 'true'
            #show prince
          else
            #show text
          end
        end
      end
    end

    #Connects the close signal.
    delete.signal_connect("activate") do 
      if iter = @view.selection.selected
        delete = Gtk::MessageDialog.new(@window, Gtk::Dialog::DESTROY_WITH_PARENT,
                                        Gtk::MessageDialog::QUESTION, 
                                        Gtk::MessageDialog::BUTTONS_YES_NO, 'Are you sure?')
        delete.run do |response|
          if response == Gtk::Dialog::RESPONSE_YES
            if iter.parent[0] == 'Texts'
              if iter[2] == 'true'
                #delete prince
                # @treestore.remove(iter)
                puts "Can't delete the prince"
              else
                if @proj.delete_text iter[1]
                  @treestore.remove(iter)
                end
              end
            end
          end
          delete.destroy
        end
      end
    end
    
    #Appends the menus
    menu.append(open)
    menu.append(delete)
    menu.show_all

    # Popup the menu on right click
    @view.signal_connect("button_press_event") do |widget, event|
      if event.kind_of? Gdk::EventButton and event.button == 3
        if iter = @view.selection.selected
          if iter.parent == nil
          elsif iter.parent[0]!= 'Texts'
          elsif iter.parent[0] == 'Texts'
            menu.popup(nil, nil, event.button, event.time)
          end
        end
      end
    end
    
    #Gets the doubleclicks
    @view.signal_connect("row-activated") do |view, path, column|
      if iter = view.model.get_iter(path)
        if iter.parent != nil and iter.parent[0] == 'Texts'
          if iter[2] == 'true'
            puts 'show prince'
          else
            puts 'show text'
            #show_file iter[1]
          end
        end
      end
    end

  end
end
