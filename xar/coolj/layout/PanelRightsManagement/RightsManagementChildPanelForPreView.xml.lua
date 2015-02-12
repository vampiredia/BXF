function OnInitControl(self)
	local attr = self:GetAttribute()
	local bkg = self:GetControlObject("bkg")
	--bkg:SetTextureID(attr.BorderTexture)
end

function TC_OnInitControl(self)
	local rootitem = self:GetRootItem()
	local temp_data = {'发布中心', '物业服务', '社区服务', '业主管理', '权限管理'}
	local temp_sub_data = {'显示', '编辑-添加', '编辑-更名', '编辑-删除'}
	for i, value in ipairs (temp_data) do
		local item = self:InsertItemText(value, rootitem)
		for j, sub_value in ipairs(temp_sub_data) do
			self:InsertItemText(sub_value, item)
		end
	end
end

function WB_OnInitControl(self)
	
end

function OnClick(self)
	local ctrl = self:GetOwnerControl()
	local web = ctrl:GetControlObject("test")
	local iwebbrowser2 = web:GetRawWebBrowser()
	local osshell = XLGetObject("CoolJ.OSShell")
	
	local html = osshell:DoScript(iwebbrowser2, "html")
	--XLMessageBox(11)
end