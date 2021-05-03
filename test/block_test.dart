import 'package:back/block.dart';
import 'package:test/test.dart';

void main() {
  late Block genesis;

  setUp(() {
    genesis = Block.genesis();
  });

  test('genesis block', () {
    expect(genesis.timestamp, equals(0));
    expect(genesis.prevHash, equals('0' * 64));
  });

  test('hash()', () {
    final block = Block(
        DateTime.now().millisecondsSinceEpoch, genesis.hash(), 0, 0, [], 0);
    final hash = block.hash();
    expect(RegExp(r'^[0-9a-f]{64}$').hasMatch(hash), equals(true));
  });

  test('isValid()', () {
    final minDifficultyBlock = Block(
        DateTime.now().millisecondsSinceEpoch, genesis.hash(), 0, 0, [], 0);
    expect(minDifficultyBlock.isValid(), equals(false));
    final maxDifficultyBlock = Block(
        DateTime.now().millisecondsSinceEpoch, genesis.hash(), 256, 0, [], 0);
    expect(maxDifficultyBlock.isValid(), equals(true));
  });

  test('toJson()', () {
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final block = Block(timestamp, genesis.hash(), 0, 0, [], 0);
    expect(block.toJson(), {
      'timestamp': timestamp,
      'prevHash': genesis.hash(),
      'difficultyTarget': 0,
      'nonce': 0,
      'transactions': [],
      'miningDuration': 0
    });
  });

  test('fromJson()', () {
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final block = Block(timestamp, genesis.hash(), 0, 0, [], 0);
    final block2 = Block.fromJson(block.toJson());
    expect(block2.timestamp, timestamp);
    expect(block2.prevHash, genesis.hash());
    expect(block2.difficultyTarget, 0);
    expect(block2.nonce, 0);
    expect(block2.transactions, []);
    expect(block2.miningDuration, 0);
  });
}
