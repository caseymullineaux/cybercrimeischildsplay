# Sample Data Reference

This document describes the realistic sample data included in the demo application.

## Overview

The database is pre-populated with 3 users and 23 realistic payment transactions to give the application a more authentic appearance during demonstrations.

## Users

| Username | Password | Role | Full Name | Email |
|----------|----------|------|-----------|-------|
| alice | password123 | User | Alice Johnson | alice@example.com |
| bob | password123 | User | Bob Smith | bob@example.com |
| admin | admin123 | Admin | Admin User | admin@typo.com |

## Payment Data

### Alice's Payments (8 transactions)

Alice represents a typical consumer with everyday expenses:

| Amount | Recipient | Description | Status |
|--------|-----------|-------------|--------|
| $1,250.00 | Rent Payment - Landlord | Monthly rent for November | Completed |
| $89.99 | Netflix Subscription | Monthly streaming service | Completed |
| $45.67 | Electric Company | Utility bill payment | Completed |
| $23.50 | Coffee Shop Downtown | Weekly coffee expenses | Completed |
| $156.78 | Grocery Store | Weekly shopping | Completed |
| $299.99 | Amazon | Electronics purchase | **Pending** |
| $75.00 | Gym Membership | Monthly fitness subscription | Completed |
| $12.99 | Spotify Premium | Music streaming | Completed |

**Total:** $1,954.92 | **Pending:** $299.99

### Bob's Payments (8 transactions)

Bob represents a homeowner with family expenses:

| Amount | Recipient | Description | Status |
|--------|-----------|-------------|--------|
| $2,100.00 | Mortgage Payment | Home loan monthly payment | Completed |
| $450.00 | Auto Insurance | Car insurance premium | Completed |
| $67.89 | Gas Station | Fuel for vehicle | Completed |
| $123.45 | Internet Provider | High-speed internet service | Completed |
| $89.00 | Phone Bill | Mobile service payment | Completed |
| $234.56 | Restaurant | Dinner with clients | **Pending** |
| $15.99 | Apple iCloud | Cloud storage subscription | Completed |
| $199.00 | Home Depot | Home improvement supplies | Completed |

**Total:** $3,279.89 | **Pending:** $234.56

### Admin's Payments (5 transactions)

Admin represents a business account with company expenses:

| Amount | Recipient | Description | Status |
|--------|-----------|-------------|--------|
| $5,000.00 | Company Payroll | Monthly salary distribution | Completed |
| $850.00 | AWS Services | Cloud hosting infrastructure | Completed |
| $299.00 | Office Supplies | Stationery and equipment | Completed |
| $1,200.00 | Marketing Agency | Digital advertising campaign | **Pending** |
| $450.00 | Software Licenses | Annual subscription renewal | Completed |

**Total:** $7,799.00 | **Pending:** $1,200.00

## Summary Statistics

- **Total Users:** 3
- **Total Transactions:** 23
- **Total Payment Volume:** $13,033.81
- **Completed Transactions:** 20 ($10,799.25)
- **Pending Transactions:** 3 ($1,734.55)
- **Average Transaction:** $566.69

## Payment Status Distribution

- **Completed:** 86.96% (20 transactions)
- **Pending:** 13.04% (3 transactions)

## User Types Represented

1. **Consumer (Alice):** Typical individual with subscriptions, utilities, and lifestyle expenses
2. **Homeowner (Bob):** Family person with mortgage, insurance, and home expenses
3. **Business (Admin):** Company account with payroll, infrastructure, and operational costs

## Purpose

This realistic data provides:
- **Context** for XSS demonstrations (search for specific merchants or amounts)
- **Authenticity** during security presentations
- **Variety** in transaction types and amounts
- **Relatability** for audiences (everyone recognizes Netflix, Amazon, etc.)

## Reset Database

To restore the database to this default state with all sample data:

### Docker
```bash
docker compose exec typo-payments python reset_db.py
```

### Local Python
```bash
python reset_db.py
```

Or rebuild the Docker container:
```bash
docker compose up --build
```

## Customization

To modify the sample data, edit the `sample_payments` list in `init_db.py`:

```python
sample_payments = [
    # (user_id, amount, recipient, description, status)
    (1, 150.00, "Your Merchant", "Your Description", "completed"),
]
```

Then reset or rebuild:
```bash
python reset_db.py  # or docker compose up --build
```

## Demo Tips

### Search Demonstrations
Try searching for:
- "Netflix" - Find subscription payments
- "Mortgage" - Find Bob's housing payment
- "AWS" - Find admin's infrastructure costs
- "500" - Find payments around $500

### Status Demonstrations
Use transaction IDs from the dashboard to test status lookups.

### Realistic Scenarios
- Alice waiting for Amazon delivery (pending payment)
- Bob expensing client dinner (pending payment)
- Admin waiting for marketing campaign approval (pending payment)

---

**Note:** All data is fictional and for demonstration purposes only.
