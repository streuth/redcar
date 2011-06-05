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
          item "Debug Current Tab", DebugTabCommand
          item "Edit Plugin - MyRunner", :command => Redcar::PluginSupport::EditPluginCommand, :value => "my_runner"
          item "Reload Plugin - MyRunner", :command => Redcar::PluginSupport::ReloadPluginCommand, :value => "my_runner"
        end
      end
    end
    
    def self.toolbars
      ToolBar::Builder.build do
        # item "Execut Tab", :command => RunCurrentTabCommand, :icon => File.join(Redcar::ICONS_DIRECTORY, "ruby.png"), :barname => :my_runner
        item "Execute Tab", :command => RunCurrentTabCommand, :icon => File.join(Redcar::ICONS_DIRECTORY, "application-dock.png"), :barname => :my_runner
        item "Debug Tab", :command => DebugTabCommand, :icon => File.join(Redcar::ICONS_DIRECTORY, "ruby.png"), :barname => :my_runner
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
        command = "jruby -S \"#{path}\""
        output = `#{command} 2>&1`
        tab = output_tab
        title = "[#{DateTime.now}]$ #{command}"
        tab.document.text = "#{tab.document.to_s}" +
          "#{"="*title.length}\n#{title}\n#{"="*title.length}\n\n#{output}"
        tab.title = TITLE
      end      
   end
  
    class DebugTabCommand < RunCurrentTabCommand
      def execute_file(path)
        #client >> jruby --debug -S rdebug --client
        #TODO figure out how to run interactively, this just hangs redcar and all output until it's finished
        command = "jruby --debug -S rdebug --server \"#{path}\""
        output = `#{command} 2>&1`
        tab = output_tab
        title = "[#{DateTime.now}]$ #{command}"
        tab.document.text = "#{tab.document.to_s}" +
          "#{"="*title.length}\n#{title}\n#{"="*title.length}\n\n#{output}"
        tab.title = TITLE
      end      
    end    

  end
end