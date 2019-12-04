# DeltaE - Quantify Color Difference
This is a Dart port of zschuessler's JavaScript **DeltaE** library which you can check out here: https://github.com/zschuessler/DeltaE.

## How to use it
This package differs from the original JavaScript version in quite a few ways. You can compare the following code to the original library's *Use It*
section to get a sense of differences between the two.
```dart
// Create two test LAB color objects to compare!
LabColor lab1 = LabColor(36, 60, 41);
LabColor lab2 = LabColor(100, 40, 90);
// 1976 formula
print(deltaE76(lab1, lab2)); // OR: print(deltaE(lab1, lab2, algorithm: DeltaEAlgorithm.cie76));
// 1994 formula
print(deltaE94(lab1, lab2)); // OR: print(deltaE(lab1, lab2, algorithm: DeltaEAlgorithm.cie94));
// 2000 formula
print(deltaE00(lab1, lab2)); // OR: print(deltaE(lab1, lab2, algorithm: DeltaEAlgorithm.ciede2000));
```
### Top-Level Functions
* **deltaE76(LabColor lab1, LabColor lab2)**<br>
The 1976 formula is the first formula that related a measured color difference to a known set of CIELAB
coordinates. This formula has been succeeded by the 1994 and 2000 formulas because the CIELAB space turned out
to be not as perceptually uniform as intended, especially in the saturated regions. This means that this formula
rates these colors too highly as opposed to other colors.
* **deltaE94(LabColor lab1, LabColor lab2, [ Weights weights = const Weights() ])**<br>
The 1976 definition was extended to address perceptual non-uniformities, while retaining the CIELAB color space,
by the introduction of application-specific weights derived from an automotive paint test's tolerance data.
* **deltaE00(LabColor lab1, LabColor lab2, [ Weights weights = const Weights() ])**<br>
Since the 1994 definition did not adequately resolve the perceptual uniformity issue, the CIE refined their
definition, adding five corrections:
  * A hue rotation term, to deal with the problematic blue region (hue angles in the neighborhood of 275°)
  * Compensation for neutral colors (the primed values in the L*C*h differences)
  * Compensation for lightness
  * Compensation for chroma
  * Compensation for hue
* **deltaE(LabColor lab1, LabColor lab2, { DeltaEAlgorithm algorithm = DeltaEAlgorithm.ciede2000, Weights weights = const Weights() })**<br>
Another way of calling the three above functions by passing an algorithm parameter which specifies which formula to use.
### Classes
* **LabColor(double lightness, double chroma, double hue)**<br>
Represents a color in the CIELAB color space, required by all top-level functions.
The lightness (L*) must be between 0 and 100, the chroma (a*) between -128 and 128, and the hue (b*) between -128 and 128.
This class comes with a handy factory that creates LabColor instances from RGB values.
* **Weights({ double lightness = 1, double chroma = 1, double hue = 1 })**<br>
Used to configure the weight factors of the 1994 and 2000 formulas. All the factors must be positive.
### Enums
* **DeltaEAlgorithm**<br>
Represents a DeltaE algorithm. It can be either cie76, cie94 or ciede2000.
## Tests
The tests have been ported using the **test** package. You can run them from the following command from inside this package's folder.
```dart
pub run test test/test.dart
```
