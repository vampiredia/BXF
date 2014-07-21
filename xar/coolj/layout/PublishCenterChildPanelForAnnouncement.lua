function OnInitControl(self)
	local attr = self:GetAttribute()
	local bkg = self:GetControlObject("bkg")
	bkg:SetTextureID(attr.BorderTexture)
end