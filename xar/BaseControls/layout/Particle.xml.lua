function Updater_Init(updater)
end



function Updater_Uninit(updater)
end


function Updater_Bind(updater, env)
	local attr = updater:GetAttribute()
	attr.env = env
end

function Updater_Action(updater)
	local attr = updater:GetAttribute()
	attr.env:Update()
end

function Particle_OnInitControl(particle)
	local graphic = XLGetObject("Xunlei.XLGraphic.Factory.Object")
	local xar = XLGetObject("Xunlei.UIEngine.XARManager")
	local obj_factory = XLGetObject("Xunlei.UIEngine.ObjectFactory")
	local attr = particle:GetAttribute()
	
	local l,t,r,b = particle:GetObjPos()
	--XLMessageBox("OnInitContrl with "..l.." "..t.." "..r.." "..b)
	
	attr.centre = {}
	attr.centre.x = (r - l) / 2
	attr.centre.y = (b - t) / 2
	attr.position = {["x"]=l+attr.centre.x,["y"]=t+attr.centre.y}
	attr.due_position = {["x"]=attr.position.x,["y"]=attr.position.y}
	
	
	local flash_obj = particle:GetObject("flash")
	flash_obj:SetFillType("Circle")
	flash_obj:SetBlendType("Source")
	flash_obj:SetSrcPt(math.floor(attr.centre.x),math.floor(attr.centre.y))
	flash_obj:SetObjPos(0,0,r - l,b - t)
	flash_obj:SetZorder(-99)
	flash_obj:SetAlpha(0)
	
	if not attr.light_color then
		attr.light_color = xar:GetColor(attr.LightColorId)
	end
	local r,g,b,a = attr.light_color:GetRGBAValues()
	local light_att_color = graphic:CreateColor(b,g,r,0)
	flash_obj:SetSrcColor(attr.light_color)
	flash_obj:SetDestColor(light_att_color)
	
	

	local star_obj = particle:GetObject("star")
	local star_img = xar:GetBitmap(attr.StarImage)
	star_obj:SetBitmap(star_img)
	local ct,w,h = star_img:GetInfo()
	star_obj:SetZorder(-98)
	star_obj:SetObjPos(attr.centre.x - w / 2,attr.centre.y - h / 2,attr.centre.x + w / 2,attr.centre.y + h / 2)
	
	attr.cur_time = 0
	
	attr.brownian_func = 
		function(dtime)
			if attr.IfBrownian then
				local BrownianIntensity = attr.BrownianIntensity
				local speed_x = math.random(0, 2 * BrownianIntensity) - BrownianIntensity
				local speed_y = math.random(0, 2 * BrownianIntensity) - BrownianIntensity
				return speed_x, speed_y
			end
			return 0, 0
		end
	
	attr.flash_radii = 0
	attr.flash_func = 
		function(dtime)
			if attr.IfFlash then
				attr.flash_radii = attr.FlashMinRadii + (attr.FlashMaxRadii - attr.FlashMinRadii) * math.abs(math.sin(-2 * math.pi * (attr.cur_time / attr.FlashCyc + attr.FlashOffset)))
			end
		end
	
	if not attr.cur_speed then
		attr.cur_speed = {["x"]=attr.SpeedX, ["y"]=attr.SpeedY}
	end
	attr.cur_force = {["x"]=0, ["y"]=0}
	
	attr.move_func = 
		function(dtime)
			attr.cur_force.x, attr.cur_force.y = attr.env:GetForceOn(attr.position.x, attr.position.y, particle) 
			local acc_x = attr.cur_force.x / attr.Mass
			local acc_y = attr.cur_force.y / attr.Mass
			
			attr.cur_speed.x = attr.cur_speed.x + acc_x * dtime
			attr.cur_speed.y = attr.cur_speed.y + acc_y * dtime
			--local spd_brow_x, spd_brow_y = attr.brownian_func()
			local spd_brow_x, spd_brow_y = 0, 0
			local spd_x = attr.cur_speed.x + spd_brow_x
			local spd_y = attr.cur_speed.y + spd_brow_y
			
			attr.due_position.x = spd_x * dtime + attr.position.x
			attr.due_position.y = spd_y * dtime + attr.position.y
			local surface = attr.env:GetSurface(particle)
			if surface then
				attr.position.x, attr.position.y = surface:ModifyPosition(particle)
				force_x, force_y = surface:GetForceOnSurface(particle)
				--XLPrint("[tsukasa]get force on surface is "..force_x.." "..force_y.."\r\n")
				acc_x = force_x / attr.Mass
				acc_y = force_y / attr.Mass
				attr.cur_speed.x = attr.cur_speed.x + acc_x * dtime
				attr.cur_speed.y = attr.cur_speed.y + acc_y * dtime
				--XLPrint("[tsukasa] set cur spd to "..attr.cur_speed.x.." "..attr.cur_speed.y.."\r\n")
				attr.position.x = attr.position.x + attr.cur_speed.x * dtime
				attr.position.y = attr.position.y + attr.cur_speed.y * dtime
			else
				attr.position.x = attr.due_position.x
				attr.position.y = attr.due_position.y
			end
			
			local x = math.floor(attr.position.x - attr.centre.x)
			local y = math.floor(attr.position.y - attr.centre.y)
			
			particle:SetObjPos(x,y,x + r - l,y + b - t)
		end
		
	
	attr.cur_alpha = 0
	attr.grow_time = attr.GrowTime * attr.LifeTime
	attr.af_grow_time = attr.LifeTime - attr.grow_time
	attr.alpha_func = 
		function(dtime)
			if attr.cur_time < attr.grow_time then
				attr.cur_alpha = attr.Intensity * attr.cur_time / attr.grow_time
			else
				attr.cur_alpha = attr.Intensity - attr.Intensity * (attr.cur_time - attr.grow_time) / attr.af_grow_time
			end
		end
	
	star_obj:AttachListener("OnDestroy", true, function() 
		attr.particle_destroyed = true
	end)
	
	star_obj:SetVisible(false)
	
	AsynCall(function()
		star_obj:SetVisible(true)
		if attr.IfRotate and not attr.particle_destroyed then
			local rotate_ani = XLGetObject("Xunlei.UIEngine.AnimationFactory"):CreateAnimation("AngleChangeAnimation")
			rotate_ani:SetKeyFrameAngle(0,0,0,0,0,-360 * 9999999)
			rotate_ani:SetKeyFrameRange(attr.RotateRate,attr.RotateRate,attr.RotateRate,
			attr.RotateRate,attr.RotateRate,attr.RotateRate)
			rotate_ani:SetTotalTime(attr.RotateCyc * 9999999)
			rotate_ani:BindObj(star_obj)
			rotate_ani:SetCentrePointMode("WidthHeightRate")
			rotate_ani:SetCentrePoint(50,50)
			star_obj:GetOwner():AddAnimation(rotate_ani)
			rotate_ani:Resume()
			
			attr.rotate_ani = rotate_ani
		end
	end)
end

function Particle_SetEnv(particle, env)
	particle:GetAttribute().env = env
end

function Particle_GetMass(particle)
	return particle:GetAttribute().Mass
end

function Particle_GetPosition(particle)
	return particle:GetAttribute().position
end


function Particle_SetColor(particle, color)
	if type(color) == "string" then
		particle:GetAttribute().light_color = XLGetObject("Xunlei.UIEngine.XARManager"):GetColor(color)
	else
		particle:GetAttribute().light_color = color
	end
end

function Particle_SetSpeed(particle, speed_x, speed_y)
	particle:GetAttribute().cur_speed = {["x"]=speed_x , ["y"]=speed_y}
end

function Particle_GetForce(particle)
	return particle:GetAttribute().cur_force
end

function Particle_GetSpeed(particle)
	return particle:GetAttribute().cur_speed
end

function Particle_GetDuePosition(particle)
	return particle:GetAttribute().due_position
end

function Particle_Update(particle, dtime)
	local attr = particle:GetAttribute()
	if not attr.removed then
		attr.cur_time = attr.cur_time + dtime
		if attr.cur_time >= attr.LifeTime then
			if attr.rotate_ani then
				attr.rotate_ani:ForceStop()
			end
			AsynCall(function() 
				if particle:GetClass() then
					particle:GetFather():RemoveChild(particle) 
				end
			end)
			attr.removed = true
		else
			attr.flash_func(dtime)
			attr.move_func(dtime)
			attr.alpha_func(dtime)
		end
	end
end

function Particle_Blend(particle)
	local flash_obj = particle:GetObject("flash")
	local attr = particle:GetAttribute()
	flash_obj:SetDestPt(math.floor(attr.centre.x + attr.flash_radii),math.floor(attr.centre.y + attr.flash_radii))
	local x = math.floor(attr.position.x - attr.centre.x)
	local y = math.floor(attr.position.y - attr.centre.y)
	local l,t,r,b = particle:GetObjPos()
	particle:SetObjPos(x,y,x + r - l,y + b - t)
	local star_obj = particle:GetObject("star")
	star_obj:SetAlpha(attr.cur_alpha)
	flash_obj:SetAlpha(attr.cur_alpha)
end
	

function Env_OnInitControl(env)
	local attr = env:GetAttribute()
	attr.elements = {}
	
	local updater = XLGetObject("Xunlei.UIEngine.AnimationFactory"):CreateAnimation("WHome.Particle.Updater")
	updater:Bind(env)
	updater:SetTotalTime(999999999)
	env:GetOwner():AddAnimation(updater)
	updater:Resume()
	
	attr.updater = updater
	attr.update_count = math.floor(30 / attr.Frame)
	--XLPrint("[tsukasa] update count is "..attr.update_count.."\r\n")
end


function Env_Update(env)
	local container = env:GetObject("container")
	local attr = env:GetAttribute()
	for i=0,container:GetChildCount() - 1 do
		local particle = container:GetChildByIndex(i)
		for j=1,attr.update_count do
			particle:Update(attr.Frame)
		end
		
		particle:Blend()
	end
end

function Env_AddElement(env, env_element)
	table.insert(env:GetAttribute().elements, env_element)
	env_element:SetEnv(env)
end

function Env_GetForceOn(env, x, y, particle)
	local force_x = 0
	local force_y = 0
	local elements = env:GetAttribute().elements
	for i=1, #elements do
		local element_force_x, element_force_y = elements[i]:GetForceOn(x,y,particle)
		force_x = force_x + element_force_x
		force_y = force_y + element_force_y
	end
	return force_x, force_y
end	

function Env_GetSurface(env, particle)
	local elements = env:GetAttribute().elements
	for i=1, #elements do
		if elements[i].GetSurface then
			local surface = elements[i]:GetSurface(particle)
			if surface then
				return surface
			end
		end
	end
	return nil
end

local function Env_OnSurface(env, x,y)
	local elements = env:GetAttribute().elements
	for i=1,#elements do
		if elements[i].OnSurface then
			if elements[i]:OnSurface(x, y) then
				return true
			end
		end
	end
	return false
end

function Env_AddParticle(env, particle,x,y)
	particle:SetEnv(env)
	particle:SetObjPos(x-50,y-50,x+50,y+50)
	--[[
	if Env_OnSurface(env,x,y) then
		return false
	end
	]]--
	particle:SetZorder(math.random(500, 50000))
	env:GetObject("container"):AddChild(particle)
	return true
end

function Env_GetRandomTable(env)
	if env:GetAttribute().random_tbl then
		return env:GetAttribute().random_tbl
	else
		local l,t,r,b = env:GetObjPos()
		env:GetAttribute().random_tbl = {
			["x"]={0,r-l},
			["y"]={0,b-t},
			["LifeTime"]={1000,30000},
			["Intensity"]={100,235},
			["GrowTime"]={0,0.2},
			["RotateCyc"]={1000,10000},
			["RotateOffset"]={0,1},
			["RotateRate"]={0,1},
			["FlashMinRadii"]={0,20},
			["FlashMaxRadii"]={20,40},
			["FlashCyc"]={1000,10000},
			["FlashOffset"]={0,1},
			["Mass"]={0,5},
			["SpeedX"]={-0.2,0.2},
			["SpeedY"]={-0.2,0.2}
		}
		return env:GetAttribute().random_tbl
	end
end

function Env_RandomParticle(env, tbl, times)
	for i=1,times do
		local particle = XLGetObject("Xunlei.UIEngine.ObjectFactory"):CreateUIObject("", "WHome.Particle")
		local particle_attr = particle:GetAttribute()
		local x, y = 0
		for k,v in pairs(tbl) do
			if k == "x" then
				x = math.random(v[1], v[2])
			elseif k == "y" then
				y = math.random(v[1], v[2])
			else
				particle_attr[k] = v[1] + (v[2] - v[1]) * math.random()
			end
		end
		env:AddParticle(particle,x,y)
	end
end

function Env_OnDestroy(env)
	env:GetAttribute().updater:Stop()
end