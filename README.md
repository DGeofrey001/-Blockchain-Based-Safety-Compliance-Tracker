> 🔒 Immutable safety inspections and compliance tracking for mining operations

## 🎯 Problem Solved

Mining operations often face issues with falsified safety inspection reports. This smart contract provides an **immutable blockchain ledger** for safety inspections, hazard reports, and certifications.

## ✨ Key Features

- 👮‍♂️ **Digital Inspector IDs** - Verified inspector registration system
- 📸 **Evidence Upload** - Photo/video proof storage via content hashes  
- ⏰ **Expiry Alerts** - Automatic safety certification expiration tracking
- 📊 **Compliance Scoring** - Real-time mine safety compliance scores
- 🚨 **Hazard Reporting** - Immutable hazard incident logging

- 🔄 **Ownership Transfers** - Seamless mine ownership transfers with data preservation
- 🔍 **Reinspection Requests** - Independent reinspection mechanism for disputed findings
- 🚨 **Emergency Shutdown Protocol** - Rapid response mechanism for critical safety incidents, halting operations and preventing new activities

## 🚀 Quick Start

### Register as Inspector

```clarity
(contract-call? .safety-tracker register-inspector "John Doe" "INS123456")
```

### Register a Mine

```clarity
(contract-call? .safety-tracker register-mine "MINE001" "Deep Valley Mine" "Colorado, USA")
```

### Submit Safety Inspection

```clarity
(contract-call? .safety-tracker submit-inspection 
  "MINE001" 
  "ROUTINE" 
  "PASSED" 
  "All safety systems operational"
  "abc123...def456" 
  u1000)
```

### Report Safety Hazard

```clarity
(contract-call? .safety-tracker report-hazard 
  "MINE001" 
  "GAS_LEAK" 
  u4 
  "Methane detected in shaft B"
  "xyz789...abc123")
```

### Issue Safety Certification

```clarity
(contract-call? .safety-tracker issue-certification 
  "MINE001" 
  "VENTILATION" 
  u2000 
  "cert456...hash789")
### Transfer Mine Ownership

```clarity
(contract-call? .safety-tracker transfer-mine-ownership "MINE001" 'ST1PQHQKV0RJXZFY1DGX8MNSNYVE3VGZJSRTPGZGM)
```

### Request Reinspection

```clarity
(contract-call? .safety-tracker request-reinspection
  u1
  "Disputed findings - ventilation system not properly inspected"
  "reinspect123...hash456")
```

## 📋 Contract Functions

### 📖 Read-Only Functions

| Function | Description |
|----------|-------------|
| `get-inspector` | Get inspector details by principal |
| `get-inspection` | Get inspection details by ID |
| `get-hazard-report` | Get hazard report by ID |
| `get-certification` | Get certification by ID |
| `get-mine-compliance` | Get mine compliance data |
| `check-compliance-status` | Check overall compliance status |
| `is-certification-expired` | Check if certification is expired |
| `get-reinspection` | Get reinspection details by ID |
| `get-emergency-shutdown` | Get emergency shutdown details by ID |
| `get-next-shutdown-id` | Get next available shutdown ID |

### ✍️ Public Functions

| Function | Description |
|----------|-------------|
| `register-inspector` | Register new safety inspector |
| `register-mine` | Register new mining operation |
| `transfer-mine-ownership` | Transfer mine ownership to new principal |
| `submit-inspection` | Submit safety inspection report |
| `report-hazard` | Report safety hazard incident |
| `issue-certification` | Issue safety certification |
| `resolve-hazard` | Mark hazard as resolved |
| `update-compliance-score` | Update mine compliance score |
| `revoke-certification` | Revoke existing certification |
| `request-reinspection` | Request reinspection for disputed findings |
| `approve-reinspection` | Approve or reject reinspection request |

## 🏗️ Data Structures

### Inspector Record
- ID, name, license number
- Active status and certifications

### Inspection Record  
- Inspector, mine ID, type, timestamp
- Status, findings, evidence hash
- Next inspection due date

### Hazard Report
- Reporter, mine ID, hazard type
- Severity level (1-5), description
- Evidence hash, resolution status

### Safety Certification
- Mine ID, certification type
- Issuer, issue/expiry dates
- Certificate hash, active status

### Mine Compliance
- Owner, name, location
- Compliance score, last inspection
- Active hazards, certifications list

### Reinspection Record
- Original inspection ID, reinspector
- Timestamp, findings, evidence hash
- Approval status

### Emergency Shutdown Record
- Mine ID, initiator, timestamp
- Reason, active status

- ✅ Ownership transfer authorization
## 🛡️ Security Features

- ✅ Inspector authorization checks
- ✅ Mine ownership validation  
- ✅ Input sanitization
- ✅ Expiry date validation
- ✅ Evidence hash integrity

## 📊 Compliance Scoring

- 🟢 **100**: Perfect compliance (no hazards, all certifications valid)
- 🟡 **75-99**: Good compliance (minor issues)
- 🟠 **50-74**: Moderate compliance (some hazards/expired certs)
- 🔴 **25-49**: Poor compliance (major hazards)
- ⚫ **0-24**: Critical compliance failure

## 🔧 Development

Built with [Clarinet](https://docs.hiro.so/stacks/clarinet) for Stacks blockchain.

### Testing

```bash
npm install
npm test
```

### Deploy

```bash
clarinet deploy
```

## 📄 License

MIT License - Built for mining safety transparency 🏗️⛑️
