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
	
	ret = 0
	if self:GetID() == "ok" then
		ret = 1
		local name = root:GetControlObject("edit.title"):GetText()
		local content = root:GetControlObject("edit.content"):GetText()
		local area = root:GetControlObject("edit.area"):GetText()
		local phone = root:GetControlObject("edit.phone"):GetText()
		local id = attr.UserData['id']
		local pid = attr.UserData['pid']
		local param = ''
		local url = ''
		
		local ret, msg = Post_Adjust({name=name, content=content, area=area, phone=phone})
		if ret == 0 then
			if attr.Method == 'add_community_service_info' then
				param = "action=add_info&pid="..pid.."&name="..name.."&content="..content.."&area="..area.."&phone="..phone
				url = "/api/community/services"
			elseif attr.Method == 'edit_community_service_info' then
				local param = "action=update_info&id="..id.."&name="..name.."&content="..content.."&area="..area.."&phone="..phone.."&i_order="..attr.UserData['i_order']
				local url = "/api/community/services"
			end
			
			local httpclient = XLGetObject("Whome.HttpCore.Factory"):CreateInstance()
			httpclient:AttachResultListener(
				function(result) 
					local response = json.decode(result)
					if response['ret'] == 0 then
						hostwnd:EndDialog(1)
					else
						
					end
				end
			)
			XLMessageBox(url.."|"..param)
			httpclient:Perform(url, "POST", param)
		else
		
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