import 'package:flutter_test/flutter_test.dart';
import 'package:sui/constants.dart';
import 'package:sui/sui_client.dart';

void main() {
  const DEFAULT_PACKAGE = '0x2';
  const DEFAULT_MODULE = 'coin';
  const DEFAULT_FUNCTION = 'balance';
  const DEFAULT_STRUCT = 'Coin';

  test('test getMoveFunctionArgTypes', () async {
    final client = SuiClient(Constants.devnetAPI);
    final functionArgTypes = await client.provider.getMoveFunctionArgTypes(
      DEFAULT_PACKAGE,
      DEFAULT_MODULE,
      DEFAULT_FUNCTION,
    );
    expect(functionArgTypes[0]['Object'] == 'ByImmutableReference', true);
  });

  test('test getNormalizedMoveModulesByPackage', () async {
    final client = SuiClient(Constants.devnetAPI);
    final moveModules = await client.provider
        .getNormalizedMoveModulesByPackage(DEFAULT_PACKAGE);
    expect(moveModules.keys.contains(DEFAULT_PACKAGE), true);
    expect(moveModules.keys.isNotEmpty, true);
  });

  test('test getNormalizedMoveModule', () async {
    final client = SuiClient(Constants.devnetAPI);
    final moveModule = await client.provider
        .getNormalizedMoveModule(DEFAULT_PACKAGE, DEFAULT_MODULE);
    expect(moveModule.exposedFunctions.containsKey(DEFAULT_FUNCTION), true);
  });

  test('test getNormalizedMoveFunction', () async {
    final client = SuiClient(Constants.devnetAPI);
    final moveFunction = await client.provider.getNormalizedMoveFunction(
      DEFAULT_PACKAGE,
      DEFAULT_MODULE,
      DEFAULT_FUNCTION,
    );
    expect(moveFunction.isEntry == false, true);
  });

  test('test getNormalizedMoveStruct', () async {
    final client = SuiClient(Constants.devnetAPI);
    final moveStruct = await client.provider.getNormalizedMoveStruct(
      DEFAULT_PACKAGE,
      DEFAULT_MODULE,
      DEFAULT_STRUCT,
    );
    expect(moveStruct.fields.length > 1, true);
  });
}
