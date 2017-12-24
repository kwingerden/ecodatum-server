import Foundation
import Random

let _alphaNumericChars = "ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"

extension String {

  init(randomUpperCaseAlphaNumericLength length: Int) {
    var value = ""
    for _ in 0..<length {
      let randomIndex = makeRandom(min: 0, max: _alphaNumericChars.count - 1)
      let index = _alphaNumericChars.index(
        _alphaNumericChars.startIndex,
        offsetBy: randomIndex)
      value.append(_alphaNumericChars[index])
    }
    self.init(value)
  }
  
}

