import FluentProvider
import Vapor

final class Note: EquatableModel {
  
  let storage = Storage()
  
  var text: String
  
  let surveyId: Identifier
  
  struct Keys {
    static let id = "id"
    static let text = "text"
    static let surveyId = Survey.foreignIdKey
  }
  
  init(text: String,
       surveyId: Identifier) {
    self.text = text
    self.surveyId = surveyId
  }
  
  // MARK: Row
  
  init(row: Row) throws {
    text = try row.get(Keys.text)
    surveyId = try row.get(Keys.surveyId)
  }
  
  func makeRow() throws -> Row {
    var row = Row()
    try row.set(Keys.text, text)
    try row.set(Keys.surveyId, surveyId)
    return row
  }
  
}

// MARK: Preparation

extension Note: Preparation {
  
  static func prepare(_ database: Database) throws {
    try database.create(self) {
      builder in
      builder.id()
      builder.custom(
        Keys.text,
        type: "TEXT",
        optional: false,
        unique: false)
      builder.foreignId(
        for: Survey.self,
        optional: false,
        unique: false)
    }
  }
  
  static func revert(_ database: Database) throws {
    try database.delete(self)
  }
  
}

// MARK: Relations

extension Note {
  
  var survey: Parent<Note, Survey> {
    return parent(id: surveyId)
  }
  
}

// MARK: TIMESTAMP

extension Note: Timestampable { }


