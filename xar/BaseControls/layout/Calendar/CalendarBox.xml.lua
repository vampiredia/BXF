function OnInitControl(self)
	local attr = self:GetAttribute()
	self:UpdateUI()
	self:UpdateDays(attr.Year, attr.Month)
	
	local temp = os.date("*t", os.time())
	self:SetSelect(temp.day, temp.month, temp.year)
--[[	
	local timerManager = XLGetObject("Xunlei.UIEngine.TimerManager")
	attr.TimerID = timerManager:SetTimer(
		function() 
			self:UpdateTime() 
		end
		, 200)
]]
end

function UpdateTime(self)
	local attr = self:GetAttribute()
	local temp = os.date("*t", os.time())
	--attr.Year = temp.year
	--attr.Month = temp.month
	--attr.Day = temp.day
	attr.Time = os.date("%H:%M:%S")
	
	local currentDate = self:GetControlObject("textlink.current.date")
	currentDate:SetText(temp.year.."年"..temp.month.."月"..temp.day.."日")
	local timeObj = self:GetControlObject("text.time")
	timeObj:SetText(attr.Time)
	local weekObj = self:GetControlObject("text.week")
	local weekName = {"星期日", "星期一", "星期二", "星期三", "星期四", "星期五", "星期六"}
	weekObj:SetText(weekName[temp.wday])
--[[
	local temp = os.date("*t", os.time())
	local xarManager = XLGetObject("Xunlei.UIEngine.XARManager")
	local minute = xarManager:GetBitmap("texture.user.head.pic")
	local s, w, h, l = minute:GetInfo()
	local fac = XLGetObject("Xunlei.XLGraphic.Factory.Object")
	local transform = fac:CreateRotateTrans(0, 0, temp.sec*6)
	local new = fac:CreateBitmap("ARGB32", w, h)
	transform:DoTransform(minute, new)
	local bmpObj = self:GetControlObject("test")
	bmpObj:SetBitmap(new)
]]
end

function UpdateUI(self)
	local attr = self:GetAttribute()
	
	local titleObj = self:GetControlObject("title")
	if attr.Level == 0 then 
		titleObj:SetText(attr.Year.."年"..attr.Month.."月")
		self:UpdateDays(attr.Year, attr.Month)
	elseif attr.Level == 1 then 
		titleObj:SetText(attr.Year)
		self:UpdateMonths(attr.Year)
	elseif attr.Level == 2 then 
		local year = math.floor(attr.Year / 10) * 10
		if year >= attr.MinYear and year <= attr.MaxYear then
			titleObj:SetText(year.." - "..year+9)
			self:UpdateYears(attr.Year)
		end
	elseif attr.Level == 3 then 
		local year = math.floor(attr.Year / 100) * 100
		if year >= attr.MinYear and year <= attr.MaxYear then
			titleObj:SetText(year.." - "..year+99)
			self:UpdateAges(attr.Year)
		end
	end
end

function OnTimer(self)
	
end

function KillTimer(self)
	
end

--
-- 日期更新 - 天更新
--
function UpdateDays(self, year, month)
	local attr = self:GetAttribute()
	--[[
		一	二	三	四	五	六	日
		1	2	3	4	5	6	7
		8	9	10	11	12	13	14
		15	16	17	18	19	20	21
		22	23	24	25	26	27	28
		29	30	31	32	33	34	35
		36	37	38	39	40	41	42
		
		1号 in [2,3,4,5,6,7,8]
	]]
	local ret = self:IsMonthValid(month) and self:IsYearValid(year)
	if not ret then return end
	
	local fbTime = os.time{year=year, month=month, day=1}
	local oneday = 24*60*60
	local today = os.date("*t", fbTime)
	local index = today.wday - 1
	if today.wday < 3 then index = index + 7 end
	
	local objFactory = XLGetObject("Xunlei.UIEngine.ObjectFactory")
	local content = self:GetControlObject("layout.content")
	content:RemoveAllChild()
	local l,t,r,b = content:GetObjPos()
	--local obj = objFactory:CreateUIObject("item."..i, "TreeItem")
	-- add obj for week tip
	local week = {"一", "二", "三", "四", "五", "六", "日"}
	for i=1, #week do
		local obj =objFactory:CreateUIObject("week."..i, "TextObject")
		content:AddChild(obj)
		obj:SetText(week[i])
		obj:SetObjPos((i-1)*attr.DayItemWidth, 0, i*attr.DayItemWidth, 0+attr.DayItemHeight)
		obj:SetVAlign("center")
		obj:SetHAlign("center")
	end
	-- add gray line 
	local lineObj = objFactory:CreateUIObject("line", "LineObject")
	content:AddChild(lineObj)
	lineObj:SetObjPos(3, 17, r-l-6, 19)
	lineObj:SetLinePenResID("pen.solid")
	lineObj:SetLineColorResID("calendar.line")
	lineObj:SetLinePoint(0, 1, r-l-6, 1)
	
	for i=1, 42 do
		local day = os.date("%d", fbTime + (i-index)*oneday)+0
		local month = os.date("%m", fbTime + (i-index)*oneday)+0
		local year = os.date("%Y", fbTime + (i-index)*oneday)+0
		local obj = objFactory:CreateUIObject("day."..i, "WHome.Button")
		local oattr = obj:GetAttribute()
		oattr.ShowFocusRect = true
		oattr.NormalBkgID = ""
		--oattr.DownBkgID = ""
		--oattr.DisableBkgID = ""
		--oattr.HoverBkgID = ""
		oattr.FocusRectWidth = attr.DayItemWidth-2
		oattr.FocusRectHeight = attr.DayItemHeight-2
		oattr.FocusRectLeft = 1
		oattr.FocusRectTop = 1
		oattr.Month = month
		oattr.Day = day
		oattr.Year = year
		if month ~= attr.Month then 
			oattr.TextColor = "system.gray"
		end
		content:AddChild(obj)
		obj:SetText(day)
		local left = ((i-1) % 7)*attr.DayItemWidth
		local right = left + attr.DayItemWidth
		local top = math.floor((i+6) / 7)*attr.DayItemHeight
		local bottom = top + attr.DayItemHeight
		obj:SetObjPos(left, top, right, bottom)
		if month == attr.Month and day == attr.Day then 
			obj:SetFocus(true)
		end
		
		local function onclick(owner)
			local dayAttr = owner:GetAttribute()
			local ret = self:IsYearValid(dayAttr.Year)
			if ret == true then 
				attr.Day = dayAttr.Day
				attr.Month = dayAttr.Month
				attr.Year = dayAttr.Year
			end
			self:UpdateUI()
		end
		obj:AttachListener("OnClick", true, onclick)
	end
end

function DayAdjust(self, year, month, day)
	local temp = os.date("*t", os.time{year=year, month=month, day=day})
	return temp.year, temp.month, temp.day
end

function IsMonthValid(self, month)
	local attr = self:GetAttribute()
	return (month >= attr.MinMonth and month <= attr.MaxMonth)
end

function IsYearValid(self, year)
	local attr = self:GetAttribute()
	return (year >= attr.MinYear and year <= attr.MaxYear)
end

function BTN_OnLeft(self)
	local ctrl = self:GetOwnerControl()
	
	local attr = ctrl:GetAttribute()
	if attr.Level == 0 then
		offset = -1
	elseif attr.Level == 1 then 
		offset = -12
	elseif attr.Level == 2 then 
		offset = -10 * 12 
	elseif attr.Level == 3 then
		offset = -100 * 12
	end
	
	ctrl:ChangeDate(offset)
end

function BTN_OnRight(self)
	local ctrl = self:GetOwnerControl()
	
	local attr = ctrl:GetAttribute()
	if attr.Level == 0 then
		offset = 1
	elseif attr.Level == 1 then 
		offset = 12
	elseif attr.Level == 2 then 
		offset = 10 * 12
	elseif attr.Level == 3 then
		offset = 100 * 12
	end
	
	ctrl:ChangeDate(offset)
end

function ChangeDate(self, offset)
	local attr = self:GetAttribute()
	
	local temp = attr.Year * 12 + attr.Month + offset

	local selectYear = math.floor((temp-1) / 12)
	if self:IsYearValid(selectYear) == false then 
		self:SetSelect(1, attr.Month, attr.Year)
		return 
	end
	
	attr.Year = selectYear
	attr.Month = (temp - 1) % 12 + 1
	self:SetSelect(1, attr.Month, attr.Year)
end

function SetSelect(self, day, month, year)
	local attr = self:GetAttribute()
	if day ~= nil then attr.Day = day end
	if month ~= nil then attr.Month = month end
	if year ~= nil then attr.Year = year end
	
	self:UpdateUI()
end

function BTN_OnCurrentDate(self)
	local ctrl = self:GetOwnerControl()
	local attr = ctrl:GetAttribute()
	attr.Level = 0
	
	local temp = os.date("*t", os.time())
	self:GetOwnerControl():SetSelect(temp.day, temp.month, temp.year)
	
	

--[[		
	local bmpObj = ctrl:GetControlObject("test")
	local image = bmpObj:GetBitmap()

	local fac = XLGetObject("Xunlei.XLGraphic.Factory.Object")
	local transform = fac:CreateRotateTrans(0, 0, 30)
	local new = fac:CreateBitmap("ARGB32", 100, 100)
	transform:DoTransform(image, new)
	bmpObj:SetBitmap(new)
	
	    if bmpObj then
        local aniFactory = XLGetObject("Xunlei.UIEngine.AnimationFactory")
        if aniFactory then
            local angleAnim = aniFactory:CreateAnimation("AngleChangeAnimation")
            angleAnim:BindObj(bmpObj)
            angleAnim:SetKeyFrameAngle(0, 0, 0, 0, 180, 360)
            angleAnim:SetTotalTime(30000)
			local objTree = self:GetOwner()
            objTree:AddAnimation(angleAnim)
            angleAnim:Resume()
        end
    end
	]]
end

function BTN_OnTop(self)
	local ctrl = self:GetOwnerControl()
	local attr = ctrl:GetAttribute()
	
	attr.Level = math.min(attr.Level + 1, attr.MaxLevel)
	ctrl:UpdateUI()
end

--
-- 日期更新 - 月更新
--
function UpdateMonths(self, year)
	--[[
		1月		2月		3月		4月
		5月		6月		7月		8月
		9月		10月	11月	12月
	]]
	local attr = self:GetAttribute()
	local ret = self:IsYearValid(year)
	if not ret then return end
	
	local objFactory = XLGetObject("Xunlei.UIEngine.ObjectFactory")
	local content = self:GetControlObject("layout.content")
	content:RemoveAllChild()
	local l,t,r,b = content:GetObjPos()
	for i=1, 12 do
		local name = i.."月"
		local obj = objFactory:CreateUIObject(name, "WHome.Button")
		local oattr = obj:GetAttribute()
		oattr.ShowFocusRect = true
		oattr.NormalBkgID = ""
		oattr.FocusRectWidth = attr.NormalItemWidth-2
		oattr.FocusRectHeight = attr.NormalItemHeight-2
		oattr.FocusRectLeft = 1
		oattr.FocusRectTop = 1
		oattr.Month = i
		oattr.Day = attr.Day
		oattr.Year = attr.Year
		content:AddChild(obj)
		obj:SetText(name)
		local left = ((i-1) % 4)*attr.NormalItemWidth
		local right = left + attr.NormalItemWidth
		local top = math.floor((i-1) / 4)*attr.NormalItemHeight
		local bottom = top + attr.NormalItemHeight
		obj:SetObjPos(left, top, right, bottom)
		if i == attr.Month then 
			obj:SetFocus(true)
		end
		
		local function onclick(owner)
			local dayAttr = owner:GetAttribute()
			attr.Level = math.min(attr.Level - 1, attr.MinLevel)
			attr.Year = dayAttr.Year
			attr.Month = dayAttr.Month
			self:UpdateUI()
		end
		obj:AttachListener("OnClick", true, onclick)
	end
end

--
--	日期更新 - 年更新
--
function UpdateYears(self, year)
--[[	2010 - 2019
		2009	2010	2011	2012
		2013	2014	2015	2016
		2017	2018	2019	2020
	]]
	local attr = self:GetAttribute()
	local ret = self:IsYearValid(year)
	if not ret then return end
	
	local objFactory = XLGetObject("Xunlei.UIEngine.ObjectFactory")
	local content = self:GetControlObject("layout.content")
	content:RemoveAllChild()
	local l,t,r,b = content:GetObjPos()
	local minYear = math.floor(year / 10) * 10
	local maxYear = minYear + 9
	for i=1, 12 do
		local curYear = minYear + i - 2
		local obj = objFactory:CreateUIObject(name, "WHome.Button")
		local oattr = obj:GetAttribute()
		oattr.ShowFocusRect = true
		oattr.NormalBkgID = ""
		oattr.FocusRectWidth = attr.NormalItemWidth-2
		oattr.FocusRectHeight = attr.NormalItemHeight-2
		oattr.FocusRectLeft = 1
		oattr.FocusRectTop = 1
		oattr.Year = curYear
		if curYear < minYear or curYear > maxYear then 
			oattr.TextColor = "system.gray"
		end
		content:AddChild(obj)
		obj:SetText(curYear)
		local left = ((i-1) % 4)*attr.NormalItemWidth
		local right = left + attr.NormalItemWidth
		local top = math.floor((i-1) / 4)*attr.NormalItemHeight
		local bottom = top + attr.NormalItemHeight
		obj:SetObjPos(left, top, right, bottom)
		if curYear == attr.Year then 
			obj:SetFocus(true)
		end
		
		local function onclick(owner)
			local dayAttr = owner:GetAttribute()
			attr.Level = math.min(attr.Level - 1, attr.MinLevel)
			attr.Year = dayAttr.Year
			self:UpdateUI()
		end
		obj:AttachListener("OnClick", true, onclick)
		if curYear < attr.MinYear or curYear > attr.MaxYear then
			obj:SetVisible(false)
			obj:SetChildrenVisible(false)
		end
	end
end

--
--	日期更新 - 年代更新
--
function UpdateAges(self, year)
--[[	2000 - 2099
		1990-	2000-	2010-	2020-	
		2000	2009	2019	2029	
		
		2030-	2040-	2050-	2060-	
		2039	2049	2059	2069
		
		2070-	2080-	2090-		
		2079	2089	2099
	]]
	local attr = self:GetAttribute()
	local ret = self:IsYearValid(year)
	if not ret then return end
	
	local objFactory = XLGetObject("Xunlei.UIEngine.ObjectFactory")
	local content = self:GetControlObject("layout.content")
	content:RemoveAllChild()
	local l,t,r,b = content:GetObjPos()
	local minYear = math.floor(year / 100) * 100
	local maxYear = minYear + 99
	for i=1, 12 do
		local curMinYear = minYear + (i - 2)*10
		local curMaxYear = curMinYear + 9
		local curYear = curMinYear + year % 10
		local obj = objFactory:CreateUIObject(name, "WHome.Button")
		local oattr = obj:GetAttribute()
		oattr.ShowFocusRect = true
		oattr.NormalBkgID = ""
		oattr.FocusRectWidth = attr.NormalItemWidth-2
		oattr.FocusRectHeight = attr.NormalItemHeight-2
		oattr.FocusRectLeft = 1
		oattr.FocusRectTop = 1
		oattr.Year = curYear
		if curYear < minYear or curYear > maxYear then 
			oattr.TextColor = "system.gray"
		end
		content:AddChild(obj)
		obj:SetText(curMinYear.."-\n"..curMaxYear)
		obj:SetMultiline(true)
		local left = ((i-1) % 4)*attr.NormalItemWidth
		local right = left + attr.NormalItemWidth
		local top = math.floor((i-1) / 4)*attr.NormalItemHeight
		local bottom = top + attr.NormalItemHeight
		obj:SetObjPos(left, top, right, bottom)
		obj:SetTextPos(4, 0, right-left, bottom-top)
		if curMinYear <= attr.Year and curMaxYear >= attr.Year then 
			obj:SetFocus(true)
		end
		
		local function onclick(owner)
			local dayAttr = owner:GetAttribute()
			attr.Level = math.min(attr.Level - 1, attr.MinLevel)
			attr.Year = dayAttr.Year
			self:UpdateUI()
		end
		obj:AttachListener("OnClick", true, onclick)
		
		if curYear < attr.MinYear or curYear > attr.MaxYear then
			obj:SetVisible(false)
			obj:SetChildrenVisible(false)
		end
	end
end

function GetCurrentDateTime(self)

end