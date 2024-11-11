--This file will cache, load or save materials from the web
BU3.ImageLoader = {}

BU3.ImageLoader.CachedMaterials = {}

--This allows you to get a material based on an ID (should be the imgur URL ID)
--Make sure directory exists
file.CreateDir("bu3")

--There is a callback in-case the image is not loaded or isnt finished. The first argument of the callback
--is the material object for that texture, it will return an error texture if the material is not loaded
function BU3.ImageLoader.GetMaterial(id, callback)
	--First check if the ID is cached
	if BU3.ImageLoader.CachedMaterials[id] ~= nil then
	--	print("Image already loaded, returning material")
		callback(BU3.ImageLoader.CachedMaterials[id])
	else
		--Now check if we have that material file, if so load it as a material and return it
		if file.Exists("bu3/"..id..".png", "DATA") then
			--print("File found, loading material then returning")
			--It does exists, so we create the material
			BU3.ImageLoader.CachedMaterials[id] = Material("data/bu3/"..id..".png", "noclamp smooth")
			callback(BU3.ImageLoader.CachedMaterials[id])
		else
			--print("Failed to find image, attempting to load from imgur")
			--So the file does not exist, so we need to load it, cache it then return the callback
			http.Fetch("https://i.imgur.com/"..id..".png",function(body)
				print("Loaded Imgur Image : "..id..",png")
				file.Write("bu3/"..id..".png", body)
				BU3.ImageLoader.CachedMaterials[id] = Material("data/bu3/"..id..".png", "noclamp smooth")
				callback(BU3.ImageLoader.CachedMaterials[id])
			end, function()
				callback(false)
			end)
		end
	end
end

