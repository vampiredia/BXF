function OnInitControl(self)
	local attr = self:GetAttribute()
	local bkg = self:GetControlObject("bkg")
	--bkg:SetTextureID(attr.BorderTexture)
end

function TC_OnInitControl(self)
	local rootitem = self:GetRootItem()
	local temp_data = {'客服A组', '客服B组', '客服C组', '客服D组', '主管中心'}
	local temp_sub_data = {'张三', '李四', '王五', '马二'}
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
	XLMessageBox(11)
end

function LRS_OnInitControl(self)
	self:InsertColumn("info", 330, "权限组管理员", "left", "center", 5, true, 330)
end

function LRI_OnInitControl(self)
	self:InsertColumn("info", 330, "管理员当前权限", "left", "center", 5, true, 330)
end