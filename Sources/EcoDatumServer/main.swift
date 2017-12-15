import EcoDatumLib
import Vapor

let config = try Config()
try config.setup()

config.addConfigurable(
  command: CreateRootUserCommand.init, 
  name: "create-root-user")

let drop = try Droplet(config)
try drop.setup()

try drop.run()
