local argon = assert(loadfile("src/index.lua"))()

local table_unpack = assert(unpack or table.unpack, "missing unpack function")

local function call_with(target_function, ...)
  local arguments = { ... }
  local function proxy_function()
    return target_function(table_unpack(arguments))
  end

  return proxy_function
end

local function argon_parser_module()
  local function argon_build()
    local function argon_parser_build_definition_error_non_table()
      assert.has.errors(call_with(argon.build, nil))
    end

    local function argon_parser_build_definition_error_bad_table_index()
      assert.has.errors(call_with(argon.build, { [{}] = {} }))
    end

    local function argon_parser_build_definition_error_bad_table_value()
      assert.has.errors(call_with(argon.build, { ["argument-name"] = true }))
    end

    it("| builder should reject non-table arguments", argon_parser_build_definition_error_non_table)
    it("| builder should reject bad table arguments (index)", argon_parser_build_definition_error_bad_table_index)
    it("| builder should reject bad table arguments (value)", argon_parser_build_definition_error_bad_table_value)
  end

  local function argon_parse()
    local function argon_parse_bad_argument()
      local parser = argon.build {}
      assert.has.errors(call_with(parser.parse, "a string"))
    end

    local function argon_parse_missmatch_type_and_default_value()
      local parser = argon.build { ["optional-argument"] = { type = "boolean", default_value = "bad value" } }
      assert.has.errors(call_with(parser.parse, { "--optional-argument" }))
    end

    local function argon_parse_missing_param()
      local parser = argon.build { ["required-argument"] = { type = "boolean" } }
      assert.has.errors(call_with(parser.parse, {}))
    end

    it("| should reject bad argument tables", argon_parse_bad_argument)
    it("| should reject params where type is not the same as default_value", argon_parse_missmatch_type_and_default_value)
    it("| should fail when required param was not supplied with a value", argon_parse_missing_param)
  end

  describe("argon.build: build parser", argon_build)
  describe("argon.parser: parse arguments", argon_parse)
end

describe("argon.parser: general functionality check", argon_parser_module)
