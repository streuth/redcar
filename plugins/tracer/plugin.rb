Plugin.define do
  name    "tracer"
  version "1.0"
  file    "lib", "tracer"
  object  "Redcar::Tracer"
  dependencies "redcar", ">0"
end
