function CreateGravity(x,y,mass)
	local gravity = {}
	gravity.G = 0.03
	gravity.position = {["x"] = x,["y"] = y}
	gravity.mass = mass
	
	gravity.SetEnv = function(gravity, env)
		gravity.env = env
	end
	gravity.SetPosition = function(gravity, x,y)
		gravity.position = {["x"] = x,["y"] = y}
	end
	gravity.SetMass = function(gravity, mass)
		gravity.mass = mass
	end
	gravity.GetForceOn = function(gravity, x,y, particle) 
		local disx = gravity.position.x - x
		local disy = gravity.position.y - y
		local sqdis = math.pow(disx, 2) + math.pow(disy, 2)
		local dis = math.sqrt(sqdis)
		local force = gravity.G * particle:GetMass() * gravity.mass / sqdis
		
		
		return force * disx / dis, force * disy / dis
	end
	
	return gravity
end


---
local particle_math = {}
---ret 1: out   0: in  2: on
particle_math.InRect = function(pos, rect)
	local min_x = rect.l
	local max_x = rect.r
	local min_y = rect.t
	local max_y = rect.b
	
	if pos.x > max_x or pos.x < min_x or pos.y > max_y or pos.y < min_y then
		return 1
	elseif pos.x < max_x and pos.x > min_x and pos.y < max_y and pos.y > min_y then
		return 0
	else
		return 2
	end
end

particle_math.GetRectCrossPoint = function(pos_in, pos_out, rect)
	local deltax = pos_out.x - pos_in.x
	local deltay = pos_out.y - pos_in.y
	
	--XLPrint("[tsukasa] get cross point on "..pos_in.x.." "..pos_in.y.." "..pos_out.x.." "..pos_out.y.."\r\n")
	if deltax == 0 then
		if pos_in.y < pos_out.y then
			return pos_in.x, rect.b
		else
			return pos_in.x, rect.t
		end
	else
		local lk = deltay / deltax
		local lb = pos_in.y - pos_in.x * lk
		local ly = lk * rect.l + lb
		local ry = lk * rect.r + lb 
		local tx = (rect.t - lb) / lk
		local bx = (rect.t - lb) / lk
			
		local temp1x = 999999
		local temp1y = 0
		local temp2x = -999999
		local temp2y = 0
		local ifcross = false
		function addCross(a,b,c,d,e)
			if e >= c and e <= d then
				if a < temp1x then
					temp1x = a
					temp1y = b
				end
				if a > temp2x then
					temp2x = a
					temp2y = b
				end
				ifcross = true
			end
		end
			
		
		addCross(rect.l,ly,rect.t,rect.b,ly) 
		addCross(rect.r,ry,rect.t,rect.b,ry)
		addCross(tx,rect.t,rect.l,rect.r,tx) 
		addCross(bx,rect.b,rect.l,rect.r,bx) 
		if ifcross then
			if pos_in.x > pos_out.x then
				return temp1x,temp1y
			elseif pos_in.x < pos_out.x then
				return temp2x,temp2y
			else
				return pos_in.x, temp1y
			end
		else
			return nil
		end
	end
end








---


function CreateCube()
	local cube = {}
	cube.SetEnv = function(cube, env)
		cube.env = env
	end
	----设置保证l<r
	cube.SetPosition = function(cube , l,t,r,b)
		cube.position = {["l"]=l,["t"]=t,["r"]=r,["b"]=b}
		cube:MoveGravity()
	end
	
	cube.gravity = nil
	
	cube.MoveGravity = function(cube)
		if cube.gravity then
			cube.gravity:SetPosition(cube.position.l + (cube.position.r - cube.position.l) / 2,
				cube.position.t + (cube.position.b - cube.position.t) / 2)
		end
	end
	
	cube.SetMass = function(cube, mass)
		if mass == 0 then
			cube.gravity = nil
		else
			cube.gravity = CreateGravity()
			cube.gravity:SetMass(mass)
			cube:MoveGravity()
		end
	end

	cube.GetForceOn = function(cube, x,y,particle) 
		if cube.gravity then
			return cube.gravity:GetForceOn(x,y,particle)
		end
		return 0, 0
	end
	
	
	---0 到 1 的浮点数， 决定解除到边界的particle以多少速度反弹出去----
	cube.SetElasticity = function(cube, elasticity)
		cube.elasticity = elasticity
	end
	
	----基于框架的实现优化先不管了~ 这里很多重复计算的地方
	cube.ModifyPosition = function(cube, particle) 
		local crossx , crossy = particle_math.GetRectCrossPoint(particle:GetDuePosition(), particle:GetPosition(), cube.position)
		--XLPrint("[tsukasa] modify pos to "..crossx.." "..crossy.."\r\n")
		return crossx, crossy
	end
	---有一帧的误差， 把下一帧的速度判定到这里实现了，低速不会有问题~
	cube.GetForceOnSurface = function(cube, particle)
		local pos = particle:GetPosition()
		local spd = particle:GetSpeed()
		local mass = particle:GetMass()
		--XLPrint("[tsukasa]get force on surface on "..pos.x.." "..pos.y.."\r\n")
		--XLPrint("[tsukasa]spd is "..spd.x.." "..spd.y.."\r\n")
		local dtime = cube.env:GetAttribute().Frame
		if (pos.x == cube.position.l and spd.x > 0) or 
			(pos.x == cube.position.r and spd.x < 0) or 
			(pos.y == cube.position.t and spd.y > 0) or 
			(pos.y == cube.position.b and spd.y < 0)then
				return - spd.x * (cube.elasticity + 1) * mass / dtime, - spd.y * (cube.elasticity + 1) * mass / dtime
		else
			return 0,0
		end
	end
	
	cube.OnSurface = function(cube, pos) 
		if 1 == particle_math.InRect(pos, cube.position) then
			return false
		else
			return true
		end
	end
	
	cube.GetSurface = function(cube, particle)
		local cur_in = particle_math.InRect(particle:GetPosition(), cube.position)
		local due_in = particle_math.InRect(particle:GetDuePosition(), cube.position)
		
		if cur_in ~= 0 and due_in ~= 1 then
			--XLPrint("[tsukasa] get surface ")
			return cube
		end
		---这里有可能完全穿越~~ 保证速度不要那么高~~
		return nil
	end

	
	return cube
end


function CreateWind(windleft,windtop,windright,windbottom,windspeedx,windspeedy)

	local wind = {}
	wind.left = windleft
	wind.top = windtop
	wind.right = windright
	wind.bottom = windbottom
	wind.speedx = windspeedx
	wind.speedy = windspeedy
	wind.SetEnv = function(thewind, env)
		thewind.env = env
	end
	wind.GetForceOn = function(thewind, x,y, particle) 
		if x>thewind.left and x <thewind.right and y>thewind.top and y<thewind.bottom then
			return thewind.speedx,thewind.speedy
		end
		return 0,0
	end
	
	return wind
end

function RegisterObject()
	local elements = {}
	elements.CreateGravity = CreateGravity
	elements.CreateCube = CreateCube
	elements.CreateWind = CreateWind
	XLSetGlobal("WHome.Particle.Elements", elements)
end