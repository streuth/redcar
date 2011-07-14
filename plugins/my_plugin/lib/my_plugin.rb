module Redcar
  # This class is your plugin. Try adding new commands in here
  # and putting them in the menus.
  class MyPlugin

    # This method is run as Redcar is booting up.
    def self.menus
      # Here's how the plugin menus are drawn. Try adding more
      # items or sub_menus.
      Menu::Builder.build do
        sub_menu "My-Plugin" do
          item "Edit - My Plugin", :command => Redcar::PluginSupport::EditPluginCommand, :value => "my_plugin"
          item "Reload - My Plugin", :command => Redcar::PluginSupport::ReloadPluginCommand, :value => "my_plugin"
          sub_menu "Work in Progress", :priority => 100 do
            item "Edit Plugin - Comment", :command => Redcar::PluginSupport::EditPluginCommand, :value => "comment"
            item "Reload Plugin - Comment", :command => Redcar::PluginSupport::ReloadPluginCommand, :value => "comment"
            item "Edit Plugin - edit_view_swt", :command => Redcar::PluginSupport::EditPluginCommand, :value => "edit_view_swt"
            item "Reload Plugin - edit_view_swt", :command => Redcar::PluginSupport::ReloadPluginCommand, :value => "edit_view_swt"
            item "Edit Plugin - edit_view", :command => Redcar::PluginSupport::EditPluginCommand, :value => "edit_view"
            item "Reload Plugin - edit_view", :command => Redcar::PluginSupport::ReloadPluginCommand, :value => "edit_view"
          end
          sub_menu "Rails", :priority => 80 do
            item "Open Streuth Blues", :command => OpenProjectCommand, :value => "c:/dev/rails/streuthblues", :active => true #replace with check for path exists
            item "Open Lick Lab", :command => OpenProjectCommand, :value => "c:/dev/rails/licklab",:active => true #not very general but this is my ide :)
            item "Open Sample App", :command => OpenProjectCommand, :value => "c:/dev/rails/tutorials/rails3tutorials/sample_app",:active => true #not very general but this is my ide :)
          end
          sub_menu "Other Projects", :priority => 100 do
            item "Html Lessons", :command => OpenProjectCommand, :value => "c:/dev/html", :active => true #replace with check for path exists
            item "Ruby Koan", :command => OpenProjectCommand, :value => "c:/dev/ruby/ruby_koans", :active => true #replace with check for path exists
          end
          group(:priority => 110) {
            item "Open Ioke", :command => OpenProjectCommand, :value => "c:/git/ioke",:active => true #not very general but this is my ide :)
            item "Load Plugin", LoadPluginCommand
          }
        end
        sub_menu "Project" do
          group(:priority => 100) {
            item "Open Streuth", :command => OpenProjectCommand, :value => "c:/dev/rails/streuth"
            item "Open Lick Lab", :command => OpenProjectCommand, :value => "c:/dev/rails/licklab"
          }
        end
        sub_menu "Plugins" do
          sub_menu "My Plugin", :priority => 139 do
            item "Hello World!", HelloWorldCommand
            item "Edit My Plugin", :command => Redcar::PluginSupport::EditPluginCommand, :value => "my_plugin"
          end
        end
      end
    end
    
    def self.edit_view_context_menus
      Menu::Builder.build do
        group(:priority => 40) do
          item ("Go To Tag"  ) { Redcar::Declarations::GoToTagCommand.new.run  }
        end
      end
    end

    
    class OpenProjectCommand < Redcar::Command
      # sensitize :open_project
      def execute(options)
        if options[:value]
          project = Redcar::Project::Manager.open_project_for_path(options[:value])
          project.refresh if project
        end
      end
    end

    class LoadPluginCommand < Redcar::Command
      def execute
        result = Application::Dialog.input("Load Plugin", "Please enter plugin name:", "my_runner") do |text|
          nil
        end
        puts result[:button]
        if (result[:button] == :ok)
          puts "==OK"
          name = result[:value]
          puts name.inspect
          
          # Redcar.plugin_manager.load(File.join(Redcar.root, "plugins", "#{name}", "lib", "#{name}.rb").to_s)
          Redcar.plugin_manager.load(name)
          Redcar.app.refresh_menu!
        end
      end
    end

    # Example command: showing a dialog box.
    class HelloWorldCommand < Redcar::Command
      def execute
        Application::Dialog.message_box("Hello World!")
      end
    end

  end
end