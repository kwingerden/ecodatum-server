import Foundation

extension String {

  init(randomUpperCaseAlphaNumericLength length: Int) {
    let alphaNumericChars = "ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"
    var value = ""
    for _ in 0..<length {
      let randomIndex = arc4random_uniform(UInt32(alphaNumericChars.count))
      let index = alphaNumericChars.index(
        alphaNumericChars.startIndex,
        offsetBy: Int(randomIndex))
      value.append(alphaNumericChars[index])
    }
    self.init(value)
  }
  
}

