function Post_Vas_Adjust(data)
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

function Post_Vas_Info_Adjust(data)
	if string.len(data['name']) == 0 then 
		return -1, '名称不能为空'
	elseif string.len(data['content']) == 0 then
		return -1, '描述不能为空'
	elseif string.len(data['price']) == 0 then
		return -1, '价格描述不能为空'
	else
		return 0, 'success'
	end
end

function Post_Adjust(method, data)
	if method == "add_vas_root" then
		return Post_Vas_Adjust(data)
	elseif method == "edit_vas_root" then
		return Post_Vas_Adjust(data)
	elseif method == "add_vas_info" then
		return Post_Vas_Info_Adjust(data)
	elseif method == "edit_vas_info" then
		return Post_Vas_Info_Adjust(data)
	else
		return -1, "不存在该方法"
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
		local price = ""
		local id = attr.UserData['id']
		local pid = attr.UserData['pid']
		local param = ''
		local url = ''
		
		if attr.Method == 'add_vas_root' then
			name = root:GetObject("content.vas.bkg:edit.title"):GetText()
			content = root:GetObject("content.vas.bkg:edit.content"):GetText()
			area = root:GetObject("content.vas.bkg:edit.area"):GetText()
			phone = root:GetObject("content.vas.bkg:edit.phone"):GetText()
			param = "action=add_root&name="..name.."&content="..content.."&area="..area.."&phone="..phone.."&icon="..""
		elseif attr.Method == 'edit_vas_root' then
			name = root:GetObject("content.vas.bkg:edit.title"):GetText()
			content = root:GetObject("content.vas.bkg:edit.content"):GetText()
			area = root:GetObject("content.vas.bkg:edit.area"):GetText()
			phone = root:GetObject("content.vas.bkg:edit.phone"):GetText()
			param = "action=update_root&id="..id.."&name="..name.."&content="..content.."&area="..area.."&phone="..phone.."&i_order="..attr.UserData['i_order'].."&icon="..attr.UserData['icon']
		elseif attr.Method == 'add_vas_info' then
			name = root:GetObject("content.vas.info.bkg:edit.title"):GetText()
			content = root:GetObject("content.vas.info.bkg:edit.content"):GetText()
			price = root:GetObject("content.vas.info.bkg:edit.price"):GetText()
			param = "action=add_info&pid="..pid.."&name="..name.."&content="..content.."&price="..price
		elseif attr.Method == 'edit_vas_info' then
			name = root:GetObject("content.vas.info.bkg:edit.title"):GetText()
			content = root:GetObject("content.vas.info.bkg:edit.content"):GetText()
			price = root:GetObject("content.vas.info.bkg:edit.price"):GetText()
			param = "action=update_info&id="..id.."&name="..name.."&content="..content.."&price="..price.."&i_order="..attr.UserData['i_order']
		end
		
		url = "/api/community/vas"
		local ret, msg = Post_Adjust(attr.Method, {name=name, content=content, area=area, phone=phone, price=price})
		if ret == 0 then
			local request = function(ret, msg, result)
				if ret == 0 then
					hostwnd:EndDialog(1)	
				else
					--AddNotify(self, msg, 5000)
					--root:GetControlObject("tip.msg"):SetText(msg)
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
	self:GetControlObject("content.vas.bkg"):SetVisible(false)
	self:GetControlObject("content.vas.bkg"):SetChildrenVisible(false)
	self:GetControlObject("content.vas.info.bkg"):SetVisible(false)
	self:GetControlObject("content.vas.info.bkg"):SetChildrenVisible(false)
end