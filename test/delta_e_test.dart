import 'package:delta_e/delta_e.dart';
import 'package:test/test.dart';

void main() {
    LabColor color1 = LabColor(36, 60, 41);
    LabColor color2 = LabColor(55, 66, 77);

    group('Delta E', () {
        // CIE76 algorithm
        group('dE76', () {
            // http://colormine.org/delta-e-calculator
            test('Return DeltaE', () {
                double correctDeltaE = 41.14608122288197;

                double resultDirect = deltaE76(color1, color2);
                double resultGlobal = deltaE(color1, color2, algorithm: DeltaEAlgorithm.cie76);

                expect(resultDirect, correctDeltaE);
                expect(resultGlobal, correctDeltaE);
            });
        });
        // CIE94 algorithm
        group('dE94', () {
            // http://colormine.org/delta-e-calculator/cie94
            test('Return DeltaE', () {
                double correctDeltaE = 22.849281934529994;

                double resultDirect = deltaE94(color1, color2);
                double resultGlobal = deltaE(color1, color2, algorithm: DeltaEAlgorithm.cie94);

                expect(resultDirect, correctDeltaE);
                expect(resultGlobal, correctDeltaE);
            });
        });
        // CIE2000 algorithm
        group('dE00', () {
            // http://colormine.org/delta-e-calculator/cie2000
            test('Return DeltaE', () {
                double correctDeltaE = 22.394506952417895;

                double resultDirect = deltaE00(color1, color2);
                double resultGlobal = deltaE(color1, color2, algorithm: DeltaEAlgorithm.ciede2000);
                
                expect(resultDirect, correctDeltaE);
                expect(resultGlobal, correctDeltaE);
            });
            /**
             * Cases taken from the paper "The CIEDE2000 Color-Difference Formula:
             * Implementation Notes, Supplementary Test Data, and Mathematical Observations"
             * by Gaurav Sharma, Wencheng Wu and Edul N. Dalal.
             */
            test('0.0 difference', () {
                assertDeltaE00(0.0, LabColor(0.0, 0.0, 0.0), LabColor(0.0, 0.0, 0.0));
                assertDeltaE00(0.0, LabColor(99.5, 0.005, -0.01), LabColor(99.5, 0.005, -0.01));
            });
            test('100.0 difference', () {
                assertDeltaE00(100.0, LabColor(100, 0.005, -0.01), LabColor(0.0, 0.0, 0.0));
            });
            test('Error', () {
                expect(() {
                    deltaE00(LabColor(double.nan, double.nan, double.nan), LabColor(0.0, 0.0, 0.0));
                }, throwsA(TypeMatcher<AssertionError>()));
            });
            test('True chroma difference (#1)', () {
                assertDeltaE00(2.0425, LabColor(50.0, 2.6772, -79.7751), LabColor(50.0, 0.0, -82.7485));
            });
            test('True chroma difference (#2)', () {
                assertDeltaE00(2.8615, LabColor(50.0, 3.1571, -77.2803), LabColor(50.0, 0.0, -82.7485));
            });
            test('True chroma difference (#3)', () {
                assertDeltaE00(3.4412, LabColor(50.0, 2.8361, -74.02), LabColor(50.0, 0.0, -82.7485));
            });
            test('True hue difference (#4)', () {
                assertDeltaE00(1.0, LabColor(50.0, -1.3802, -84.2814), LabColor(50.0, 0.0, -82.7485));
            });
            test('True hue difference (#5)', () {
                assertDeltaE00(1.0, LabColor(50.0, -1.1848, -84.8006), LabColor(50.0, 0.0, -82.7485));
            });
            test('True hue difference (#6)', () {
                assertDeltaE00(1.0, LabColor(50.0, -0.9009, -85.5211), LabColor(50.0, 0.0, -82.7485));
            });
            test('Arctangent computation (#8)', () {
                assertDeltaE00(2.3669, LabColor(50.0, -1.0, 2.0), LabColor(50.0, 0.0, 0.0));
            });
            test('Arctangent computation (#9)', () {
                assertDeltaE00(7.1792, LabColor(50.0, 2.49, -0.001), LabColor(50.0, -2.49, 0.0009));
            });
            test('Arctangent computation (#10)', () {
                assertDeltaE00(7.1792, LabColor(50.0, 2.49, -0.001), LabColor(50.0, -2.49, 0.001));
            });
            test('Arctangent computation (#11)', () {
                assertDeltaE00(7.2195, LabColor(50.0, 2.49, -0.001), LabColor(50.0, -2.49, 0.0011));
            });
            test('Arctangent computation (#12)', () {
                assertDeltaE00(7.2195, LabColor(50.0, 2.49, -0.001), LabColor(50.0, -2.49, 0.0012));
            });
            test('Arctangent computation (#13)', () {
                assertDeltaE00(4.8045, LabColor(50.0, -0.001, 2.49), LabColor(50.0, 0.0009, -2.49));
            });
            test('Arctangent computation (#14)', () {
                assertDeltaE00(4.8045, LabColor(50.0, -0.001, 2.49), LabColor(50.0, 0.001, -2.49));
            });
            test('Arctangent computation (#15)', () {
                assertDeltaE00(4.7461, LabColor(50.0, -0.001, 2.49), LabColor(50.0, 0.0011, -2.49));
            });
            test('Arctangent computation (#16)', () {
                assertDeltaE00(4.3065, LabColor(50.0, 2.5, 0.0), LabColor(50.0, 0.0, -2.5));
            });
            test('Large color differences (#17)', () {
                assertDeltaE00(27.1492, LabColor(50.0, 2.5, 0.0), LabColor(73.0, 25.0, -18.0));
            });
            test('Large color differences (#18)', () {
                assertDeltaE00(22.8977, LabColor(50.0, 2.5, 0.0), LabColor(61.0, -5.0, 29.0));
            });
            test('Large color differences (#19)', () {
                assertDeltaE00(31.9030, LabColor(50.0, 2.5, 0.0), LabColor(56.0, -27.0, -3.0));
            });
            test('Large color differences (#20)', () {
                assertDeltaE00(19.4535, LabColor(50.0, 2.5, 0.0), LabColor(58.0, 24.0, 15.0));
            });
            test('CIE technical report (#21)', () {
                assertDeltaE00(1.0, LabColor(50.0, 2.5, 0.0), LabColor(50.0, 3.1736, 0.5854));
            });
            test('CIE technical report (#22)', () {
                assertDeltaE00(1.0, LabColor(50.0, 2.5, 0.0), LabColor(50.0, 3.2972, 0.0));
            });
            test('CIE technical report (#23)', () {
                assertDeltaE00(1.0, LabColor(50.0, 2.5, 0.0), LabColor(50.0, 1.8634, 0.5757));
            });
            test('CIE technical report (#24)', () {
                assertDeltaE00(1.0, LabColor(50.0, 2.5, 0.0), LabColor(50.0, 3.2592, 0.3350));
            });
            test('CIE technical report (#25)', () {
                assertDeltaE00(1.2644, LabColor(60.2574, -34.0099, 36.2677), LabColor(60.4626, -34.1751, 39.4387));
            });
            test('CIE technical report (#26)', () {
                assertDeltaE00(1.2630, LabColor(63.0109, -31.0961, -5.8663), LabColor(62.8187, -29.7946, -4.0864));
            });
            test('CIE technical report (#27)', () {
                assertDeltaE00(1.8731, LabColor(61.2901, 3.7196, -5.3901), LabColor(61.4292, 2.2480, -4.962));
            });
            test('CIE technical report (#28)', () {
                assertDeltaE00(1.8645, LabColor(35.0831, -44.1164, 3.7933), LabColor(35.0232, -40.0716, 1.5901));
            });
            test('CIE technical report (#29)', () {
                assertDeltaE00(2.0373, LabColor(22.7233, 20.0904, -46.694), LabColor(23.0331, 14.9730, -42.5619));
            });
            test('CIE technical report (#30)', () {
                assertDeltaE00(1.4146, LabColor(36.4612, 47.8580, 18.3852), LabColor(36.2715, 50.5065, 21.2231));
            });
            test('CIE technical report (#31)', () {
                assertDeltaE00(1.4441, LabColor(90.8027, -2.0831, 1.441), LabColor(91.1528, -1.6435, 0.0447));
            });
            test('CIE technical report (#32)', () {
                assertDeltaE00(1.5381, LabColor(90.9257, -0.5406, -0.9208), LabColor(88.6381, -0.8985, -0.7239));
            });
            test('CIE technical report (#33)', () {
                assertDeltaE00(0.6377, LabColor(6.7747, -0.2908, -2.4247), LabColor(5.8714, -0.0985, -2.2286));
            });
            test('CIE technical report (#34)', () {
                assertDeltaE00(0.9082, LabColor(2.0776, 0.0795, -1.135), LabColor(0.9033, -0.0636, -0.5514));
            });
        });
    });

    // Expected values taken from http://colormine.org/convert/rgb-to-lab
    group('Lab Color', () {
        LabColor expected = LabColor(28.1103, 25.9003, -5.2481);
        test('RGB to Lab (#1)', () {
            assertLabColor(expected, LabColor.fromRGB(100, 50, 75));
        });
        test('RGB to Lab (#2)', () {
            assertLabColor(expected, LabColor.fromRGBValue(0x64324B, RGBStructure.rgb));
        });
        test('RGB to Lab (#3)', () {
            assertLabColor(expected, LabColor.fromRGBValue(0xFF64324B));
            assertLabColor(expected, LabColor.fromRGBValue(0xFF64324B, RGBStructure.argb));
        });
        test('RGB to Lab (#4)', () {
            assertLabColor(expected, LabColor.fromRGBValue(0x64324BFF, RGBStructure.rgba));
        });
    });
}

void assertDeltaE00(double expected, LabColor c1, LabColor c2) {
    expect(round(deltaE00(c1, c2)), round(expected));
    expect(round(deltaE00(c2, c1)), round(expected));
}

void assertLabColor(LabColor expected, LabColor result) {
    expect(round(result.l), expected.l);
    expect(round(result.a), expected.a);
    expect(round(result.b), expected.b);
}

double round(double n) {
    return (n * 10000).round() / 10000;
}