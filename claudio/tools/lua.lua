local h = require("claudio.tools.processing")
local a = require("claudio.tools.actions")

return {
  ["docstring"] = {
    before = h.to_md_codeblock,
    after = h.extract_from_md_codeblock,
    mode = a.insert_contents,
    prompt = [[
You are tasked with generating an EmmyLua docstring for a given Lua function. The function code will be provided to you, and you must return only the docstring. Here is the Lua code for which you need to generate a docstring:

<lua_code>
{{USER_QUERY}}
</lua_code>

Follow these guidelines to create the EmmyLua docstring:

1. Use the EmmyLua docstring format, which includes sections for a short summary, parameters, returns, and optionally notes.
2. Keep the language concise and clear. Avoid unnecessary words or explanations.
3. Include variable typing for all parameters and return values. Use Lua type annotations (e.g., number, string, table, boolean).
4. Add a "@see" section if there are related functions or modules that should be referenced.
5. Do not include an "@example" section.
6. Ensure that the docstring accurately reflects the function's behavior, parameters, and return values as shown in the provided code.
7. Assume the developer is using the following: (i) Neovim Lua API, (ii) Lua 5.0, and (iii) LuaJit 2.1.

Format your docstring as follows:
```
---Short summary of the function.
---@param param1 type Description of param1
---@param param2 type Description of param2
---@return type Description of return value
---@see Related function or module (if necessary)
```

Generate the EmmyLua docstring based on the provided Lua function and output it without any additional text or explanations. Place your docstring inside <docstring> tags formatted as a markdown code block (three backticks and filetype).]],
  },
}
