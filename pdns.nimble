srcDir        = "src"
binDir        = "bin"
bin           = @["pdns"]

# Package

version       = "0.1.0"
author        = "Nael Tasmim"
description   = "pdns sqlite3 wrapper"
license       = "BSD"

# Dependencies

requires "nim >= 0.17.2", "protocol"
