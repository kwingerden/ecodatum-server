import EcoDatumLib
import Vapor

let config = try Config()
try config.setup()

config.addConfigurable(
  command: InitializeDatabaseCommand.init, 
  name: "initialize-database")

let drop = try Droplet(config)
try drop.setup()

try drop.run()
