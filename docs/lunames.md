# IFS Cloud History Log — LuName Reference

The `HistoryLogHandling.svc/HistoryLogOverviewSet` endpoint supports filtering
by `LuName` to get audit trail entries for specific entity types.

## Filter syntax

```
$filter=LuName eq 'SupplierInfo' and TimeStamp gt 2026-01-01T00:00:00Z
```

URL-encoded (replace spaces with `%20`):
```
$filter=LuName%20eq%20'SupplierInfo'%20and%20TimeStamp%20gt%202026-01-01T00:00:00Z
```

## Confirmed LuName Values

### Suppliers
| LuName | Description |
|---|---|
| `SupplierInfo` | Core supplier record — name, status |
| `SupplierInfoGeneral` | Payment terms, currency, supplier category |
| `SupplierInfoAddress` | Address changes |
| `ContactSupplierInfo` | Contact details |

### Customers
| LuName | Description |
|---|---|
| `CustomerInfo` | Core customer record |
| `CustomerInfoAddress` | Address changes |
| `CustomerInfoContact` | Contact details |
| `CustomerCreditInfo` | Credit limit and block changes |

### Purchasing
| LuName | Description |
|---|---|
| `PurchaseOrder` | Purchase order header changes |
| `PurchaseOrderLine` | Purchase order line changes |

### Sales
| LuName | Description |
|---|---|
| `CustomerOrder` | Customer order header changes |
| `CustomerOrderLine` | Customer order line changes |

### Finance
| LuName | Description |
|---|---|
| `IdentityPayInfo` | Payment identity changes |
| `PaymentAddress` | Payment address changes |
| `PaymentWayPerIdentity` | Payment method changes |

## Field-level detail

For each `LogId` returned by the overview, fetch the attribute array:

```
GET /HistoryLogHandling.svc/HistoryLogDetailsSet(LogId=21)/HistoryLogAttributeArray
```

Returns:
| Field | Description |
|---|---|
| `LogId` | Links back to the overview record |
| `ColumnName` | Database column name e.g. `VENDOR_NAME` |
| `ColumnNamePrompt` | Human-readable label e.g. `Vendor Name` — use this in reports |
| `OldValue` | Value before the change |
| `NewValue` | Value after the change |

> History logging must be enabled in IFS for each LU you want to track.
> If a filter returns no results, check that history logging is active for that entity.
