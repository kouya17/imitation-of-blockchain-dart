import 'package:back/blockchain.dart';
import 'package:back/block.dart';
import 'package:back/config.dart';
import 'package:test/test.dart';

void main() {
  late Blockchain blockchain;
  late Block newBlock;

  setUp(() {
    blockchain = Blockchain();
    newBlock = Block(DateTime.now().millisecondsSinceEpoch,
        blockchain.chain[0].hash(), 256, 0, [], 0);
  });

  test('initial value', () {
    expect(blockchain.chain.length, equals(1));
    final block = Block.genesis();
    expect(blockchain.chain[0].hash(), equals(block.hash()));
  });

  test('canAddBlock()', () {
    final olderBlock = Block(-1, blockchain.chain[0].hash(), 256, 0, [], 0);
    expect(blockchain.canAddBlock(olderBlock), equals(false));
    final wrongHashBlock =
        Block(DateTime.now().millisecondsSinceEpoch, 'xxxx', 256, 0, [], 0);
    expect(blockchain.canAddBlock(wrongHashBlock), equals(false));
    final invalidBlock = Block(DateTime.now().millisecondsSinceEpoch,
        blockchain.chain[0].hash(), 0, 0, [], 0);
    expect(blockchain.canAddBlock(invalidBlock), equals(false));
    expect(blockchain.canAddBlock(newBlock), equals(true));
  });

  test('addBlock()', () {
    final invalidBlock = Block(DateTime.now().millisecondsSinceEpoch,
        blockchain.chain[0].hash(), 0, 0, [], 0);
    expect(blockchain.addBlock(invalidBlock), equals(false));
    expect(blockchain.chain.length, equals(1));

    expect(blockchain.addBlock(newBlock), equals(true));
    expect(blockchain.chain.length, equals(2));
    expect(blockchain.chain[0].hash(), equals(blockchain.chain[1].prevHash));
  });

  test('lastHash()', () {
    final genesis = Block.genesis();
    expect(blockchain.lastHash(), equals(genesis.hash()));
    blockchain.addBlock(newBlock);
    expect(blockchain.lastHash(), equals(newBlock.hash()));
  });

  test('isValidChain()', () {
    // invalid genesis block
    var chain = [newBlock];
    expect(Blockchain.isValidChain(chain), equals(false));

    final genesis = Block.genesis();
    chain = [genesis];
    expect(Blockchain.isValidChain(chain), equals(true));

    // invalid prev hash
    chain = [genesis, Block(0, 'xxx', 256, 0, [], 0)];
    expect(Blockchain.isValidChain(chain), equals(false));

    // invalid block
    chain = [genesis, Block(0, genesis.hash(), 0, 0, [], 0)];
    expect(Blockchain.isValidChain(chain), equals(false));

    chain = [genesis, newBlock];
    expect(Blockchain.isValidChain(chain), equals(true));
  });

  test('calcDifficultyTarget', () {
    const difficultyTarget = 250;
    final longMiningBlock = Block(
        DateTime.now().millisecondsSinceEpoch,
        blockchain.chain[0].hash(),
        difficultyTarget,
        0,
        [],
        Config.MINING_DURATION * 2);
    final chain = blockchain.chain + [longMiningBlock];
    expect(Blockchain.calcDifficultyTarget(chain), difficultyTarget + 1);

    final shortMiningBlock = Block(
        DateTime.now().millisecondsSinceEpoch,
        blockchain.chain[0].hash(),
        difficultyTarget,
        0,
        [],
        (Config.MINING_DURATION / 2).round());
    chain.add(shortMiningBlock);
    expect(
        Blockchain.calcDifficultyTarget(chain), equals(difficultyTarget - 1));

    final justRightBlock = Block(
        DateTime.now().millisecondsSinceEpoch,
        blockchain.chain[0].hash(),
        difficultyTarget,
        0,
        [],
        (Config.MINING_DURATION * 1.1).round());
    chain.add(justRightBlock);
    expect(Blockchain.calcDifficultyTarget(chain), equals(difficultyTarget));
  });

  test('replaceChain()', () {
    blockchain.addBlock(newBlock);
    final genesis = Block.genesis();

    // ignore short chain
    blockchain.replaceChain([genesis]);
    expect(blockchain.chain.length, 2);

    // ignore invalid chain
    blockchain.replaceChain([genesis, Block(0, 'xxx', 256, 0, [], 0)]);
    expect(blockchain.chain[1], newBlock);

    // replace valid chain
    final newBlock2 = Block(DateTime.now().millisecondsSinceEpoch,
        newBlock.hash(), 256, 0, [], Config.MINING_DURATION);
    blockchain.replaceChain([genesis, newBlock, newBlock2]);
    expect(blockchain.chain.length, 3);
  });
}
