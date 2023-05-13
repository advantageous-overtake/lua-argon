package = "argon"
version = "scm-1"
source = {
   url = "git://github.com/wfrsk/lua-argon",
   tag = "v0.1"
}
description = {
   homepage = "https://argon.docs.wfrsk.dev",
   license = "GPL-3.0",
   summary = "A tiny, performant and hackable command-line parsing library."
}
dependencies = {
   "lua >= 5.1, < 5.5",
   "inspect"
}
build = {
   type = "builtin",
   modules = {
      ["argon"] = "src/index.lua",
   },
   copy = { "doc", "spec" }
}
