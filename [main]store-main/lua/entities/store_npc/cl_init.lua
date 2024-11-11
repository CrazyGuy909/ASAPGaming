include("shared.lua")

surface.CreateFont("Store.NPC", {
  size = 42,
  font = "Roboto",
})

function ENT:Draw()
  self:DrawModel()

  local ply = LocalPlayer()
  local pos = self:GetPos()
  local eyePos = ply:GetPos()
  local dist = pos:Distance(eyePos)
  local alpha = math.Clamp(900 - dist * 2.7, 0, 235)

  if (alpha <= 0) then return end

  local angle = self:GetAngles()
  local eyeAngle = ply:EyeAngles()

  angle:RotateAroundAxis(angle:Forward(), 90)
  angle:RotateAroundAxis(angle:Right(), - 90)

  cam.Start3D2D(pos + self:GetUp() * 90, Angle(0, eyeAngle.y - 90, 90), 0.12)
    surface.SetFont("Store.NPC")
    local width = surface.GetTextSize("Token store")
    width = width + 32

    local center = 300 / 2
    local x = -width / 2 - 10
    local h = 60

	draw.RoundedBox(6, x, 20, width, h, Color(0, 0, 0, alpha))
    draw.SimpleText("Token store", "Store.NPC", x + width / 2, h / 2 + 20, Color(205, 205, 205, alpha), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)

  cam.End3D2D()
end