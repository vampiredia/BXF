

function OnInitControl(self)

end

function Btn_ViewPayProject(self)

end

function LBP_OnInitControl(self)
	local objFactory = XLGetObject("Xunlei.UIEngine.ObjectFactory")
	local headerTable = {
		{HeaderItemId='title', ItemWidth=200, Text="缴费分类", TextLeftOffset=7, TextHalign="left", SubItem=false, MaxSize=200, MiniSize=200, ShowSplitter=false, ShowSortIcon=false, IncludeNext=false, SortProperty=0}
	}
	table.foreach(headerTable, function(i, v) self:InsertColumn(v) end);
	self:ReloadHeader()
	
	local objFactory = XLGetObject("Xunlei.UIEngine.ObjectFactory")
	local datasource = objFactory:CreateUIObject(1, "Pay.DataSource")
	datasource:InitControl()
	local dataconverter = objFactory:CreateUIObject(2, "Pay.DataConverter")
	dataconverter:InitControl()
	self:SetDataSourceAndDataConverter(datasource, dataconverter)
	
	local payData = {
		{id=1, name="物业费", icon="texture.icon.rawmoney", account="6225********3122", bank="工商××××××××××××××××××", user="远××××××××××××××××团"},
		{id=2, name="停车费", icon="texture.icon.stopcar", account="6225********3123", bank="招商××××××××××××××××××", user="远××××××××××××××××团"},
		{id=3, name="水费", icon="texture.icon.watermoney", account="6225********3124", bank="建设××××××××××××××××××", user="远××××××××××××××××团"},
		{id=4, name="电费", icon="texture.icon.elemoney", account="6225********3125", bank="农业××××××××××××××××××", user="远××××××××××××××××团"},
		{id=5, name="燃气费", icon="texture.icon.firemoney", account="6225********3126", bank="工商××××××××××××××××××", user="远××××××××××××××××团"},
		{id=6, name="宽带费", icon="texture.icon.onlinemoney", account="6225********3127", bank="工商××××××××××××××××××", user="远××××××××××××××××团"},
		{id=7, name="固话费", icon="texture.icon.phonemoney", account="6225********3122", bank="工商××××××××××××××××××", user="远××××××××××××××××团"},
		{id=8, name="充值卡", icon="texture.icon.card", account="6225********3122", bank="工商××××××××××××××××××", user="远××××××××××××××××团"}
	}
	self:GetDataSource():SetData(payData)
	self:ReloadData()
end

function LBP_OnHeaderItemPosChanged(self, event, isDrag, GridInfoList)
	if isDrag == true then
		self:GetTableViewObj():UpdateItemInfo(isDrag, GridInfoList)
	end
end

function LBP_OnItemEvent(self, eventName, eventType, UserData, ItemObj)
	if eventType == "OnSelect" then
		--XLMessageBox(UserData['icon'])
		self:GetOwnerControl():GetControlObject("edit.user"):SetText(UserData["user"])
		self:GetOwnerControl():GetControlObject("edit.account"):SetText(UserData["account"])
		self:GetOwnerControl():GetControlObject("edit.bank"):SetText(UserData["bank"])
	elseif eventType == "OnHideDetails" then
	
	elseif eventType == "OnDragDetails" then
	end
end