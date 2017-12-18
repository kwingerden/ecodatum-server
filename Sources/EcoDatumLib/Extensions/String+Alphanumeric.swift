import Foundation
import Random

extension String {

  init(randomUpperCaseAlphaNumericLength length: Int) {
    let alphaNumericChars = "ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"
    var value = ""
    for _ in 0..<length {
      let randomIndex = makeRandom(min: 0, max: alphaNumericChars.count - 1)
      //let randomIndex = arc4random_uniform(UInt32(alphaNumericChars.count))
      let index = alphaNumericChars.index(
        alphaNumericChars.startIndex,
        offsetBy: randomIndex)
      value.append(alphaNumericChars[index])
    }
    self.init(value)
  }
  
}

