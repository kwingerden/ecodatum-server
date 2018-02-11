import FluentProvider
import Foundation

protocol EquatableModel: Equatable, Model  {
  
}

extension EquatableModel {
  
  static func ==(lhs: Self, rhs: Self) -> Bool {
    return lhs.id == rhs.id
  }
  
}
