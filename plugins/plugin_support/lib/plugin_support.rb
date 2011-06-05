module Redcar
  # This class is your plugin. Try adding new commands in here
  # and putting them in the menus.
  class PluginSupport

    # This method is run as Redcar is booting up.
    def self.menus
      # Here's how the plugin menus are drawn. Try adding more
      # items or sub_menus.
      Menu::Builder.build do
        sub_menu "Plugins" do
          sub_menu "Plugin Support" do
            item "Edit Plugin", :command => Redcar::PluginSupport::EditPluginCommand, :value => "plugin_support"
            item "Reload Plugin", :command => Redcar::PluginSupport::ReloadPluginCommand, :value => "plugin_support"
          end
        end
      end
    end
    
    #Quick menu to reload my plugin
    class ReloadPluginCommand < Redcar::Command
      def execute(options)
        if options[:value]
          plugin = Redcar.plugin_manager.loaded_plugins.detect {|pl| pl.name == options[:value] }
          Redcar.plugin_manager.load_plugin(plugin)
          Redcar.app.refresh_menu!
        end
      end
    end
    


    # Command to open a new window, make the project my_plugin
    # and open this file.
    class EditPluginCommand < Redcar::Command
      def execute(options)
        # Open the project in a new window
        if options[:value]
          plugin_name = options[:value]
          Project::Manager.open_project_for_path(Redcar.root)
          
          # Create a new edittab
          tab  = Redcar.app.focussed_window.new_tab(Redcar::EditTab)
          
          # A FileMirror's job is to wrap up the file in an interface that the Document understands.
          mirror = Project::FileMirror.new(File.join(Redcar.root, "plugins", plugin_name, "lib", plugin_name+".rb"))
          tab.edit_view.document.mirror = mirror
  
          # Make sure the tab is focussed and the user can't undo the insertion of the document text
          tab.edit_view.reset_undo
          tab.focus
        end
      end
    end    
  end
end