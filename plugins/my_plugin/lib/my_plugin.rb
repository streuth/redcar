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
          item "Edit Plugin - Comment", :command => Redcar::PluginSupport::EditPluginCommand, :value => "comment"
          item "Reload Plugin - Comment", :command => Redcar::PluginSupport::ReloadPluginCommand, :value => "comment"
          item "Load Plugin", LoadPluginCommand
          item "Open Streuth", :command => OpenProjectCommand, :value => "c:/dev/rails/streuth", :active => true #replace with check for path exists
          item "Open Lick Lab", :command => OpenProjectCommand, :value => "c:/dev/rails/licklab",:active => true #not very general but this is my ide :)
          item "Open Ioke", :command => OpenProjectCommand, :value => "c:/git/ioke",:active => true #not very general but this is my ide :)
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