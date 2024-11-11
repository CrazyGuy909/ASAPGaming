-- Easing function, http://www.timotheegroleau.com/Flash/experiments/easing_function_generator.htm

function BATTLEPASS:Ease(t, b, c, d)
  t = t / d
  local ts = t * t
  local tc = ts * t
  return b + c * (ts)
end

function BATTLEPASS:SizeTo(panel, width, height, duration, callback)
  local anim = panel:NewAnimation(duration)
  anim.Size = { width, height }
  anim.Think = function(anim, panel, fraction)
    local fract = self:Ease(fraction, 0, 1, 1)

    if not anim.StartSize then
      anim.StartSize = { panel:GetWide(), panel:GetTall() }
    end

    local width = Lerp(fract, anim.StartSize[1], anim.Size[1])
    local height = Lerp(fract, anim.StartSize[2], anim.Size[2])

    panel:SetSize(width, height)
  end
  anim.OnEnd = function()
    if not callback then return end

    callback()
  end
end

function BATTLEPASS:MoveTo(panel, x, y, duration, callback)
  local anim = panel:NewAnimation(duration)
  anim.Pos = { x, y }
  anim.Think = function(anim, panel, fraction)
    local fract = self:Ease(fraction, 0, 1, 1)

    if not anim.StartPos then
      anim.StartPos = { panel.x, panel.y }
    end

    local x = Lerp(fract, anim.StartPos[1], anim.Pos[1])
    local y = Lerp(fract, anim.StartPos[2], anim.Pos[2])

    panel:SetPos(x, y)
  end
  anim.OnEnd = function()
    if not callback then return end

    callback()
  end
end
