import 'package:flutter_test/flutter_test.dart';
import 'package:taxigo_flutter/services/store.dart';
void main(){test('fare formula is base 50 plus 15 per km plus 10 service fee',(){expect(Store.fare(0),60);expect(Store.fare(5),135);expect(Store.fare(12),240);});}
