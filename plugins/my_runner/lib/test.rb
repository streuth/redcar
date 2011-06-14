puts "hello world  xxxx  "
s = "Woo Hoo"


name = "String"

c = Kernel.const_get(name)
puts c.inspect

puts ss.inspect

c.class_eval {
  def foo
    "FOO BAR"
  end
}


puts "".foo

eval(name)  #or eval(:Name.to_s)

                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                        