import 'package:delta_e/delta_e.dart';

void main() {
    // Creating two test LAB color objects to compare
    LabColor lab1 = LabColor(36, 60, 41);
    LabColor lab2 = LabColor(100, 40, 90);
    // 1976 formula
    print(deltaE76(lab1, lab2)); // 83.04817878797824
    print(deltaE(lab1, lab2, algorithm: DeltaEAlgorithm.cie76)); // 83.04817878797824
    // 1994 formula
    print(deltaE94(lab1, lab2)); // 67.97917774753019
    print(deltaE(lab1, lab2, algorithm: DeltaEAlgorithm.cie94)); // 67.97917774753019
    // 2000 formula
    print(deltaE00(lab1, lab2)); // 56.85828292477247
    print(deltaE(lab1, lab2, algorithm: DeltaEAlgorithm.ciede2000)); // 56.85828292477247
}