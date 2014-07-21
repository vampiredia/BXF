function CreateLoginWnd()
    local templateManager = XLGetObject("Xunlei.UIEngine.TemplateManager")
    local frameHostWndTemplate = templateManager:GetTemplate("Wizard.LoginWnd", "HostWndTemplate")
    if frameHostWndTemplate == nil then
        return 
    end
    
    local frameHostWnd = frameHostWndTemplate:CreateInstance("Wizard.LoginWnd.Instance")
    if frameHostWnd == nil then
        return
    end
    
    local objectTreeTemplate = templateManager:GetTemplate("Wizard.LoginObjTree","ObjectTreeTemplate")
    if objectTreeTemplate == nil then 
        return
    end
    
    local uiObjectTree = objectTreeTemplate:CreateInstance("Wizard.LoginObjTree.Instance")
    if uiObjectTree == nil then
		return
	end
	
	frameHostWnd:BindUIObjectTree(uiObjectTree)
	
	local app = XLGetObject("Wizard.App")
	
	-- ��ȡ����ѡ������� �������Ƿ�͸�� ������Ӧ�ĳ�ʼ��
	local opaque = app:GetInt("ConfigGraphics", "ConfigGraphics_MainWndOpaque", 0)
	if opaque == 1 then
		frameHostWnd:SetLayered(false)
	else
		--��ȡ͸����
		local alpha = app:GetInt("ConfigGraphics", "ConfigGraphics_MainWndAlpha", 200)
	end

	-- ��ȡ����ѡ������� �����Ƿ���ë����Ч��
	local enableBlur = app:GetInt("ConfigGraphics", "ConfigGraphics_EnableBlur", 0)
	
	local hostwndManager = XLGetObject("Xunlei.UIEngine.HostWndManager")
	if opaque == 0 and enableBlur == 1 then
		hostwndManager:SetSystemBlur(true)
	else
		hostwndManager:SetSystemBlur(false)
	end
	
    frameHostWnd:Create()
	frameHostWnd:Center()
	
	return frameHostWnd
end

function CreateMainWnd()
	local templateMananger = XLGetObject("Xunlei.UIEngine.TemplateManager")
	local frameHostWndTemplate = templateMananger:GetTemplate("Wizard.MainWnd","HostWndTemplate")
	if frameHostWndTemplate == nil then
		return
	end

	local frameHostWnd = frameHostWndTemplate:CreateInstance("Wizard.MainWnd.Instance")
	if frameHostWnd == nil then
		return
	end
	local objectTreeTemplate = templateMananger:GetTemplate("Wizard.MainObjTree","ObjectTreeTemplate")
	if objectTreeTemplate == nil then
		return
	end


	local uiObjectTree = objectTreeTemplate:CreateInstance("Wizard.MainObjTree.Instance")
	if uiObjectTree == nil then
		return
	end

	frameHostWnd:BindUIObjectTree(uiObjectTree)
	
	local app = XLGetObject("Wizard.App")
	
	-- ��ȡ����ѡ������� �������Ƿ�͸�� ������Ӧ�ĳ�ʼ��
	local opaque = app:GetInt("ConfigGraphics", "ConfigGraphics_MainWndOpaque", 0)
	if opaque == 1 then
		frameHostWnd:SetLayered(true)
	else
		--��ȡ͸����
		local alpha = app:GetInt("ConfigGraphics", "ConfigGraphics_MainWndAlpha", 200)
	end
	frameHostWnd:SetLayered(true)
	-- ��ȡ����ѡ������� �����Ƿ���ë����Ч��
	local enableBlur = app:GetInt("ConfigGraphics", "ConfigGraphics_EnableBlur", 1)
	
	local hostwndManager = XLGetObject("Xunlei.UIEngine.HostWndManager")
	if opaque == 0 and enableBlur == 1 then
		hostwndManager:SetSystemBlur(true)
	else
		hostwndManager:SetSystemBlur(true)
	end
	
	frameHostWnd:Create()
	frameHostWnd:Center()
	
	return frameHostWnd
end

local function OnConfigChange(section, key, value)
	local app = XLGetObject("Wizard.App")
	local hostwndManager = XLGetObject("Xunlei.UIEngine.HostWndManager")
	local mainWnd = hostwndManager:GetHostWnd("Wizard.MainWnd.Instance")
	
	if section == "ConfigGraphics" then
		XLMessageBox(key)
		if key == "ConfigGraphics_MainWndOpaque" then
			if value == 0 then
				mainWnd:SetLayered(true)
				local enableBlur = app:GetInt("ConfigGraphics", "ConfigGraphics_EnableBlur", 1)
				if enableBlur == 1 then
					hostwndManager:SetSystemBlur(true)
				end
			else
				mainWnd:SetLayered(false)
			end
		elseif key == "ConfigGraphics_EnableBlur" then
			if value == 0 then
				hostwndManager:SetSystemBlur(false)
			else
				hostwndManager:SetSystemBlur(true)
			end
		end
	end
end

local app = XLGetObject("Wizard.App")
app:AttachListener("ConfigChange", OnConfigChange)

local hostwnd = CreateMainWnd()
if hostwnd ~= nil then
	hostwnd:SetVisible(true)
end

--local hostwnd = CreateLoginWnd()
--if hostwnd ~= nil then
--end


