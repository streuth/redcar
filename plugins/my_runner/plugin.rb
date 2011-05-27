
Plugin.define do
  name    "my_runner"
  version "1.0"
  file    "lib", "my_runner"
  object  "Redcar::MyRunner"
  dependencies "redcar", ">0"
end