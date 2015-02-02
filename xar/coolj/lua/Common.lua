-- LoginWnd 弹窗函数
-- Param：
--	url	网络请求地址
--	method	请求方法、包括GET和POST
--	param	请求参数，对于get方法，此处为''
--	callback	请求回调接口，其中
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