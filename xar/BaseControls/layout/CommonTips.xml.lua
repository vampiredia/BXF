local TIP_MARGIN = 10

function SetTipId(self, id)
	self:GetAttribute().tipId = id
end

function IntersectRect(left1,top1,right1,bottom1,left2,top2,right2,bottom2)
	local left,top,right,bottom
	left  = math.max(left1, left2);
    right = math.min(right1, right2);

    if left < right then 
        top = math.max(top1, top2);
        bottom = math.min(bottom1, bottom2);

        if top < bottom then
            return left,top,right,bottom
        end
    end

     return 0,0,0,0 
end

function SetText(self, text)
    local textobj = self:GetControlObject("tip.text")
    textobj:SetText(text)
end

function GetTipRect(self, hostCtrl)
	if hostCtrl == nil then
		return
	end
	
	local attr = self:GetAttribute()
	local shell = XLGetObject( "Xunlei.UIEngine.OSShell" )
	local waLeft,waTop,waRight,waBottom = shell:GetWorkArea()
	local ownerTree = self:GetOwner()
	local hostWnd = ownerTree:GetBindHostWnd()
	local HostWndLeft, HostWndTop, HostWndRight, HostWndBottom = hostWnd:GetWindowRect()
	local hostLeft,hostTop,hostRight,hostBottom = hostCtrl:GetAbsPos()
	local hostHeight = hostBottom - hostTop
	hostLeft,hostTop = hostWnd:ClientPtToScreenPt(hostLeft,hostTop)
	hostRight,hostBottom = hostWnd:ClientPtToScreenPt(hostRight,hostBottom)
	local initTipLeft,initTipTop,initTipRight,initTipBottom
	initTipLeft = hostLeft
	initTipTop = hostTop
	
	local limitTipLeft,limitTipTop,limitTipRight,limitTipBottom
	if attr.LimitTipRectLeft == nil then
		limitTipLeft = HostWndLeft + TIP_MARGIN
	else
		limitTipLeft = HostWndLeft + attr.LimitTipRectLeft
	end
	
	if attr.LimitTipRectTop == nil then
		limitTipTop = HostWndTop + TIP_MARGIN
	else
		limitTipTop = HostWndTop + attr.LimitTipRectTop
	end
	
	if attr.LimitTipRectRight == nil then
		limitTipRight = HostWndRight - TIP_MARGIN
	else
		limitTipRight = HostWndLeft + attr.LimitTipRectRight
	end
	
	if attr.LimitTipRectBottom == nil then
		limitTipBottom = HostWndBottom - TIP_MARGIN
	else
		limitTipBottom = HostWndTop + attr.LimitTipRectBottom
	end	
	
	local maxLimitTipLeft = math.max(HostWndLeft + TIP_MARGIN,limitTipLeft)
	if initTipLeft < maxLimitTipLeft then
		initTipLeft = maxLimitTipLeft
	end
	
    local maxLimitTipTop = math.max(HostWndTop + TIP_MARGIN,limitTipTop)
    if initTipTop < maxLimitTipTop then
        initTipTop = maxLimitTipTop
    end
    
	local minLimitTipRight = math.min(HostWndRight - TIP_MARGIN,limitTipRight)
    local minLimitTipBottom = math.min(HostWndBottom - TIP_MARGIN,limitTipBottom)
	
	limitTipLeft,limitTipTop,limitTipRight,limitTipBottom = IntersectRect(waLeft,waTop,waRight,waBottom,limitTipLeft,limitTipTop,limitTipRight,limitTipBottom)

	local text = self:GetControlObject("tip.text")
	local textwidth, textheight
	if attr.Multiline == false then
		text:SetEndEllipsis(true)
		textwidth, textheight = text:GetTextExtent()
	else
		text:SetEndEllipsis(false)
		text:SetMultiline(false)
		textwidth, textheight = text:GetTextExtent()
		text:SetMultiline(true)
		text:SetEndEllipsis(true)
		if attr.MultilineTextLimitWidth < textwidth and attr.MultilineTextLimitWidth > textwidth*0.8 then
			attr.MultilineTextLimitWidth = math.ceil(textwidth*0.5)+2*3 --左右各预留3像素作为文字与TextObject左右的间距
		end
		text:SetMultilineTextLimitWidth(attr.MultilineTextLimitWidth)
		textwidth, textheight = text:GetTextExtent()
	end
	
	local TipNeedWidth,TipNeedHeight
	local tipLeft,tipTop,tipRight,tipBottom
	TipNeedWidth = 2*attr.TextMarginH + textwidth
	TipNeedHeight = 2*attr.TextMarginV + textheight + 2
	if attr.TrackMouse == false then
		if attr.TipType == 1 then --左上
		    initTipLeft = hostRight - TipNeedWidth
			initTipTop = hostTop - TipNeedHeight
		elseif attr.TipType == 2 then --左下
		    initTipLeft = hostRight - TipNeedWidth
		    initTipTop = hostBottom
		elseif attr.TipType == 3 then --右上
		    initTipLeft = hostLeft
		    initTipTop = hostTop - TipNeedHeight
		elseif attr.TipType == 4 then --右下
		    initTipLeft = hostLeft
			initTipTop = hostBottom
		end
	else
        local cursorPosX,cursorPosY = shell:GetCursorPos()
        if attr.TipType == 1 then
            initTipLeft = cursorPosX - TipNeedWidth
            initTipTop = cursorPosY - TipNeedHeight
        elseif attr.TipType == 2 then
            initTipTop = cursorPosY
            initTipLeft = cursorPosX - TipNeedWidth
        elseif attr.TipType == 3 then
            initTipLeft = cursorPosX
            initTipTop = cursorPosY - TipNeedHeight
        elseif attr.TipType == 4 then
            initTipLeft = cursorPosX+8
            initTipTop = cursorPosY+16
        end 
	end
	
	initTipBottom = initTipTop + TipNeedHeight
	initTipRight = initTipLeft + TipNeedWidth
	
		if attr.TipType == 1 then 
			if initTipBottom - limitTipTop > limitTipBottom - initTipBottom then
				if initTipTop < limitTipTop then
					if initTipLeft < limitTipLeft then
						initTipLeft = limitTipLeft
						if attr.Multiline == true then
							local newLimitWidth = initTipRight - limitTipLeft - 2*attr.TextMarginH
							text:SetMultilineTextLimitWidth(newLimitWidth)
							textwidth, textheight = text:GetTextExtent()
							TipNeedWidth = 2*attr.TextMarginH + textwidth
							TipNeedHeight = 2*attr.TextMarginV + textheight + 2
							initTipRight = initTipLeft + TipNeedWidth
							initTipTop = initTipBottom-TipNeedHeight
						end
					end
				end
			else 
				if initTipTop < limitTipTop then 
					attr.TipType = 2
					if attr.TrackMouse == true then
					    initTipTop = initTipBottom
					    initTipBottom = initTipTop + TipNeedHeight
					else
					    initTipTop = hostBottom
					    initTipBottom = initTipTop+TipNeedHeight
					end
				end
			end
			
			if initTipLeft < limitTipLeft then
				initTipLeft = limitTipLeft
				if attr.Multiline == true then
					local newLimitWidth = initTipRight - limitTipLeft - 2*attr.TextMarginH
					text:SetMultilineTextLimitWidth(newLimitWidth)
					textwidth, textheight = text:GetTextExtent()
					TipNeedWidth = 2*attr.TextMarginH + textwidth
					TipNeedHeight = 2*attr.TextMarginV + textheight + 2
					initTipRight = initTipLeft + TipNeedWidth
					if attr.TipType == 1 then
						initTipTop =  initTipBottom - TipNeedHeight
					else
						initTipBottom = initTipTop + TipNeedHeight
					end
				end
			end
		elseif attr.TipType == 2 then
			if initTipBottom - limitTipTop < limitTipBottom - initTipBottom then
				if initTipBottom > limitTipBottom then
					if initTipLeft < limitTipLeft then
						initTipLeft = limitTipLeft
						if attr.Multiline == true then
							local newLimitWidth = initTipRight - limitTipLeft - 2*attr.TextMarginH
							text:SetMultilineTextLimitWidth(newLimitWidth)
							textwidth, textheight = text:GetTextExtent()
							TipNeedWidth = 2*attr.TextMarginH + textwidth
							TipNeedHeight = 2*attr.TextMarginV + textheight + 2
							initTipRight = initTipLeft + TipNeedWidth
							initTipBottom = initTipTop + TipNeedHeight
						end
					end
				end
			else
				if initTipBottom > limitTipBottom then
					attr.TipType = 1
					if attr.TrackMouse == true then
					    initTipBottom = initTipTop
					    initTipTop = initTipBottom - TipNeedHeight
					else
					    initTipBottom = hostTop
					    initTipTop = initTipBottom - TipNeedHeight
					end
				end
			end
			
			if initTipLeft < limitTipLeft then
				initTipLeft = limitTipLeft
				if attr.Multiline == true then
					local newLimitWidth = initTipRight - limitTipLeft - 2*attr.TextMarginH
					text:SetMultilineTextLimitWidth(newLimitWidth)
					textwidth, textheight = text:GetTextExtent()
					TipNeedWidth = 2*attr.TextMarginH + textwidth
					TipNeedHeight = 2*attr.TextMarginV + textheight + 2
					initTipRight = initTipLeft + TipNeedWidth
					if attr.TipType == 1 then
						initTipTop =  initTipBottom - TipNeedHeight
					else
						initTipBottom = initTipTop + TipNeedHeight
					end
				end
			end
		elseif attr.TipType == 3 then
			if initTipBottom - limitTipTop > limitTipBottom - initTipBottom then
				if initTipTop < limitTipTop then
					initTipRight = limitTipRight
					initTipLeft = limitTipRight - TipNeedWidth
					if initTipLeft < limitTipLeft then
						initTipLeft = limitTipLeft
					end
					if attr.Multiline == true then
						local newLimitWidth = limitTipRight - initTipLeft - 2*attr.TextMarginH
						text:SetMultilineTextLimitWidth(newLimitWidth)
						textwidth, textheight = text:GetTextExtent()
						TipNeedWidth = 2*attr.TextMarginH + textwidth
						TipNeedHeight = 2*attr.TextMarginV + textheight + 2
						initTipLeft = limitTipRight - TipNeedWidth
						initTipTop = initTipBottom-TipNeedHeight
					end
				end
			else
				if initTipTop < limitTipTop then
					attr.TipType = 4
					if attr.TrackMouse == true then
					    initTipTop = initTipBottom + 16
					    initTipBottom = initTipTop + TipNeedHeight
					    initTipLeft = initTipLeft+8
					else
					    initTipTop = hostBottom
					    initTipBottom = initTipTop+TipNeedHeight
					end	
				end
			end
			
			if initTipRight > limitTipRight then
				initTipRight = limitTipRight
				initTipLeft = limitTipRight - TipNeedWidth
				if initTipLeft < limitTipLeft then
					initTipLeft = limitTipLeft
				end
				if attr.Multiline == true then
					local newLimitWidth = limitTipRight - initTipLeft - 2*attr.TextMarginH
					text:SetMultilineTextLimitWidth(newLimitWidth)
					textwidth, textheight = text:GetTextExtent()
					TipNeedWidth = 2*attr.TextMarginH + textwidth
					TipNeedHeight = 2*attr.TextMarginV + textheight + 2
					initTipLeft = limitTipRight - TipNeedWidth
					if attr.TipType == 3 then
						initTipTop =  initTipBottom - TipNeedHeight
					else
						initTipBottom = initTipTop + TipNeedHeight
					end
				end
			end
		elseif attr.TipType == 4 then
			if initTipBottom - limitTipTop < limitTipBottom - initTipBottom then
				if initTipBottom > limitTipBottom then
					initTipRight = limitTipRight
					initTipLeft = limitTipRight - TipNeedWidth
					if initTipLeft < limitTipLeft then
						initTipLeft = limitTipLeft
					end
					if attr.Multiline == true then
						local newLimitWidth = limitTipRight - initTipLeft - 2*attr.TextMarginH
						text:SetMultilineTextLimitWidth(newLimitWidth)
						textwidth, textheight = text:GetTextExtent()
						TipNeedWidth = 2*attr.TextMarginH + textwidth
						TipNeedHeight = 2*attr.TextMarginV + textheight + 2
						initTipLeft = limitTipRight - TipNeedWidth
						initTipBottom = initTipTop + TipNeedHeight
					end
				end
			else
				if initTipBottom > limitTipBottom then
					attr.TipType = 3
					if attr.TrackMouse == true then
					    initTipBottom = initTipTop - 16
					    initTipTop = initTipBottom - TipNeedHeight
					    initTipLeft = initTipLeft-8
					else
					    initTipBottom = hostTop
					    initTipTop = initTipBottom - TipNeedHeight
					end
				end
			end
			
			if initTipRight > limitTipRight then
				initTipRight = limitTipRight
				initTipLeft = limitTipRight - TipNeedWidth
				if initTipLeft < limitTipLeft then
					initTipLeft = limitTipLeft
				end
				if attr.Multiline == true then
					local newLimitWidth = limitTipRight - initTipLeft - 2*attr.TextMarginH
					text:SetMultilineTextLimitWidth(newLimitWidth)
					textwidth, textheight = text:GetTextExtent()
					TipNeedWidth = 2*attr.TextMarginH + textwidth
					TipNeedHeight = 2*attr.TextMarginV + textheight + 2
					initTipLeft = limitTipRight - TipNeedWidth
					if attr.TipType == 3 then
						initTipTop =  initTipBottom - TipNeedHeight
					else
						initTipBottom = initTipTop + TipNeedHeight
					end
				end
			end
		end
	tipLeft,tipTop,tipRight,tipBottom = IntersectRect(limitTipLeft,limitTipTop,limitTipRight,limitTipBottom,initTipLeft,initTipTop,initTipRight,initTipBottom)
	local parent = self:GetParent()
	local parentLeft,parentTop,parentRight,parentBottom = parent:GetAbsPos()
	tipLeft,tipTop = hostWnd:ScreenPtToClientPt(tipLeft,tipTop)
	tipRight,tipBottom = hostWnd:ScreenPtToClientPt(tipRight,tipBottom)
	tipLeft = tipLeft - parentLeft
	tipTop = tipTop - parentTop
	tipRight = tipRight - parentLeft
	tipBottom = tipBottom - parentTop
		
    return tipLeft,tipTop,tipRight,tipBottom
end

function DeleteSelf(self)
    local parent = self:GetParent()
    parent:RemoveChild(self)
end

function SetType(self, type_)
    local bkg = self:GetControlObject("tip.bkg")
    local text = self:GetControlObject("tip.text")
    local left, top, right, bottom = text:GetObjPos()
	local attr = self:GetAttribute()
	attr.TipType = type_
    if type_ == 1 then
    elseif type_ == 2 then
        text:SetObjPos(attr.TextMarginH+attr.TextMarginLeft, attr.TextMarginV+attr.TextMarginTop, "father.width-"..attr.TextMarginH, "father.height-"..attr.TextMarginV)
    elseif type_ == 3 then
    elseif type_ == 4 then
        text:SetObjPos(attr.TextMarginH+attr.TextMarginLeft, attr.TextMarginV+attr.TextMarginTop, "father.width-"..attr.TextMarginH, "father.height-"..attr.TextMarginV)
    end
end

function SetMultilineParam(self, isMultiline, width)
	local attr = self:GetAttribute()
	attr.Multiline = isMultiline
	attr.MultilineTextLimitWidth = width
	local text = self:GetControlObject("tip.text")
	text:SetMultiline(isMultiline)
	text:SetMultilineTextLimitWidth(width)
end



function OnPosChange(self)
	local attr = self:GetAttribute()
	local textObj = self:GetControlObject("tip.text")
	local left, top, right, bottom = self:GetObjPos()
	local width, height = right - left, bottom - top
	left = attr.TextMarginH+attr.TextMarginLeft
	top = attr.TextMarginV+attr.TextMarginTop
	right = left + width - 2*attr.TextMarginH
	bottom = top + height - 2*attr.TextMarginV
	textObj:SetObjPos(left, top, right, bottom)
	
	local hostWndManager = XLGetObject("Xunlei.UIEngine.HostWndManager")
	local tipsHostWnd = hostWndManager:GetHostWnd("WHome.Tips.HostWnd")
	if tipsHostWnd ~= nil then
		tipsHostWnd:SetPositionByObject(0,0,self)
	end
end

function OnInitControl(self)
	local attr = self:GetAttribute()
	local bkgObj = self:GetControlObject("tip.bkg")
	self:SetType(attr.TipType)
	bkgObj:SetTextureID(attr.BkgTexture)
	local textObj = self:GetControlObject("tip.text")
	textObj:SetMultiline(attr.Multiline)
	textObj:SetMultilineTextLimitWidth(attr.MultilineTextLimitWidth)
	textObj:SetHAlign(attr.TextHAlign)
	textObj:SetVAlign(attr.TextVAlign)
	textObj:SetTextColorResID(attr.TextColor)
	textObj:SetTextFontResID(attr.TextFont)
	textObj:SetEnableShadow(attr.Shadow)
	textObj:SetShadowColorResID(attr.ShadowColor)
	local templateMananger = XLGetObject("Xunlei.UIEngine.TemplateManager")
	local hostWndManager = XLGetObject("Xunlei.UIEngine.HostWndManager")
	--local tipsHostWnd = hostWndManager:GetHostWnd("WHome.Tips.HostWnd")
	--if tipsHostWnd ~= nil then
	--	return
	--end
	local tipsHostWndTemplate = templateMananger:GetTemplate("WHome.tips","HostWndTemplate")
	if attr.tipId == nil then
		attr.tipId = XLGetGlobal("xunlei.TipsHelper"):GetNewWindowTipId()
	end
	tipsHostWnd = tipsHostWndTemplate:CreateInstance("WHome.Tips.HostWnd" .. attr.tipId)
	attr.tipHostWndId = "WHome.Tips.HostWnd" .. attr.tipId
	if tipsHostWnd ~= nil then
		local function OnCreate(hostwnd)
			local objTree = hostwnd:GetBindUIObjectTree()
			if objTree ~= nil then
				attr.objTree = objTree
				local bkg = objTree:GetUIObject("tip.bkg")
				bkg:SetTextureID(attr.BkgTexture)
				local text = objTree:GetUIObject("tip.text")
				text:SetMultiline(attr.Multiline)
				text:SetMultilineTextLimitWidth(attr.MultilineTextLimitWidth)
				text:SetHAlign(attr.TextHAlign)
				text:SetVAlign(attr.TextVAlign)
				text:SetTextColorResID(attr.TextColor)
				text:SetTextFontResID(attr.TextFont)
				text:SetEnableShadow(attr.Shadow)
				text:SetShadowColorResID(attr.ShadowColor)
				text:SetText(textObj:GetText())
				local textLeft, textTop, textRight, textBottom = textObj:GetObjPos()
				text:SetObjPos(textObj:GetObjPos())
				local bkgLeft, bkgTop, bkgRight, bkgBottom = bkgObj:GetObjPos()
				bkg:SetObjPos(bkgLeft, bkgTop, bkgRight + attr.TextMarginLeft,bkgBottom + attr.TextMarginTop)
				local absLeft, absTop = self:GetAbsPos()
				local ownerTree = self:GetOwner()
				local mainWnd = ownerTree:GetBindHostWnd()
				local absScreenLeft, absScreenTop = mainWnd:ClientPtToScreenPt(absLeft, absTop)
				hostwnd:Move(absScreenLeft, absScreenTop, absScreenLeft + bkgRight - bkgLeft,absScreenTop + bkgBottom - bkgTop)
				if attr.OnWndCreateFunc ~= nil then
					attr.OnWndCreateFunc(hostwnd)
				end
			end
		end
		
		tipsHostWnd:SetTipTemplate("tips.template")
		if attr.EnableDelayShow == true then
			tipsHostWnd:DelayPopup(attr.DelayShowInterval)--新的调用会覆盖老的调用
		else
			tipsHostWnd:DelayPopup(0)
		end
		
		tipsHostWnd:AttachListener("OnCreate", false, OnCreate)
		attr.tipHostWnd = tipsHostWnd
	end
end

function OnHostMouseHover(self)
	local attr = self:GetAttribute()
	local timerManager = XLGetObject("Xunlei.UIEngine.TimerManager")
	function OnDelayShowTimer( item, id )
		if id == attr.DelayShowTimer then
			timerManager:KillTimer(attr.DelayShowTimer)
			attr.DelayShowTimer = nil
			self:SetVisible(true)
			self:SetChildrenVisible(true)	
		end
	end
	
	function OnAutoHideTimer( item, id )
		if id == attr.AutoHideTimer then
			timerManager:KillTimer(attr.AutoHideTimer)
			attr.AutoHideTimer = nil
			self:SetVisible(false)
			self:SetChildrenVisible(false)
			local hostWndManager = XLGetObject("Xunlei.UIEngine.HostWndManager")
			local tipsHostWnd = hostWndManager:GetHostWnd("WHome.Tips.HostWnd")
			if tipsHostWnd == nil then
				return
			end
			
			tipsHostWnd:DelayCancel(0)
		end
	end
	
	if attr.MouseHover == nil or attr.MouseHover == false then
		if attr.EnableDelayShow == true then
			self:SetVisible(false)
			self:SetChildrenVisible(false)
			attr.DelayShowTimer = timerManager:SetTimer(OnDelayShowTimer, attr.DelayShowInterval)
		end
		
		attr.MouseHover = true
	end
	
	if self:GetVisible() == true and attr.EnableAutoHide == true then
		attr.AutoHideTimer = timerManager:SetTimer( OnAutoHideTimer, attr.AutoHideInterval)
	end
end

function OnHostMouseLeave(self)
	local hostWndManager = XLGetObject("Xunlei.UIEngine.HostWndManager")
	local tipsHostWnd = hostWndManager:GetHostWnd("WHome.Tips.HostWnd")
	if tipsHostWnd == nil then
		return
	end
	
	tipsHostWnd:DelayCancel(0)
	
	local attr = self:GetAttribute()
	local timerManager = XLGetObject("Xunlei.UIEngine.TimerManager")
	if attr.DelayShowTimer ~= nil then
		timerManager:KillTimer(attr.DelayShowTimer)
		attr.DelayShowTimer = nil
	end
	
	if attr.AutoHideTimer ~= nil then
		timerManager:KillTimer(attr.AutoHideTimer)
		attr.AutoHideTimer = nil
	end
	
	attr.MouseHover = false
end

function GetSize(self)
    local text = self:GetControlObject("tip.text")
    local textwidth, textheight = text:GetTextExtent()
    return textwidth + 10, textheight + 10
end

function OnDestroy(self)
	local hostWndManager = XLGetObject("Xunlei.UIEngine.HostWndManager")
	local tipsHostWnd = hostWndManager:GetHostWnd("WHome.Tips.HostWnd" .. self:GetAttribute().tipId)
	if tipsHostWnd then
		tipsHostWnd:DelayCancel(0) --指定延时为0，就是立刻隐藏
		
		local wndId = tipsHostWnd:GetID()
		local hostwndManager = XLGetObject("Xunlei.UIEngine.HostWndManager")
		if wndId ~= nil then
			hostwndManager:RemoveHostWnd(wndId)
		end
	end
end