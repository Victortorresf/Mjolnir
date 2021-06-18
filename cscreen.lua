local CScreen = {}
local rx, ry, ctr = 800, 600, true
local rxv, ryv, fsv, fsvr = 800, 600, 1.0, 1.0
local tx, ty, rwf, rhf = 0, 0, 800, 600
local cr, cg, cb, ca = 0, 0, 0, 255

-- Initializes CScreen with the initial size values
function CScreen.init(tw, th, cntr)
	rx = tw or 800
	ry = th or 600
	ctr = cntr or false
	CScreen.update(love.graphics.getWidth(), love.graphics.getHeight())
end

-- Draws letterbox borders
function CScreen.cease()
	if ctr then
		local pr, pg, pb, pa = love.graphics.getColor()
		love.graphics.setColor(cr, cg, cb, ca)
		love.graphics.scale(fsvr, fsvr)

		if tx ~= 0 then
			love.graphics.rectangle("fill", -tx, 0, tx, rhf)
			love.graphics.rectangle("fill", rxv, 0, tx, rhf)
		elseif ty ~= 0 then
			love.graphics.rectangle("fill", 0, -ty, rwf, ty)
			love.graphics.rectangle("fill", 0, ryv, rwf, ty)
		end

		love.graphics.setColor(pr, pg, pb, pa)
	end
end

-- Scales and centers all graphics properly
function CScreen.apply()
	if ctr then
		love.graphics.translate(tx, ty)
	end
	love.graphics.scale(fsv, fsv)
end

-- Updates CScreen when the window size changes
function CScreen.update(w, h)
	local sx = w / rx
	local sy = h / ry
	fsv = math.min(sx, sy)
	fsvr = 1 / fsv
	-- Centering
	if ctr and fsv == sx then -- Vertically
		tx = 0
		ty = (h / 2) - (ry * fsv / 2)
	elseif ctr and fsv == sy then -- Horizontally
		ty = 0
		tx = (w / 2) - (rx * fsv / 2)
	end
	-- Variable sets
	rwf = w
	rhf = h
	rxv = rx * fsv
	ryv = ry * fsv
end

-- Convert from window coordinates to target coordinates
function CScreen.project(x, y)
	return math.floor((x - tx) / fsv), math.floor((y - ty) / fsv)
end

-- Change letterbox color
function CScreen.setColor(r, g, b, a)
	cr = r
	cg = g
	cb = b
	ca = a
end

-- Return the table for use
return CScreen