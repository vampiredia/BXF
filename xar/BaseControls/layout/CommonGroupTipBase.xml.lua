function GetTipContextObject(self)
	return self:GetControlObject("tip.context")
end

function FillTipData(self, tipData)
	self:GetAttribute().tipData = tipData
end

function GetTipData(self)
	return self:GetAttribute().tipData
end

function GetTipSize(self, tipType)

end