SWEP.PrintName = "Inventory Pick-Up"
SWEP.Instructions = "Primary Fire: Pickup Item"

SWEP.WorldModel	= ""
SWEP.ViewModel	= "models/weapons/c_arms.mdl"

SWEP.UseHands = false
SWEP.Spawnable = true
SWEP.Slot = 1
SWEP.SlotPos = 0

SWEP.ViewModelFOV = 50
SWEP.ViewModelFlip = false

SWEP.Primary.ClipSize = -1
SWEP.Primary.DefaultClip = 0
SWEP.Primary.Automatic = false
SWEP.Primary.Ammo = "none"

SWEP.Secondary.ClipSize = -1
SWEP.Secondary.DefaultClip = 0
SWEP.Secondary.Automatic = false
SWEP.Secondary.Ammo = "none"

function SWEP:Initialize()
	self:SetWeaponHoldType("normal")
end