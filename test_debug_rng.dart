import 'dart:math';

void main() {
  // Test: if simulationSeed = 0, what does Random(0).nextDouble() give?
  final r = Random(0);
  final val = r.nextDouble();
  print('Random(0).nextDouble() = $val');
  print('Is < 0.03? ${val < 0.03}');
  
  // Test with sequential seeds
  int hits = 0;
  for (int i = 0; i < 500; i++) {
    final r2 = Random(i);
    if (r2.nextDouble() < 0.03) hits++;
  }
  print('With seeds 0-499: $hits/500 hit < 0.03');
}
