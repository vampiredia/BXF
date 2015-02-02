-- LoginWnd ��������
-- Param��
--	url	���������ַ
--	method	���󷽷�������GET��POST
--	param	�������������get�������˴�Ϊ''
--	callback	����ص��ӿڣ�����
--		function callback(ret, msg, result)
function HttpRequest(url, method, param, callback)
	local httpclient = XLGetObject("Whome.HttpCore.Factory"):CreateInstance()
	httpclient:AttachResultListener(
		function(result, http_code)
			callback(0, "success", {})
		end
	)
	httpclient:Perform(url, method, param)
end

function RegisterGlobal()
	XLSetGlobal("HttpRequest", HttpRequest)
end