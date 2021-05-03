import 'dart:convert';
import 'package:back/block.dart';
import 'package:back/config.dart';

class Blockchain {
  List<Block> chain;

  Blockchain() : chain = ([Block.genesis()]);

  bool addBlock(Block block) {
    if (!canAddBlock(block)) {
      return false;
    }
    chain.add(block);
    return true;
  }

  bool canAddBlock(Block block) {
    final lastBlock = chain[chain.length - 1];
    return block.prevHash == lastBlock.hash() &&
        block.timestamp > lastBlock.timestamp &&
        block.isValid();
  }

  String lastHash() {
    return chain[chain.length - 1].hash();
  }

  static bool isValidChain(List<Block> chain) {
    if (jsonEncode(chain[0]) != jsonEncode(Block.genesis())) {
      return false;
    }

    Block? prevBlock;
    return chain.every((block) {
      if (prevBlock == null) {
        prevBlock = block;
        return true;
      }
      if (!block.isValid()) {
        return false;
      }
      if (prevBlock!.hash() != block.prevHash) {
        return false;
      }
      prevBlock = block;
      return true;
    });
  }

  int nextDifficultyTarget() {
    return Blockchain.calcDifficultyTarget(chain);
  }

  static int calcDifficultyTarget(List<Block> chain) {
    final lastBlock = chain[chain.length - 1];
    if (lastBlock.miningDuration > Config.MINING_DURATION * 1.2) {
      return lastBlock.difficultyTarget + 1;
    }
    if (lastBlock.miningDuration < Config.MINING_DURATION * 0.8) {
      return lastBlock.difficultyTarget - 1;
    }
    return lastBlock.difficultyTarget;
  }

  void replaceChain(List<Block> newChain) {
    if (newChain.length < chain.length) {
      print('チェーンが短いため無視');
      return;
    }
    if (!Blockchain.isValidChain(newChain)) {
      print('チェーンが有効でないため無視');
      return;
    }
    chain = newChain;
    print('チェーン更新');
  }
}
