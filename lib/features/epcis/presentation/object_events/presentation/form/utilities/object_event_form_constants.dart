const List<String> objectEventStandardBusinessSteps = [
  'urn:epcglobal:cbv:bizstep:commissioning',
  'urn:epcglobal:cbv:bizstep:decommissioning',
  'urn:epcglobal:cbv:bizstep:shipping',
  'urn:epcglobal:cbv:bizstep:receiving',
  'urn:epcglobal:cbv:bizstep:accepting',
  'urn:epcglobal:cbv:bizstep:packing',
  'urn:epcglobal:cbv:bizstep:unpacking',
  'urn:epcglobal:cbv:bizstep:inspecting',
  'urn:epcglobal:cbv:bizstep:storing',
  'urn:epcglobal:cbv:bizstep:holding',
  'urn:epcglobal:cbv:bizstep:picking',
  'urn:epcglobal:cbv:bizstep:loading',
  'urn:epcglobal:cbv:bizstep:unloading',
  'urn:epcglobal:cbv:bizstep:dispensing',
  'urn:epcglobal:cbv:bizstep:retail_selling',
  'urn:epcglobal:cbv:bizstep:destroying',
  'urn:epcglobal:cbv:bizstep:void_shipping',
  'urn:epcglobal:cbv:bizstep:returning',
];

const List<String> objectEventStandardDispositions = [
  'urn:epcglobal:cbv:disp:active',
  'urn:epcglobal:cbv:disp:available',
  'urn:epcglobal:cbv:disp:in_progress',
  'urn:epcglobal:cbv:disp:in_transit',
  'urn:epcglobal:cbv:disp:expired',
  'urn:epcglobal:cbv:disp:damaged',
  'urn:epcglobal:cbv:disp:destroyed',
  'urn:epcglobal:cbv:disp:dispensed',
  'urn:epcglobal:cbv:disp:recalled',
  'urn:epcglobal:cbv:disp:retail_sold',
  'urn:epcglobal:cbv:disp:returned',
  'urn:epcglobal:cbv:disp:sellable_accessible',
  'urn:epcglobal:cbv:disp:sellable_not_accessible',
  'urn:epcglobal:cbv:disp:inactive',
  'urn:epcglobal:cbv:disp:non_sellable_other',
  'urn:epcglobal:cbv:disp:container_closed',
  'urn:epcglobal:cbv:disp:encoded',
  'urn:epcglobal:cbv:disp:partially_dispensed',
  'urn:epcglobal:cbv:disp:stolen',
  'urn:epcglobal:cbv:disp:unknown',
  'urn:epcglobal:cbv:disp:consumed',
  'urn:epcglobal:cbv:disp:created',
  'urn:epcglobal:cbv:disp:sold',
];

const List<String> objectEventActions = ['ADD', 'OBSERVE', 'DELETE'];

const Map<String, String> cbvBizStepDefaultDisposition = {
  'urn:epcglobal:cbv:bizstep:commissioning': 'urn:epcglobal:cbv:disp:active',
  'urn:epcglobal:cbv:bizstep:decommissioning': 'urn:epcglobal:cbv:disp:inactive',
  'urn:epcglobal:cbv:bizstep:shipping': 'urn:epcglobal:cbv:disp:in_transit',
  'urn:epcglobal:cbv:bizstep:receiving': 'urn:epcglobal:cbv:disp:in_progress',
  'urn:epcglobal:cbv:bizstep:accepting': 'urn:epcglobal:cbv:disp:sellable_accessible',
  'urn:epcglobal:cbv:bizstep:inspecting': 'urn:epcglobal:cbv:disp:in_progress',
  'urn:epcglobal:cbv:bizstep:dispensing': 'urn:epcglobal:cbv:disp:dispensed',
  'urn:epcglobal:cbv:bizstep:retail_selling': 'urn:epcglobal:cbv:disp:retail_sold',
  'urn:epcglobal:cbv:bizstep:destroying': 'urn:epcglobal:cbv:disp:destroyed',
  'urn:epcglobal:cbv:bizstep:void_shipping': 'urn:epcglobal:cbv:disp:in_progress',
  'urn:epcglobal:cbv:bizstep:storing': 'urn:epcglobal:cbv:disp:sellable_not_accessible',
  'urn:epcglobal:cbv:bizstep:packing': 'urn:epcglobal:cbv:disp:container_closed',
  'urn:epcglobal:cbv:bizstep:unpacking': 'urn:epcglobal:cbv:disp:in_progress',
  'urn:epcglobal:cbv:bizstep:returning': 'urn:epcglobal:cbv:disp:returned',
  'urn:epcglobal:cbv:bizstep:holding': 'urn:epcglobal:cbv:disp:sellable_not_accessible',
  'urn:epcglobal:cbv:bizstep:picking': 'urn:epcglobal:cbv:disp:in_progress',
  'urn:epcglobal:cbv:bizstep:loading': 'urn:epcglobal:cbv:disp:in_progress',
  'urn:epcglobal:cbv:bizstep:unloading': 'urn:epcglobal:cbv:disp:in_progress',
};

const Map<String, List<String>> cbvBizStepAllowedDispositions = {
  'urn:epcglobal:cbv:bizstep:commissioning': [
    'urn:epcglobal:cbv:disp:active',
    'urn:epcglobal:cbv:disp:encoded',
  ],
  'urn:epcglobal:cbv:bizstep:decommissioning': ['urn:epcglobal:cbv:disp:inactive'],
  'urn:epcglobal:cbv:bizstep:shipping': ['urn:epcglobal:cbv:disp:in_transit'],
  'urn:epcglobal:cbv:bizstep:receiving': ['urn:epcglobal:cbv:disp:in_progress'],
  'urn:epcglobal:cbv:bizstep:accepting': [
    'urn:epcglobal:cbv:disp:sellable_accessible',
    'urn:epcglobal:cbv:disp:sellable_not_accessible',
  ],
  'urn:epcglobal:cbv:bizstep:inspecting': [
    'urn:epcglobal:cbv:disp:in_progress',
    'urn:epcglobal:cbv:disp:sellable_accessible',
    'urn:epcglobal:cbv:disp:non_sellable_other',
  ],
  'urn:epcglobal:cbv:bizstep:dispensing': ['urn:epcglobal:cbv:disp:dispensed'],
  'urn:epcglobal:cbv:bizstep:retail_selling': ['urn:epcglobal:cbv:disp:retail_sold'],
  'urn:epcglobal:cbv:bizstep:destroying': ['urn:epcglobal:cbv:disp:destroyed'],
  'urn:epcglobal:cbv:bizstep:void_shipping': ['urn:epcglobal:cbv:disp:in_progress'],
  'urn:epcglobal:cbv:bizstep:storing': [
    'urn:epcglobal:cbv:disp:sellable_not_accessible',
    'urn:epcglobal:cbv:disp:sellable_accessible',
  ],
  'urn:epcglobal:cbv:bizstep:packing': [
    'urn:epcglobal:cbv:disp:container_closed',
    'urn:epcglobal:cbv:disp:in_progress',
  ],
  'urn:epcglobal:cbv:bizstep:unpacking': ['urn:epcglobal:cbv:disp:in_progress'],
  'urn:epcglobal:cbv:bizstep:returning': ['urn:epcglobal:cbv:disp:returned'],
  'urn:epcglobal:cbv:bizstep:holding': [
    'urn:epcglobal:cbv:disp:sellable_not_accessible',
    'urn:epcglobal:cbv:disp:sellable_accessible',
  ],
  'urn:epcglobal:cbv:bizstep:picking': ['urn:epcglobal:cbv:disp:in_progress'],
  'urn:epcglobal:cbv:bizstep:loading': ['urn:epcglobal:cbv:disp:in_progress'],
  'urn:epcglobal:cbv:bizstep:unloading': ['urn:epcglobal:cbv:disp:in_progress'],
};

const Map<String, List<String>> actionAllowedBizSteps = {
  'ADD': objectEventStandardBusinessSteps,
  'OBSERVE': objectEventStandardBusinessSteps,
  'DELETE': [
    'urn:epcglobal:cbv:bizstep:decommissioning',
    'urn:epcglobal:cbv:bizstep:destroying',
  ],
};

const Map<String, String> actionDefaultBizStep = {
  'ADD': 'urn:epcglobal:cbv:bizstep:commissioning',
  'DELETE': 'urn:epcglobal:cbv:bizstep:decommissioning',
};

const String ilmdItemExpirationDateKey = 'cbvmda:itemExpirationDate';
const String ilmdManufacturerOfGoodsKey = 'cbvmda:manufacturerOfGoods';
