--[[
-- 全局公共函数
-- @author zhiyuan <zhiyuan12@staff.weibo.com>
--]]
-- 转化为可以用下标的字符串
function my_string (s)
    assert(type(s) == "string", "string expected")
    local ms = s or ""
    local u = newproxy(true)
    local mt = getmetatable(u)
    local relatpos = function(p)
        local l = #ms
        if p < 0 then p = l + p + 1 end
        if p < 1 then p = 1 end
        return p, l
    end
    mt.__index = function(_, k)
        assert(type(k) == "number", "number expected as key")
        local k, l = relatpos(k)
        if k <= l then
            return ms:sub(k, k)
        end
    end
    mt.__newindex = function(_, k, v)
        assert(type(k) == "number", "number expected as key")
        assert(type(v) == "string" and #v == 1, "character expected as value")
        local k, l = relatpos(k)
        if k <= l + 1 then
            ms = ms:sub(1, k - 1) .. v .. ms:sub(k + 1, l)
        end
    end
    mt.__len = function(_) return #ms end
    mt.__tostring = function(_) return ms end
    return u
end
-- 首字母大写
function ucfirst(s)
    local ts = my_string(s);
    ts[1] = string.upper(ts[1])
    return tostring(ts)
end
-- 变量输出
function var_dump(...)
    recurse = function (o, indent)
        if indent == nil then indent = '' end
        local indent2 = indent .. '  '
        if type(o) == 'table' then
            local s = indent .. '{' .. '\n'
            local first = true
            for k, v in pairs(o) do
                if first == false then s = s .. ', \n' end
                if type(k) ~= 'number' then k = string(k) end
                s = s .. indent2 .. '[' .. k .. '] = ' .. recurse(v, indent2)
                first = false
            end
            return s .. '\n' .. indent .. '}'
        elseif type(o) == 'userdata' then
            return o
        elseif type(o) == 'string' then
            return string(o)
        elseif type(o) == 'function' or type(o) == 'thread' or type(o) == 'nil' or type(o) == 'userdata' then
            return type(o)
        else
            return o
        end
    end
    string = function (o)
        return '"' .. tostring(o) .. '"'
    end
    local args = {...}
    if #args > 1 then
        var_dump(args)
    else
        ngx.say(recurse(args[1]))
    end

end
