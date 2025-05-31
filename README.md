# DeepSea Vessel Registry

A blockchain-based certification system for deep ocean research vessels built on the Stacks blockchain using Clarity smart contracts.

## Overview

The DeepSea Vessel Registry provides a comprehensive, immutable system for managing deep ocean research vessel certifications, crew qualifications, equipment validation, and deployment approvals. The system ensures transparency, security, and regulatory compliance through blockchain technology.

## Features

### 🚢 Vessel Registration & Management

- Register deep ocean research vessels with detailed specifications
- Track vessel capabilities including maximum depth and crew capacity
- Maintain vessel status and certification levels
- Immutable registration records with timestamp verification

### 👨‍🔬 Crew Certification System

- Record and validate crew member certifications
- Track certification expiry dates and renewal requirements
- Multi-authority certification support
- Immutable certification history

### 🔧 Equipment Validation

- Comprehensive equipment certification tracking
- Validation by authorized maritime authorities
- Certification hash storage for document verification
- Automated inspection scheduling

### 📋 Maintenance Records

- Complete maintenance history tracking
- Cost and technician documentation
- Scheduled maintenance reminders
- Immutable maintenance logs

### ✅ Multi-Signature Deployment Approval

- Multi-authority approval system for vessel deployments
- Configurable signature requirements
- Mission-specific deployment tracking
- Real-time approval status monitoring

### 🏛️ Maritime Authority Integration

- Authorized maritime authority registration
- Jurisdiction-based authority management
- Role-based access control
- Real-time status verification

## Smart Contract Structure

### Core Data Maps

- `vessels`: Main vessel registry with specifications and status
- `crew-certifications`: Crew member certification records
- `equipment-validation`: Equipment certification and inspection data
- `maintenance-records`: Complete maintenance history
- `deployment-approvals`: Mission deployment approval tracking
- `approval-signatures`: Multi-signature approval records
- `maritime-authorities`: Authorized certifying bodies

### Key Functions

#### Vessel Management

- `register-vessel`: Register a new research vessel
- `update-vessel-status`: Update vessel operational status
- `get-vessel`: Retrieve vessel information

#### Certification & Validation

- `certify-crew`: Issue crew member certifications
- `validate-equipment`: Certify vessel equipment
- `add-maintenance-record`: Log maintenance activities

#### Deployment Authorization

- `request-deployment-approval`: Submit deployment request
- `approve-deployment`: Authority approval with signature
- Multi-signature requirement enforcement

#### Authority Management

- `register-maritime-authority`: Register certifying authorities
- `is-maritime-authority`: Verify authority status

## Getting Started

### Prerequisites

- Stacks blockchain development environment
- Clarity CLI tools
- Vitest for testing

### Installation

1. Clone the repository:

```bash
git clone https://github.com/your-org/deepsea-vessel-registry.git
cd deepsea-vessel-registry
```

2. Install dependencies:

```bash
npm install
```

3. Run tests:

```bash
npm test
```

### Deployment

Deploy the smart contract to Stacks blockchain:

```bash
# Deploy to testnet
clarinet deploy --network testnet

# Deploy to mainnet
clarinet deploy --network mainnet
```

## Usage Examples

### Register a Vessel

```clarity
(contract-call? .vessel-registry register-vessel
  "Deep Explorer I"
  "research"
  u6000
  u12)
```

### Certify Equipment

```clarity
(contract-call? .vessel-registry validate-equipment
  u1
  "Sonar Array System"
  0x1234567890abcdef...
  u144) ;; 144 blocks until next inspection
```

### Request Deployment Approval

```clarity
(contract-call? .vessel-registry request-deployment-approval
  u1
  "Mariana Trench Survey"
  u1000
  u1100)
```

## Security Considerations

### Access Control

- Contract owner has administrative privileges
- Vessel owners control their vessel data
- Maritime authorities have certification powers
- Multi-signature requirements for critical operations

### Data Integrity

- Immutable record storage on blockchain
- Cryptographic hash verification for documents
- Timestamp-based audit trails
- Tamper-proof certification system

### Compliance Features

- Regulatory authority integration
- Automated compliance checking
- Real-time status verification
- Audit trail generation

## Testing

The project includes comprehensive test coverage using Vitest:

```bash
# Run all tests
npm test

# Run specific test file
npm test vessel-registry.test.js

# Run tests with coverage
npm run test:coverage
```

Test categories:

- Vessel registration and management
- Crew certification workflows
- Equipment validation processes
- Maintenance record keeping
- Multi-signature deployment approvals
- Authority management

## API Reference

### Read-Only Functions

- `get-vessel(vessel-id)`: Retrieve vessel details
- `get-crew-certification(vessel-id, crew-member)`: Get certification info
- `get-equipment-validation(vessel-id, equipment-id)`: Equipment status
- `get-maintenance-record(vessel-id, record-id)`: Maintenance details
- `get-deployment-approval(vessel-id, deployment-id)`: Approval status
- `is-maritime-authority(authority)`: Check authority status

### Public Functions

- `register-vessel(...)`: Register new vessel
- `certify-crew(...)`: Issue crew certification
- `validate-equipment(...)`: Certify equipment
- `add-maintenance-record(...)`: Log maintenance
- `request-deployment-approval(...)`: Request mission approval
- `approve-deployment(...)`: Authority approval
- `register-maritime-authority(...)`: Register authority

## Error Codes

- `u1`: Unauthorized access
- `u2`: Vessel not found
- `u3`: Vessel already exists
- `u4`: Invalid certification
- `u5`: Insufficient signatures
- `u6`: Already signed
- `u7`: Invalid status

## License

MIT License - see LICENSE file for details

## Contact

For questions or support, please contact the development team or create an issue in the repository.

## Roadmap

### Phase 1 (Current)

- ✅ Basic vessel registration
- ✅ Crew certification system
- ✅ Equipment validation
- ✅ Multi-signature approvals

### Phase 2 (Planned)

- 🔄 Integration with IoT sensors
- 🔄 Real-time vessel tracking
- 🔄 Automated compliance monitoring
- 🔄 Advanced reporting dashboard

### Phase 3 (Future)

- 📋 Cross-chain interoperability
- 📋 AI-powered risk assessment
- 📋 Predictive maintenance alerts
- 📋 Global regulatory harmonization

---

Built with ❤️ for the deep ocean research community
