import Console
import FluentProvider
import Vapor

public final class TestCommand: Command {
    
  public let id = "test-command"
  
  public let console: ConsoleProtocol
  
  let driver: Driver
  
  public init(console: ConsoleProtocol,
              driver: Driver) {
    self.console = console
    self.driver = driver
  }

  public func run(arguments: [String]) throws {
    
    let result = try driver.makeConnection(.read).raw("SELECT @@version")
    let version = result.array![0].object!["@@version"]!.string!
    print("MySQL Version: \(version)")
    
    try Organization.all().forEach {
      print($0.code)
    }
    console.print("running custom command...")
  }

}

extension TestCommand: ConfigInitializable {

  public convenience init(config: Config) throws {
    let console = try config.resolveConsole()
    let driver = try config.resolveDriver()
    self.init(console: console, driver: driver)
  }

}
