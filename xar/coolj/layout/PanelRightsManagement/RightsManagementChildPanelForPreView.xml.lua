function OnInitControl(self)
	local attr = self:GetAttribute()
	local bkg = self:GetControlObject("bkg")
	--bkg:SetTextureID(attr.BorderTexture)
end

function TC_OnInitControl(self)
	local rootitem = self:GetRootItem()
	local temp_data = {'物业费相关', '保洁相关', '停车位相关'}
	local temp_sub_data = {'电费', '水费', '物业费'}
	for i, value in ipairs (temp_data) do
		local item = self:InsertItemText(value, rootitem)
		for j, sub_value in ipairs(temp_sub_data) do
			self:InsertItemText(sub_value, item)
		end
	end
end