local a = require("claudio.tools.actions")
local h = require("claudio.tools.processing")

return {
  ["docstring"] = {
    before = h.to_md_codeblock,
    after = h.extract_from_md_codeblock,
    action = a.insert_contents,
    prompt = [[
You are tasked with generating a docstring in the Numpy specification for a given Julia function. The function code will be provided to you, and you must return only the docstring. Here is the Julia code for which you need to generate a docstring:

<julia_code>
{{USER_QUERY}}
</julia_code>

Follow these guidelines to create the docstring:

1. Use the Numpy docstring format, which includes sections for a short summary, parameters, returns, and optionally notes and examples.
2. Keep the language concise and clear. Avoid unnecessary words or explanations.
3. Include variable typing for all parameters and return values. Use Julia type hints syntax (e.g., int, float, str, List[int], Dict[str, float]).
4. Add a "Notes" section if the function has any important caveats, edge cases, or complex behaviors that need explanation.
5. Do not include an "Examples" section.
6. Ensure that the docstring accurately reflects the function's behavior, parameters, and return values as shown in the provided code.

Generate the docstring based on the provided Julia code and output it without any additional text or explanations. Always return the docstrings in a markdown code block (delimited by three backticks plus the filetype).]],
  },
}
