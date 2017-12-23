import AuthProvider
import FluentProvider
import LeafProvider
import PostgreSQLProvider

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
    try addProvider(PostgreSQLProvider.Provider.self)
  
  }
  
  private func setupPreparations() throws {
    
    // The order of the following preparations matters!!
    preparations.append(User.self)
    
    preparations.append(AbioticFactor.self)
    preparations.append(Image.self)
    preparations.append(MeasurementUnit.self)
    preparations.append(Organization.self)
    preparations.append(Role.self)
    preparations.append(Site.self)
    preparations.append(Survey.self)
    preparations.append(Token.self)
    preparations.append(UserOrganizationRole.self)
  
  }
  
}
