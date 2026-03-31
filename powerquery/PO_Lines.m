// PO Lines — All purchase order lines (part + no-part/service combined)
// ========================================================================
// IMPORTANT: Uses Entity API (/int/) not Projection API (/main/)
// PurchaseOrderHandling.svc only exposes PurchaseOrderLineNopartSet
// For combined part + no-part lines you must use PurchaseOrderLineEntity.svc

let
    Source = fnCallIFS("/int/ifsapplications/entity/v1/PurchaseOrderLineEntity.svc/PurchaseOrderLineSet"),
    Result = if List.IsEmpty(Source) then
                 #table({"No Data"}, {{"No records returned"}})
             else
                 let
                     ToTable  = Table.FromList(Source, Splitter.SplitByNothing(), null, null, ExtraValues.Error),
                     Expanded = Table.ExpandRecordColumn(ToTable, "Column1", Record.FieldNames(Source{0})),
                     Renamed  = Table.RenameColumns(Expanded, {
                         {"OrderNo",             "Order Number"},
                         {"LineNo",              "Line Number"},
                         {"ReleaseNo",           "Release"},
                         {"PartNo",              "Part Number"},
                         {"Description",         "Description"},
                         {"BuyQtyDue",           "Quantity"},
                         {"BuyUnitMeas",         "Unit"},
                         {"BuyUnitPrice",        "Unit Price"},
                         {"NetAmtCurr",          "Net Amount"},
                         {"GrossAmtCurr",        "Gross Amount"},
                         {"CurrencyCode",        "Currency"},
                         {"Objstate",            "Line Status"},
                         {"Contract",            "Site"},
                         {"VendorNo",            "Supplier"},
                         {"WantedDeliveryDate",  "Wanted Delivery Date"},
                         {"PlannedReceiptDate",  "Planned Receipt Date"},
                         {"ProjectId",           "Project"}
                     }, MissingField.Ignore)
                 in Renamed
in Result
