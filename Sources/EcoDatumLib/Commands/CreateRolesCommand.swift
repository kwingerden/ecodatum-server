import Console
import FluentProvider
import Vapor

public final class CreateRolesCommand: Command {
  
  public let id = "create-roles"
  
  public let console: ConsoleProtocol
  
  public init(console: ConsoleProtocol) {
    self.console = console
  }
  
  public func run(arguments: [String]) throws {
  
    try [
      Role.RoleType.ADMINISTRATOR,
      Role.RoleType.MEMBER
      ].forEach {
        let role = Role(roleId: $0.rawValue, roleType: $0)
        try role.save()
        console.print("Successfully create the root user.")
    }
    
  }
  
}

extension CreateRolesCommand: ConfigInitializable {
  
  public convenience init(config: Config) throws {
    self.init(console: try config.resolveConsole())
  }
  
}

