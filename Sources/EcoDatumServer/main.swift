import EcoDatumLib
import Vapor

let config = try Config()
try config.setup()

config.addConfigurable(
  command: AddERHSDataCommand.init,
  name: "add-erhs-data")
config.addConfigurable(
  command: AddTestDataCommand.init,
  name: "add-test-data")
config.addConfigurable(
  command: InitializeDatabaseCommand.init, 
  name: "initialize-database")

let drop = try Droplet(config)
try drop.setup()

try drop.run()
