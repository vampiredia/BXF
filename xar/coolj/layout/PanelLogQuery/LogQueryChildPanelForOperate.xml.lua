function OnInitControl(self)
	local attr = self:GetAttribute()
	local bkg = self:GetControlObject("bkg")
	--bkg:SetTextureID(attr.BorderTexture)
	
	self:PageChange("CoolJ.PanelOperateList")
end

function PageChange(self, class)
	local objFactory = XLGetObject("Xunlei.UIEngine.ObjectFactory")
	local obj = objFactory:CreateUIObject("panel",class)
	if obj == nil then return end
	
	local bkg = self:GetControlObject("bkg")
	bkg:RemoveAllChild()
	bkg:AddChild(obj)
end

function OnPosChange(self, oldl, oldt, oldr, oldb, newl, newt, newr,  newt)
	local bkg = self:GetControlObject("bkg")
	for i=1, bkg:GetChildCount() do
		local obj = bkg:GetChildByIndex(i-1)
		obj:SetObjPos(bkg:GetObjPos())
	end
end