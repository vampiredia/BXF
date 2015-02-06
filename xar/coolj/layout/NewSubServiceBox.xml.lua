function Post_Adjust(data)
	if string.len(data['name']) == 0 then 
		return -1, '名称不能为空'
	elseif string.len(data['content']) == 0 then
		return -1, '描述不能为空'
	elseif string.len(data['phone']) == 0 then
		return -1, '电话号码不能为空'
	else
		return 0, 'success'
	end
end

function OnNcActivate(self, activate)
	local ownerTree = self:GetOwner()
	local flashObj = ownerTree:GetUIObject("app.bkg:bkg.flash")
			
	if activate then
		flashObj:SetVisible(false)
	else
		flashObj:SetVisible(true)
	end
	
	return 10, true, false
end

function OnClick(self)
	local owner = self:GetOwner()
	local hostwnd = owner:GetBindHostWnd()
	local root = self:GetOwnerControl()
	local attr = root:GetAttribute()
	root:GetControlObject("tip.msg"):SetText("")
	
	ret = 0
	if self:GetID() == "ok" then
		ret = 1
		local name = ""
		local content = ""
		local area = ""
		local phone = ""
		local id = attr.UserData['id']
		local pid = attr.UserData['pid']
		local param = ''
		local url = ''
		
		if attr.Method == 'add_property_service_info' then
			name = root:GetObject("content.property.bkg:edit.title"):GetText()
			content = root:GetObject("content.property.bkg:edit.content"):GetText()
			area = root:GetObject("content.property.bkg:edit.area"):GetText()
			phone = root:GetObject("content.property.bkg:edit.phone"):GetText()
			param = "action=add_info&pid="..pid.."&name="..name.."&content="..content.."&area="..area.."&phone="..phone
			url = "/api/community/services"
		elseif attr.Method == 'edit_property_service_info' then
			name = root:GetObject("content.property.bkg:edit.title"):GetText()
			content = root:GetObject("content.property.bkg:edit.content"):GetText()
			area = root:GetObject("content.property.bkg:edit.area"):GetText()
			phone = root:GetObject("content.property.bkg:edit.phone"):GetText()
			param = "action=update_info&id="..id.."&name="..name.."&content="..content.."&area="..area.."&phone="..phone.."&i_order="..attr.UserData['i_order']
			url = "/api/community/services"
		elseif attr.Method == 'add_community_service_info' then
			name = root:GetObject("content.community.bkg:edit.title"):GetText()
			content = root:GetObject("content.community.bkg:richedit.content_msg"):GetText()
			content_msg = root:GetObject("content.community.bkg:richedit.content_msg"):GetText()
			content_des = root:GetObject("content.community.bkg:richedit.content_des"):GetText()
			area = root:GetObject("content.community.bkg:edit.area"):GetText()
			phone = root:GetObject("content.community.bkg:edit.phone"):GetText()
			param = "action=add_info&pid="..pid.."&name="..name.."&content="..content.."&content_msg="..content_msg.."&content_des="..content_des.."&area="..area.."&phone="..phone.."&address="..""
			url = "/api/life/business"
		elseif attr.Method == 'edit_community_service_info' then
			name = root:GetObject("content.community.bkg:edit.title"):GetText()
			content = root:GetObject("content.community.bkg:richedit.content_msg"):GetText()
			content_msg = root:GetObject("content.community.bkg:richedit.content_msg"):GetText()
			content_des = root:GetObject("content.community.bkg:richedit.content_des"):GetText()
			area = root:GetObject("content.community.bkg:edit.area"):GetText()
			phone = root:GetObject("content.community.bkg:edit.phone"):GetText()
			param = "action=update_info&id="..id.."&name="..name.."&content="..content.."&content_msg="..content_msg.."&content_des="..content_des.."&area="..area.."&phone="..phone.."&address="..attr.UserData['address'].."&i_order="..attr.UserData['i_order']
			url = "/api/life/business"
		end
		
		local ret, msg = Post_Adjust({name=name, content=content, area=area, phone=phone})
		if ret == 0 then
			local request = function(ret, msg, result)
				if ret == 0 then
					hostwnd:EndDialog(1)	
				else
					--AddNotify(self, msg, 5000)
					root:GetControlObject("tip.msg"):SetText(msg)
					return
				end
			end
			HttpRequest(url, "POST", param, request)
		else
			--AddNotify(self, msg, 5000)
			root:GetControlObject("tip.msg"):SetText(msg)
			return
		end
	end
	hostwnd:EndDialog(ret)
end

function OnCreate(self)
	local hostWndManager = XLGetObject("Xunlei.UIEngine.HostWndManager")
	local mainWnd = hostWndManager:GetHostWnd("CoolJ.MainWnd.Instance")
	self:Center(mainWnd)
end

function OnSize(self)
	local objectTree = self:GetBindUIObjectTree()
	local rootObject = objectTree:GetRootObject()
	--rootObject:SetObjPos(0, 0, width, height)
end

function OnClose(self)
	local owner = self:GetOwner()
	local hostwnd = owner:GetBindHostWnd()
	
	hostwnd:EndDialog(0)
end

function OnOK(self)
	
end

function OnChange(self)
	
end

function OnInitControl(self)
	self:GetControlObject("content.property.bkg"):SetVisible(false)
	self:GetControlObject("content.property.bkg"):SetChildrenVisible(false)
	self:GetControlObject("content.community.bkg"):SetVisible(false)
	self:GetControlObject("content.community.bkg"):SetChildrenVisible(false)
end

function OnEditChange(self)
	local textLength = self:GetLength()
	if textLength == nil then return end
	local textMaxLength = self:GetMaxLength()
	if textMaxLength == nil then return end
	--XLMessageBox(textMaxLength)
	
	local id = self:GetID()
	if id == "richedit.content_des" then
		local wordTips = self:GetOwnerControl():GetControlObject("tip.content_des")
		if wordTips ~= nil then wordTips:SetText("还能输入"..textMaxLength-textLength.."个汉字") end
	elseif id == "richedit.content_msg" then
		local wordTips = self:GetOwnerControl():GetControlObject("tip.content_msg")
		if wordTips ~= nil then wordTips:SetText("还能输入"..textMaxLength-textLength.."个汉字") end
	end
end