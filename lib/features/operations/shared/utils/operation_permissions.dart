import 'package:traqtrace_app/data/models/operations/shared/operation_type.dart';

abstract final class OperationSteps {
  static const commission = 'commission';
  static const decommission = 'decommission';
  static const pack = 'pack';
  static const unpack = 'unpack';
  static const aggregate = 'aggregate';
  static const ship = 'ship';
  static const cancelShip = 'cancel-ship';
  static const receive = 'receive';
  static const accept = 'accept';
  static const cancelReceive = 'cancel-receive';
  static const returnShip = 'return-ship';
  static const returnReceive = 'return-receive';
  static const transform = 'transform';
  static const updateStatus = 'update-status';
  static const read = 'read';
  static const delete = 'delete';
}

abstract final class OperationPermissions {
  static const Set<String> _manufacturerAdmin = {'MANUFACTURER', 'ADMIN'};
  static const Set<String> _manufacturerDistributorAdmin = {
    'MANUFACTURER',
    'DISTRIBUTOR',
    'ADMIN',
  };
  static const Set<String> _supplyChain = {
    'MANUFACTURER',
    'DISTRIBUTOR',
    'RETAILER',
    'ADMIN',
  };
  static const Set<String> _distributorRetailerAdmin = {
    'DISTRIBUTOR',
    'RETAILER',
    'ADMIN',
  };
  static const Set<String> _adminOnly = {'ADMIN'};

  static const Map<String, Set<String>> _rolesByStep = {
    OperationSteps.commission: _manufacturerAdmin,
    OperationSteps.decommission: _manufacturerAdmin,
    OperationSteps.aggregate: _manufacturerDistributorAdmin,
    OperationSteps.pack: _manufacturerDistributorAdmin,
    OperationSteps.unpack: _manufacturerDistributorAdmin,
    OperationSteps.ship: _supplyChain,
    OperationSteps.cancelShip: _supplyChain,
    OperationSteps.receive: _distributorRetailerAdmin,
    OperationSteps.accept: _distributorRetailerAdmin,
    OperationSteps.cancelReceive: _distributorRetailerAdmin,
    OperationSteps.returnShip: _distributorRetailerAdmin,
    OperationSteps.returnReceive: _distributorRetailerAdmin,
    OperationSteps.transform: _manufacturerAdmin,
    OperationSteps.updateStatus: _supplyChain,
    OperationSteps.read: _supplyChain,
    OperationSteps.delete: _adminOnly,
  };

  static Set<String>? rolesFor(String step) {
    final key = step.trim().toLowerCase();
    return _rolesByStep[key];
  }

  static String stepForOperationType(OperationType type) => switch (type) {
    OperationType.commissioning => OperationSteps.commission,
    OperationType.updateStatus => OperationSteps.updateStatus,
    OperationType.packing => OperationSteps.pack,
    OperationType.unpacking => OperationSteps.unpack,
    OperationType.shipping => OperationSteps.ship,
    OperationType.cancelShipping => OperationSteps.cancelShip,
    OperationType.returnShipping => OperationSteps.returnShip,
    OperationType.receiving => OperationSteps.receive,
    OperationType.cancelReceiving => OperationSteps.cancelReceive,
    OperationType.returnReceiving => OperationSteps.returnReceive,
  };
}