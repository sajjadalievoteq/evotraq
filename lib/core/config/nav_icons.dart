import 'package:traqtrace_app/core/config/app_assets.dart';
import 'package:traqtrace_app/core/utils/cbv_display_utils.dart';





abstract final class NavIcons {
  
  static String forBizStep(String businessStep) {
    final token = CbvDisplayUtils.shortName(businessStep)?.toLowerCase();
    if (token != null) {
      return switch (token) {
        'commissioning' => commissioning,
        'decommissioning' => AppAssets.iconDecommissioning,
        'unpacking' => unpacking,
        'packing' => packing,
        'shipping' => shipping,
        'receiving' => receiving,
        'accepting' => AppAssets.iconAccepting,
        'returning' => AppAssets.iconReturning,
        'loading' => AppAssets.iconLoadingCargo,
        'unloading' => AppAssets.iconUnloadingCargo,
        'dispatching' => AppAssets.iconDispatching,
        'transporting' => logistics,
        'holding' => AppAssets.iconHolding,
        'encoding' => serialization,
        'update_status' => updateStatus,
        'destroying' => AppAssets.iconFlame,
        'inspecting' => AppAssets.iconInspecting,
        'storing' => AppAssets.iconWarehouse,
        'picking' => AppAssets.iconCart,
        'cancel' => cancelShipping,
        _ => epcisEvents,
      };
    }

    final s = businessStep.toLowerCase();
    if (s.contains('unpacking')) return unpacking;
    if (s.contains('packing')) return packing;
    return epcisEvents;
  }

  
  static const String chevronRight = AppAssets.iconChevronR;
  static const String themeSun = AppAssets.iconSun;
  static const String themeMoon = AppAssets.iconMoon;
  static const String logout = AppAssets.iconLogout;
  static const String security = AppAssets.iconSecurity;

  
  static const String dashboard = AppAssets.iconDashboard;
  static const String profile = AppAssets.iconUser;
  static const String productJourney = AppAssets.iconProductJourney;
  static const String productHierarchy = AppAssets.iconProductHierarchy;
  static const String inboxOutbox = AppAssets.iconInboxOutbox;

  
  static const String masterData = AppAssets.iconDataset;
  static const String gtin = AppAssets.iconGtin;
  static const String gln = AppAssets.iconGln;
  static const String serialization = AppAssets.iconQr;
  static const String sscc = AppAssets.iconSscc;
  static const String sgtin = AppAssets.iconSgtin;

  
  static const String epcisEvents = AppAssets.iconEvent;
  static const String objectEvents = AppAssets.iconObjectEvent;
  static const String aggregationEvents = AppAssets.iconAggregate;

  
  static const String eventQueries = AppAssets.iconSearch;
  static const String allEvents = AppAssets.iconEvent;
  static const String aggregationHierarchy = AppAssets.iconHierarchy;
  static const String advancedQuery = AppAssets.iconAdvancedFilter;
  static const String supplyChainTraversal = AppAssets.iconRoute;
  static const String eventSerialization = AppAssets.iconChip;

  
  static const String lifecycle = AppAssets.iconPrecisionManufacturing;
  static const String packaging = AppAssets.iconPackage;
  static const String logistics = AppAssets.iconTruck;
  static const String shippings = AppAssets.iconShipment;
  static const String receivings = AppAssets.iconReceivingInbound;
  static const String inbox = AppAssets.iconReceivingInbound;
  static const String outbox = AppAssets.iconShipment;

  static const String commissioning = AppAssets.iconPrecisionManufacturing;
  static const String packing = AppAssets.iconPackingSealed;
  static const String unpacking = AppAssets.iconUnpacking;
  static const String shipping = AppAssets.iconShipment;
  static const String returnShipping = AppAssets.iconReturnShipping;
  static const String cancelShipping = AppAssets.iconXCircle;
  static const String receiving = AppAssets.iconReceivingInbound;
  static const String returnReceiving = AppAssets.iconReturnReceiving;
  static const String cancelReceiving = AppAssets.iconXCircle;
  static const String updateStatus = AppAssets.iconUpdateStatus;
  static const String shipmentCorrection = AppAssets.iconTransform;

  
  static const String generateVerifyBarcode = AppAssets.iconQr;
  static const String validation = AppAssets.iconCheck;
  static const String gs1ValidationDemo = AppAssets.iconFlask;
  static const String gs1ValidationTests = AppAssets.iconCheckCircle;
  static const String integrationValidation = AppAssets.iconNetworkCheck;
  static const String validationRules = AppAssets.iconChecklist;
  static const String conversion = AppAssets.iconTransform;
  static const String epcConversion = AppAssets.iconTransform;

  
  static const String userManagement = AppAssets.iconUsers;
  static const String pendingApprovals = AppAssets.iconApproval;

  
  static const String notifications = AppAssets.iconNotification;
  static const String notificationCenter = AppAssets.iconNotification;
  static const String manageSubscriptions = AppAssets.iconMail;
  static const String webhookConfiguration = AppAssets.iconWebhook;

  
  static const String batchProcessing = AppAssets.iconSpinner;
  static const String jobQueueManagement = AppAssets.iconQueue;
  static const String etlManagement = AppAssets.iconTransform;
  static const String bulkExport = AppAssets.iconDownload;

  
  static const String apiManagement = AppAssets.iconApi;
  static const String apiCollections = AppAssets.iconFolder;
  static const String partnerManagement = AppAssets.iconBusiness;
  static const String serviceAccounts = AppAssets.iconKey;

  
  static const String systemTools = AppAssets.iconBuild;
  static const String systemSettings = AppAssets.iconSettings;
  static const String cacheManagement = AppAssets.iconCloud;
  static const String performanceTests = AppAssets.iconTimer;
  static const String performanceOptimization = AppAssets.iconGauge;
  static const String systemMonitoring = AppAssets.iconEye;
  static const String databasePartitioning = AppAssets.iconDatabase;
  static const String dataConsistencyIntegrity = AppAssets.iconVerified;

  
  static const String testDataGeneration = AppAssets.iconFlask;
  static const String eventGenerationTests = AppAssets.iconEvent;
  static const String industryTestData = AppAssets.iconFactory;
  static const String cbvVocabulary = AppAssets.iconTag;

  
  static const String postmanCollection = AppAssets.iconDownload;
  static const String helpSupport = AppAssets.iconHelpCircle;
}
