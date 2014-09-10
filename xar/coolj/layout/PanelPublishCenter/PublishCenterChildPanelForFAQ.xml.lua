function OnInitControl(self)
	local attr = self:GetAttribute()
	local bkg = self:GetControlObject("bkg")
	--bkg:SetTextureID(attr.BorderTexture)
end

function TB_OnInitControl(self)
--[[
	local attr = self:GetAttribute()
	local objFactory = XLGetObject("Xunlei.UIEngine.ObjectFactory")
	
	for i=1, 4 do
		local obj = objFactory:CreateUIObject(nil, "CoolJ.TableFAQItem")
		obj:SetText(i)
		self:AddItem(obj)
	end
]]
end

function TC_OnInitControl(self)
	local rootitem = self:GetRootItem()
	local temp_data = {'物业费相关', '保洁相关', '停车位相关', '居委会业务', "安保事宜", "缴费相关"}
	local temp_sub_data = {'电费', '水费', '物业费'}
	for i, value in ipairs (temp_data) do
		local item = self:InsertItemText(value, rootitem)
		for j, sub_value in ipairs(temp_sub_data) do
			self:InsertItemText(sub_value, item)
		end
	end
end

function TC_OnSelectChanged(self, method, obj)
	XLMessageBox(obj:GetText())
end