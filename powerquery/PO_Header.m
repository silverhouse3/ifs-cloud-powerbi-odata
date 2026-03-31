// PO Header — Purchase Order headers
// =====================================
// Projection API: PurchaseOrderHandling.svc

let
    Source = fnCallIFS("/main/ifsapplications/projection/v1/PurchaseOrderHandling.svc/PurchaseOrderSet"),
    Result = if List.IsEmpty(Source) then
                 #table({"No Data"}, {{"No records returned"}})
             else
                 let
                     ToTable  = Table.FromList(Source, Splitter.SplitByNothing(), null, null, ExtraValues.Error),
                     Expanded = Table.ExpandRecordColumn(ToTable, "Column1", Record.FieldNames(Source{0})),
                     Renamed  = Table.RenameColumns(Expanded, {
                         {"OrderNo",       "Order Number"},
                         {"VendorNo",      "Supplier"},
                         {"OrderDate",     "Order Date"},
                         {"Objstate",      "Status"},
                         {"Contract",      "Site"},
                         {"BuyerCode",     "Buyer"},
                         {"AuthorizeCode", "Coordinator"},
                         {"CurrencyCode",  "Currency"},
                         {"Company",       "Company"}
                     }, MissingField.Ignore)
                 in Renamed
in Result
