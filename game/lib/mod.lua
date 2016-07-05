--Under MIT License
--Originally developed by Brendan Hansen

--[[ found on http://lua-users.org/lists/lua-l/2010-06/msg00314.html ]]
setfenv = setfenv or function(f, t)
    f = (type(f) == 'function' and f or debug.getinfo(f + 1, 'f').func)
    local name
    local up = 0
    repeat
        up = up + 1
        name = debug.getupvalue(f, up)
    until name == '_ENV' or name == nil
    if name then
        debug.upvaluejoin(f, up, function() return t end, 1) -- use unique upvalue, set it to f
    end
end

--[[
    Module System
    "imports" are defined by:
    import {
        SOMENAME = "path.to.lua.file";
        SOMEOTHERNAME = "path.to.other.file:use_this_to_override_what_is_exported";
        ANOTHERNAME = "path.to.thing:"; --this uses the default export (see below)
    }

    "exports" are defined by:
    return module {
        the_default_export_variable;
        other_export=some_value;
    }
]]
function import(reqs)
    local function convertPath(req)
        local r
        if req:find(":") ~= nil then
            r = req:sub(1, req:find(":") - 1)
        else
            r = req
        end
        r = r:gsub("%.", "/")
        return r
    end

    local function getField(req)
        if req:find(":") ~= nil then
            if req:sub(-1) == ":" then
                return "default"
            else
                return req:sub(req:find(":")+1)
            end
        else
            return nil
        end;
    end

    local dep = {}
    for name, req in pairs(reqs) do
        if type(req) ~= "string" then
            error "Please use strings for referencing modules"
        end
        local mod = require(convertPath(req))
        if type(mod) == "table" then
            local field = getField(req)
            if field ~= nil then
                if field == "default" and mod["default"] == nil then
                    dep[name] = mod
                else
                    dep[name] = mod[field]
                end
            else
                dep[name] = mod
            end
        else
            dep[name] = mod
        end
    end

    local newenv = setmetatable({}, {
        __index = function(t, k)
            local v = dep[k];
            if v == nil then v = _G[k] end
            return v
        end;
        __newindex = function(t, k, v)
            dep[k] = v;
        end;
    })
    setfenv(2, newenv)
end

function module(exp)
    exp["default"] = exp[1]
    exp[1] = nil
    return exp
end

--[[
    Data - basically tables that can only hold numbers, strings, bools, tables, or nil (no functions)
]]
function data(d)
    for k, v in pairs(d) do
        if type(v) == "function" then
            d[k] = nil
        end
    end
    return d
end

--[[
    Factories - basically tables that can only hold functions, normally static
]]
function factory(f)
    for k, v in pairs(f) do
        if type(v) ~= "function" then
            f[k] = nil
        end
    end
    return f
end

--[[
    Classes - factories with a initializer and a self-reference, and are allowed to hold variables

    Initialize with "init"
    Create new instance by calling name of class
    local A = class { ... }
    local instance_a = A(args)
]]
function class(obj)
    local cls = {}
    if obj.extends ~= nil then
        for k, v in pairs(obj.extends) do
            cls[k] = v
        end
    end
    if obj.multiExtends ~= nil then
        for _, c in pairs(obj.multiExtends) do
            for k, v in pairs(c) do
                cls[k] = v
            end
        end
    end

    for k, v in pairs(obj) do
        if k ~= "extends" then
            cls[k] = v
        end
    end
    cls = setmetatable(cls, {
        __call = function(_, ...)
            local o = {}
            local mt = {}
            for k, v in pairs(cls) do
                if k:sub(0, 2) == "__" then
                    mt[k] = v
                end
            end
            mt.__index = cls
            o = setmetatable(o, mt)
            if cls.init then
                cls.init(o, ...)
            end
            return o
        end;
    })
    cls.extend = function(d)
        d.extends = cls
        return class(d)
    end;
    return cls;
end

--[[
    Singleton - a single instance of a class
]]
function singleton(obj)
    return (class(obj))()
end
