function TAI_OnInitControl(self)
	local attr = self:GetAttribute()
end

function TAI_OnClick(self)
	local shell = XLGetObject( "CoolJ.OSShell" )
	--XLMessageBox(shell:UUID())

	local ctrl = self:GetOwnerControl():GetOwnerControl()
	local objFactory = XLGetObject("Xunlei.UIEngine.ObjectFactory")
	
	local obj = objFactory:CreateUIObject(shell:UUID(), "CoolJ.TableFAQItem")
	ctrl:AddItem(obj)
	
end