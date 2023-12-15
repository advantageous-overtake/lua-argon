local pattern_record = {
  boolean = { "^%-([a-zA-Z])$", "^%-%-([a-zA-Z_-]+)$" },
  string = { "^%-%-([a-zA-Z_-]+)=(.*)$" },
  number = { "^%-%-([a-zA-Z_-]+)=([+-]?%d*%.?%d+)$" }
}

local function build_parser(defined_options)
  assert(type(defined_options) == "table",
    string.format("argon.build: parameter `defined_options` expected to be of type table, got value of type `%s`.",
      type(defined_options)))

  local parser_context = {
    option_lookup_hash = {}
  }

  local lookup_hash = parser_context.option_lookup_hash

  for param_name, param_definition in next, defined_options do
    assert(type(param_name) == "string",
      string.format("argon.build: `param_name` is expected to of type `string`, got value of type `%s`.",
        type(param_name)))
    assert(type(param_definition) == "table",
      string.format("argon.build: `param_definition` is expected to be of type `table`, got value of type `%s`.",
        type(param_definition)))

    lookup_hash[#lookup_hash + 1] = param_name
    lookup_hash[#lookup_hash + 1] = param_definition.short_param
  end

  local function parse_routine(target_arguments)
    assert( type( target_arguments ) == "table" or target_arguments == nil )

    target_arguments = ( type(target_arguments) == "table" and target_arguments ) or arg

    local argument_list = assert(type(target_arguments) == "table",
      string.format(
      "argon.parser: global(`arg`)|`target_arguments` expected to be of type `table`, got value of type `%s`.",
        type(target_arguments))) and target_arguments

    local parse_result = {}

    for param_name, param_definition in next, defined_options do
      if param_definition.type == "boolean" then
        parse_result[param_name] = assert(type(param_definition.default_value) == param_definition.type,
          "argon.parser: missmatch between param type and param default value.") and param_definition.default_value or
        false
      elseif param_definition.type == "string" then
        parse_result[param_name] = assert(type(param_definition.default_value) == param_definition.type,
          "argon.parser: missmatch between param type and param default value.") and param_definition.default_value
      end
    end

    for index = 1, #argument_list do
      ---@diagnostic disable-next-line: need-check-nil
      local argument = argument_list[index]

      for match_type, pattern_list in next, pattern_record do
        for pattern_index = 1, #pattern_list do
          local pattern = pattern_list[pattern_index]

          local name, value = string.match(argument, pattern)

          if name and not lookup_hash[name] then
            print(string.format("warning: no such argument `%s`", name))
            goto loop_next
          end

          if match_type == "boolean" and name then
            parse_result[name] = true
            goto done_argument
          elseif match_type == "string" and name and value then
            parse_result[name] = value
            goto done_argument
          elseif match_type == "number" and name and value then
            parse_result[name] = tonumber(value)
            goto done_argument
          end
        end

        :: done_argument ::
      end

      :: loop_next ::
    end

    for index, value in next, defined_options do
      assert(value.default_value == nil and parse_result[index] == nil,
        string.format("required parameter `%s` was not supplied a value.", index))
    end

    return parse_result
  end

  local function inspect_routine(target_arguments)
    return require("inspect")(parse_routine(target_arguments))
  end

  return { parse = parse_routine, inspect_arguments = inspect_routine }
end


return { build = build_parser }
