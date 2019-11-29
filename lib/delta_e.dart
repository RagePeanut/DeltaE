/// A package of CIE76, CIE94 and CIEDE2000 algorithms.
/// 
/// Example use case:
/// ```dart
/// LabColor lab1 = LabColor(50, 50, 50);
/// LabColor lab2 = LabColor(20, 20, 20);
/// deltaE(lab1, lab2, algorithm: DeltaEAlgorithm.cie94); // The default algorithm is CIEDE2000.
/// ```
library delta_e;

import 'dart:math';

/// Calculates the color difference between `lab1` and `lab2`.
/// 
/// The `weights` parameter is only taken into account if `algorithm` isn't set to `DeltaEAlgorithm.cie76`.
double deltaE(LabColor lab1, LabColor lab2, {
    DeltaEAlgorithm algorithm = DeltaEAlgorithm.ciede2000,
    Weights weights = const Weights(),
}) {
    switch(algorithm) {
        case DeltaEAlgorithm.cie76:
            return deltaE76(lab1, lab2);
        case DeltaEAlgorithm.cie94:
            return deltaE94(lab1, lab2, weights);
        case DeltaEAlgorithm.ciede2000:
        default:
            return deltaE00(lab1, lab2, weights);
    }
}

/// The 1976 formula is the first formula that related a measured color difference to a known set of CIELAB
/// coordinates. This formula has been succeeded by the 1994 and 2000 formulas because the CIELAB space turned out
/// to be not as perceptually uniform as intended, especially in the saturated regions. This means that this formula
/// rates these colors too highly as opposed to other colors.
/// 
/// Source: http://en.wikipedia.org/wiki/Color_difference#CIE76
double deltaE76(LabColor lab1, LabColor lab2) {
    return sqrt(
        pow(lab2.l - lab1.l, 2) +
        pow(lab2.a - lab1.a, 2) +
        pow(lab2.b - lab1.b, 2)
    );
}

/// The 1976 definition was extended to address perceptual non-uniformities, while retaining the CIELAB color space,
/// by the introduction of application-specific weights derived from an automotive paint test's tolerance data.
/// 
/// Source: https://en.wikipedia.org/wiki/Color_difference#CIE94
double deltaE94(LabColor lab1, LabColor lab2, [ Weights weights = const Weights() ]) {
    double k1, k2;
    if(weights.l == 1) {
        k1 = 0.045;
        k2 = 0.015;
    } else {
        k1 = 0.048;
        k2 = 0.014;
    }
    // Cab
    double c1 = sqrt(pow(lab1.a, 2) + pow(lab1.b, 2)),
           c2 = sqrt(pow(lab2.a, 2) + pow(lab2.b, 2)),
           cab = c1 - c2;
    // L
    double l = (lab1.l - lab2.l) / weights.lightness;
    // a
    double sc = 1 + (k1 * c1),
           a = cab / (weights.a * sc);
    // b - Top
    double hab = sqrt(
        pow(lab1.a - lab2.a, 2) +
        pow(lab1.b - lab2.b, 2) -
        pow(cab, 2)
    );
    // b - Bottom
    double sh = 1 + (k2 * c1),
           b = hab / sh;

    return sqrt(
        pow(l, 2) +
        pow(a, 2) +
        pow(b, 2)
    );
}

/// Since the 1994 definition did not adequately resolve the perceptual uniformity issue, the CIE refined their
/// definition, adding five corrections:
/// - A hue rotation term, to deal with the problematic blue region (hue angles in the neighborhood of 275°)
/// - Compensation for neutral colors (the primed values in the L*C*h differences)
/// - Compensation for lightness
/// - Compensation for chroma
/// - Compensation for hue
/// 
/// Source: https://en.wikipedia.org/wiki/Color_difference#CIEDE2000
double deltaE00(LabColor lab1, LabColor lab2, [ Weights weights = const Weights() ]) {
    // Delta L Prime
    double deltaLPrime = lab2.l - lab1.l;
    // L Bar
    double lBar = (lab1.l + lab2.l) / 2;
    // C1 & C2
    double c1 = sqrt(pow(lab1.a, 2) + pow(lab1.b, 2)),
           c2 = sqrt(pow(lab2.a, 2) + pow(lab2.b, 2));
    // C Bar
    double cBar = (c1 + c2) / 2;
    // A Prime 1
    double aPrime1 = lab1.a +
        (lab1.a / 2) *
        (1 - sqrt(
            pow(cBar, 7) /
            (pow(cBar, 7) + pow(25, 7))
        ));
    // A Prime 2
    double aPrime2 = lab2.a +
        (lab2.a / 2) *
        (1 - sqrt(
            pow(cBar, 7) /
            (pow(cBar, 7) + pow(25, 7))
        ));
    // C Prime 1
    double cPrime1 = sqrt(
        pow(aPrime1, 2) +
        pow(lab1.b, 2)
    );
    // C Prime 2
    double cPrime2 = sqrt(
        pow(aPrime2, 2) +
        pow(lab2.b, 2)
    );
    // C Bar Prime
    double cBarPrime = (cPrime1 + cPrime2) / 2;
    // Delta C Prime
    double deltaCPrime = cPrime2 - cPrime1;
    // S sub L
    double sSubL = 1 + (
        (0.015 * pow(lBar - 50, 2)) /
        sqrt(20 + pow(lBar - 50, 2))
    );
    // S sub C
    double sSubC = 1 + 0.045 * cBarPrime;
    // h Primes
    double hPrime1 = _getPrimeFn(lab1.b, aPrime1),
           hPrime2 = _getPrimeFn(lab2.b, aPrime2);
    // Delta h Prime
    double deltahPrime;
    // - When either C′1 or C′2 is zero, then Δh′ is irrelevant and may be set to zero.
    if(c1 == 0 || c2 == 0) deltahPrime = 0.0;
    else if((hPrime1 - hPrime2).abs() <= 180.0) deltahPrime = hPrime2 - hPrime1;
    else if(hPrime2 <= hPrime1) deltahPrime = hPrime2 - hPrime1 + 360.0;
    else deltahPrime = hPrime2 - hPrime1 - 360.0;
    // Delta H Prime
    double deltaHPrime = 2 *
        sqrt(cPrime1 * cPrime2) *
        sin(_degreesToRadians(deltahPrime) / 2);
    // H Bar Prime
    double hBarPrime;
    if((hPrime1 - hPrime2).abs() > 180) hBarPrime = (hPrime1 + hPrime2 + 360) / 2;
    else hBarPrime = (hPrime1 + hPrime2) / 2;
    // T
    double t = 1 -
        0.17 * cos(_degreesToRadians(hBarPrime - 30)) +
        0.24 * cos(_degreesToRadians(2 * hBarPrime)) +
        0.32 * cos(_degreesToRadians(3 * hBarPrime + 6)) -
        0.20 * cos(_degreesToRadians(4 * hBarPrime - 63));
    // S sub H
    double sSubH = 1 + 0.015 * cBarPrime * t;
    // R sub T
    double rSubT = -2 *
        sqrt(
            pow(cBarPrime, 7) /
            (pow(cBarPrime, 7) + pow(25, 7))
        ) *
        sin(_degreesToRadians(
            60 *
            exp(
                -pow((hBarPrime - 275) / 25, 2)
            )
        ));
    // Lab
    double lightness = deltaLPrime / (weights.l * sSubL);
    double chroma = deltaCPrime / (weights.a * sSubC);
    double hue = deltaHPrime / (weights.b * sSubH);

    return sqrt(
        pow(lightness, 2) +
        pow(chroma, 2) +
        pow(hue, 2) +
        rSubT * chroma * hue
    );
}

/// Converts `degrees` to radians.
double _degreesToRadians(num degrees) => degrees * (pi / 180);

/// A helper function to calculate the h Prime 1 and h Prime 2 values.
double _getPrimeFn(double x, double y) {
    if(x == 0 && y == 0) return 0;
    double hueAngle = _radiansToDegrees(atan2(x, y));
    return hueAngle >= 0 ? hueAngle : hueAngle + 360;
}

/// Converts `radians` to degrees.
double _radiansToDegrees(num radians) => radians * (180 / pi);

/// A color represented in the CIELAB color space which expresses colors as three values:
/// its lightness (L\*) from black (0) to white (100), its chroma (a\*) from green (-180) to
/// red (+180), and its hue (b\*) from blue (-180) to yellow (+180).
/// 
/// Learn more: https://en.wikipedia.org/wiki/CIELAB_color_space
class LabColor {
    /// Constructs a `LabColor`.
    /// 
    /// - `lightness` (L) must be between 0 (inclusive) and 100 (inclusive).
    /// - `chroma` (a) must be between -128 (inclusive) and 128 (inclusive).
    /// - `hue` (b) must be between -128 (inclusive) and 128 (inclusive).
    const LabColor(this.lightness, this.chroma, this.hue)
        : assert(lightness >= 0 && lightness <= 100),
          assert(chroma >= -128 && chroma <= 128),
          assert(hue >= -128 && hue <= 128);

    /// Constructs a `LabColor` from a RGB color.
    /// 
    /// Reference: https://gist.github.com/manojpandey/f5ece715132c572c80421febebaf66ae
    factory LabColor.fromRGB(int red, int green, int blue) {
        List<num> rgb = [red, green, blue].map((int channel) {
            double value = channel / 255;
            if(value > 0.04045) value = pow(((value + 0.055) / 1.055), 2.4);
            else value /= 12.92;
            return value * 100;
        }).toList();

        List<num> xyz = [
            (rgb[0] * 0.4124 + rgb[1] * 0.3576 + rgb[2] * 0.1805) / 95.047,
            (rgb[0] * 0.2126 + rgb[1] * 0.7152 + rgb[2] * 0.0722) / 100,
            (rgb[0] * 0.0193 + rgb[1] * 0.1192 + rgb[2] * 0.9505) / 108.883,
        ].map((double value) {
            if(value > 0.008856) return pow(value, (1/3).toDouble());
            else return (7.787 * value) + (16 / 116); 
        }).toList();

        return LabColor(
            (116 * xyz[1]) - 16,
            500 * (xyz[0] - xyz[1]),
            200 * (xyz[1] - xyz[2]),
        );
    }

    /// Shorthand for `lightness`.
    double get l => this.lightness;
    /// Shorthand for `chroma`.
    double get a => this.chroma;
    /// Shorthand for `hue`.
    double get b => this.hue;

    final double lightness;
    final double chroma;
    final double hue;

    @override
    String toString() => 'LabColor(L: $lightness, a: $chroma, b: $hue)';
}

/// Used to configure weight factors.
class Weights {
    const Weights({
        this.lightness = 1,
        this.chroma = 1,
        this.hue = 1,
    }) : assert(lightness >= 0),
         assert(chroma >= 0),
         assert(hue >= 0);
    
    double get l => this.lightness;
    double get a => this.chroma;
    double get b => this.hue;

    final double lightness;
    final double chroma;
    final double hue;
}

/// The algorithms used to calculate the difference between two colors.
enum DeltaEAlgorithm {
    /// The 1976 formula is the first formula that related a measured color difference to a known set of CIELAB
    /// coordinates. This formula has been succeeded by the 1994 and 2000 formulas because the CIELAB space turned out
    /// to be not as perceptually uniform as intended, especially in the saturated regions. This means that this formula
    /// rates these colors too highly as opposed to other colors.
    /// 
    /// Source: http://en.wikipedia.org/wiki/Color_difference#CIE76
    cie76,
    /// The 1976 definition was extended to address perceptual non-uniformities, while retaining the CIELAB color space,
    /// by the introduction of application-specific weights derived from an automotive paint test's tolerance data.
    /// 
    /// Source: https://en.wikipedia.org/wiki/Color_difference#CIE94
    cie94,
    /// Since the 1994 definition did not adequately resolve the perceptual uniformity issue, the CIE refined their
    /// definition, adding five corrections:
    /// - A hue rotation term, to deal with the problematic blue region (hue angles in the neighborhood of 275°)
    /// - Compensation for neutral colors (the primed values in the L*C*h differences)
    /// - Compensation for lightness
    /// - Compensation for chroma
    /// - Compensation for hue
    /// 
    /// Source: https://en.wikipedia.org/wiki/Color_difference#CIEDE2000
    ciede2000,
}
