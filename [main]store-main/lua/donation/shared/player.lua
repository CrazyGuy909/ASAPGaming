DonationRoles = DonationRoles or {}
DonationRoles.roles = {}
DonationRoles.roleNames = {}

function DonationRoles:AddRole(index, roleName)
    self.roles[index] = roleName
    self.roleNames[roleName] = index
end

DonationRoles:AddRole(1, "VIP")
DonationRoles:AddRole(2, "Ultra VIP")
DonationRoles:AddRole(3, "Meme")
DonationRoles:AddRole(4, "Meme God")
DonationRoles:AddRole(5, "Meme Legend")
DonationRoles:AddRole(6, "Grinch")
DonationRoles:AddRole(7, "Chungus")
DonationRoles:AddRole(8, "VERY HOT")
DonationRoles:AddRole(9, "Sp0okyy")
DonationRoles:AddRole(10, "Snowy")
DonationRoles:AddRole(11, "EGG")
DonationRoles:AddRole(12, "Snowflake")
DonationRoles:AddRole(13, "Event Manager")
DonationRoles:AddRole(14, "Pipi")

local plyMeta = FindMetaTable("Player")

function plyMeta:SetDonatorByRoleName(name)
    self:SetDonator(DonationRoles.roleNames[name])
end

function plyMeta:SetDonator(tier, visual, ignoreSave)
    if not IsValid(self) then return end
    visual = visual or tier
    if (not DonationRoles.roles[tier] and tier ~= 0) then return end
    if (not DonationRoles.roles[visual] and visual ~= 0) then return end
    self.donator = tier
    self.donatorVisual = visual

    if (not ignoreSave and SERVER) then
        local saveInv
        if (not table.HasValue(self.rankInventory, tier)) then
            saveInv = true
            table.insert(self.rankInventory, tier)
        end
        DonationRoles.Database:SavePlayer(self, tier, visual, saveInv)
    end

    if (SERVER) then
        DonationRoles:NetworkPlayer(self, tier, visual)
    end
end

function plyMeta:IsDonator(tier)
    return self:GetDonator() >= tier
end

function plyMeta:IsDonatorByRoleName(name)
    return self:IsDonator(DonationRoles.roleNames[name])
end

function plyMeta:GetDonator(visual)
    if visual then
        return self.donatorVisual or self.donator or 0
    end
    return self.donator or 0
end

function plyMeta:GetDonatorByRoleName(visual)
    return DonationRoles.roles[self:GetDonator(visual)] or ""
end