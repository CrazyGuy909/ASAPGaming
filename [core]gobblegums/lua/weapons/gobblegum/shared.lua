
AddCSLuaFile( "shared.lua" )

SWEP.Author			= "<CODE BLUE>"
SWEP.Instructions	= "Chew that shit nigga"
SWEP.Category = "ASAP Gobblegum"
SWEP.Spawnable			= true
SWEP.AdminSpawnable		= false

SWEP.ViewModel			= "models/asapgaming/bubblegum/bubblegum.mdl"
SWEP.WorldModel			= ""
SWEP.UseHands = true

SWEP.Primary.ClipSize		= -1
SWEP.Primary.DefaultClip	= -1
SWEP.Primary.Automatic		= true
SWEP.Primary.Ammo			= "none"
SWEP.Primary.Delay = 1

SWEP.Secondary.ClipSize		= -1
SWEP.Secondary.DefaultClip	= -1
SWEP.Secondary.Automatic	= false
SWEP.Secondary.Ammo			= "none"
SWEP.ViewModelFOV = 90

SWEP.Weight				= 5
SWEP.AutoSwitchTo		= true
SWEP.AutoSwitchFrom		= false

SWEP.PrintName			= "ASAP Gobblegum"			
SWEP.Slot				= 3
SWEP.SlotPos			= 1
SWEP.DrawAmmo			= false
SWEP.DrawCrosshair		= false

SWEP.CorrectModelPlacement = Vector(0,0,-1)
SWEP.SwayScale = 0.01
SWEP.BobScale = 0.01

function SWEP:Equip(NewOwner)
	NewOwner:SelectWeapon("gobblegum")
	timer.Simple(0.5,function() self:Remove() NewOwner:StripWeapon("gobblegum") end)

end

function SWEP:Deploy()
	self.Owner:DrawViewModel(true)

end


function SWEP:OnRemove()
	hook.Remove("CalcView", "GOBBLEGUM:CAMERA_BONE")
end

function SWEP:PreDrop()

end

function SWEP:Holster()
	--return false
end

function SWEP:PreDrawViewModel(vm)
	local color = ASAP_GOBBLEGUMS.TYPE_TO_COLOR[self:GetGumballType()]
	self.Weapon:SetColor(color)
end

function SWEP:PostDrawViewModel(vm)
	--render.SetMaterial()
end
		
function SWEP:ShouldDropOnDie()
	return false
end

function SWEP:SetupDataTables()
	self:NetworkVar( "Int", 0, "GumballType" )
end