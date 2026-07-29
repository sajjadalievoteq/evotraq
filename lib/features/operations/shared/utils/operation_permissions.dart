import 'package:traqtrace_app/data/models/operations/shared/operation_type.dart';

/// EPCIS / operations step keys. Keep these aligned with
/// `OperationSecurityExpressions` on the backend (Phase 2).
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

/// Single role→step matrix mirroring backend `OperationSecurityExpressions`.
///
/// <pre>
/// Step                              Allowed roles
/// Commission / decommission         MANUFACTURER, ADMIN
/// Pack / unpack                     MANUFACTURER, DISTRIBUTOR, ADMIN
/// Ship / cancel-ship                MANUFACTURER, DISTRIBUTOR, RETAILER, ADMIN
/// Receive / accept / cancel-receive DISTRIBUTOR, RETAILER, ADMIN
/// Return-ship / return-receive      DISTRIBUTOR, RETAILER, ADMIN
/// Transform product                 MANUFACTURER, ADMIN
/// Update-status                     MANUFACTURER, DISTRIBUTOR, RETAILER, ADMIN
/// Read operations/events            MANUFACTURER, DISTRIBUTOR, RETAILER, ADMIN
/// Delete / destructive              ADMIN
/// </pre>
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

  /// Canonical matrix. Aliases (pack/unpack → aggregate, etc.) resolve here.
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

  /// Roles allowed to perform [step], or `null` if the step is unknown.
  static Set<String>? rolesFor(String step) {
    final key = step.trim().toLowerCase();
    return _rolesByStep[key];
  }

  /// Write-step key for a home/drawer [OperationType], or `null` if none.
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
