# Ask Olive — Sample Questions & Answers

These are examples of the kind of questions Ask Olive can answer about IFS Cloud.
The answers below are abbreviated — Ask Olive provides full detail with code examples,
configuration steps, and references to relevant IFS documentation.

---

## IFS Cloud OData API

**Q: I want to get purchase order lines from Power BI. What endpoint should I use?**

> Use `/int/ifsapplications/entity/v1/PurchaseOrderLineEntity.svc/PurchaseOrderLineSet`
> for all lines (part + no-part). The projection API only exposes no-part lines.
> [Full M query code and column mapping provided]

**Q: Why does `$expand` always return ODP_NOT_IMPLEMENTED in IFS Cloud?**

> IFS Cloud's OData implementation does not support `$expand` at all, despite
> navigation properties appearing in the metadata. The correct approach is to
> query related EntitySets separately and join them in Power BI using relationships.

**Q: How do I paginate through large result sets in IFS OData?**

> IFS Cloud returns `@odata.nextLink` in the response when there are more pages.
> [Recursive Power Query M function provided]

---

## History Log

**Q: What LuName do I use to get supplier address changes from the history log?**

> `SupplierInfoAddress` — filter with `$filter=LuName eq 'SupplierInfoAddress'`

**Q: How do I get old value and new value for a supplier change?**

> Call `HistoryLogDetailsSet(LogId=N)/HistoryLogAttributeArray` for each LogId.
> Returns `ColumnName`, `ColumnNamePrompt` (human label), `OldValue`, `NewValue`.

---

## Procurement

**Q: Which suppliers haven't had a purchase order raised against them in 6 months?**

> [OData filter query + Power BI DAX measure provided to identify inactive suppliers]

**Q: How do I build a procurement authorisation framework in IFS Cloud?**

> IFS Cloud supports authorisation levels on purchase orders by value threshold.
> [Configuration steps for authorisation codes, limits, and approval workflows]

---

## Power BI Integration

**Q: How do I create a Power BI template (.pbit) file programmatically?**

> A .pbit is a ZIP file. The key file is `DataModelSchema` (UTF-16-LE JSON).
> [Full Python script provided — see also github.com/silverhouse3/ifs-cloud-powerbi-odata]

**Q: Why does my generated .pbit file say "corrupted or encrypted" when I open it?**

> Usually a BOM encoding issue. `[Content_Types].xml` needs a UTF-8 BOM.
> All other JSON files need UTF-16-LE with NO BOM.
> [Full encoding rules table provided]

---

*Ask Olive holds thousands of IFS-specific Q&A pairs, API schemas, and*
*implementation patterns. Visit [askolive.ai](https://askolive.ai) for access.*
