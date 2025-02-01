local a = require("claudio.tools.actions")
local after = require("claudio.tools.processing.after")
local before = require("claudio.tools.processing.before")

return {
  ["docstring"] = {
    before = before.to_md_codeblock,
    after = after.extract_from_md_codeblock,
    action = a.insert_contents,
    prompt = [[
You are tasked with generating a docstring in the Numpy specification for a given Julia
function. The function code will be provided to you, and you must return only the docstring.
Here is the Julia code for which you need to generate a docstring:

<julia_code>
{{USER_QUERY}}
</julia_code>

Follow these example to create the docstring:

````jl
"""
    bar(x[, y])

Compute the Bar index between `x` and `y`.

If `y` is unspecified, compute the Bar index between all pairs of columns of `x`.

# Examples
```julia-repl
julia> bar([1, 2], [1, 2])
1
```
"""
function bar(x, y) ...
````

Generate the docstring based on the provided Julia code and output it without any additional
text or explanations. Always return the docstrings in a markdown code block (delimited by three
backticks plus the filetype).
]],
  },
}
