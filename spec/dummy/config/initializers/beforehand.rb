Beforehand.configure do |c|
  c.anti_dogpile_threshold = 20 # as in 20s
  c.verbose = false
end
