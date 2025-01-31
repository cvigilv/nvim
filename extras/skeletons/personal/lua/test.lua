---@diagnostic disable: undefined-global, lowercase-global, undefined-field

-- NOTE: refer to https://github.com/lunarmodules/luassert/tree/master for more info and examples
local eq = assert.are.same
local is_true = assert.is.True
local throws_error = assert.has.errors

describe("WHAT ARE YOU TESTING (function name, for example)", function()
  before_each(function()
    -- Setup environment to test
    ...
  end)

  it("SHOULD DO SOMETHING", function()
    -- Expected behaviour
    ...

    -- Observed behaviour
    ...

    eq() -- Check if behaviours are equal
  end)
end)
