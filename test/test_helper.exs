if System.get_env("CI") do
  ExUnit.configure(formatters: [JUnitFormatter, ExUnit.CLIFormatter])
  Code.put_compiler_option(:warnings_as_errors, true)
end

ExUnit.start()
