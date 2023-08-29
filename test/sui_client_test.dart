import 'dart:convert';
import 'dart:typed_data';

import 'package:bcs/bcs.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sui/builder/inputs.dart';
import 'package:sui/builder/transaction_block.dart';
import 'package:sui/builder/transactions.dart';
import 'package:sui/constants.dart';
import 'package:sui/cryptography/signature.dart';
import 'package:sui/rpc/faucet_client.dart';
import 'package:sui/signers/txn_data_serializers/txn_data_serializer.dart';
import 'package:sui/sui_account.dart';
import 'package:sui/sui_client.dart';
import 'package:sui/types/framework.dart';
import 'package:sui/types/sui_bcs.dart';
import 'package:sui/types/transactions.dart';


const modules = ["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"];
const dependencies = ["0x0000000000000000000000000000000000000000000000000000000000000001","0x0000000000000000000000000000000000000000000000000000000000000002"];

void main() {

  const test_mnemonics =
      'result crisp session latin must fruit genuine question prevent start coconut brave speak student dismiss';

  const DEFAULT_RECIPIENT = '0x32fa9903c31428579456cc5edcb76f8c09c02a0b5a3b3e94f6fe05bd99405741';

  const DEFAULT_GAS_BUDGET = 10000000;

  final data = Uint8List.fromList(utf8.encode('hello world'));

  test('test mnemonic generate', (){
    final mnemonics = SuiAccount.generateMnemonic();
    final isValid = SuiAccount.isValidMnemonics(mnemonics);
    expect(isValid, true);
  });

  test('test secp256k1 account generate from mnemonics', () {
    final account = SuiAccount.fromMnemonics(test_mnemonics, SignatureScheme.Secp256k1);
    expect(account.getAddress() == '0x7ec1b6df34a4018c377109851af1cf70db6687dd4a880a51f9119af86d855643', true);
  });

  test('test secp256r1 account generate from mnemonics', () {
    final account = SuiAccount.fromMnemonics(test_mnemonics, SignatureScheme.Secp256r1);
    expect(account.getAddress() == '0xab1965357f9765022c52f46c3ddd299c7980fbf5ddf63231066d3f27efd54d8e', true);
  });

  test('test ed25519 account generate from mnemonics', () {
    final account = SuiAccount.fromMnemonics(test_mnemonics, SignatureScheme.ED25519);
    expect(account.getAddress() == '0x936accb491f0facaac668baaedcf4d0cfc6da1120b66f77fa6a43af718669973', true);
  });

  test('test secp256k1 account generate', () {
    final account = SuiAccount.fromMnemonics(test_mnemonics, SignatureScheme.Secp256k1);
    final signature = account.signData(data);
    bool success = account.verify(data, signature);
    expect(success, true);
  });

  test('test secp256r1 account generate', () {
    final account = SuiAccount.fromMnemonics(test_mnemonics, SignatureScheme.Secp256r1);
    final signature = account.signData(data);
    bool success = account.verify(data, signature);
    expect(success, true);
  });

  test('test ed25519 account generate', () {
    final account = SuiAccount.ed25519Account();
    final signature = account.signData(data);
    bool success = account.verify(data, signature);
    expect(success, true);
  });

  test('test publish package', () async {
    final account = SuiAccount.fromMnemonics(test_mnemonics, SignatureScheme.Secp256k1);
    final client = SuiClient(Constants.devnetAPI, account: account);
    final modules = ["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"];
    final dependencies = ["0x0000000000000000000000000000000000000000000000000000000000000001","0x0000000000000000000000000000000000000000000000000000000000000002"];
    final txn = PublishTransaction(modules, dependencies, 100000000);
    final resp = await client.publish(txn);
    final objectChanges = (resp.json["objectChanges"] as List);
    final package = objectChanges.firstWhere((e) => e["type"] == "published");
    final packageId = package["packageId"].toString();
    expect(packageId.isNotEmpty, true);
  });

  test('test move contract call', () async {
    final account = SuiAccount.fromMnemonics(test_mnemonics, SignatureScheme.Secp256k1);
    final client = SuiClient(Constants.devnetAPI, account: account);
    final createSharedCounter = MoveCallTransaction(
        '0xa1a985ed4ce15503f36625c5996817337dc9e551',
        'counter',
        'create',
        [],
        [],
        1000
    );
    final createCounterResp = await client.executeMoveCall(createSharedCounter);
    final shareObj = createCounterResp.objectChanges?[0]?['objectId'];
    final shareObjId = shareObj.reference.objectId;

    final assertValueCall = MoveCallTransaction(
        '0xa1a985ed4ce15503f36625c5996817337dc9e551',
        'counter',
        'assert_value',
        [],
        [shareObjId, 0],
        1000
    );
    var assertValueResp = await client.executeMoveCall(assertValueCall);
    var error = assertValueResp.errors;
    expect(error == null, true);

    final incrementValueCall = MoveCallTransaction(
        '0xa1a985ed4ce15503f36625c5996817337dc9e551',
        'counter',
        'increment',
        [],
        [shareObjId],
        1000
    );
    final incrementValueResp = await client.executeMoveCall(incrementValueCall);
    error = incrementValueResp.errors;
    expect(error == null, true);

    assertValueResp = await client.executeMoveCall(assertValueCall);
    error = assertValueResp.errors;
    expect(error != null, true);
  });

  test('test pay sui with secp256k1', () async {
    final account = SuiAccount.fromMnemonics(test_mnemonics, SignatureScheme.Secp256k1);
    final client = SuiClient(Constants.devnetAPI, account: account);
    final coins = await client.getCoins(account.getAddress());
    if (coins.data.isEmpty) {
      final faucet = FaucetClient(Constants.faucetDevAPI);
      final resp = await faucet.requestSui(account.getAddress());
      assert(resp.transferredGasObjects.isNotEmpty);
    }

    final inputObjectIds = coins.data.take(2).map((x) => x.coinObjectId).toList();
    final txn = PaySuiTransaction(
        inputObjectIds,
        [DEFAULT_RECIPIENT],
        [1000],
        DEFAULT_GAS_BUDGET
    );

    final gasBudget = await client.getGasCostEstimation(txn);
    txn.gasBudget = gasBudget;

    final waitForLocalExecutionTx = await client.paySui(txn);
    expect(waitForLocalExecutionTx.confirmedLocalExecution, true);
  });

  test('test pay sui with secp256r1', () async {
    final account = SuiAccount.fromMnemonics(test_mnemonics, SignatureScheme.Secp256r1);
    final client = SuiClient(Constants.devnetAPI, account: account);
    final coins = await client.getCoins(account.getAddress());
    if (coins.data.isEmpty) {
      final faucet = FaucetClient(Constants.faucetDevAPI);
      final resp = await faucet.requestSui(account.getAddress());
      assert(resp.transferredGasObjects.isNotEmpty);
    }

    final inputObjectIds = coins.data.take(2).map((x) => x.coinObjectId).toList();
    final txn = PaySuiTransaction(
        inputObjectIds,
        [DEFAULT_RECIPIENT],
        [1000],
        DEFAULT_GAS_BUDGET
    );

    final gasBudget = await client.getGasCostEstimation(txn);
    txn.gasBudget = gasBudget;

    final waitForLocalExecutionTx = await client.paySui(txn);
    expect(waitForLocalExecutionTx.confirmedLocalExecution, true);
  });

  test('test pay sui with ed25519', () async {
    final account = SuiAccount.fromMnemonics(test_mnemonics, SignatureScheme.ED25519);
    final client = SuiClient(Constants.devnetAPI, account: account);
    final coins = await client.getCoins(account.getAddress());
    if (coins.data.isEmpty) {
      final faucet = FaucetClient(Constants.faucetDevAPI);
      final resp = await faucet.requestSui(account.getAddress());
      assert(resp.transferredGasObjects.isNotEmpty);
    }

    final inputObjectIds = coins.data.take(2).map((x) => x.coinObjectId).toList();
    final txn = PaySuiTransaction(
        inputObjectIds,
        [DEFAULT_RECIPIENT],
        [1000],
        DEFAULT_GAS_BUDGET
    );

    final gasBudget = await client.getGasCostEstimation(txn);
    txn.gasBudget = gasBudget;

    final waitForLocalExecutionTx = await client.paySui(txn);
    expect(waitForLocalExecutionTx.confirmedLocalExecution, true);
  });

  test('test getNormalizedMoveStruct', () async {
    final client = SuiClient(Constants.devnetAPI);
    final moveStruct = await client.provider.getNormalizedMoveStruct(
        '0x15297be265fda4ed4776a7752a433802bd64da8d',
        'counter',
        'Counter'
    );
    expect(moveStruct.fields[0].name == "id", true);
    expect(moveStruct.fields[1].name == "owner", true);
    expect(moveStruct.fields[2].name == "value", true);
  });


  test('test getMoveFunctionArgTypes', () async {
    final client = SuiClient(Constants.devnetAPI);
    final functionArgTypes = await client.provider.getMoveFunctionArgTypes(
        packageId: '0x15297be265fda4ed4776a7752a433802bd64da8d',
        moduleName: 'counter',
        functionName: 'set_value'
    );
    expect(functionArgTypes.length >= 3, true);
  });

  test('test transacitonblock SplitCoins', () async {
    final client = SuiClient(Constants.devnetAPI);
    final signer = SuiAccount.fromMnemonics(test_mnemonics, SignatureScheme.ED25519);
    final sender = signer.getAddress();

    final ownedObjs = await client.provider.getOwnedObjectList(sender);
    final coins = ownedObjs.data.where((e) => e.data?.type?.contains(SUI_TYPE_ARG) ?? false).toList();
    final gasCoin = coins.first.data!;

    final txb = TransactionBlock();
    txb.setGasPayment([gasCoin]);
    txb.setGasBudget(BigInt.from(4000000));

    // final coin = txb.splitCoins(txb.gas, [txb.pureInt(100000000)]);
    // txb.transferObjects([coin], txb.pureAddress(sender));

    final coin = txb.splitCoins(txb.gas, [txb.pureInt(100000000), txb.pureInt(100000000)]);
    txb.transferObjects([coin[0], coin[1]], txb.pureAddress(sender));
    // txb.transferObjects([coin[0]], txb.pureAddress(sender));
    // txb.transferObjects([coin[1]], txb.pureAddress(sender));

    final resp = await client.signAndExecuteTransactionBlock(
      signer, 
      txb,
      requestType: ExecuteTransaction.WaitForLocalExecution);
    expect(resp.confirmedLocalExecution, true);
  });


  test('test transacitonblock transferObjects', () async {
    final client = SuiClient(Constants.devnetAPI);
    final signer = SuiAccount.fromMnemonics(test_mnemonics, SignatureScheme.ED25519);
    final sender = signer.getAddress();

    final ownedObjs = await client.provider.getOwnedObjectList(sender);
    final coins = ownedObjs.data.where((e) => e.data?.type?.contains(SUI_TYPE_ARG) ?? false).toList();
    final gasCoin = coins.first.data!;
    final obj = coins.skip(1).first.data!;

    final txb = TransactionBlock();
    txb.setGasPayment([gasCoin]);
    txb.setGasBudget(BigInt.from(2000000));
    txb.transferObjects(
      [txb.objectRef(obj)],
      txb.pureAddress(sender),
    );

    final resp = await client.signAndExecuteTransactionBlock(
      signer,
      txb,
    );
    print(resp);
  });


  test('test transacitonblock mergeCoins', () async {
    final client = SuiClient(Constants.devnetAPI);
    final signer = SuiAccount.fromMnemonics(test_mnemonics, SignatureScheme.ED25519);
    final sender = signer.getAddress();

    final ownedObjs = await client.provider.getOwnedObjectList(sender);
    final coins = ownedObjs.data.where((e) => e.data?.type?.contains(SUI_TYPE_ARG) ?? false).toList();
    final gasCoin = coins.last.data!;
    final destObj = coins.first.data!;
    final srcObj = coins.skip(1).first.data!;

    final txb = TransactionBlock();
    txb.setGasPayment([gasCoin]);
    txb.setGasBudget(BigInt.from(2000000));

    txb.mergeCoins(txb.objectRef(destObj), [
      txb.objectRef(srcObj),
    ]);

    final resp = await client.signAndExecuteTransactionBlock(
      signer,
      txb,
    );
    print(resp);
  });


  test('test transacitonblock public package', () async {
    final client = SuiClient(Constants.devnetAPI);
    final signer = SuiAccount.fromMnemonics(test_mnemonics, SignatureScheme.ED25519);
    final sender = signer.getAddress();

    final ownedObjs = await client.provider.getOwnedObjectList(sender);
    final coins = ownedObjs.data.where((e) => e.data?.type?.contains(SUI_TYPE_ARG) ?? false).toList();
    final gasCoin = coins.first.data!;

    final txb = TransactionBlock();
    txb.setGasPayment([gasCoin]);
    txb.setGasBudget(BigInt.from(100000000));
    final cap = txb.publish(modules, dependencies);
    txb.transferObjects([cap], txb.pureAddress(sender));

    final resp = await client.signAndExecuteTransactionBlock(
      signer,
      txb,
    );
    print(resp);
  });


  test('test transacitonblock moveCall', () async {
    final client = SuiClient(Constants.devnetAPI);
    final signer = SuiAccount.fromMnemonics(test_mnemonics, SignatureScheme.ED25519);
    final sender = signer.getAddress();

    final ownedObjs = await client.provider.getOwnedObjectList(sender);
    final coins = ownedObjs.data.where((e) => e.data?.type?.contains(SUI_TYPE_ARG) ?? false).toList();
    final gasCoin = coins.first.data!;

    final capObj = ownedObjs.data.firstWhere((e) => e.data?.type?.startsWith("0x2::coin::TreasuryCap") ?? false);

    final txb = TransactionBlock();
    txb.setGasPayment([gasCoin]);
    txb.setGasBudget(BigInt.from(100000000));

    txb.moveCall(
      target: "0xf6612affa17fb388ffa0a429243abc4796c976afa681fc50e08fa237f2464a1a::managed::mint",
      arguments: [
        txb.objectRef(capObj.data!), txb.pureInt(1000), txb.pureAddress(sender)
      ]
    );

    final resp = await client.signAndExecuteTransactionBlock(
      signer,
      txb,
    );
    print(resp);
  });


  test('test transacitonblock makeMoveVec', () async {
    final client = SuiClient(Constants.devnetAPI);
    final signer = SuiAccount.fromMnemonics(test_mnemonics, SignatureScheme.ED25519);
    final sender = signer.getAddress();

    final ownedObjs = await client.provider.getOwnedObjectList(sender);
    final coins = ownedObjs.data.where((e) => e.data?.type?.contains(SUI_TYPE_ARG) ?? false).toList();
    final gasCoin = coins.first.data!;

    final txb = TransactionBlock();
    txb.setGasPayment([gasCoin]);
    txb.setGasBudget(BigInt.from(100000000));

    final vec = txb.makeMoveVec(objects: [
      txb.objectRef(coins.skip(2).first.data!),
      txb.objectRef(coins.skip(3).first.data!)
    ]);

    txb.moveCall(
      target: "0x2::pay::join_vec",
      typeArguments: ["0x2::sui::SUI"],
      arguments: [txb.objectRef(coins.skip(1).first.data!), vec]
    );

    final resp = await client.signAndExecuteTransactionBlock(
      signer,
      txb,
    );
    print(resp);
  });


  test('test transacitonblock test publish package', () async {
    final client = SuiClient(Constants.devnetAPI);
    final signer = SuiAccount.fromMnemonics(test_mnemonics, SignatureScheme.ED25519);
    final sender = signer.getAddress();

    final ownedObjs = await client.provider.getOwnedObjectList(sender);
    final coins = ownedObjs.data.where((e) => e.data?.type?.contains(SUI_TYPE_ARG) ?? false).toList();
    final gasCoin = coins.first.data!;

    final bytecodeStr = '{"modules":["oRzrCwYAAAAHAQAGAgYIAw4KBRgPByctCFRgDLQBDgAEAQMCBQEABwACAQIAAAIAAQAABAIBAAEHCAEABAgACAAIAAcIAQZTdHJpbmcJVHhDb250ZXh0BGluaXQGc3RyaW5nBHRlc3QKdHhfY29udGV4dAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAEAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAgAAAAABAQIBAQQAAQECAA=="],"dependencies":["0x0000000000000000000000000000000000000000000000000000000000000001","0x0000000000000000000000000000000000000000000000000000000000000002"],"digest":[54,25,72,21,237,244,164,121,88,120,101,42,91,74,72,110,81,80,196,167,192,190,64,83,78,199,83,77,32,91,82,189]}';
    final bytecode = jsonDecode(bytecodeStr);
    final modules = bytecode["modules"].cast<String>();
    final dependencies = bytecode["dependencies"].cast<String>();

    final txb = TransactionBlock();
    txb.setGasPayment([gasCoin]);
    txb.setGasBudget(BigInt.from(100000000));
    final cap = txb.publish(modules, dependencies);
    txb.transferObjects([cap], txb.pureAddress(sender));

    final responseOptions = SuiTransactionBlockResponseOptions(
      showEffects: true,
      showObjectChanges: true
    );
    final resp = await client.signAndExecuteTransactionBlock(
      signer,
      txb,
      responseOptions: responseOptions
    );
    final packageId = resp.objectChanges?.where((o) => o["type"] == "published").first["packageId"];
    expect(packageId is String, true);
    print("Published package $packageId from address $sender");
  });

  test('test transaction block test args', () async {

    final account = SuiAccount.fromMnemonics(test_mnemonics, SignatureScheme.ED25519);
    final client = SuiClient(Constants.devnetAPI, account: account);
    final receiver = SuiAccount.ed25519Account();
    final ownedObjs =
        await client.provider.getOwnedObjectList(account.getAddress());
    final coins = ownedObjs.data
        .where((e) => e.data?.type?.contains(SUI_TYPE_ARG) ?? false)
        .toList();
    final gasCoin = coins.first.data!;
    final txb = TransactionBlock();
    txb.setGasPayment([gasCoin]);
    txb.setGasBudget(BigInt.from(2000000));

    final coin = txb.splitCoins(txb.gas, [txb.pureInt(10000000)]);
    txb.transferObjects([coin], txb.pureAddress(receiver.getAddress()));

    txb.moveCall(target: '0xb1d6722effda483fdee29fb26460906f188c9cb8c41f428bc42676d093cd08cf::test::test', arguments: [
      txb.pureString('demo'),
      txb.pureString('string'),
      txb.pureString("xyz")
    ]);

    final resp = await client.signAndExecuteTransactionBlock(account, txb);
    expect(resp.confirmedLocalExecution, false);
    
  });

}