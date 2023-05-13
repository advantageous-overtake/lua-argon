 [![Continous Integration](https://github.com/wfrsk/lua-argon/actions/workflows/ci.yml/badge.svg)]

# Installation

A rock is published to `luarocks` each time a new version is released.

Run the following command to install `argon` in your system.

```command
sudo luarocks install argon
```

Or, if you preffer an user-specific installation.

```command
luarocks install argon --local
```

# How it works

`argon` is _really_ simple, build -> parse.

You give it a definition with your desired parameters to match, and it gives you a parser object.

Yes, it is THAT simple.

The given table is a representation to C's `argv` array, this means that parameters cannot span multiple values in that array and thus makes it faster.

# Documentation

### **argon.build**

`argon.build` is the main entry point to `argon`, takes a definition table, and returns a parser.

```lua
local argon = require("argon")

local parser = argon
                    .build{
                      ["parameter-name"] = {
                        type = "boolean",
                        default_value = nil
                      }
                    }        
```

The definition table has the following structure:

```lua
{
  [string] = {
    ["type"] = "boolean|number|string",
    ["default_value"] = boolean|number|string (where type of 'default_value' is equal to 'type')
  }
}
```

### **<parser>.parse**

`<parser>.parse` is the routine who parses already defined parameters from either the `arg` global (default) or the `target_arguments` parameter (if provided).

```lua
local argon = require("argon")

local cli_params = argon
                        .build{
                          ["parameter-name"] = {
                            type = "boolean",
                            default_value = true
                          }
                        }
                        .parse()

print( cli_params["parameter-name"] ) --> true
```

Giving a parameter a default value marks it as optional, _by default_, all parameters are required and will produce an error if not provided.


### **<parser>.inspect**

`<parser>.inspect` is a routine who has the same API as `<parser>.parse`, but instead of returning the parse result, it returns its stringified representation.

```lua
local argon = require("argon")

local cli_params = argon
                        .build{
                          ["parameter-name"] = {
                            type = "boolean",
                            default_value = true
                          }
                        }
                        .inspect()

print( cli_params ) --> { ["parameter-name"] = true }
```

# License

All files under this repository are licensed under the `GPL-3.0` license.