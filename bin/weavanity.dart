import 'dart:async';
import 'dart:io';
import 'dart:isolate';

import 'package:args/args.dart';
import 'package:colorize/colorize.dart';

import 'package:weavanity/wallet.dart';
import 'package:weavanity/utils.dart';

Future<void> main(List<String> args) async {
  final ArgParser parser = ArgParser()
    ..addOption('prefix',
        abbr: 'p', help: 'Desired prefix. Should be [a-zA-Z0-9_-]')
    ..addOption('suffix',
        abbr: 's', help: 'Desired suffix. Should be [a-zA-Z0-9_-]')
    ..addOption('threads',
        abbr: 't',
        help: 'number of threads',
        defaultsTo: Platform.numberOfProcessors.toString())
    ..addFlag('help', abbr: 'h', help: 'Display help', negatable: false);

  final ArgResults cliArgs = parser.parse(args);

  if (cliArgs['help']) return printHelp(cliUsage: parser.usage);

  final String prefix = cliArgs['prefix'] ?? '';
  final String suffix = cliArgs['suffix'] ?? '';
  final int threads = int.tryParse(cliArgs['threads']) != null &&
          int.parse(cliArgs['threads']) > 0
      ? int.parse(cliArgs['threads'])
      : 0;

  if (!checkArgs(prefix: prefix, suffix: suffix, threads: threads)) {
    return printHelp(cliUsage: parser.usage);
  }

  final isolateListener =
      await startIsolates(prefix: prefix, suffix: suffix, threads: threads);

  final int startDate = DateTime.now().millisecondsSinceEpoch;
  int counter = 0;

  isolateListener((dynamic message) async {
    if (message['jwk'] != null) {
      final String address = message['address'];
      final String jwkJson = message['jwk'];

      await File('$address.json').writeAsString(jwkJson);
      await stdout.flush();
      stdout.write('🎉 ${Colorize('Address found!').bold()}\n');
      stdout.write('😬 Tried $counter addresses\n\n');
      stdout.write('📬 Address: ${Colorize(address).yellow()}\n');
      stdout.write('📝 Wallet written: $address.json');
      exit(0);
    }

    counter++;
    final double frequency =
        calculateFrequencyInSeconds(counter: counter, startDateInMs: startDate);

    final Colorize frequencyText =
        Colorize('(${frequency.toStringAsFixed(2)} addresses/s)').lightGray();

    stdout.write('Tried $counter addresses $frequencyText\r');
  });
}

startIsolates(
    {required String prefix,
    required String suffix,
    required int threads}) async {
  final p = ReceivePort();

  for (int i = 0; i < threads; i++) {
    await Isolate.spawn(generateAddress,
        {'send': p.sendPort.send, 'prefix': prefix, 'suffix': suffix});
  }

  return p.listen;
}

Future<void> generateAddress(Map<String, Object> params) async {
  final send = params['send'] as Function;
  final prefix = params['prefix'] as String;
  final suffix = params['suffix'] as String;

  String address;
  Wallet wallet;

  do {
    wallet = await Wallet.generate();
    address = await wallet.getAddress();

    send({'address': address});
  } while (!checkAddress(prefix: prefix, suffix: suffix, address: address));

  send({'address': address, 'jwk': wallet.toJwkJson()});
}
