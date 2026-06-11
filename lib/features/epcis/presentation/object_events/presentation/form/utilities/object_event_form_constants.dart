/// GS1 CBV business steps relevant for Object Events.
const List<String> objectEventStandardBusinessSteps = [
  'urn:epcglobal:cbv:bizstep:commissioning',
  'urn:epcglobal:cbv:bizstep:shipping',
  'urn:epcglobal:cbv:bizstep:receiving',
  'urn:epcglobal:cbv:bizstep:packing',
  'urn:epcglobal:cbv:bizstep:unpacking',
  'urn:epcglobal:cbv:bizstep:inspecting',
  'urn:epcglobal:cbv:bizstep:storing',
  'urn:epcglobal:cbv:bizstep:picking',
  'urn:epcglobal:cbv:bizstep:loading',
  'urn:epcglobal:cbv:bizstep:unloading',
  'urn:epcglobal:cbv:bizstep:dispensing',
  'urn:epcglobal:cbv:bizstep:destroying',
  'urn:epcglobal:cbv:bizstep:decommissioning',
];

/// GS1 CBV dispositions relevant for Object Events.
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
];

/// EPCIS Object Event actions.
const List<String> objectEventActions = ['ADD', 'OBSERVE', 'DELETE'];
