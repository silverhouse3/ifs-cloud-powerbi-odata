# IFS Cloud OData — Quick Reference Cheat Sheet

## Authentication
```
POST /auth/realms/[REALM]/protocol/openid-connect/token
Content-Type: application/x-www-form-urlencoded

grant_type=client_credentials&client_id=[ID]&client_secret=[SECRET]
```

## Base URL Patterns
```
Projection: /main/ifsapplications/projection/v1/[Name].svc/[Set]
Entity:     /int/ifsapplications/entity/v1/[Name].svc/[Set]
```

## List EntitySets on a projection
```
GET /main/ifsapplications/projection/v1/[Name].svc/
```

## Common Endpoints

| Data | Endpoint |
|---|---|
| PO Headers | `/main/.../PurchaseOrderHandling.svc/PurchaseOrderSet` |
| PO All Lines | `/int/.../PurchaseOrderLineEntity.svc/PurchaseOrderLineSet` |
| PO No-Part Lines | `/main/.../PurchaseOrderHandling.svc/PurchaseOrderLineNopartSet` |
| Suppliers | `/main/.../SuppliersHandling.svc/SupplierInfoGeneralSet` |
| Customers | `/main/.../CustomersHandling.svc/CustomerInfoSet` |
| Audit Log | `/main/.../HistoryLogHandling.svc/HistoryLogOverviewSet` |
| Field Changes | `/main/.../HistoryLogHandling.svc/HistoryLogDetailsSet(LogId=N)/HistoryLogAttributeArray` |

## OData Query Options
```
?$top=5
?$filter=LuName eq 'SupplierInfo' and TimeStamp gt 2026-01-01T00:00:00Z
?$select=OrderNo,VendorNo,Objstate
?$orderby=OrderDate desc
```
> ❌ `$expand` NOT supported — returns ODP_NOT_IMPLEMENTED

## History Log LuNames

| Entity | LuName |
|---|---|
| Supplier | `SupplierInfo` |
| Supplier Address | `SupplierInfoAddress` |
| Supplier Contact | `ContactSupplierInfo` |
| Customer | `CustomerInfo` |
| Customer Address | `CustomerInfoAddress` |
| Purchase Order | `PurchaseOrder` |
| Customer Order | `CustomerOrder` |

## Power Query — Standard Pattern
```m
let
    Source   = fnCallIFS("/main/.../[Projection].svc/[EntitySet]"),
    Result   = if List.IsEmpty(Source) then #table({"No Data"},{{"None"}}) else
        let
            ToTable  = Table.FromList(Source, Splitter.SplitByNothing(), null, null, ExtraValues.Error),
            Expanded = Table.ExpandRecordColumn(ToTable, "Column1", Record.FieldNames(Source{0})),
            Renamed  = Table.RenameColumns(Expanded, {{"OldName","New Name"}}, MissingField.Ignore)
        in Renamed
in Result
```

## PBIT Encoding (critical)
```
[Content_Types].xml  → UTF-8 WITH BOM
DataModelSchema      → UTF-16-LE, no BOM, \r\n line endings
Report/Layout        → UTF-16-LE, no BOM
SecurityBindings     → copy from real .pbit (DPAPI binary)
compatibilityLevel   → 1600 (March 2026 / 2.152.x)
```

---
*More IFS Cloud knowledge: [askolive.ai](https://askolive.ai)*
