


function OnObjectFocusChange(self,obj,isFocus,lastFocusObj,funIsEnable,funcGetFrameRect)
	local attr = self:GetAttribute()
	--关键函数
	local isEnable = true
	if funIsEnable then
		isEnable = funIsEnable(obj)
	end
	
	local aniFactory = XLGetObject("Xunlei.UIEngine.AnimationFactory")
	
	if isFocus and isEnable then
		local left,top,right,bottom
		if funcGetFrameRect then
			nleft,ntop,nright,nbottom = funcGetFrameRect(obj)
			local ileft,itop,iright,ibottom = obj:GetObjPos()
			left,top,right,bottom = obj:GetAbsPos()
			left = left - ileft + nleft
			top = top - itop + ntop
			right = right - iright + nright
			bottom = bottom - ibottom + nbottom
		else
			left,top,right,bottom = obj:GetAbsPos()
		end
				
		local dLeft,dTop,dRight,dBottom
		dLeft,dTop,dRight,dBottom = self:GetAbsPos()		
		dLeft = left - dLeft
		dTop = top - dTop
		dRight = right - dRight
		dBottom = bottom - dBottom
		local myleft,mytop,myright,mybottom = self:GetObjPos()
		
		
		
		if attr.lastObj then
			if attr.alphaChangeAni then
				attr.alphaChangeAni:Stop()
				attr.alphaChangeAni = nil
				self:GetControlObject("frame"):SetAlpha(255)
			end
			local posChangeAni = aniFactory:CreateAnimation("PosChangeAnimation")
			posChangeAni:SetTotalTime(200)
			posChangeAni:BindObj(self)
			posChangeAni:SetKeyFrameRect(myleft,mytop,myright,mybottom,myleft+dLeft,mytop+dTop,myright+dRight,mybottom+dBottom)
			self:GetOwner():AddAnimation(posChangeAni)
			posChangeAni:Resume()
			
			self:SetVisible(true)
			self:SetChildrenVisible(true)
			
			local alphaChangeAni = aniFactory:CreateAnimation("AlphaChangeAnimation")
			alphaChangeAni:SetTotalTime(6000)
			alphaChangeAni:BindObj(self:GetControlObject("frame"))
			alphaChangeAni:BindCurveID("curve.breath")
			alphaChangeAni:SetKeyFrameAlpha(10,255)
			self:GetOwner():AddAnimation(alphaChangeAni)
			alphaChangeAni:Resume()
			
			attr.alphaChangeAni = alphaChangeAni
			attr.lastObj = nil
			attr.nowObj = obj
		else
			--让Frame出现，并开始闪烁
			self:SetObjPos(myleft+dLeft,mytop+dTop,myright+dRight,mybottom+dBottom)
			self:SetVisible(true)
			self:SetChildrenVisible(true)	
			self:GetControlObject("frame"):SetAlpha(10)   
			
			local alphaChangeAni = aniFactory:CreateAnimation("AlphaChangeAnimation")
			alphaChangeAni:SetTotalTime(6000)
			alphaChangeAni:BindObj(self:GetControlObject("frame"))
			alphaChangeAni:BindCurveID("curve.breath")
			alphaChangeAni:SetKeyFrameAlpha(10,255)
			self:GetOwner():AddAnimation(alphaChangeAni)
			alphaChangeAni:Resume()
			attr.alphaChangeAni = alphaChangeAni
			attr.lastObj = nil
			attr.nowObj = obj
		end
	else
		attr.lastObj = attr.nowObj
		attr.nowObj = nil
		
		AsynCall(function (x) 
					if attr.lastObj then
						attr.lastObj = nil
						local alphaChangeAni = aniFactory:CreateAnimation("AlphaChangeAnimation")
						alphaChangeAni:SetTotalTime(200)
						alphaChangeAni:BindObj(self:GetControlObject("frame"))
						alphaChangeAni:SetKeyFrameAlpha(255,0)
						if self.GetOwner ~= nil then
							local owner = self:GetOwner()
							if owner ~= nil and owner.AddAnimation ~= nil then
								owner:AddAnimation(alphaChangeAni)
								alphaChangeAni:Resume()
								alphaChangeAni:AttachListener(true,function(old,new)
									if new == 4 then
										self:SetVisible(false)
										self:SetChildrenVisible(false)
									end
								end)
							end
						end
					end
				end)
	end
end

function RegsiterObject(self,obj,funIsEnable,funcGetFrameRect,eventtable)
	if obj == nil then
		return
	end
	
	local attr = self:GetAttribute()
	if attr.AllObjects == nil then
		attr.AllObjects = {}
	end
	
	if attr.AllObjects then
		local cookie1,cookie2
		if attr.AllObjects[obj] == nil then
			local node = {}
			node["GetFrameRect"] = funcGetFrameRect
			node["IsEnable"] = funIsEnable
			node["cookie1"] = cookie1
			node["cookie2"] = cookie2
			attr.AllObjects[obj] = node
			cookie1 = obj:AttachListener ("OnControlFocusChange",true,function (focusObj,isFocus,lastFocusObj)
				OnObjectFocusChange(self,focusObj,isFocus,lastFocusObj,funIsEnable,funcGetFrameRect)
			end)
			
			cookie2 = obj:AttachListener ("OnDestroy",true,function (destroyObj)
				attr.AllObjects[destroyObj] = nil
			end)
			
			if eventtable then
				local allcookies = {}
				node["extcookies"] = allcookies
				for i=1,table.getn(eventtable) do
					local eventName = eventtable[i]
					allcookies[eventName] = obj:AttachListener(eventName,true,function (sender)
						local isEnableFrame = true

						if funIsEnable then
							isEnableFrame = funIsEnable(sender)
						end
						
						attr.lastObj = sender
						OnObjectFocusChange(self,sender,isEnableFrame,nil,funIsEnable,funcGetFrameRect)
					end)
				end
			end
		end
	end
end

function UnRegisterObject(self,obj)
	if obj == nil then
		return false
	end
	
	local attr = self:GetAttribute()
	local tab = attr.AllObjects[obj]
	if tab then
		obj:RemoveListener("OnFocusChange",tab["cookie1"])
		obj:RemoveListener("OnDestroy",tab["cookie2"])
		eventtable =  tab["extcookies"]
		if eventtable then
			for k,v in pairs(eventtable) do
				obj:RemoveListener(k,v)
			end
		end
		attr.AllObjects[obj] = nil
		return true
	end
	
	return false
end

function OnInitControl(self)
	local attr = self:GetAttribute()
	attr.AllObjects = {}
	attr.lastObj = nil
	self:SetVisible(false)
	self:SetChildrenVisible(false)
end

function CleanAllObject(self)
	local attr = self:GetAttribute()
	
	for k,v in pairs(attr.AllObjects) do
		k:RemoveListener("OnFocusChange",v["cookie1"])
		k:RemoveListener("OnDestroy",v["cookie2"])
	end
	
	attr.AllObjects = {}
end