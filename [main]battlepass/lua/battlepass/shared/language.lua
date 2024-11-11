BATTLEPASS.Languages = {}
BATTLEPASS.ActiveLanguage = "English"

function BATTLEPASS:SetLanguage(id)
  self.ActiveLanguage = id
end

function BATTLEPASS:AddLanguage(name, tbl)
  self.Languages[name] = tbl
end

function BATTLEPASS:GetTranslation(phrase)
  local active = self.ActiveLanguage
  if (!self.Languages[active]) then return "No " .. active .. " language found" end
  active = self.Languages[active]
  if (!active[phrase]) then return "No " .. phrase .. " phrase found" end

  return active[phrase]
end

BATTLEPASS:SetLanguage("English")
BATTLEPASS:AddLanguage("English", {
  ["Frame_Title"] = "Battle Pass",

  ["Tabs_BattlePass"] = "Battle Pass",
  ["Tabs_Challenges"] = "Challenges",

  ["Pass_Date"] = "Ends at ${date}",
  ["Pass_Info"] = "Contains ",
  ["Pass_Purchase"] = "Purchase - ${price}",
  ["Pass_PurchaseTier"] = "Purchase tier",
  ["Pass_Page"] = "PAGE ${currentPage}/${totalPages}",

  ["Config_Pass_Title"] = "Title",
  ["Config_Pass_EndDate"] = "End date",
  ["Config_Pass_Tiers"] = "Amount of tiers (1-100)",
  ["Config_Pass_PassCurrency"] = "Battle Pass purchase currency",
  ["Config_Pass_PassPrice"] = "Battle Pass price",
  ["Config_Pass_TiersCurrency"] = "Tier purchase currency",
  ["Config_Pass_TiersPrice"] = "Price per tier"
})