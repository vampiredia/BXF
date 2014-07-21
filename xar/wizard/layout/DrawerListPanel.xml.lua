--[[
-- DataSource 数据源，存储
   DataManager 数据管理
   
   INSERT_COLUMN:
   json {
		drawer_column : {
			id: "service_name",
			name: "服务类型",
		}
		drawer_column_item : [
			{
				id: "service_child_name",
				name: "详细分类",
			},
			{
				id: "charge_standard",
				name: "收费标准",
			},
			{
				id: "contact_phone",
				name: "联系电话",
			},
		]
   }
   INSERT_ITEM:
   json {
		[
			id: 1,
			name: "维修",
			item: [
				{
					service_child_name: "房屋防水",
					charge_standard: "30元/平米",
					contact_phone: "010-59883939"
				},
				{
					service_child_name: "电梯维修",
					charge_standard: "免费",
					contact_phone: "13810012120"
				},
			],
		],
		
   }

]]