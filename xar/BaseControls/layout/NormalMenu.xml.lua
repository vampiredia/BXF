function OnInitControl(self)
	local attr = self:GetAttribute()
	attr.v_status = 1
	attr.h_status = 1
	
	local contextid = attr.ContextID
	if contextid ~= nil then
		local templateMananger = XLGetObject("Xunlei.UIEngine.TemplateManager")	
		local contextTemplate = templateMananger:GetTemplate(contextid, "ObjectTemplate")
		local contextObj = contextTemplate:CreateInstance("context_menu")
		if contextObj ~= nil then
			local bkn = self:GetControlObject("menu.bkn")
			bkn:AddChild(contextObj)
		end		
		
		local menu_helper = XLGetGlobal( "xunlei.MenuHelper" )
		if menu_helper ~= nil then
			local menu_ex = menu_helper:GetNormalMenuTemplate( contextid )
			if menu_ex ~= nil then
				local count = menu_ex:GetItemCount()
				for i = 1, count do
					local item = menu_ex:GetItem( i )
					if item ~= nil then
						local template_name = attr.DefaultItemTemplate
						if item.type == 1 then
							template_name = attr.DefaultSpliterTemplate
						end
						local menu = self:GetControlObject("context_menu")
						local menu_item_template = templateMananger:GetTemplate( template_name, "ObjectTemplate" )
						if menu_item_template ~= nil then
							local menu_item = menu_item_template:CreateInstance( item.id )
							menu_item:SetType( item.type )
							menu_item:SetIconID( item.icon )
							menu_item:SetText( item.text )
							--此处修改了原来的代码顺序，应该先InsetItem再SetSubMenu,原来的代码是先SetSubMenu再InsetItem
							--将菜单条加入到菜单对象中
							if item.after_id == "_front_" then
								self:InsertItem( 1, menu_item )--添加到菜单的最前面
							elseif item.after_id == "_last_" then
								self:AddItem( menu_item )--添加到菜单的最后没
							else--将菜单插入到指定id菜单条的最后面
								for i = 1, self:GetItemCount() do
									local item_temp = self:GetItem( i )
									local id = item_temp:GetID()
									if item_temp ~= nil and item_temp:GetID() == item.after_id then
										if i < self:GetItemCount() then
											self:InsertItem( i+1, menu_item )
										else
											self:AddItem( menu_item )
										end
										break
									end
								end
							end
							menu_item:SetSubMenu( item.sub_menu )
							if item.on_select_func ~= nil then
								local cookie, ret = menu_item:AttachListener( "OnSelect", false, item.on_select_func )
							end
							if item.init_func ~= nil then
								item.init_func( menu_item )
							end
						end
					end
				end
			end
		end	
	end
		
	local bknRes = attr.BknID
	if bknRes ~= nil then
		local bkn = self:GetControlObject("menu.bkn")
		if attr.v_status == nil or attr.v_status == 1 then
			bkn:SetResID(bknRes)
		else
			bkn:SetResID(attr.UpBknID)
		end
	end
	
	--[[local shadingID = attr.ShadingID
	if shadingID ~= nil then
		local shading = self:GetControlObject("menu.shading")
		if attr.v_status == nil or attr.v_status == 1 then
			shading:SetResID(shadingID)
			shading:SetVisible( true )
		else
			shading:SetVisible( false )
		end
	end]]
--[[	
	if attr.SrcColorID ~= nil and attr.DestColorID ~= nil then
		local fill = self:GetControlObject("menu.bkg.fill")
		if fill == nil then
			local uiFactory = XLGetObject("Xunlei.UIEngine.ObjectFactory")
			local xarManager = XLGetObject("Xunlei.UIEngine.XARManager")
			local frame = self:GetControlObject("menu.frame")
			local fill = uiFactory:CreateUIObject("menu.bkg.fill", "FillObject")
			local grf = XLGetObject("Xunlei.XLGraphic.Factory.Object")
			if fill ~= nil then
				fill:SetFillType("Line")
				fill:SetSrcPt(0,0)
				fill:SetDestPt(0,1)
				fill:SetAlpha( attr.FillAlpha )
				fill:SetResProvider( xarManager )
				fill:SetSrcColor( attr.SrcColorID )
				fill:SetDestColor( attr.DestColorID )
				fill:SetBlendType( "Source" )
				local alphaProvider = XLGetGlobal("xunlei.SkinAlphaProvider")
				fill:SetAlpha( alphaProvider.GetMainWndAlpha() )
				frame:AddChild( fill )
				local left, top, right, bottom = self:GetObjPos()
				fill:SetObjPos( "2", "2", "father.width-2", "father.height - 2" )
				fill:AttachListener( "OnAbsPosChange", true, 
									function ( self_obj )
										local left,top,right,bottom = self_obj:GetObjPos()
										self_obj:SetSrcPt(0,0)
										self_obj:SetDestPt(0, bottom-top)
									end )
			end
		end
	end
	]]
	UpdateSize( self )
	
	return true
end

function UpdateSize( self )
	local menu = self:GetControlObject( "context_menu" )
	if menu ~= nil then
		local left, top, right, bottom = menu:GetObjPos()
		--menu:SetObjPos(left, top, right, bottom)
		local self_left, self_top, self_right, self_bottom = self:GetObjPos()
		self:SetObjPos( self_left, self_top, self_left + right - left, self_top + bottom - top )
	end
end

function EndMenu( self )
	local menu = self:GetControlObject( "context_menu" )
	if menu ~= nil then
		menu:EndMenu()
	end
end

function GetScreenPos(self, x, y, dontCalc)
	local left,top,right,bottom = self:GetObjPos()
	
	local width = right - left
	local height = bottom - top
	--XLMessageBox("get"..width.." "..x)
	local menuTree = self:GetOwner()
	local menuHostWnd = menuTree:GetBindHostWnd()
	
	local osshell = XLGetObject( "CoolJ.OSShell" )
	local lleft, ltop, lright, lbottom = 0,0,1200,800
	local rleft, rtop, rright, rbottom = 0,0,1200,800
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
	if y + height > sbottom and dontCalc ~= true then
		y = y - height
	end
	
	if x + width > sright and dontCalc ~= true then
		x = x - width
	end
	return x, y, width, height
end

--v_status垂直方向状态1表示往下弹，2表示往上弹
--h_status水平方向状态1表示往右弹，2表示往左弹
function SetPopStatus( self, v_status, h_status )
	local attr = self:GetAttribute()
	attr.v_status = v_status
	if h_status ~= nil then
		attr.h_status = h_status
	end
	
	
	local bknRes = attr.BknID
	if bknRes ~= nil then
		local bkn = self:GetControlObject("menu.bkn")
		if attr.v_status == nil or attr.v_status == 1 or attr.UpBknID == nil then
			bkn:SetResID(bknRes)
		else
			bkn:SetResID(attr.UpBknID)
		end
	end
	
	--[[local shadingID = attr.ShadingID
	if shadingID ~= nil then
		local shading = self:GetControlObject("menu.shading")
		if attr.v_status == nil or attr.v_status == 1 then
			shading:SetResID(shadingID)
			shading:SetVisible( true )
		else
			shading:SetVisible( false )
		end
	end]]
end

function AnimateShow(self)
	local attr = self:GetAttribute()
	local menuTree = self:GetOwner()
	
	local frame = self:GetControlObject("menu.frame")
	local bkn = self:GetControlObject("menu.bkn")
	local shading = self:GetControlObject("menu.shading")
	local left,top,right,bottom = self:GetObjPos()
	
	if attr.AnimationTemplateID == nil or attr.AnimationTemplateID == "" then
		frame:SetObjPos2("0","0","father.width","father.height")
		return
	end
	local templateMananger = XLGetObject("Xunlei.UIEngine.TemplateManager")
	if templateMananger then
		local animationTemplate = templateMananger:GetTemplate(attr.AnimationTemplateID,"AnimationTemplate")
		if animationTemplate then
			local ani = animationTemplate:CreateInstance()
			if ani then
				local function onAniFinish(self,old,new)
					if new == 4 then
						attr.MenuAniFinish = true
						frame:SetLimitChild( false )
						if attr.UserData then
							if not g_UserData then
								g_UserData = "11" 
							end
							if attr.UserData:GetAttribute().NowState ~= 3 then
								attr.UserData:SetState(1)
							end
						end
					end
				end
				
				if attr.AnimationTemplateID == "animation.menu.alpha" then
					--frame:SetObjPos(0,0,right-left,bottom-top)
					frame:SetObjPos2("0","0","father.width","father.height")
					frame:SetLimitChild( false )
					ani:BindRenderObj(frame,true)
					ani:SetKeyFrameAlpha(0,255)
				elseif attr.AnimationTemplateID == "animation.menu.pos" then
					ani:BindLayoutObj(frame)
					ani:BindCurveID("menu.show")
					local srcLeft, srcTop, srcRight, srcBottom
					if attr.v_status == nil or attr.v_status == 1 then
						srcTop = 0
						srcBottom = 0
					else
						srcTop = bottom - top
						srcBottom = bottom - top
					end
					
					if attr.h_status == nil or attr.h_status == 1 then
						srcLeft = 0
						srcRight = 0
					else
						srcLeft = right - left
						srcRight = right - left
					end
						
					ani:SetKeyFrameRect(srcLeft, srcTop, srcRight, srcBottom, 0,0,right-left,bottom-top)
					shading:SetObjPos( ((right-left)*0.1/18)*19,bottom - top - 31- 2,right-left-((right-left)*0.1/18)*19,bottom - top -2 )
				elseif attr.AnimationTemplateID == "animation.menu.new" then
					--frame:SetObjPos(0,0,right-left,bottom-top)
					frame:SetObjPos2("0","0","father.width","father.height")
					local aniAttr = ani:GetAttribute()
					aniAttr.AniType = 1 --显示
					if attr.h_status == nil or attr.h_status == 1 then
						aniAttr.Direction = "right"
					else
						aniAttr.Direction = "left"
					end
					ani:BindObj(self)
				end
				
				ani:AttachListener(true,onAniFinish)
				menuTree:AddAnimation(ani)
				ani:Resume()
			end
		end
	end
end

function AnimateHide(self)
	local attr = self:GetAttribute()
	local menuTree = self:GetOwner()
	local context = menuTree:GetRootObject()
	
	local frame = self:GetControlObject("menu.frame")
	local bkn = self:GetControlObject("menu.bkn")
	local shading = self:GetControlObject("menu.shading")
	
	frame:SetLimitChild(true)
	
	local function onAniFinish(self,old,new)
		if new == 4 then
			local tree = frame:GetOwner()
			local hostWnd = tree:GetBindHostWnd()
			hostWnd:FinalClear()
			if attr.UserData then
				if not g_UserData then
					g_UserData = attr.UserData 
				end
				if g_UserData ~= attr.UserData then
					g_UserData = attr.UserData 
					
					
					if attr.UserData:IsMouseInRect() then
						attr.UserData:SetState(2)
					else
						attr.UserData:SetState(0)
					end
				else
					attr.UserData:SetState(2)
				end
				if EscPress then
					attr.UserData:SetState(2)
					EscPress = nil
				end
			end
		end
	end
				
	if attr.AnimationTemplateID == nil or attr.AnimationTemplateID == "" then
		onAniFinish(nil,0,4)
		return
	end
	local templateMananger = XLGetObject("Xunlei.UIEngine.TemplateManager")
	if templateMananger then
		local animationTemplate = templateMananger:GetTemplate(attr.AnimationTemplateID,"AnimationTemplate")
		if animationTemplate then
			local ani = animationTemplate:CreateInstance()
			if ani then				
				local left,top,right,bottom = self:GetObjPos()
				
				if attr.AnimationTemplateID == "animation.menu.alpha" then
					frame:SetObjPos(0,0,right-left,bottom-top)
					frame:SetLimitChild( false )
					ani:BindRenderObj(frame,true)
					ani:SetKeyFrameAlpha(255,0)
				elseif attr.AnimationTemplateID == "animation.menu.pos" then
					ani:BindLayoutObj(frame)
					ani:BindCurveID("menu.hide")
					local destLeft, destTop, destRight, destBottom
					if attr.v_status == nil or attr.v_status == 1 then
						destTop = 0
						destBottom = 0
					else
						destTop = bottom - top
						destBottom = bottom - top
					end
					
					if attr.h_status == nil or attr.h_status == 1 then
						destLeft = 0
						destRight = 0
					else
						destLeft = right - left
						destRight = right - left
					end
						
					ani:SetKeyFrameRect(0,0,right-left,bottom-top,destLeft, destTop, destRight, destBottom)
				elseif attr.AnimationTemplateID == "animation.menu.new" then
					frame:SetObjPos(0,0,right-left,bottom-top)
					local aniAttr = ani:GetAttribute()
					aniAttr.AniType = 0 --隐藏
					ani:BindObj(self)
				end
				
				ani:AttachListener(true,onAniFinish)
				menuTree:AddAnimation(ani)
				ani:Resume()	
			end
		end
	end
end

function InsertItem( self, index, item )
	local menu = self:GetControlObject("context_menu")
	if menu ~= nil then
		menu:InsertItem( index, item )
	end
	UpdateSize( self )
end

function RemoveItem( self, index )
	local menu = self:GetControlObject("context_menu")
	if menu ~= nil then
		menu:RemoveItem( index )
	end
	UpdateSize( self )
end

function GetItemCount( self )
	local menu = self:GetControlObject("context_menu")
	if menu ~= nil then
		return menu:GetItemCount()
	end
end

function GetItem( self, index )
	local menu = self:GetControlObject("context_menu")
	if menu ~= nil then
		return menu:GetItem( index )
	end
end

function AddItem( self, item )
	local menu = self:GetControlObject("context_menu")
	if menu ~= nil then
		menu:AddItem( item )
	end
	UpdateSize( self )
end

function GetMenuBar( self )
	local father = self:GetFather()
	local temp = self
	while true do
		if temp:GetClass() == "NormalMenu" then
			if father == nil or father:GetClass() ~= "MenuItemObject" then
				local attr = temp:GetAttribute()
				return attr.menu_bar
			else
                temp = father
                father = father:GetFather()
			end
		else
			if father == nil then
				return
			end
			temp = father
			father = father:GetFather()
		end
	end
end

function OnKeyDown( self, char )
	local menu = self:GetControlObject("context_menu")
	if menu == nil then
		return
	end
	
	if char == 38 then --up
		menu:MoveToPrevItem()
	elseif char == 40 then --down
		menu:MoveToNextItem()
	elseif char == 39 then --right
		local item = menu:GetHoverItem()
		if item ~= nil then
			if item:HasSubMenu() then
				item:ShowSubMenu( true )
				return
			end
		end
		local menu_bar = GetMenuBar( self )
		if menu_bar ~= nil then
			menu_bar:MoveToNext( true )
		end
	elseif char == 37 then --left
		local father = self:GetFather()
		if father ~= nil and father:GetClass() == "MenuItemObject" then
			father:SetFocus( true )
			father:EndSubMenu()
		else
			local menu_bar = GetMenuBar( self )
			if menu_bar ~= nil then
				menu_bar:MoveToPrev( true )
			end
		end
	elseif char == 27 then--ESC
		local father = self:GetFather()
		EscPress =  true
		if father ~= nil and father:GetClass() == "MenuItemObject" then
			father:SetFocus( true )
			father:EndSubMenu()
		else
			local attr = self:GetAttribute()
			if attr.menu_bar ~= nil then
				attr.esc_close_menu = true
				attr.menu_bar:EndLastPopMenu()
			elseif father == nil then
				self:EndMenu()
			end
		end
	elseif char == 18 then--ALT
		local attr = self:GetAttribute()
		local menu_bar = GetMenuBar( self )
		if menu_bar ~= nil then
			attr.alt_close_menu = true
			menu_bar:EndLastPopMenu()
		end
	elseif char == 13 then--ENTER
		local item = menu:GetHoverItem()
		if item ~= nil then
			if item:HasSubMenu() then
				item:ShowSubMenu( true )
			else
				item:SelectItem()
			end
		end
	else
		local key_item = menu:GetKeyItem( char )
		if #key_item == 1 then
			if key_item[1]:HasSubMenu() then
				menu:SetHoverItem( key_item[1], false )				
				key_item[1]:ShowSubMenu( true )
			else
				key_item[1]:SelectItem()
			end
		elseif #key_item > 1 then
			local hover_item = menu:GetHoverItem()
			if hover_item == nil then
				menu:SetHoverItem( key_item[ 1 ], false )
			else
				for i = 1, #key_item do
					if key_item[i]:GetID() == hover_item:GetID() then
						if i == #key_item then
							menu:SetHoverItem( key_item[ 1 ], false )
							break
						else
							menu:SetHoverItem( key_item[ i + 1 ], false )
							break
						end
					else
						if i == #key_item then
							menu:SetHoverItem( key_item[ 1 ], false )
							break
						end
					end
				end
			end
		end
	end
end

function OnFocusChange( self, is_focus )
end

function MoveNextItem( self )
	local menu = self:GetControlObject("context_menu")
	if menu == nil then
		return
	end
	menu:MoveToNextItem()
end

function MovePrevItem( self )
	local menu = self:GetControlObject("context_menu")
	if menu == nil then
		return
	end
	menu:MoveToPrevItem()
end

function GetCurItem( self )
	local menu = self:GetControlObject("context_menu")
	if menu == nil then
		return
	end
	return menu:GetHoverItem()
end

function SetMenuBar( self, menu_bar )
	local attr = self:GetAttribute()
	attr.menu_bar = menu_bar
end