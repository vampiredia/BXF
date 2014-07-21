function OnInitControl(self)
	local attr = self:GetAttribute()
	
	if attr.Text ~= nil then
		self:SetText(attr.Text)
	end
end

function SetResPackage(self, resPackage)
	local attr = self:GetAttribute()
	if attr.ResPackage == nil or attr.ResPackage ~= resPackage then
		attr.ResPackage = resPackage
		if attr.Text ~= nil then
			self:SetText(attr.Text)
		end
	end
end

function SetTextColor(self, textColor)
	local attr = self:GetAttribute()
	local lowerColor = string.lower(textColor)
	if lowerColor == "white" or lowerColor == "black" then
		if attr.TextColor ~= lowerColor then
			attr.TextColor = lowerColor
			self:SetText(attr.Text)
		end
	end
end

function SetControlVisible(self, bVisible)
	self:SetVisible(false, bVisible)
	self:SetChildrenVisible(false, bVisible)
end

function SetPoint2NumDistance(self, distance)
	local attr = self:GetAttribute()
	if attr.point2numDistance ~= distance then
		attr.point2numDistance = distance
		self:SetText(attr.Text)
	end
end

function SetPoint2SymbolDistance(self, distance)
	local attr = self:GetAttribute()
	if attr.point2symbolDistance ~= distance then
		attr.point2symbolDistance = distance
		self:SetText(attr.Text)
	end
end

function SetNum2SymbolDistance(self, distance)
	local attr = self:GetAttribute()
	if attr.num2symbolDistance ~= distance then
		attr.num2symbolDistance = distance
		self:SetText(attr.Text)
	end
end

function SetNum2NumDistance(self, distance)
	local attr = self:GetAttribute()
	if attr.num2numDistance ~= distance then
		attr.num2numDistance = distance
		self:SetText(attr.Text)
	end
end

function SetText(self, text)
	local objFactory = XLGetObject("Xunlei.UIEngine.ObjectFactory")
	local stringText = tostring(text)
	local attr = self:GetAttribute()
	attr.Text = stringText
	
	local textColor = self:GetAttribute().TextColor
	local singleNumArray = {}
	local strLength = string.len(stringText)
	for i = 1, strLength do
		singleNumArray[#singleNumArray + 1] = string.sub(stringText, i, i)
	end
	
	local layoutObj = self:GetControlObject("ImageTextLayout")
	local orginChildCount = layoutObj:GetChildCount()
	local imageNumObjArray = {}
	
	for i = 1, strLength do
		if i <= orginChildCount then
			imageNumObjArray[i] = layoutObj:GetChildByIndex(i - 1)
		else
			imageNumObjArray[i] = objFactory:CreateUIObject("numImage" .. i, "ImageObject")
		end
	end
	
	--多出来的不用的obj，remove掉
	local noUserObjArray = {}
	if strLength < orginChildCount then
		for i = 1, orginChildCount - strLength do
			noUserObjArray[#noUserObjArray + 1] = layoutObj:GetChildByIndex(i + strLength - 1)
		end
	end
	
	for i = 1, #noUserObjArray do
		layoutObj:RemoveChild(noUserObjArray[i])
	end
	
	local startX = 0
	local textColor = nil
	local resPackage = "Normal"
	if attr.ResPackage ~= nil then
		resPackage = attr.ResPackage
	end
	
	if attr.TextColor == "white" then
		textColor = "whiteText"
	else
		textColor = "blackText"
	end
	
	for i = 1, strLength do
		if singleNumArray[i] == "." then
			imageNumObjArray[i]:SetResID(resPackage .. ".P." .. textColor .. ".Point")
			imageNumObjArray[i]:SetObjPos(startX, 0, startX + 1, 9)
			if i < strLength then
				if singleNumArray[i + 1] == "%" then
					startX = startX + 1 + attr.point2symbolDistance
				else
					startX = startX + 1 + attr.point2numDistance
				end
			end
		elseif singleNumArray[i] == "%" then
XLPrint("RESPAKDFJLS:" .. resPackage)		
			imageNumObjArray[i]:SetResID(resPackage .. ".S." .. textColor .. ".Percent")
			imageNumObjArray[i]:SetObjPos(startX, 0, startX + 9, 9)
			if i < strLength then
				if singleNumArray[i + 1] == "." then
					startX = startX + 9 + attr.point2symbolDistance
				else
					startX = startX + 9 + attr.num2symbolDistance
				end
			end
		elseif singleNumArray[i] == "/" then
			imageNumObjArray[i]:SetResID(resPackage .. ".S." .. textColor .. ".slash")
			imageNumObjArray[i]:SetObjPos(startX, 0, startX + 3, 9)
			if i < strLength then
				if singleNumArray[i + 1] == "." then
					startX = startX + 3 + attr.point2symbolDistance
				else
					startX = startX + 3 + attr.num2symbolDistance
				end
			end
		elseif singleNumArray[i] == "<" then
			imageNumObjArray[i]:SetResID(resPackage .. ".S." .. textColor .. ".less")
			imageNumObjArray[i]:SetObjPos(startX, 0, startX + 5, 9)
			if i < strLength then
				if singleNumArray[i + 1] == "." then
					startX = startX + 5 + attr.point2symbolDistance
				else
					startX = startX + 5 + attr.num2symbolDistance
				end
			end
		elseif tonumber(singleNumArray[i]) ~= nil then
			imageNumObjArray[i]:SetResID(resPackage .. ".N." .. textColor .. "." .. singleNumArray[i])
			imageNumObjArray[i]:SetObjPos(startX, 0, startX + 5, 9)
			if i < strLength then
				if singleNumArray[i + 1] == "." then
					startX = startX + 5 + attr.point2numDistance
				elseif singleNumArray[i + 1] == "%" then
					startX = startX + 5 + attr.num2symbolDistance
				else
					startX = startX + 5 + attr.num2numDistance
				end
			end
		else
			imageNumObjArray[i]:SetResID(resPackage .. ".C." .. textColor .. "." .. singleNumArray[i])
			imageNumObjArray[i]:SetObjPos(startX, 0, startX + 5, 9)
			if i < strLength then
				if singleNumArray[i + 1] == "." then
					startX = startX + 5 + attr.point2numDistance
				elseif singleNumArray[i + 1] == "%" then
					startX = startX + 5 + attr.num2symbolDistance
				else
					startX = startX + 5 + attr.num2numDistance
				end
			end
		end
	end
	
	if singleNumArray[#singleNumArray] == "." then
		startX = startX + 1
	elseif singleNumArray[#singleNumArray] == "%" then
		startX = startX + 9
	else
		startX = startX + 5
	end
	
	
	if strLength > orginChildCount then
		for i = 1, strLength - orginChildCount do
			layoutObj:AddChild(imageNumObjArray[i + orginChildCount])
		end
	end
	
	local l, t, r, b = self:GetObjPos()
	if r - l > startX then
		layoutObj:SetObjPos((r - l - startX) / 2.0, (b - t - 9) / 2.0, "father.width", "father.height")
	end
	
end
