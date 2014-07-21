function GetTipContextObject(self)
	return self:GetControlObject("tip.context")
end

function ClearTipBkg(self)
	self:GetControlObject("tip.bkg"):SetTextureID("")
end

function GetTipSize(self)	
	local attr = self:GetAttribute()
	attr.textMarginWidth = attr.textMarginWidth or 0
	attr.textMarginHeight = attr.textMarginHeight or 3
	local w,h = self:GetControlObject("tip.Text"):GetTextExtent()
	return w + 10 + attr.textMarginWidth, h + 5 + attr.textMarginHeight
end

function FillTipData(self, tipData)
	local function FillTipContext(tip, data)
		tip:GetAttribute().tipData = data	
		if type(data) ~= "table" and type(data) ~= "string" then		
			return
		end	
		if type(data) == "string" then	
			tip:GetControlObject("tip.Text"):SetText(data)
			tip:GetControlObject("tip.Text"):SetObjPos(0, 3, "father.width", "father.height")
		elseif type(data) == "table" then
			if data["multiline"] then
				tip:GetControlObject("tip.Text"):SetMultiline(true)
				tip:GetControlObject("tip.Text"):SetMultilineTextLimitWidth(data["textMaxWidth"])
				--tip:GetControlObject("tip.Text"):SetText(data["text"])
			end			
			if data["text"] ~= nil then
				tip:GetControlObject("tip.Text"):SetText(data["text"])
			end
			if data["bkgResId"] ~= nil then
				tip:GetControlObject("tip.bkg"):SetTextureID(data["bkgResId"])
			end	
			
			local attr = tip:GetAttribute()
			attr.textMarginLeft = data["TextMarginLeft"] or 0
			attr.textMarginTop = data["TextMarginTop"] or 3
			attr.textMarginRight = data["TextMarginRight"] or 0
			attr.textMarginBottom = data["TextMarginBottom"] or 0
			
			attr.textMarginWidth = attr.textMarginLeft + attr.textMarginRight
			attr.textMarginHeight = attr.textMarginTop + attr.textMarginBottom
			
			tip:GetControlObject("tip.Text"):SetObjPos(attr.textMarginLeft, attr.textMarginTop, "father.width", "father.height")
			
		end
	end	
	if type(tipData) == "function" then
		tipData = tipData(self)
	end
	
	FillTipContext(self, tipData)
end

function GetTipData(self)
	local attr = self:GetAttribute()
	if attr == nil then
		return nil
	end

	return self:GetAttribute().tipData
end

function GetTipContextObject(self)
	return self:GetControlObject("tip.context")
end
