import 'dart:io';

import 'package:args/args.dart';

bool checkArgs(
        {required String prefix,
        required String suffix,
        required int threads}) =>
    ((prefix.isNotEmpty || suffix.isNotEmpty) && threads >= 0);

bool checkAddress(
    {required String prefix, required String suffix, required String address}) {
  if (prefix.isNotEmpty && suffix.isNotEmpty) {
    return address.startsWith(prefix) && address.endsWith(suffix);
  }

  if (prefix.isNotEmpty) {
    return address.startsWith(prefix);
  }

  if (suffix.isNotEmpty) {
    return address.endsWith(suffix);
  }

  return false;
}

double calculateFrequencyInSeconds(
    {required int counter, required int startDateInMs}) {
  int currentDate = DateTime.now().millisecondsSinceEpoch;
  int difference = (currentDate - startDateInMs);
  return (counter / difference) * 1000;
}

void printHelp({required String cliUsage}) {
  stdout.write('Weavanity - An Arweave vanity address generator\n\n');
  stdout.write('Usage: weavanity [options]\n\n');
  stdout
      .write('Example: weavanity --prefix karl --suffix perm --threads 8\n\n');
  stdout.write('Options:\n');
  stdout.write(cliUsage);
}
