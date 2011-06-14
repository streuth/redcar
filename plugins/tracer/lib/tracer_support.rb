#From The Ruby Programming Language - Chapter 8: Reflection and Metaprogramming

#todo - output to output tab
#     - save methods to file and reload

#class Class
#  alias_method :old_new,  :new
#  def new(*args)
#    result = old_new(*args)
#    return result
#  end
#end

module Kernel
  def qualified_const_get(str)
    path = str.to_s.split('::')
    from_root = path[0].empty?
    if from_root
      from_root = []
      path = path[1..-1]
    else
      start_ns = ((Class === self)||(Module === self)) ? self : self.class
      from_root = start_ns.to_s.split('::')
    end
    until from_root.empty?
      begin
        return (from_root+path).inject(Object) { |ns,name| ns.const_get(name) }
      rescue NameError
        from_root.delete_at(-1)
      end
    end
    path.inject(Object) { |ns,name| ns.const_get(name) }
  end
  
  def class_exists?(class_name)
    klass = qualifed_const_get(class_name)
    return klass.is_a?(Class)
  rescue NameError
    return false
  end  
end

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
    
    STDERR << "Tracing #{methods.join(', ')} on #{object_id}\n"

    #methods are defined on the eigenclass
    eigenclass = class << self; self; end
    
    methods.each do |m| 
      eigenclass.class_eval %Q{
      def #{m}(*args, &block)
        begin
          STDERR << "Entering: #{m}(\#{args.join(', ')})\n"
          result = super
          STDERR << "Exiting: #{m} with \#{result}\n"
          result
        rescue
          STDERR << "Aborting: #{m}: \#{$!.class}: \#{$!.message}"
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