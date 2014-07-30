function OnInitControl(self)
	local attr = self:GetAttribute()
	
	local objArea = self:GetControlObject("area")
	objArea:SetBorder(attr.Border)
	objArea:SetReadOnly(attr.ReadOnly)
	
	local objTelphone = self:GetControlObject("telphone")
	objTelphone:SetBorder(attr.Border)
	objTelphone:SetReadOnly(attr.ReadOnly)
	
	self:GetControlObject("area"):SetObjPos2(0, 0, attr.AreaWidth, attr.Height)
	self:GetControlObject("space"):SetObjPos2(attr.AreaWidth, 0, attr.SpaceWidth, attr.Height)
	self:GetControlObject("telphone"):SetObjPos2(attr.AreaWidth+attr.SpaceWidth, 0, attr.TelphoneWidth, attr.Height)
end

function SetBorder(self, status)
	local attr = self:GetAttribute()
	attr.ReadOnly = status
	
	local objArea = self:GetControlObject("area")
	objArea:SetBorder(status)
	local objTelphone = self:GetControlObject("telphone")
	objTelphone:SetBorder(status)
end

function GetBorder(self)
	local attr = self:GetAttribute()
	return attr.Border
end

function SetReadOnly(self, status)
	local attr = self:GetAttribute()
	attr.ReadOnly = status
	
	local objArea = self:GetControlObject("area")
	objArea:SetReadOnly(status)
	local objTelphone = self:GetControlObject("telphone")
	objTelphone:SetReadOnly(status)
end

function GetReadOnly(self)
	local attr = self:GetAttribute()
	return attr.ReadOnly
end


function OnEditChange(self)
	local owner = self:GetOwnerControl()
	owner:FireExtEvent("OnEditChange")
end

function GetText(self)
	local area = self:GetControlObject("area"):GetText()
	local telphone = self:GetControlObject("telphone"):GetText()
	
	return {area=area, telphone=telphone}
end

function SetText(self, text)
	self:GetControlObject("area"):SetText(text['area'])
	self:GetControlObject("telphone"):SetText(text['telphone'])
end