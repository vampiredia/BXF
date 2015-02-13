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
		function(result, status_code)
			if callback == nil then return end
		
			if status_code > 399 and status_code < 500 then
				callback(-1, "网络异常，请重新再试")
			elseif status_code == 500 then
				local response = json.decode(result)
				callback(500, response['error_msg'], response['result'])
			elseif status_code > 500 then
				callback(-1, "服务器异常错误")
			else
				local response = json.decode(result)
				callback(0, result['error_msg'], response['result'])
			end
		end
	)
	local app = XLGetObject("CoolJ.App")
	local ret, ak = app:GetString("Community", "Community_Ak", "")
	if ak ~= "" then
		if method == "GET" then
			url = url.."&ak="..ak
		elseif method == "POST" then
			param = param.."&ak="..ak
		end
	end
	httpclient:Perform(url, method, param)
end

function RegisterGlobal()
	XLSetGlobal("HttpRequest", HttpRequest)
end