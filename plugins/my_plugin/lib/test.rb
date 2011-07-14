class Roulette 
	def method_missing(name, *args)
		person = name.to_s.capitalize
    number = 1
		3.times do
			number = rand(10) + 1
			puts "#{number}..."
		end
		"#{person} got a #{number.to_s}"
	end
end

number_of = Roulette.new
puts number_of.bob
puts number_of.mark
