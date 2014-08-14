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

function RegisterGlobal()
	XLSetGlobal("MessageBox", MessageBox)
end