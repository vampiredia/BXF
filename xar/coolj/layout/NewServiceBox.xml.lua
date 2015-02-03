function Post_Adjust(data)
	if string.len(data['name']) == 0 then 
		return -1, '名称不能为空'
	elseif string.len(data['content']) == 0 then
		return -1, '描述不能为空'
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
		local name = root:GetControlObject("edit.title"):GetText()
		local content = root:GetControlObject("edit.content"):GetText()
		local param = ''
		local url = ''
		
		local ret, msg = Post_Adjust({name=name, content=content, area=area, phone=phone})
		if ret == 0 then
			if attr.Method == 'add_property_service_root' then
				param = "action=add_root".."&name="..name.."&content="..content.."&icon="..""
				url = "/api/community/services"
			elseif attr.Method == 'edit_property_service_root' then
				local id = attr.UserData['id']
				param = "action=update_root&id="..id.."&name="..name.."&content="..content.."&icon=".."".."&i_order="..attr.UserData['i_order']
				url = "/api/community/services"
			elseif attr.Method == 'add_community_service_root' then
				param = "action=add_root".."&name="..name.."&content="..content.."&icon="..""
				url = "/api/life/business"
			elseif attr.Method == 'edit_community_service_root' then
				local id = attr.UserData['id']
				param = "action=update_root&id="..id.."&name="..name.."&content="..content.."&icon=".."".."&i_order="..attr.UserData['i_order']
				url = "/api/life/business"
			end
			
			local request = function(ret, msg, result)
				if ret == 0 then
					hostwnd:EndDialog(1)	
				else
					--AddNotify(nil, msg, 5000)
					--XLMessageBox(1234)
					--root:GetControlObject("tip.msg"):SetText(msg)
					return
				end
			end
			HttpRequest(url, "POST", param, request)
		else
			--AddNotify(self, msg, 5000)
			--root:GetControlObject("tip.msg"):SetText(msg)
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