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
    preparations.append(Organization.self)
    preparations.append(Site.self)
    
    preparations.append(EcosystemFactor.self)
    preparations.append(MeasurementUnit.self)
    preparations.append(MediaType.self)
    preparations.append(Role.self)
    preparations.append(QualitativeObservationType.self)
    preparations.append(QuantitativeObservationType.self)

    preparations.append(Token.self)
    preparations.append(UserOrganizationRole.self)
  
    preparations.append(QualitativeObservationFactor.self)
    preparations.append(QuantitativeObservationFactor.self)
    
  }
  
}
