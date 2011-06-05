module Redcar
  # This class is your plugin. Try adding new commands in here
  # and putting them in the menus.
  class Tracer

    # This method is run as Redcar is booting up.
    def self.menus
      # Here's how the plugin menus are drawn. Try adding more
      # items or sub_menus.
      Menu::Builder.build do
        sub_menu "Tracer" do
          item "Edit Plugin - Tracer", :command => Redcar::PluginSupport::EditPluginCommand, :value => "tracer"
          item "Reload Plugin - Tracer", :command => Redcar::PluginSupport::ReloadPluginCommand, :value => "tracer"
        end
      end
    end
    
  end
end