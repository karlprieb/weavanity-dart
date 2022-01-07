import 'package:weavanity/utils.dart';
import 'package:test/test.dart';

void main() {
  group('checkArgs', () {
    test('when prefix is provided', () {
      expect(checkArgs(prefix: 'a', suffix: '', threads: 1), equals(true));
    });

    test('when suffix is provided', () {
      expect(checkArgs(prefix: '', suffix: 'a', threads: 1), equals(true));
    });

    test('when prefix and suffix are provided', () {
      expect(checkArgs(prefix: 'a', suffix: 'a', threads: 1), equals(true));
    });

    test('when prefix and suffix are not provided', () {
      expect(checkArgs(prefix: '', suffix: '', threads: 1), equals(false));
    });

    test('when threads are <= 0', () {
      expect(checkArgs(prefix: '', suffix: '', threads: 0), equals(false));
      expect(checkArgs(prefix: '', suffix: '', threads: -1), equals(false));
    });
  });

  group('checkAddress', () {
    const String address = 'KYSHaL_D2fNEatjdgMxZIpZj-9IZpur7l2SHjGNnIlc';

    test('when both prefix and suffix are valid', () {
      expect(checkAddress(prefix: 'KY', suffix: 'lc', address: address),
          equals(true));
      expect(checkAddress(prefix: 'KY', suffix: 'wrong', address: address),
          equals(false));
      expect(checkAddress(prefix: 'wrong', suffix: 'lc', address: address),
          equals(false));
      expect(checkAddress(prefix: 'wrong', suffix: 'wrong', address: address),
          equals(false));
    });

    test('when just prefix is valid', () {
      expect(checkAddress(prefix: 'KY', suffix: '', address: address),
          equals(true));
      expect(checkAddress(prefix: 'wrong', suffix: '', address: address),
          equals(false));
    });

    test('when just prefix is valid', () {
      expect(checkAddress(prefix: 'KY', suffix: '', address: address),
          equals(true));
      expect(checkAddress(prefix: 'wrong', suffix: '', address: address),
          equals(false));
    });

    test('when prefix and suffix are not valid', () {
      expect(checkAddress(prefix: '', suffix: '', address: address),
          equals(false));
      expect(checkAddress(prefix: 'wrong', suffix: 'wrong', address: address),
          equals(false));
    });
  });

  test('calculateFrequencyInSeconds', () {
    expect(
        calculateFrequencyInSeconds(
            counter: 1,
            startDateInMs: DateTime.now().millisecondsSinceEpoch - 1000),
        equals(1.0));
    expect(
        calculateFrequencyInSeconds(
            counter: 100000,
            startDateInMs: DateTime.now().millisecondsSinceEpoch - 1000),
        equals(100000.0));
  });
}
