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
function LoginWnd(hWnd)
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
									
					end
				local cookie = objectTreeTemplate:AttachListener("OnPostCreateInstance", true, OnPostCreateInstance)
				local uiObjectTree = objectTreeTemplate:CreateInstance("CoolJ.LoginWnd.Instance")
				if uiObjectTree then
					modalHostWnd:BindUIObjectTree(uiObjectTree)

					ret = modalHostWnd:DoModal(mainWnd:GetWndHandle())
					-- XLLoginWnd(ret)
				end
				local objtreeManager = XLGetObject("Xunlei.UIEngine.TreeManager")	
				objtreeManager:DestroyTree("CoolJ.LoginWnd.Instance")
			end
			hostWndManager:RemoveHostWnd("CoolJ.LoginWnd.Instance")
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
end