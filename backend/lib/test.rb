replacements = {"{{test}}" => "black", "{{swag}}" => "bieber"}

text = "Much {{swag}} wow {{test}} cool"
puts text
replacements.each do |key, value| 
	puts key + " " + value
	text = text.gsub(key,value.to_s)
end
puts "done: " + text