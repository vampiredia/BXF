function OnInitControl(self)
	local attr = self:GetAttribute()
	local bkg = self:GetControlObject("bkg")
	--bkg:SetTextureID(attr.BorderTexture)
end

function LC_OnVersionInitControl(self)
	self:InsertColumn("version", 330, "版本号", "left", "center", 5, true, 330)
end

function LC_OnSuggestInitControl(self)
	self:InsertColumn("suggest", 330, "意见反馈", "left", "center", 5, true, 330)
end

function LC_OnInfoInitControl(self)
	self:InsertColumn("suggest", 330, "官方信息", "left", "center", 5, true, 330)
end