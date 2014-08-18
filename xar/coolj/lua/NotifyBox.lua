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

function AddNotify(self, text)
	local tree = self:GetOwner()
	local obj = tree:GetRootObject():GetObject("Notify.Container")
	if obj == nil then return end
	obj:AddNotify(text)
end

function RegisterGlobal()
	--XLSetGlobal("CreateNotifyBox", CreateNotifyBox)
	XLSetGlobal("AddNotify", AddNotify)
	--CreateNotifyBox()
end