# This file contains the functions to manipulate the project
# save, load, create, add texts, etc

require 'gtk2'
require 'rexml/document'
include REXML

# Class Project
# Controls everything related to the porject managment.
class Project
  
  attr_accessor :doc

  # Saves the project in a .cproj file.
  # doc is the document that is going to be saved
  def save
    file = File.new("#{@doc.root.attributes["path"]}","w")
    @doc.write(file, 3, false)
    file.close
    puts "saved in #{@doc.root.attributes["path"]} \n"
  end
  
  # Creates an xml with just the prince text and the project path
  # prince is the path of the prince text
  # name is the name of the project
  # path is the path of the project
  def create_project prince, name, path=File.expand_path('')
    @doc = Document.new
    @doc << XMLDecl.new
    @doc.add_element "Project", {"name" => name, "path" => "#{path}/#{name}.cproj"}
    @doc.root.add_element "Texts"
    
    element = Element.new "Text"
    element.add_attribute "name", File.basename(prince)
    element.add_attribute "path", prince
    element.add_attribute "p", "true" 
    @doc.root.elements["Texts"].add_element element

    #Updates the tree view
    #Esto lo haria el tree view handler
    #init_tree
    
    #Saves the project
    save
    
    #Puts the project path.
    puts "#{name} created succesfully in #{path}\n"
  end

  # Opens a project from an xml file
  # path is the path of the project.
  def open path
    begin
      @doc = Document.new(File.new(path))
      puts "#{File.basename(path)} at #{path} was open succesfully\n"
    rescue
      #Algun metodo que muestre un mensaje de error
      #show_error("The file doesn't exist", "File Not Found")
    end
  end

  # Changes the prince file with another one specified
  # path, is the path of the new prince file
  def add_prince path
    if File.exist?(path)
      filename = File.basename(path)
      filepath = File.expand_path(path)
      element = @doc.root.elements["Texts/Text[@p='true']"]
      element.attributes["name"] = filename
      element.attributes["path"] = filepath

      #saves the project
      save
      puts "#{File.expand_path(path)} was added to project"
    else
      #Algun metodo que muestre un mensaje de error
      puts "The file doesn't exists"
    end 
  end

  # Adds a text to the project
  # path is the path of the new text
  def add_text path
    if File.exist?(path)
      if (@doc.root.elements["Texts/Text[@name='#{File.basename(path)}']"] == nil)
        filename = File.basename(path)
        filepath = File.expand_path(path)
        element = Element.new "Text"
        element.add_attribute "name", filename
        element.add_attribute "path", filepath
        element.add_attribute "p", "false"

        @doc.root.elements["Texts"].add_element element 
        
        #some mehtod updates the treestore
        
        #saves the project
        save
        puts "#{File.expand_path(path)} was added to project"
      else
         #Algun metodo que muestre un mensaje de error
        puts "The text is already in the project"
      end
    else
       #Algun metodo que muestre un mensaje de error
      puts "The file doesn't exists"
    end
  end

  # Deletes the specified text from the project
  # path is the path of the text that is going to be deleted
  def delete_text path
    element = @doc.root.elements["Texts/Text[@name='#{File.basename(path)}']"]
    if element == nil
      puts "The text is not in the project"
      return false
    elsif element.attributes["p"] == "true"
      puts "Can't delete the prince text"
      return false
    elsif 
      @doc.root.elements.delete("Texts/Text[@name='#{File.basename(path)}']")
      puts "Deleted #{path} from the project"
      save
      return true
    end
  end
  
end
