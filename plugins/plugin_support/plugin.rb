
Plugin.define do
  name    "plugin_support"
  version "1.0"
  file    "lib", "plugin_support"
  object  "Redcar::PluginSupport"
  dependencies "redcar", ">0"
end