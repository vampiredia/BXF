

function ShowMenu(self, menunHostWndTemplateID, menuTreeTemplateID, menuObjID, parentHandle, x, y)
	local templateMananger = XLGetObject("Xunlei.UIEngine.TemplateManager")
	local menuTreeTemplate = templateMananger:GetTemplate(menuTreeTemplateID,"ObjectTreeTemplate")

	local menuTreeID = menuTreeTemplateID..".Instance"
	local menuTree = menuTreeTemplate:CreateInstance(menuTreeID)

	local hostwndManager = XLGetObject("Xunlei.UIEngine.HostWndManager")
	
	if not parentHandle then
		local parent = hostwndManager:GetHostWnd("WHome.MainFrame")
		parentHandle = parent:GetWndHandle()
	end

	local menuHostWndTemplate = templateMananger:GetTemplate(menunHostWndTemplateID, "HostWndTemplate")

	local menuHostWndID = menunHostWndTemplateID..".Instance"
	local menuHostWnd = menuHostWndTemplate:CreateInstance(menuHostWndID)
	
	menuHostWnd:BindUIObjectTree(menuTree)
	local root = menuTree:GetRootObject()
	local root_left, root_top, root_right, root_bottom = root:GetObjPos()
	
	local menuContext = menuTree:GetUIObject(menuObjID)
	menuContext:SetFocus( true )
	
	local osShell = XLGetObject("CoolJ.OSShell")
	x = 12
	y = 20
	if x == nil or y == nil then
		x, y = osShell:GetCursorPos()
	end

	local left, top, width, height = menuContext:GetScreenPos(x, y)
	XLPrint( "menulog:wnd pos left = "..(left - 350).." top = "..(top - 750).." right = "..(width + 750).." bottom = "..(height + 1350) )
	
	local wleft, wtop, wright, wbottom = left - 1000, top - 750, left - 1000 + width + 2000, top - 750 + height + 1350
	local lleft, ltop, lright, lbottom = 0, 0, 1200,800
	local rleft, rtop, rright, rbottom = 0, 0, 1200,800
	local sleft, stop, sright, sbotton
	if lright == rleft then
		sleft = lleft
		sright = rright
	else
		sleft = lleft
		sright = lright
	end
	if lbottom == rtop then
		stop = ltop
		sbottom = rbottom
	else
		stop = ltop
		sbottom = lbottom
	end
	
	local dw, dh = 1000, 750
	if wleft < sleft then
		wleft = sleft
		dw = left - wleft
	end
	if wtop < stop then
		wtop = stop
		dh = top - wtop
	end
	
	if wright > sright then
		wright = sright
	end
	if wbottom > sbottom then
		wbottom = sbottom
	end
	
	root:SetObjPos( root_left + dw, root_top + dh, root_right + dw, root_bottom + dh )
	if top < y then
		if left < x then
			menuContext:SetPopStatus(2,2)
		else
			menuContext:SetPopStatus(2,1)
		end
		menuHostWnd:TrackPopupMenu(parentHandle, left - dw, top - dh, wright - left + dw - 1, wbottom - top + dh)
	else
		if left < x then
			menuContext:SetPopStatus(1,2)
		else
			menuContext:SetPopStatus(1,1)
		end
		menuHostWnd:TrackPopupMenu(parentHandle, left - dw, top - dh, wright - left + dw - 1, wbottom - top + dh)
	end
	
	if menuHostWnd:GetMenuMode() == "manual" then
		local objtreeManager = XLGetObject("Xunlei.UIEngine.TreeManager")	
		objtreeManager:DestroyTree(menuTreeID)
		hostwndManager:RemoveHostWnd(menuHostWndID)
	end
end

--[[
id：插入菜单的id
after_id：插入位置菜单条id，如播放是插入在
type：菜单条类型，1表示分割条，0表示正常菜单
icon：菜单显示图标id
text：菜单显示文本
sub_menu：子菜单id
init_func：菜单初始化时调用函数
on_select_func：点击菜单时调用函数 
]]


local function createNormalMenuItemTemplate(id, after_id, type_, icon, text, sub_menu, init_func, on_select_func)
	local munmItemTemplate = {["id"] = id, ["after_id"] = after_id, 
		["type"] = type_, ["icon"] = icon, ["text"] = text, ["sub_menu"] = sub_menu, 
		["init_func"] = init_func, ["on_select_func"] = on_select_func}
	return munmItemTemplate
end


local function createNormalMenuTemplate()
	local normalMenuTemplate = {}
	normalMenuTemplate.Items = {}
	normalMenuTemplate.EraseItems = {}
	
	normalMenuTemplate.InsertItem = function ( curNormalMenuTemplate, id, after_id, type_, icon, text, sub_menu, init_func, on_select_func )
		local normalMenuItemTemplate = createNormalMenuItemTemplate(id, after_id, type_, icon, text, sub_menu, init_func, on_select_func )
		curNormalMenuTemplate.Items[#curNormalMenuTemplate.Items + 1] = normalMenuItemTemplate
	end
	
	normalMenuTemplate.InsertAfter = function ( curNormalMenuTemplate, id, type_, icon, text, sub_menu, init_func, on_select_func )
		return curNormalMenuTemplate:InsertItem(id, "_last_", type_, icon, text, sub_menu, init_func, on_select_func)
	end
	
	normalMenuTemplate.InsertFront = function ( curNormalMenuTemplate, id, type_, icon, text, sub_menu, init_func, on_select_func )
		return curNormalMenuTemplate:InsertItem(id, "_front_", type_, icon, text, sub_menu, init_func, on_select_func)
	end
	
	normalMenuTemplate.RemoveItem = function ( curNormalMenuTemplate, id )
		if curNormalMenuTemplate.Items == nil then
			return
		end
		for i = 1, #curNormalMenuTemplate.Items do
			local item = curNormalMenuTemplate.Items[ i ]
			if item ~= nil and item.id == id then
				curNormalMenuTemplate.Items[ i ] = nil
			end
		end
	end

	normalMenuTemplate.EraseItem = function (curNormalMenuTemplate, id)
		if curNormalMenuTemplate.EraseItems == nil then
			curNormalMenuTemplate.EraseItems = {}
		end
		curNormalMenuTemplate.EraseItems[#curNormalMenuTemplate.EraseItems + 1] = id
	end
	
	normalMenuTemplate.RemoveAllItem = function(curNormalMenuTemplate)
		if curNormalMenuTemplate.Items == nil then
			return
		end
		for i = 1, #curNormalMenuTemplate.Items do
			curNormalMenuTemplate.Items[ i ] = nil
		end
	end
	
	normalMenuTemplate.GetItemCount = function( curNormalMenuTemplate )
		return #curNormalMenuTemplate.Items
	end
	
	normalMenuTemplate.GetEraseItemCount = function(curNormalMenuTemplate)
		return #curNormalMenuTemplate.EraseItems
	end

	normalMenuTemplate.GetItem = function( curNormalMenuTemplate, index )
		return curNormalMenuTemplate.Items[ index ]
	end
	
	normalMenuTemplate.GetEraseItemIDByIndex = function (curNormalMenuTemplate, index)
		return curNormalMenuTemplate.EraseItems[index]
	end
	
	normalMenuTemplate.RollAllEraseItem = function (curNormalMenuTemplate)
		curNormalMenuTemplate.EraseItems = nil
	end
	
	
	normalMenuTemplate.DestroyBoundSpliter = function (curNormalMenuTemplate, bDestroy)
		curNormalMenuTemplate.bDestroyBoundSpliter = bDestroy
	end
	
	normalMenuTemplate.IsDestroyBoundSpliter = function (curNormalMenuTemplate)
		return curNormalMenuTemplate.bDestroyBoundSpliter
	end
	
	
	return normalMenuTemplate
end



function RegisterNormalMenuTemplate( menuHelper, id )
	if menuHelper.normalMenuTemplates[id] ~= nil then
		return
	end
	local normalMenuTemplate = createNormalMenuTemplate()
	menuHelper.normalMenuTemplates[id] = normalMenuTemplate
end

	
function GetNormalMenuTemplate( menuHelper, id )
	return menuHelper.normalMenuTemplates[id]
end


function GetUserData(menuHelper)
	return menuHelper.UserData
end

function RegisterObject( )
	local menuHelper = {}
	----这一对接口定义特定NormalMenu对象的模板， 以后再创建该id的NormalMenu对象时按照模板加入MenuItem
	menuHelper.normalMenuTemplates = {}
	menuHelper.GetNormalMenuTemplate = GetNormalMenuTemplate
	menuHelper.RegisterNormalMenuTemplate = RegisterNormalMenuTemplate
	
	menuHelper.UserData = {}
	menuHelper.GetUserData = GetUserData
	
	
	menuHelper.ShowMenu = ShowMenu
	XLSetGlobal("xunlei.MenuHelper", menuHelper )
end