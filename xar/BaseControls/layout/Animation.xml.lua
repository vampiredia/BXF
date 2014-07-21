function OldTVAnimation_Action(self)
	local attr = self:GetAttribute()
	local curve = self:GetCurve()
	local totalTime = self:GetTotalTime()
	local runningTime = self:GetRuningTime()
	
	local percent
	local showlightTime = totalTime*0.5
	local progress = curve:GetProgress(runningTime / (totalTime))
	local left,right,top,bottom
	local smallProgress = 0.0
	local lightHight = 56	
	if runningTime > totalTime-showlightTime then
		percent = (runningTime - (totalTime-showlightTime)) / showlightTime
		local w,h = attr.right - attr.left , attr.bottom - attr.top
		
		local lightTop = attr.top+(h-lightHight)/2
		
		if attr.lightObj == nil then

			--create light
			local objFactory = XLGetObject("Xunlei.UIEngine.ObjectFactory")
			attr.lightObj = objFactory:CreateUIObject("","ImageObject")
			attr.lightObj:SetResID("animation.close.light")
			attr.lightObj:SetObjPos(attr.left,lightTop,attr.right,lightTop+lightHight)
			attr.lightObj:SetZorder(5)
			attr.lightObj:SetDrawMode(1)
			attr.imageObj:GetFather():AddChild(attr.lightObj)
			
			--create centerlight
			attr.centerLightObj = objFactory:CreateUIObject("","ImageObject")
			attr.centerLightObj:SetResID("animation.close.centerlight")
			attr.centerLightObj:SetObjPos(attr.left+(w-80)/2,attr.top+(h-56)/2,attr.right+(w-80)/2+80,attr.bottom+(h-56)/2+56)
			attr.centerLightObj:SetZorder(6)
			attr.imageObj:GetFather():AddChild(attr.centerLightObj)
		end
		
		smallProgress = percent
		attr.lightObj:SetObjPos(attr.left+(w/2)*smallProgress,lightTop,attr.right-(w/2)*smallProgress,lightTop+lightHight)
		attr.centerLightObj:SetAlpha(255-255*smallProgress)
	end
	
	local alpha = 255 - 255*(runningTime / totalTime)
	attr.imageObj:SetAlpha(alpha)
	top = attr.top - attr.ChangeY * progress
	bottom = attr.bottom + attr.ChangeY* progress
	local nowH = bottom - top
	if nowH <= lightHight then
		left = attr.left - attr.ChangeX * ((lightHight - nowH)/lightHight)
		right = attr.right + attr.ChangeX * ((lightHight - nowH)/lightHight)
		if attr.imageObj:GetAlpha() > 15 then
			attr.imageObj:SetAlpha(15)
		end
	else
		left = attr.left
		right = attr.right
	end

	attr.imageObj:SetObjPos(left,top,right,bottom)


	return true
end

function OldTVAnimation_BindObj(self,obj)
	local attr = self:GetAttribute()
	if attr and obj then
		attr.BindObj = obj
		
		attr.left,attr.top,attr.right,attr.bottom = obj:GetObjPos()
		local w,h = attr.right - attr.left , attr.bottom - attr.top
		local xlgraphic = XLGetObject("Xunlei.XLGraphic.Factory.Object")
		local theBitmap = xlgraphic:CreateBitmap("ARGB32",w,h)
		local render = XLGetObject("Xunlei.UIEngine.RenderFactory")
		render:RenderObject(obj,theBitmap)
		
		local objFactory = XLGetObject("Xunlei.UIEngine.ObjectFactory")
		local newImageObject = objFactory:CreateUIObject("","ImageObject")
		newImageObject:SetBitmap(theBitmap)
		newImageObject:SetDrawMode(1)
		obj:GetFather():AddChild(newImageObject)
		
		attr.imageObj = newImageObject
		obj:SetVisible(false)
		obj:SetChildrenVisible(false)
		
		local function OnAniFinish(aniself,old,new)
			if new == 4 then
				newImageObject:GetFather():RemoveChild(newImageObject)
				if attr.lightObj then
					attr.lightObj:GetFather():RemoveChild(attr.lightObj)
				end
				
				if attr.centerLightObj then
					attr.centerLightObj:GetFather():RemoveChild(attr.centerLightObj)
				end
				
				obj:SetVisible(true)
				obj:SetChildrenVisible(true)
			end
		end
		self:AttachListener(true,OnAniFinish)
	end
end

function OldTVAnimation_GetBindObj(self)
	local attr = self:GetAttribute()
	return attr.BindObj
end



function ProgressParticle_Action(ppa)	
	local attr = ppa:GetAttribute()
	attr.cur_count = attr.cur_count + attr.Frequency
	local create_count = 0
	if attr.cur_count > 1 then
		create_count = math.floor(attr.cur_count)
		attr.cur_count = attr.cur_count - create_count
	end
	local cur_progress = attr.bind_progress:GetProgress()
	local l,t,r,b = attr.bind_progress:GetObjPos()
	if cur_progress > 30  then
		local cpos = (r - l) * cur_progress / 100
		local rtbl = attr.particle_env:GetRandomTable()
		rtbl.x = {0,cpos / 5}
		if create_count ~= 0 then
			attr.particle_env:RandomParticle(rtbl, create_count)
		end
		
		attr.particle_cube:SetPosition(cpos - 5,-2,cpos + 5, (b - t) + 2)
	end
end


function ProgressParticle_BindObj(ppa,progress)
	local attr = ppa:GetAttribute()
	ppa:SetTotalTime(99999999)
	attr.particle_env = XLGetObject("Xunlei.UIEngine.ObjectFactory"):CreateUIObject("", "WHome.Particle.Env")
	attr.particle_env:SetObjPos("0","0","father.width", "father.height")
	progress:AddChild(attr.particle_env)
	local function onProgressPos()
		local l,t,r,b = progress:GetObjPos()
		local rtbl = attr.particle_env:GetRandomTable()
		
		rtbl.x = {0,20}
		rtbl.y = {0,b-t}
		rtbl.SpeedX={0.06,0.09}
		rtbl.SpeedY={-0.007,0.007}
		rtbl.FlashMinRadii={2,4}
		rtbl.FlashMaxRadii={5,8}
		rtbl.RotateRate={0,0.3}
		rtbl.LifeTime={1000,10000}
		rtbl.GrowTime={0.2,0.25}
	end
	
	onProgressPos()
	--progress:AttachListener("OnPosChange", true, onProgressPos)
	progress:AttachListener("OnDestroy",true, function() ppa:Stop() end)
	attr.bind_progress = progress
	
	attr.particle_cube = XLGetGlobal("WHome.Particle.Elements"):CreateCube()
	attr.particle_cube:SetPosition(0,0,1,1)
	attr.particle_cube:SetMass(1)
	attr.particle_cube:SetElasticity(0.6)
	attr.particle_env:AddElement(attr.particle_cube)
	
	attr.cur_count = 0
end


function ProgressParticle_GetBindObj(ppa)
	return ppa:GetAttribute().bind_progress
end