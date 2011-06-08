#From The Ruby Programming Language - Chapter 8: Reflection and Metaprogramming

#todo - output to output tab
#     - save methods to file and reload
class Object
  puts "SHOULD BE DEFINING TRACER SUPPORT"
  #Trace the specified methods, for now output to STDERR - want to change this the Output tab
  def trace!(*method) #add a boolean to trace private
    $_out = STDERR
    
    @_traced = @_traced || []
    
    #if not methods defined then trace all public methods
    methods = public_methods(false) if methods == nil || methods.size = 0
    methods.map! {|m| m.to_sym }
    methods -= @_traced
    return if methods.empty?
    @_traced |= methods
    
    $_out << "Tracing #{methods.join(', ')} on #{object_id}\n"

    #methods are defined on the eigenclass
    eigenclass = class << self; self; end
    
    methods.each do |m| 
      eigenclass.class_eval %Q{
      def #{m}(*args, &block)
        begin
          $_out << "Entering: #{m}(\#{args.join(', ')})\n"
          result = super
          $_out << "Exiting: #{m} with \#{result}\n"
        rescue
          $_out << "Aborting: #{m}: \#{$!.class}: \#{$!.message}"
          raise
        end
      end
      }
    end
  end
  
  #Untrace specified methods
  def untrace!(*methods)
    if methods.size == 0
      methods = @_traced
      $_out << "Untracing all methods on #(object_id)\n"
    else
      methods.map! {|m| m.to_sym }
      methods &= @_traced
      $_out << "Untracing #{methods.join(', ')} on #(object_id)\n"
    end
    
    (class << self; self; end).class_eval do
      methods.each do |m|
        remove_method m
      end
    end
    
    if @_traced.empty?
      remove_instance_variable :@_traced
    end
  end
  
  
  
end    