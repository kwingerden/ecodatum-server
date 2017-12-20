import Foundation

let numberFormatter = NumberFormatter()
numberFormatter.minimumFractionDigits = 2
numberFormatter.maximumFractionDigits = 2
numberFormatter.minimumIntegerDigits = 1
numberFormatter.maximumIntegerDigits = 3
numberFormatter.formatWidth = 8
numberFormatter.allowsFloats = true
numberFormatter.alwaysShowsDecimalSeparator = true
numberFormatter.generatesDecimalNumbers = true

let measurementFormatter = MeasurementFormatter()
measurementFormatter.locale = Locale(identifier: "en_US")
measurementFormatter.unitOptions = .providedUnit
measurementFormatter.numberFormatter = numberFormatter
measurementFormatter.unitStyle = .medium

var tempF = Measurement(value: 32.0, unit: UnitTemperature.fahrenheit)
print("tempF.value: \(numberFormatter.string(from: NSDecimalNumber(value: tempF.value))!)")
print(measurementFormatter.string(from: tempF))

var tempC = tempF.converted(to: UnitTemperature.celsius)
print("tempC: \(tempC.value)")
print(measurementFormatter.string(from: tempC))

