function OnHitTest(self)
	--return true,true,0
	return 0,true,true
end


function SetNoneStatus(self, visible)
	local noneStatus = self:GetControlObject("dragitem.status")
	noneStatus:SetVisible(visible)
	if visible then
		local tip = self:GetControlObject("dragitem.tip")
		tip:SetVisible(false)
		tip:SetChildrenVisible(false)
	end
end

function IsIconVisible(self, visible)
	local icon = self:GetControlObject("dragitem.icon")
	return icon:GetVisible()
end

function ShowIcon(self)
	local icon = self:GetControlObject("dragitem.icon")
	icon:SetVisible(true)
end

function SetIcon(self, imageType, image)
	local icon = self:GetControlObject("dragitem.icon")
	if imageType == 1 then
		icon:SetResID(image)
	elseif imageType == 2 then
		icon:SetBitmap(image)
	end
	icon:SetVisible(true)
end

function SetText(self, text)
	local tip = self:GetControlObject("dragitem.tip")
	tip:SetVisible(true)
	tip:SetChildrenVisible(true)
	tip:SetText(text)
	local width, height = tip:GetSize(40, 25)
	local left,top,right,bottom = tip:GetObjPos()
	tip:SetObjPos(left, top, left+width, bottom)
end

function HideText(self)
	local tip = self:GetControlObject("dragitem.tip")
	tip:SetVisible(false)
	tip:SetChildrenVisible(false)
end

function HideItem(self)
	local tip = self:GetControlObject("dragitem.tip")
	tip:SetChildrenVisible(false)
	local icon = self:GetControlObject("dragitem.icon")
	icon:SetVisible(false)
	local noneStatus = self:GetControlObject("dragitem.status")
	noneStatus:SetVisible(false)
	self:SetObjPos(0,0,0,0)
	self:SetChildrenVisible(false)
end

