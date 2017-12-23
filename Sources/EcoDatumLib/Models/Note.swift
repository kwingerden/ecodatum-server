import Vapor
import FluentProvider
import HTTP

final class Note: Model {
  
  let storage = Storage()
  
  var note: String
  
  let surveyId: Identifier
  
  struct Keys {
    static let id = "id"
    static let note = "note"
    static let surveyId = Survey.foreignIdKey
  }
  
  init(note: String,
       surveyId: Identifier) {
    self.note = note
    self.surveyId = surveyId
  }
  
  // MARK: Row
  
  init(row: Row) throws {
    note = try row.get(Keys.note)
    surveyId = try row.get(Keys.surveyId)
  }
  
  func makeRow() throws -> Row {
    var row = Row()
    try row.set(Keys.note, note)
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
        Keys.note,
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


// MARK: JSONConvertible

extension Note: JSONConvertible {
  
  convenience init(json: JSON) throws {
    self.init(note: try json.get(Keys.note),
              surveyId: try json.get(Keys.surveyId))
  }
  
  func makeJSON() throws -> JSON {
    var json = JSON()
    try json.set(Keys.id, id)
    try json.set(Keys.note, note)
    try json.set(Keys.surveyId, surveyId)
    return json
  }
  
}

// MARK: HTTP

extension Note: ResponseRepresentable { }

// MARK: TIMESTAMP

extension Note: Timestampable { }




