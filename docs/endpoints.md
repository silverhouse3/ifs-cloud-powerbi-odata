# Confirmed Working IFS Cloud OData Endpoints

All endpoints verified against IFS Cloud 25R1.

## Purchase Orders

| Endpoint | EntitySet | Notes |
|---|---|---|
| `/main/.../PurchaseOrderHandling.svc/PurchaseOrderSet` | PO headers | `OrderNo`, `VendorNo`, `Objstate`, `Contract` |
| `/int/.../PurchaseOrderLineEntity.svc/PurchaseOrderLineSet` | All lines (part + nopart) | Use `/int/` — not available on `/main/` |
| `/main/.../PurchaseOrderHandling.svc/PurchaseOrderLineNopartSet` | No-part/service lines only | Available on `/main/` |
| `/int/.../PurchaseOrderLinePartEntity.svc/PurchaseOrderLinePartSet` | Part lines only | Use `/int/` |

## Suppliers & Customers

| Endpoint | EntitySet | Notes |
|---|---|---|
| `/main/.../SuppliersHandling.svc/SupplierInfoGeneralSet` | Supplier master | `VendorNo`, `VendorName` |
| `/main/.../CustomersHandling.svc/CustomerInfoSet` | Customer master | `CustomerId`, `Name` |

## History Log (Audit Trail)

| Endpoint | Notes |
|---|---|
| `/main/.../HistoryLogHandling.svc/HistoryLogOverviewSet` | Supports `$filter` by `LuName` and `TimeStamp` |
| `/main/.../HistoryLogHandling.svc/HistoryLogDetailsSet(LogId=N)/HistoryLogAttributeArray` | Field-level changes — `ColumnName`, `ColumnNamePrompt`, `OldValue`, `NewValue` |

## Discovering EntitySets

Call the service document to list all available EntitySets on a projection:

```
GET /main/ifsapplications/projection/v1/[ProjectionName].svc/
```

Returns JSON array of all EntitySet names.

## OData Query Options

| Option | Supported | Notes |
|---|---|---|
| `$top` | ✅ | Works on all sets |
| `$filter` | ✅ | Works on most sets |
| `$select` | ✅ | Works on most sets |
| `$orderby` | ✅ | Works on most sets |
| `$expand` | ❌ | Returns `ODP_NOT_IMPLEMENTED` |
| `$count` | ⚠️ | Inconsistent support |
