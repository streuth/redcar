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
          item "Run Current Tab", RunCurrentTabCommand
          item "Edit My Runner", EditMyRunnerCommand
          item "Reload My Runner", ReloadMyRunnerCommand
        end
      end
    end
    
    def self.toolbars
      ToolBar::Builder.build do
        # item "Execut Tab", :command => RunCurrentTabCommand, :icon => File.join(Redcar::ICONS_DIRECTORY, "ruby.png"), :barname => :my_runner
        item "Execute Tab", :command => RunCurrentTabCommand, :icon => File.join(Redcar::ICONS_DIRECTORY, "application-dock.png"), :barname => :my_runner
        #could use application-documents.png
      end
    end

    
   class RunCurrentTabCommand < EditTabCommand
      TITLE = "Output"

      def execute
        # current_tab = Redcar.app.focussed_window.focussed_notebook_tab
        current_tab = tab
        path = doc.path
        if path
          execute_file(path)
        else
          path = File.join(Redcar.tmp_dir, "execute_file.rb")
          File.open(path, "w") { |file| file.puts doc.to_s }
          execute_file(path)
          FileUtils.rm(path)
        end
        current_tab.focus
      end
      
      def output_tab
        tabs = win.notebooks.map {|nb| nb.tabs }.flatten
        tabs.detect {|t| t.title == TITLE} || begin
          notebook = Redcar::Application::OpenNewNotebookCommand.new.run
          tab = Top::OpenNewEditTabCommand.new.run
          move_tab(tab)
          result = tab
        end
      end      
      
      def move_tab(tab)
        current_notebook = tab.notebook
        i = win.notebooks.index current_notebook

        target_notebook = win.notebooks[ (i + 1) % win.notebooks.length ]
        target_notebook.grab_tab_from(current_notebook, tab)
        win.rotate_notebooks
      end
      
      def execute_file(path)
        command = "ruby \"#{path}\""
        output = `#{command} 2>&1`
        tab = output_tab
        title = "[#{DateTime.now}]$ #{command}"
        tab.document.text = "#{tab.document.to_s}" +
          "#{"="*title.length}\n#{title}\n#{"="*title.length}\n\n#{output}"
        tab.title = TITLE
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