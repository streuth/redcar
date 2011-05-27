module Redcar
  # This class is your plugin. Try adding new commands in here
  # and putting them in the menus.
  class MyRunner
  
    # This method is run as Redcar is booting up.
    def self.menus
      # Here's how the plugin menus are drawn. Try adding more
      # items or sub_menus.
      Menu::Builder.build do
        sub_menu "My-Runner" do
          item "Edit My Runner", EditMyRunnerCommand
          item "Reload My Runner", ReloadMyRunnerCommand
        end
      end
    end
    
   class RunCurrentTab < EditTabCommand
      TITLE = "Output"

      def execute
        path = doc.path
        if path
          execute_file(path)
        else
          path = File.join(Redcar.tmp_dir, "execute_file.rb")
          File.open(path, "w") { |file| file.puts doc.to_s }
          execute_file(path)
          FileUtils.rm(path)
        end
      end
      
      def execute_file(path)
        command = "ruby \"#{path}\""
        output = `#{command} 2>&1`
        tab = output_tab
        title = "[#{DateTime.now}]$ #{command}"
        tab.document.text = "#{tab.document.to_s}" +
          "#{"="*title.length}\n#{title}\n#{"="*title.length}\n\n#{output}"
        tab.title = TITLE
        tab.focus
      end      
 
   end

    #Quick menu to reload my plugin
    class ReloadMyRunnerCommand < Redcar::Command
      def execute
        plugin = Redcar.plugin_manager.loaded_plugins.detect {|pl| pl.name == "my_runner" }
        puts plugin.inspect
        Redcar.plugin_manager.load_plugin(plugin)
        Redcar.app.refresh_menu!
      end
    end
    

    # Command to open a new window, make the project my_plugin
    # and open this file.
    class EditMyRunnerCommand < Redcar::Command
      def execute
        # Open the project in a new window
        Project::Manager.open_project_for_path(Redcar.root)
        
        # Create a new edittab
        tab  = Redcar.app.focussed_window.new_tab(Redcar::EditTab)
        
        # A FileMirror's job is to wrap up the file in an interface that the Document understands.
        mirror = Project::FileMirror.new(File.join(Redcar.root, "plugins", "my_runner", "lib", "my_runner.rb"))
        tab.edit_view.document.mirror = mirror

        # Make sure the tab is focussed and the user can't undo the insertion of the document text
        tab.edit_view.reset_undo
        tab.focus
      end
    end
  end
end