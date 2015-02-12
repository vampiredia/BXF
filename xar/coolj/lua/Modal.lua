-- NotifyBox 通知消息窗口
-- Param：
--	hWnd：绑定窗口句柄，nil时指定ID为"CoolJ.MainWnd.Instance"的窗口为父窗口
--  caption：标题
--  table_data：消息数据
function CreateNotifyBox()
	local templateMananger = XLGetObject("Xunlei.UIEngine.TemplateManager")
	local notifyHostWndTemplate = templateMananger:GetTemplate("CoolJ.NotifyBox","HostWndTemplate")
	if notifyHostWndTemplate then 
		local notifyHostWnd = notifyHostWndTemplate:CreateInstance("CoolJ.NotifyBox.Instance")
		notifyHostWnd:SetTipTemplate("CoolJ.Notify.Panel")
	end
end

function AddPushNotify(obj, caption, table_data)
	local ret = 0

	local hostWndManager = XLGetObject("Xunlei.UIEngine.HostWndManager")
	local tipsHostWnd = hostWndManager:GetHostWnd("CoolJ.NotifyBox")
	if tipsHostWnd then
		tipsHostWnd:DelayPopup(1000) 
		tipsHostWnd:SetPositionByObject(100,30,obj)  
	end
end

-- AddNotifyBox 弹窗函数-右下角弹窗
-- Param：
--	hWnd：绑定窗口句柄，nil时指定ID为"CoolJ.MainWnd.Instance"的窗口为父窗口
--  text：消息内容
--  caption：消息标题
--  icon：弹出窗口的ICON、暂时未使用
function AddNotifyBox(caption, text, tp)
	if tp ~= "Owner" and tp ~= "OnCall" then return end
	
	local handleID = "CoolJ.NotifyBox."..tp..".Instance"
	local hostWndManager = XLGetObject("Xunlei.UIEngine.HostWndManager")
	local notifyHostWnd = hostWndManager:GetHostWnd(handleID)
	if notifyHostWnd == nil then 
		local templateManager = XLGetObject("Xunlei.UIEngine.TemplateManager")
		local notifyHostWndTemplate = templateManager:GetTemplate("CoolJ.NotifyBox.Wnd", "HostWndTemplate")
		if notifyHostWndTemplate == nil then return end
		
		notifyHostWnd = notifyHostWndTemplate:CreateInstance(handleID)
		if notifyHostWnd == nil then return end
		
		local objectTreeTemplate = templateManager:GetTemplate("CoolJ.NotifyBox", "ObjectTreeTemplate")
		if objectTreeTemplate == nil then return end
		
		local uiObjectTree = objectTreeTemplate:CreateInstance(handleID)
		if uiObjectTree == nil then return end
		
		notifyHostWnd:BindUIObjectTree(uiObjectTree)
		notifyHostWnd:Create()
		
	end
	local function NotifyBoxPositionChange()
		local osShell = XLGetObject("CoolJ.OSShell")
		local l,t,r,b = osShell:GetWorkArea()
	
		local oncallHandleID = "CoolJ.NotifyBox.OnCall.Instance"
		local oncallHwnd = hostWndManager:GetHostWnd(oncallHandleID)
		if oncallHwnd ~= nil then
			local cl,ct,cr,cb = oncallHwnd:GetWindowRect()
			local cWidth = cr-cl
			local cHeight = cb-ct
	
			oncallHwnd:Move(r-cWidth,b-cHeight,cWidth,cHeight)
			b = b - cHeight
		end
		
		local ownerHandleID = "CoolJ.NotifyBox.Owner.Instance"
		local ownerHwnd = hostWndManager:GetHostWnd(ownerHandleID)
		if ownerHwnd ~= nil then
			local cl,ct,cr,cb = ownerHwnd:GetWindowRect()
			local cWidth = cr-cl
			local cHeight = cb-ct
			
			ownerHwnd:Move(r-cWidth,b-cHeight,cWidth,cHeight)
		end
	end
	
	local function NotifyBoxUpdate()
		if notifyHostWnd == nil then return end
	
		local objtreeManager = XLGetObject("Xunlei.UIEngine.TreeManager")
		local uiNotifyTree = objtreeManager:GetUIObjectTree(handleID)
		if uiNotifyTree == nil then return end
		local objCaption = uiNotifyTree:GetRootObject():GetObject("caption.text")
		objCaption:SetText(caption)
		local objContent = uiNotifyTree:GetRootObject():GetObject("content.text")
		objContent:SetText(text)
		
		local attr = uiNotifyTree:GetRootObject():GetAttribute()
		attr.Type = tp
	end
	
	-- 更新通知窗口
	NotifyBoxPositionChange()
	-- 更新通知内容
	NotifyBoxUpdate()
end

function AddNotify(self, text, timeout)
	local tree = self:GetOwner()
	local obj = tree:GetRootObject():GetObject("Notify.Container")
	if obj == nil then return end
	obj:AddNotify(text, timeout)
end

-- MessageBox 弹窗函数
-- Param：
--	hWnd：绑定窗口句柄，nil时指定ID为"CoolJ.MainWnd.Instance"的窗口为父窗口
--  text：消息内容
--  caption：消息标题
--  icon：弹出窗口的ICON、暂时未使用
function MessageBox(hWnd, caption, text, icon)
	local ret = 0
	local mainWnd = hWnd
	local templateMananger = XLGetObject("Xunlei.UIEngine.TemplateManager")
	local hostWndManager = XLGetObject("Xunlei.UIEngine.HostWndManager")
	
	if mainWnd == nil then mainWnd = hostWndManager:GetHostWnd("CoolJ.MainWnd.Instance") end
	if mainWnd == nil then return ret end
	
	local modalHostWndTemplate = templateMananger:GetTemplate("CoolJ.MessageBox","HostWndTemplate")
	if modalHostWndTemplate then
		local modalHostWnd = modalHostWndTemplate:CreateInstance("CoolJ.MessageBox.Instance")
		if modalHostWnd then
			local objectTreeTemplate = templateMananger:GetTemplate("CoolJ.MessageBox","ObjectTreeTemplate")
			if objectTreeTemplate then
				local function OnPostCreateInstance(self, obj, userdata)
						local root = obj:GetRootObject()
						if userdata['caption'] ~= nil then
							root:GetControlObject("caption.text"):SetText(userdata['caption'])
						end
						if userdata['text'] ~= nil then
							root:GetControlObject("text"):SetText(userdata['text'])
						end					
					end
				local cookie = objectTreeTemplate:AttachListener("OnPostCreateInstance", true, OnPostCreateInstance)
				local uiObjectTree = objectTreeTemplate:CreateInstance("CoolJ.MessageBox.Instance", nil ,{text=text, caption=caption})
				if uiObjectTree then
					modalHostWnd:BindUIObjectTree(uiObjectTree)

					ret = modalHostWnd:DoModal(mainWnd:GetWndHandle())
					-- XLMessageBox(ret)
				end
				local objtreeManager = XLGetObject("Xunlei.UIEngine.TreeManager")	
				objtreeManager:DestroyTree("CoolJ.MessageBox.Instance")
			end
			hostWndManager:RemoveHostWnd("CoolJ.MessageBox.Instance")
		end
	end
	
	return ret
end

-- LoginWnd 弹窗函数
-- Param：
--	hWnd：绑定窗口句柄，nil时指定ID为"CoolJ.MainWnd.Instance"的窗口为父窗口
function LoginWnd(hWnd, cb)
	local ret = 0
	local mainWnd = hWnd
	local templateMananger = XLGetObject("Xunlei.UIEngine.TemplateManager")
	local hostWndManager = XLGetObject("Xunlei.UIEngine.HostWndManager")
	
	if mainWnd == nil then mainWnd = hostWndManager:GetHostWnd("CoolJ.MainWnd.Instance") end
	if mainWnd == nil then return ret end
	
	local modalHostWndTemplate = templateMananger:GetTemplate("CoolJ.LoginWnd","HostWndTemplate")
	if modalHostWndTemplate then
		local modalHostWnd = modalHostWndTemplate:CreateInstance("CoolJ.LoginWnd.Instance")
		if modalHostWnd then
			local objectTreeTemplate = templateMananger:GetTemplate("CoolJ.LoginObjTree","ObjectTreeTemplate")
			if objectTreeTemplate then
				local function OnPostCreateInstance(self, obj, userdata)
						local root = obj:GetRootObject()
						local attr = root:GetAttribute()
						attr.CallBack = cb
					end
				local cookie = objectTreeTemplate:AttachListener("OnPostCreateInstance", true, OnPostCreateInstance)
				local uiObjectTree = objectTreeTemplate:CreateInstance("CoolJ.LoginWnd.Instance")
				if uiObjectTree then
					modalHostWnd:BindUIObjectTree(uiObjectTree)

					ret = modalHostWnd:Create(mainWnd:GetWndHandle())
					modalHostWnd:Center()
					modalHostWnd:SetVisible(true)
					-- XLLoginWnd(ret)
				end
				--local objtreeManager = XLGetObject("Xunlei.UIEngine.TreeManager")	
				--objtreeManager:DestroyTree("CoolJ.LoginWnd.Instance")
			end
			--hostWndManager:RemoveHostWnd("CoolJ.LoginWnd.Instance")
		end
	end
	
	return ret
end

-- NewServiceBox 新建服务分类弹窗函数
-- Param
--	hWnd：绑定窗口句柄，nil时指定ID为"CoolJ.MainWnd.Instance"的窗口为父窗口
--  title：窗口标题
--  method：方法分类
--  userdata：用户自定义数据
function NewServiceBox(hWnd, title, method, userdata)
	local ret = 0
	local mainWnd = hWnd
	local templateMananger = XLGetObject("Xunlei.UIEngine.TemplateManager")
	local hostWndManager = XLGetObject("Xunlei.UIEngine.HostWndManager")
	
	if mainWnd == nil then mainWnd = hostWndManager:GetHostWnd("CoolJ.MainWnd.Instance") end
	if mainWnd == nil then return ret end
	
	local modalHostWndTemplate = templateMananger:GetTemplate("CoolJ.NewServiceBox","HostWndTemplate")
	if modalHostWndTemplate then
		local modalHostWnd = modalHostWndTemplate:CreateInstance("CoolJ.NewServiceBox.Instance")
		if modalHostWnd then
			local objectTreeTemplate = templateMananger:GetTemplate("CoolJ.NewServiceBox","ObjectTreeTemplate")
			if objectTreeTemplate then
				local function OnPostCreateInstance(self, obj, userdata)
						local root = obj:GetRootObject()
						if userdata['caption'] ~= nil then
							root:GetControlObject("caption.text"):SetText(userdata['caption'])
						end
						if userdata['text'] ~= nil then
							root:GetControlObject("text"):SetText(userdata['text'])
						end
						root:GetAttribute().Method = userdata['method']				
						root:GetAttribute().UserData = userdata['userdata']
						if userdata['method'] == 'edit_property_service_root' then
							root:GetControlObject("edit.title"):SetText(userdata['userdata']['name'])
							root:GetControlObject("edit.content"):SetText(userdata['userdata']['content'])
						elseif userdata['method'] == 'edit_community_service_root' then
							root:GetControlObject("edit.title"):SetText(userdata['userdata']['name'])
							root:GetControlObject("edit.content"):SetText(userdata['userdata']['content'])
						end
					end
				local cookie = objectTreeTemplate:AttachListener("OnPostCreateInstance", true, OnPostCreateInstance)
				local uiObjectTree = objectTreeTemplate:CreateInstance("CoolJ.NewServiceBox.Instance", nil ,{method=method, caption=title, userdata=userdata})
				if uiObjectTree then
					modalHostWnd:BindUIObjectTree(uiObjectTree)

					ret = modalHostWnd:DoModal(mainWnd:GetWndHandle())
					-- XLMessageBox(ret)
				end
				local objtreeManager = XLGetObject("Xunlei.UIEngine.TreeManager")	
				objtreeManager:DestroyTree("CoolJ.NewServiceBox.Instance")
			end
			hostWndManager:RemoveHostWnd("CoolJ.NewServiceBox.Instance")
		end
	end
	
	return ret
end

-- NewSubServiceBox 新建服务子分类弹窗函数
-- Param
--	hWnd：绑定窗口句柄，nil时指定ID为"CoolJ.MainWnd.Instance"的窗口为父窗口
--  title：窗口标题
--  method：方法分类
--  userdata：用户自定义数据
function NewSubServiceBox(hWnd, title, method, userdata)
	local ret = 0
	local mainWnd = hWnd
	local templateMananger = XLGetObject("Xunlei.UIEngine.TemplateManager")
	local hostWndManager = XLGetObject("Xunlei.UIEngine.HostWndManager")
	
	if mainWnd == nil then mainWnd = hostWndManager:GetHostWnd("CoolJ.MainWnd.Instance") end
	if mainWnd == nil then return ret end
	
	local modalHostWndTemplate = templateMananger:GetTemplate("CoolJ.NewSubServiceBox","HostWndTemplate")
	if modalHostWndTemplate then
		local modalHostWnd = modalHostWndTemplate:CreateInstance("CoolJ.NewSubServiceBox.Instance")
		if modalHostWnd then
			local objectTreeTemplate = templateMananger:GetTemplate("CoolJ.NewSubServiceBox","ObjectTreeTemplate")
			if objectTreeTemplate then
				local function OnPostCreateInstance(self, obj, userdata)
						local root = obj:GetRootObject()
						if userdata['caption'] ~= nil then
							root:GetControlObject("caption.text"):SetText(userdata['caption'])
						end
						root:GetAttribute().Method = userdata['method']				
						root:GetAttribute().UserData = userdata['userdata']
						if userdata['method'] == 'edit_property_service_info' then
							root:GetObject("content.property.bkg:edit.title"):SetText(userdata['userdata']['name'])
							root:GetObject("content.property.bkg:edit.content"):SetText(userdata['userdata']['content'])
							root:GetObject("content.property.bkg:edit.area"):SetText(userdata['userdata']['area'])
							root:GetObject("content.property.bkg:edit.phone"):SetText(userdata['userdata']['phone'])
							root:GetControlObject("content.property.bkg"):SetVisible(true)
							root:GetControlObject("content.property.bkg"):SetChildrenVisible(true)
						elseif userdata['method'] == 'add_property_service_info' then
							root:GetControlObject("content.property.bkg"):SetVisible(true)
							root:GetControlObject("content.property.bkg"):SetChildrenVisible(true)
						elseif userdata['method'] == 'edit_community_service_info' then
							root:GetObject("content.community.bkg:edit.title"):SetText(userdata['userdata']['name'])
							root:GetObject("content.community.bkg:richedit.content_msg"):SetText(userdata['userdata']['content_msg'])	
							root:GetObject("content.community.bkg:richedit.content_des"):SetText(userdata['userdata']['content_des'])	
							root:GetObject("content.community.bkg:edit.area"):SetText(userdata['userdata']['area'])	
							root:GetObject("content.community.bkg:edit.phone"):SetText(userdata['userdata']['phone'])	
							root:GetControlObject("content.community.bkg"):SetVisible(true)
							root:GetControlObject("content.community.bkg"):SetChildrenVisible(true)
						elseif userdata['method'] == 'add_community_service_info' then
							root:GetControlObject("content.community.bkg"):SetVisible(true)
							root:GetControlObject("content.community.bkg"):SetChildrenVisible(true)
						end
					end
				local cookie = objectTreeTemplate:AttachListener("OnPostCreateInstance", true, OnPostCreateInstance)
				local uiObjectTree = objectTreeTemplate:CreateInstance("CoolJ.NewSubServiceBox.Instance", nil ,{method=method, caption=title, userdata=userdata})
				if uiObjectTree then
					modalHostWnd:BindUIObjectTree(uiObjectTree)

					ret = modalHostWnd:DoModal(mainWnd:GetWndHandle())
					-- XLMessageBox(ret)
				end
				local objtreeManager = XLGetObject("Xunlei.UIEngine.TreeManager")	
				objtreeManager:DestroyTree("CoolJ.NewSubServiceBox.Instance")
			end
			hostWndManager:RemoveHostWnd("CoolJ.NewSubServiceBox.Instance")
		end
	end
	
	return ret
end

function ServiceVasBox(hWnd, title, method, userdata)
	local ret = 0
	local mainWnd = hWnd
	local templateMananger = XLGetObject("Xunlei.UIEngine.TemplateManager")
	local hostWndManager = XLGetObject("Xunlei.UIEngine.HostWndManager")
	
	if mainWnd == nil then mainWnd = hostWndManager:GetHostWnd("CoolJ.MainWnd.Instance") end
	if mainWnd == nil then return ret end
	
	local modalHostWndTemplate = templateMananger:GetTemplate("CoolJ.ServiceVasBox","HostWndTemplate")
	if modalHostWndTemplate then
		local modalHostWnd = modalHostWndTemplate:CreateInstance("CoolJ.ServiceVasBox.Instance")
		if modalHostWnd then
			local objectTreeTemplate = templateMananger:GetTemplate("CoolJ.ServiceVasBox","ObjectTreeTemplate")
			if objectTreeTemplate then
				local function OnPostCreateInstance(self, obj, userdata)
						local root = obj:GetRootObject()
						if userdata['caption'] ~= nil then
							root:GetControlObject("caption.text"):SetText(userdata['caption'])
						end
						root:GetAttribute().Method = userdata['method']				
						root:GetAttribute().UserData = userdata['userdata']
						if userdata['method'] == 'add_vas_root' then
							root:GetControlObject("content.vas.bkg"):SetVisible(true)
							root:GetControlObject("content.vas.bkg"):SetChildrenVisible(true)
						elseif userdata['method'] == 'edit_vas_root' then
							root:GetObject("content.vas.bkg:edit.title"):SetText(userdata['userdata']['name'])
							root:GetObject("content.vas.bkg:edit.content"):SetText(userdata['userdata']['content'])
							root:GetObject("content.vas.bkg:edit.area"):SetText(userdata['userdata']['area'])
							root:GetObject("content.vas.bkg:edit.phone"):SetText(userdata['userdata']['phone'])
							root:GetControlObject("content.vas.bkg"):SetVisible(true)
							root:GetControlObject("content.vas.bkg"):SetChildrenVisible(true)
						elseif userdata['method'] == 'add_vas_info' then
							root:GetControlObject("content.vas.info.bkg"):SetVisible(true)
							root:GetControlObject("content.vas.info.bkg"):SetChildrenVisible(true)
						elseif userdata['method'] == 'edit_vas_info' then
							root:GetObject("content.vas.info.bkg:edit.title"):SetText(userdata['userdata']['name'])
							root:GetObject("content.vas.info.bkg:edit.content"):SetText(userdata['userdata']['content'])
							root:GetObject("content.vas.info.bkg:edit.price"):SetText(userdata['userdata']['price'])
							root:GetControlObject("content.vas.info.bkg"):SetVisible(true)
							root:GetControlObject("content.vas.info.bkg"):SetChildrenVisible(true)
						end
					end
				local cookie = objectTreeTemplate:AttachListener("OnPostCreateInstance", true, OnPostCreateInstance)
				local uiObjectTree = objectTreeTemplate:CreateInstance("CoolJ.ServiceVasBox.Instance", nil ,{method=method, caption=title, userdata=userdata})
				if uiObjectTree then
					modalHostWnd:BindUIObjectTree(uiObjectTree)

					ret = modalHostWnd:DoModal(mainWnd:GetWndHandle())
					-- XLMessageBox(ret)
				end
				local objtreeManager = XLGetObject("Xunlei.UIEngine.TreeManager")	
				objtreeManager:DestroyTree("CoolJ.ServiceVasBox.Instance")
			end
			hostWndManager:RemoveHostWnd("CoolJ.ServiceVasBox.Instance")
		end
	end
	return ret
end

function RegisterGlobal()
	XLSetGlobal("LoginWnd", LoginWnd)
	--XLSetGlobal("CreateNotifyBox", CreateNotifyBox)
	XLSetGlobal("AddNotify", AddNotify)
	XLSetGlobal("AddNotifyBox", AddNotifyBox)
	--CreateNotifyBox()
	XLSetGlobal("MessageBox", MessageBox)
	XLSetGlobal("NewServiceBox", NewServiceBox)
	XLSetGlobal("NewSubServiceBox", NewSubServiceBox)
	XLSetGlobal("ServiceVasBox", ServiceVasBox)
end