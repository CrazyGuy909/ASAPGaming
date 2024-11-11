--[[
     _        _                       _ _   _            _                    _ _                             
 ___| |_ ___ | | ___ _ __   __      _(_) |_| |__     ___| |__   ___  __ _  __| | | _____      ____ _ _ __ ___ 
/ __| __/ _ \| |/ _ \ '_ \  \ \ /\ / / | __| '_ \   / __| '_ \ / _ \/ _` |/ _` | |/ _ \ \ /\ / / _` | '__/ _ \
\__ \ || (_) | |  __/ | | |  \ V  V /| | |_| | | | | (__| | | |  __/ (_| | (_| | |  __/\ V  V / (_| | | |  __/
|___/\__\___/|_|\___|_| |_|   \_/\_/ |_|\__|_| |_|  \___|_| |_|\___|\__,_|\__,_|_|\___| \_/\_/ \__,_|_|  \___|
--]]

/**

* Derma Emoticons 

**/



-- Enable Derma emoticons?

-- You can see the full list here: http://www.famfamfam.com/lab/icons/silk/previews/index_abc.png

LOUNGE_CHAT.EnableDermaEmoticons = false



-- Restrict Derma emoticons?

-- You can configure the restrictions in the "DermaEmoticonsRestrictions" option.

-- "false" means derma emoticons can be used by anyone.

LOUNGE_CHAT.RestrictDermaEmoticons = false



-- Here you can decide on restrictions for players to be able to use Derma emoticons in their messages.

-- Only works if the "RestrictDermaEmoticons" option is set to true

LOUNGE_CHAT.DermaEmoticonsRestrictions = {

	-- This means only admins, superadmins and players with the specific SteamID/SteamID64 can use Derma emoticons.

	usergroups = {"admin", "superadmin"},

	steamids = {"STEAM_0:1:8039869", "76561197976345467"}

}



/**

* Custom Emoticons 

**/





-- Add your custom emoticons here!

-- Two examples are provided for you to copy.

LOUNGE_CHAT.CustomEmoticons = {
	["grin"] = {
		path = "vgui/face/grin",
		w = 64,
		h = 32,
	},

	-- This creates a "awesomeface" emoticon with the URL "http://i.imgur.com/YBUpyZg.png"
	["awesomeface"] = {
		url = "http://i.imgur.com/YBUpyZg.png",
		w = 32,
		h = 32,
	},

	// FA emoticons

	["kami"] = {
		url = "https://vgy.me/pzfz8k.png",
		w = 32,
		h = 32,
	},

    ["nebula"] = {
        url = "https://i.imgur.com/FBWAnU2.png",
        w = 13,
        h = 16,
    },

	["kosmugi"] = {
		url = "http://i.imgur.com/fWxbVLv.png",
		w = 32,
		h = 32,
	},

	["chaika"] = {
		url = "http://i.imgur.com/h25fTDE.png",
		w = 32,
		h = 32,
	},

	["thatcat"] = {
		url = "http://i.imgur.com/00Xaj13.png",
		w = 32,
		h = 32,
	},

	["shutup"] = {
		url = "https://imgur.com/OtgXt1H.png",
		w = 32,
		h = 32,
	},

	["cute"] = {
		url = "https://imgur.com/xmjovZb.png",
		w = 32,
		h = 32,
	},

	["mlady"] = {
		url = "https://imgur.com/C9Oxdwq.png",
		w = 32,
		h = 32,
	},

	["tyler"] = {
		url = "https://imgur.com/GMFbPTd.png",
		w = 32,
		h = 32,
	},

	["mike"] = {
		url = "https://imgur.com/8uSVHw5.png",
		w = 32,
		h = 32,
	},

	["f"] = {
		url = "https://imgur.com/AqSq7OE.png",
		w = 32,
		h = 32,
	},

	["eri"] = {
		url = "https://imgur.com/NmS9wyF.png",
		w = 32,
		h = 32,
	},

	["noice"] = {
		url = "https://imgur.com/oJ6mO2t.png",
		w = 32,
		h = 32,
	},

	["wtf"] = {
		url = "https://imgur.com/IREuoNe.png",
		w = 32,
		h = 32,
	},

	["hmm"] = {
		url = "https://imgur.com/V6P3FSW.png",
		w = 32,
		h = 32,
	},

	["cross"] = {
		url = "https://imgur.com/gfX8dV7.png",
		w = 32,
		h = 32,
	},

	["rock"] = {
		url = "https://imgur.com/ufydLPu.png",
		w = 32,
		h = 32,
	},

	["bruh"] = {
		url = "https://imgur.com/KDoI8OG.png",
		w = 32,
		h = 32,
	},

	["bruh2"] = {
		url = "https://imgur.com/vlenUru.png",
		w = 32,
		h = 32,
	},

	["bruh3"] = {
		url = "https://imgur.com/RKn1HrC.png",
		w = 32,
		h = 32,
	},

	["pog"] = {
		url = "https://imgur.com/TrMwMYP.png",
		w = 32,
		h = 32,
	},

	["gun"] = {
		url = "https://imgur.com/DDYS79l.png",
		w = 32,
		h = 32,
	},

	["money"] = {
		url = "https://imgur.com/QFdBEta.png",
		w = 32,
		h = 32,
	},

	["why"] = {
		url = "https://imgur.com/karK6yR.png",
		w = 13,
		h = 16,
	},

	["dying"] = {
		url = "https://imgur.com/PXOGFl4.png",
		w = 32,
		h = 32,
	},

	["joy"] = {
		url = "https://imgur.com/vKSUuz1.png",
		w = 32,
		h = 32,
	},

	["joy2"] = {
		url = "https://imgur.com/CdBMdtX.png",
		w = 13,
		h = 16,
	},

	["clown1"] = {
		url = "https://imgur.com/VZcLGXd.png",
		w = 32,
		h = 32,
	},

	["clown2"] = {
		url = "https://imgur.com/SLYzNHj.png",
		w = 32,
		h = 32,
	},

	["clown3"] = {
		url = "https://imgur.com/QeH0LLP.png",
		w = 32,
		h = 32,
	},

	["clown4"] = {
		url = "https://imgur.com/TWDyIuT.png",
		w = 32,
		h = 32,
	},
	
	["texture"] = {

		url = "https://i.imgur.com/XNoMzVR.png",

		w = 32,

		h = 32,

	},

	["thinkies"] = {

		url = "https://i.imgur.com/gP9n7QG.png",

		w = 32,

		h = 32,

	},

	["think_rope"] = {

		url = "https://i.imgur.com/FffH86U.png",

		w = 32,

		h = 32,

	},

	["thonk"] = {

		url = "https://i.imgur.com/YALgpec.png",

		w = 32,

		h = 32,

	},

	["umm"] = {

		url = "https://i.imgur.com/HrZJU6e.png",

		w = 32,

		h = 32,

	},

	["vee"] = {

		url = "https://i.imgur.com/3GxNeAi.png",

		w = 32,

		h = 32,

	},

	["weeb"] = {

		url = "https://i.imgur.com/6KErgLm.png",

		w = 32,

		h = 32,

	},

	["angery"] = {

		url = "https://i.imgur.com/tpmrczA.png",

		w = 32,

		h = 32,

	},

	["ayaya"] = {

		url = "https://i.imgur.com/H1uzrkI.png",

		w = 32,

		h = 32,

	},

	["deadpanpig"] = {

		url = "https://i.imgur.com/B8oP1Vj.png",

		w = 32,

		h = 32,

	},

	["feelsbadman"] = {

		url = "https://i.imgur.com/btjZl7A.png",

		w = 32,

		h = 32,

	},

	["funny"] = {

		url = "https://i.imgur.com/S22GgrB.png",

		w = 32,

		h = 32,

	},

	["good_morning"] = {

		url = "https://i.imgur.com/WqhYu0X.png",

		w = 32,

		h = 32,

	},

	["greekp"] = {

		url = "https://i.imgur.com/5so4e5T.png",

		w = 32,

		h = 32,

	},

	["hypers"] = {

		url = "https://i.imgur.com/FHZcare.png",

		w = 32,

		h = 32,

	},

	["kappa"] = {

		url = "https://i.imgur.com/sOsgcjw.png",

		w = 32,

		h = 32,

	},

	["kappa_pride"] = {

		url = "https://i.imgur.com/AHxbEIP.png",

		w = 32,

		h = 32,

	},

	["kms"] = {

		url = "https://i.imgur.com/kDs30QB.png",

		w = 32,

		h = 32,

	},

	["monkainsane"] = {

		url = "https://i.imgur.com/dSvSCHB.png",

		w = 32,

		h = 32,

	},

	["monkas"] = {

		url = "https://i.imgur.com/3HS4L6N.png",

		w = 32,

		h = 32,

	},

	["ok"] = {

		url = "https://i.imgur.com/kaM0dWz.png",

		w = 32,

		h = 32,

	},

	["owo"] = {

		url = "https://i.imgur.com/hrSfm8O.png",

		w = 32,

		h = 32,

	},

	["pepejesus"] = {

		url = "https://i.imgur.com/kYQ0Bgj.png",

		w = 32,

		h = 32,

	},

	["pepelove"] = {

		url = "https://i.imgur.com/CnrLPIg.png",

		w = 32,

		h = 32,

	},

	["pepe_ok"] = {

		url = "https://i.imgur.com/aQFLHNa.png",

		w = 32,

		h = 32,

	},

	["pepe_think"] = {

		url = "https://i.imgur.com/5tmZhSh.png",

		w = 32,

		h = 32,

	},

	["pepewow"] = {

		url = "https://i.imgur.com/A9Un27i.png",

		w = 32,

		h = 32,

	},

	["pepoblanket"] = {

		url = "https://i.imgur.com/asLZZCx.png",

		w = 32,

		h = 32,

	},

	["puke"] = {

		url = "https://i.imgur.com/pvfDtTO.png",

		w = 32,

		h = 32,

	},

	["residentsleeper"] = {

		url = "https://i.imgur.com/38bCHBY.png",

		w = 32,

		h = 32,

	},

	["scary"] = {

		url = "https://i.imgur.com/7QFaxY8.png",

		w = 32,

		h = 32,

	},

	["obunga"] = {

		url = "https://i.imgur.com/QYlM0YK.png",

		w = 32,

		h = 32,

	},

	["pepega"] = {

		url = "https://i.imgur.com/nGLnEgr.png",

		w = 32,

		h = 32,

	},

	["pepohappy"] = {

		url = "https://i.imgur.com/719eXdO.png",

		w = 32,

		h = 32,

	},

	["poggers"] = {

		url = "https://i.imgur.com/QuGenvG.png",

		w = 32,

		h = 32,

	},

	["wat"] = {

		url = "https://i.imgur.com/KZ5xHPu.png",

		w = 32,

		h = 32,

	},

	["weirdchamp"] = {

		url = "https://i.imgur.com/aWEcrIx.png",

		w = 32,

		h = 32,

	},

	["kanna_angry"] = {

		url = "https://i.imgur.com/8gQcE73.png",

		w = 32,

		h = 32,

	},

	["cry"] = {

		url = "https://i.imgur.com/oHkEBwN.png",

		w = 32,

		h = 32,

	},

	["doggof"] = {

		url = "https://i.imgur.com/asSQSBG.png",

		w = 32,

		h = 32,

	},

	["doggop"] = {

		url = "https://i.imgur.com/1H2hAXz.png",

		w = 32,

		h = 32,

	},

	["forsene"] = {

		url = "https://i.imgur.com/MvFZHbp.png",

		w = 32,

		h = 32,

	},

	["very_funny"] = {

		url = "https://i.imgur.com/kL12JWD.png",

		w = 32,

		h = 32,

	},

	["gmod"] = {

		url = "https://i.imgur.com/SFEEmO1.png",

		w = 32,

		h = 32,

	},

	["kk"] = {

		url = "https://i.imgur.com/KuwuzYq.png",

		w = 32,

		h = 32,

	},

	["monka"] = {

		url = "https://i.imgur.com/U1dLDow.png",

		w = 32,

		h = 32,

	},

	["monkahmm"] = {

		url = "https://i.imgur.com/1761lWj.png",

		w = 32,

		h = 32,

	},

	["monkaomega"] = {

		url = "https://i.imgur.com/feTVVXE.png",

		w = 32,

		h = 32,

	},

	["thatcat"] = {

		url = "http://i.imgur.com/00Xaj13.png",

		w = 32,

		h = 32,

	},

}



-- Here you can decide whether an emoticon can only be used by a specific usergroup/SteamID

LOUNGE_CHAT.EmoticonRestriction = {

	-- This restricts the "awesomeface" emoticon so that it can only be used by:

	-- * "admin" and "superadmin" usergroups

	-- * players with the SteamID "STEAM_0:1:8039869" or SteamID64 "76561197976345467"

	["awesomeface"] = {

		usergroups = {"admin", "superadmin"},

		steamids = {"STEAM_0:1:8039869", "76561197976345467"}

	},

}



/**

* End of configuration

**/



LOUNGE_CHAT.Emoticons = {}



function LOUNGE_CHAT:RegisterEmoticon(id, path, url, w, h, restrict)

	self.Emoticons[id] = {

		path = path,

		url = url,

		w = w or 16,

		h = h or 16,

		restrict = restrict,

	}

end



if (LOUNGE_CHAT.EnableDermaEmoticons) then

	local fil = file.Find("materials/icon16/*.png", "GAME")

	for _, f in pairs (fil) do

		local restrict

		if (LOUNGE_CHAT.RestrictDermaEmoticons) then

			restrict = LOUNGE_CHAT.DermaEmoticonsRestrictions

		end



		LOUNGE_CHAT:RegisterEmoticon(string.StripExtension(f), "icon16/" .. f, nil, 16, 16, restrict)

	end

end



for id, em in pairs (LOUNGE_CHAT.CustomEmoticons) do

	LOUNGE_CHAT:RegisterEmoticon(id, em.path, em.url, em.w, em.h, LOUNGE_CHAT.EmoticonRestriction[id])

end