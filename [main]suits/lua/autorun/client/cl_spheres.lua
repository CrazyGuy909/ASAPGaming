local color_mask2 = Color(0, 0, 0, 0)

local function drawStencilSphere(pos, ref, compare_func, radius, color, detail)
    render.SetStencilReferenceValue(ref)
    render.SetStencilCompareFunction(compare_func)
    render.DrawSphere(pos, radius, detail, detail, color)
end

function render.StartWorldRings()
    render.WORLD_RINGS = {}
    cam.IgnoreZ(false)
    render.SetStencilEnable(true)
    render.SetStencilTestMask(255)
    render.SetStencilWriteMask(255)
    render.ClearStencil()
    render.SetColorMaterial()
end

function render.AddWorldRing(pos, radius, thicc, detail)
    detail = detail or 25
    thicc = thicc or 10

    local z = {
        detail = detail,
        thicc = thicc,
        pos = pos,
        outer_r = radius,
        inner_r = math.max(radius - thicc, 0)
    }

    table.insert(render.WORLD_RINGS, z)
end

function render.FinishWorldRings(color)
    local ply = LocalPlayer()
    local zones = render.WORLD_RINGS
    render.SetStencilZFailOperation(STENCILOPERATION_REPLACE)

    for i, zone in ipairs(zones) do
        local outer_r = zone.radius
        drawStencilSphere(zone.pos, 1, STENCILCOMPARISONFUNCTION_ALWAYS, -zone.outer_r, color_mask2, zone.detail) -- big, inside-out
    end

    render.SetStencilZFailOperation(STENCILOPERATION_DECR)

    for i, zone in ipairs(zones) do
        local outer_r = zone.radius
        drawStencilSphere(zone.pos, 1, STENCILCOMPARISONFUNCTION_ALWAYS, zone.outer_r, color_mask2, zone.detail) -- big
    end

    render.SetStencilZFailOperation(STENCILOPERATION_INCR)

    for i, zone in ipairs(zones) do
        drawStencilSphere(zone.pos, 1, STENCILCOMPARISONFUNCTION_ALWAYS, -zone.inner_r, color_mask2, zone.detail) -- small, inside-out
    end

    render.SetStencilZFailOperation(STENCILOPERATION_DECR)

    for i, zone in ipairs(zones) do
        drawStencilSphere(zone.pos, 1, STENCILCOMPARISONFUNCTION_ALWAYS, zone.inner_r, color_mask2, zone.detail) -- small
    end

    render.SetStencilCompareFunction(STENCILCOMPARISONFUNCTION_EQUAL)
    local cam_pos = EyePos()
    local cam_angle = EyeAngles()
    local cam_normal = cam_angle:Forward()
    cam.IgnoreZ(true)
    render.SetStencilReferenceValue(1)
    render.DrawQuadEasy(cam_pos + cam_normal * 10, -cam_normal, 10000, 10000, color, cam_angle.roll)
    cam.IgnoreZ(false)
    render.SetStencilEnable(false)
end