import Foundation

#if os(Linux)
  srandom(UInt32(time(nil)))
#endif

extension String {

  init(randomUpperCaseAlphaNumericLength length: Int) {
    let alphaNumericChars = "ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"
    var value = ""
    for _ in 0..<length {
      #if os(Linux)
        let randomIndex = Int(random() % alphaNumericChars.count)
      #else
        let randomIndex = arc4random_uniform(UInt32(alphaNumericChars.count))
      #endif
      let index = alphaNumericChars.index(
        alphaNumericChars.startIndex,
        offsetBy: Int(randomIndex))
      value.append(alphaNumericChars[index])
    }
    self.init(value)
  }
  
}

