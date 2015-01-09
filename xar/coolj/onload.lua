local path = __document
local index = string.find(path, "/[^/]*$")
local rootDir = string.sub(path,1,index)
local folderDir = rootDir.."lua/"
XLSetGlobal("lua_code_dir", folderDir)

local logDir = folderDir.."log.lua"
local mdLog = XLLoadModule(logDir)
mdLog.RegisterGlobal()

local cmDir = folderDir.."CheckMethod.lua"
local mdCheckMethod = XLLoadModule(cmDir)
mdCheckMethod.RegisterGlobal()

local modalDir = folderDir.."Modal.lua"
local mdModal = XLLoadModule(modalDir)
mdModal.RegisterGlobal()

function CreateMainWnd()
	local templateMananger = XLGetObject("Xunlei.UIEngine.TemplateManager")
	local frameHostWndTemplate = templateMananger:GetTemplate("CoolJ.MainWnd","HostWndTemplate")
	if frameHostWndTemplate == nil then
		return
	end

	local frameHostWnd = frameHostWndTemplate:CreateInstance("CoolJ.MainWnd.Instance")
	if frameHostWnd == nil then
		return
	end
	local objectTreeTemplate = templateMananger:GetTemplate("CoolJ.MainObjTree","ObjectTreeTemplate")
	if objectTreeTemplate == nil then
		return
	end


	local uiObjectTree = objectTreeTemplate:CreateInstance("CoolJ.MainObjTree.Instance")
	if uiObjectTree == nil then
		return
	end

	frameHostWnd:BindUIObjectTree(uiObjectTree)
	
	local app = XLGetObject("CoolJ.App")
	
	-- 读取配置选项里面的 主界面是否透明 并做相应的初始化
	local opaque = app:GetInt("ConfigGraphics", "ConfigGraphics_MainWndOpaque", 0)
	if opaque == 1 then
		frameHostWnd:SetLayered(true)
	else
		--读取透明度
		local alpha = app:GetInt("ConfigGraphics", "ConfigGraphics_MainWndAlpha", 200)
	end
	frameHostWnd:SetLayered(true)
	-- 读取配置选项里面的 界面是否开启毛玻璃效果
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
	local app = XLGetObject("CoolJ.App")
	local hostwndManager = XLGetObject("Xunlei.UIEngine.HostWndManager")
	local mainWnd = hostwndManager:GetHostWnd("CoolJ.MainWnd.Instance")
	
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

local app = XLGetObject("CoolJ.App")
app:AttachListener("ConfigChange", OnConfigChange)

local hostwnd = CreateMainWnd()
if hostwnd ~= nil then
	hostwnd:SetVisible(true)
end


