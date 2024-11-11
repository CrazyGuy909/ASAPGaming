function BATTLEPASS:CreateFont(name, size, weight, shadow)
	surface.CreateFont(name, {
		font = "Montserrat",
		size = size or 16,
		weight = weight or 500,
		shadow = shadow
	})
end