-- Don't overwrite the directory if the user doesn't want to
if fs.exists("/trainlib") then
  print("A version of TrainLib already exists on the system.")
  print("Overwrite? (y/N) ")
  local overwrite = read()
  if overwrite.lower() == "y" then
    fs.delete("/trainlib")
  else
    error("Operation cancelled by user",0)
  end
end
fs.makeDir("/trainlib")
fs.makeDir("/trainlib/internal")
shell.run("wget https://raw.githubusercontent.com/scmcgowen/trainlib/refs/heads/main/init.lua /trainlib/init.lua")
shell.run("wget https://raw.githubusercontent.com/scmcgowen/trainlib/refs/heads/main/internal/expect.lua /trainlib/internal/expect.lua")
print("Installed TrainLib.")
