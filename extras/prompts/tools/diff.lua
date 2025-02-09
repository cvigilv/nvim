local a = require("claudio.tools.actions")
local after = require("claudio.tools.processing.after")
local before = require("claudio.tools.processing.before")

return {
  ["conventional_commit"] = {
    before = before.to_md_codeblock,
    after = after.extract_from_md_codeblock,
    action = function(contents)
      a.populate_clipboard(contents)
      vim.cmd("wincmd h")
      vim.cmd("normal 0p")
    end,
    prompt = [[
You will be creating a GitHub commit message in the conventional commit specification based on a
provided diff file. Here are your instructions:

1. You will receive a diff file in the following format:
   \<diff_file>
   {{USER_QUERY}}
   \</diff_file>

1. The conventional commit specification follows this format:
   <type>\[optional scope\]: <description>

[optional body]

[optional footer(s)]

Where:

- type: describes the kind of change (e.g., feat, fix, docs, style, refactor, test, chore)
- scope: (optional) describes what is affected by the change
- description: a short summary of the code changes
- body: (optional) additional contextual information about the code changes
- footer: (optional) for indicating breaking changes or referencing issues

3. Carefully analyze the provided diff file. Pay attention to:

   - Files that have been modified, added, or deleted
   - The nature of the changes in each file
   - Any patterns or themes across multiple changes

1. Based on your analysis:

   - Determine the most appropriate type for the commit
   - Identify a suitable scope if applicable
   - Assess whether the changes constitute a breaking change

1. Create a commit message title following the conventional commit format. If it's a breaking
   change, add an exclamation mark after the type/scope.

1. For the commit message body:

   - Explain your reasoning for choosing the type, scope (if applicable), and breaking change
     status
   - Provide a bullet point list of the relevant changes observed in the diff

1. Format your response as follows:

```gitcommit
<title>Your commit message title here</title>

<body>
Your explanation and bullet points here
</body>
```

- Skip writing the tags \<title> and \<body>, this are just so you know where to put the
  contents.
- Only write the commit title and body, dont write anythin else.
- Hard wrap contents to that contents don't exceed 72 characters.

Remember to be concise yet informative in your commit message. Focus on the most significant
changes and their impact on the project.
]],
  },
}
