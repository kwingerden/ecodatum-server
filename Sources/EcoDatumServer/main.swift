import EcoDatumLib
import Vapor

let config = try Config()
try config.setup()

config.addConfigurable(
  command: InitializeDatabaseCommand.init, 
  name: "initialize-database")
config.addConfigurable(
  command: AddTestDataCommand.init,
  name: "add-test-data")

let drop = try Droplet(config)
try drop.setup()

try drop.run()
