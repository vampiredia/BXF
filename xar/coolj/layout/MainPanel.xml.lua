function OnDemoButton_Click(self)
	XLMessageBox("Click Demo Button!")
end

function DemoListBox_OnInitControl(self)
	for i=1,100 do
		self:AddString("String at "..i)
	end
	self:UpdateUI()
end

function OnTipsMouseEnter(self, x, y)
	local hostWndManager = XLGetObject("Xunlei.UIEngine.HostWndManager")
	local tipsHostWnd = hostWndManager:GetHostWnd("CoolJ.Tips.Instance")
						
	tipsHostWnd:DelayPopup(600)
	tipsHostWnd:SetPositionByObject(50,30,self)
end

function OnTipsMouseLeave(self)
	local hostWndManager = XLGetObject("Xunlei.UIEngine.HostWndManager")
	local tipsHostWnd = hostWndManager:GetHostWnd("CoolJ.Tips.Instance")
	
	tipsHostWnd:DelayCancel(0)
end

function OnTipsInitControl(self)
	local templateMananger = XLGetObject("Xunlei.UIEngine.TemplateManager")
	local tipsHostWndTemplate = templateMananger:GetTemplate("CoolJ.Tips","HostWndTemplate")
	tipsHostWndTemplate:CreateInstance("CoolJ.Tips.Instance")
end

function OnTipsDestroy(self)
	local hostWndManager = XLGetObject("Xunlei.UIEngine.HostWndManager")
	hostWndManager:RemoveHostWnd("CoolJ.Tips.Instance")
end

function OnModalLButtonUp(self)
	local templateMananger = XLGetObject("Xunlei.UIEngine.TemplateManager")
	local hostWndManager = XLGetObject("Xunlei.UIEngine.HostWndManager")
	
	local modalHostWndTemplate = templateMananger:GetTemplate("CoolJ.ModalDlg","HostWndTemplate")
	if modalHostWndTemplate then
		local modalHostWnd = modalHostWndTemplate:CreateInstance("CoolJ.ModalDlg.Instance")
		if modalHostWnd then
			local objectTreeTemplate = templateMananger:GetTemplate("CoolJ.ModalDlg","ObjectTreeTemplate")
			if objectTreeTemplate then
				local uiObjectTree = objectTreeTemplate:CreateInstance("CoolJ.ModalDlg.Instance")
				if uiObjectTree then
					modalHostWnd:BindUIObjectTree(uiObjectTree)
					
					local mainWnd = hostWndManager:GetHostWnd("CoolJ.MainWnd.Instance")
					modalHostWnd:DoModal(mainWnd:GetWndHandle())
				end
				
				local objtreeManager = XLGetObject("Xunlei.UIEngine.TreeManager")	
				objtreeManager:DestroyTree("CoolJ.ModalDlg.Instance")
			end
			
			
			hostWndManager:RemoveHostWnd("CoolJ.ModalDlg.Instance")
		end
	end
end

function OnCrashButton_Click(self)
	local app = XLGetObject("CoolJ.App")
	app:Crash()
end

function OnDragTextUp(self)
    local ctrl = self:GetOwnerControl()
    local cattr = ctrl:GetAttribute()
    cattr.dragmouse = false
end

function OnDragTextDown(self)
    local ctrl = self:GetOwnerControl()
    local cattr = ctrl:GetAttribute()
    cattr.dragmouse = true
end

function OnDragTextMove(self)
    local ctrl = self:GetOwnerControl()
    local cattr = ctrl:GetAttribute()
    if cattr.dragmouse then
        local DataObjectHelper = XLGetObject("CoolJ.DataObjectHelper")
        local dataObj = DataObjectHelper:CreateDataObjectFromText("XLUE界面引擎，Drag测试文字")
        if dataObj then
            local tree = self:GetOwner()
            local hostwnd = tree:GetBindHostWnd()
            hostwnd:DoDragDrop(dataObj, 1)
            cattr.dragmouse = false
        end
    end
end

function OnDragQuery(self, dataObject, keyState, x, y)
    local DataObjectHelper = XLGetObject("CoolJ.DataObjectHelper")
    if DataObjectHelper:IsCFTEXTData(dataObject) then
        return 1, true
    end
    return 0, true
end

local effect

function OnDragEnter(self, dataObject, keyState, x, y)
    effect = 0
	
	local DataObjectHelper = XLGetObject("CoolJ.DataObjectHelper")
	local ret = DataObjectHelper:IsCFTEXTData(dataObject)
	if not ret then
		return effect, true
	end
	
	effect = 1 --DROPEFFECT_COPY
	return effect, true
end

function OnDragOver(self)
    return effect, true
end

function OnDrop(self, dataObject, keyState, x, y)
    local DataObjectHelper = XLGetObject("CoolJ.DataObjectHelper")
    local ret, text = DataObjectHelper:PraseDataObject(dataObject)
    if ret then
        local textObject = self:GetControlObject("droptext")
        textObject:SetText(text)
    end
end