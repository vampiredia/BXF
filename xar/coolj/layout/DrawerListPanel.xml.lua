--[[
-- DataSource ����Դ���洢
   DataManager ���ݹ���
   
   INSERT_COLUMN:
   json {
		drawer_column : {
			id: "service_name",
			name: "��������",
		}
		drawer_column_item : [
			{
				id: "service_child_name",
				name: "��ϸ����",
			},
			{
				id: "charge_standard",
				name: "�շѱ�׼",
			},
			{
				id: "contact_phone",
				name: "��ϵ�绰",
			},
		]
   }
   INSERT_ITEM:
   json {
		[
			id: 1,
			name: "ά��",
			item: [
				{
					service_child_name: "���ݷ�ˮ",
					charge_standard: "30Ԫ/ƽ��",
					contact_phone: "010-59883939"
				},
				{
					service_child_name: "����ά��",
					charge_standard: "���",
					contact_phone: "13810012120"
				},
			],
		],
		
   }

]]