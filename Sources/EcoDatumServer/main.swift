import EcoDatumLib
import Vapor

let config = try Config()
try config.setup()

config.addConfigurable(
  command: TestCommand.init, 
  name: "test-command")

let drop = try Droplet(config)
try drop.setup()

try drop.run()
