local a = require "nvim-lsp-installer.core.async"
local process = require "nvim-lsp-installer.process"
local platform = require "nvim-lsp-installer.platform"

local async_spawn = a.promisify(process.spawn)

local spawn = {
    aliases = {
        npm = platform.is_win and "npm.cmd" or "npm",
    },
}

-- TODO.. cleanre
setmetatable(spawn, {
    __index = function(self, k)
        return function(args)
            local sink = process.in_memory_sink()
            local spawn_args = vim.tbl_extend("force", {
                stdio_sink = sink.sink,
            }, args)
            local cmd_args = {}
            for i, arg in ipairs(args) do
                cmd_args[i] = arg
            end
            spawn_args.cmd = self.aliases[k] or k
            spawn_args.args = cmd_args
            local ok, _, exit_code = async_spawn(self.aliases[k] or k, spawn_args)
            return ok, table.concat(sink.buffers.stdout, ""), table.concat(sink.buffers.stderr, ""), exit_code
        end
    end,
})

return spawn
