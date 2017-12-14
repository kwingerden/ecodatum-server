import AuthProvider
import FluentProvider
import LeafProvider
import MySQLProvider

extension Config {
  
  public func setup() throws {

    Node.fuzzy = [Row.self, JSON.self, Node.self]
    try setupProviders()
    try setupPreparations()

  }
  
  private func setupProviders() throws {
  
    try addProvider(AuthProvider.Provider.self)
    try addProvider(FluentProvider.Provider.self)
    try addProvider(LeafProvider.Provider.self)
    try addProvider(MySQLProvider.Provider.self)
  
  }
  
  private func setupPreparations() throws {
    
    // The order of the following preparations matters!!
    preparations.append(User.self)
    
    preparations.append(Photo.self)
    preparations.append(Organization.self)
    preparations.append(Token.self)
  
  }
  
}
