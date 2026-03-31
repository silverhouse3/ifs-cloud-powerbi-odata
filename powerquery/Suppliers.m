// Suppliers — Supplier master data
// ===================================
// Projection API: SuppliersHandling.svc

let
    Source = fnCallIFS("/main/ifsapplications/projection/v1/SuppliersHandling.svc/SupplierInfoGeneralSet"),
    Result = if List.IsEmpty(Source) then
                 #table({"No Data"}, {{"No records returned"}})
             else
                 let
                     ToTable  = Table.FromList(Source, Splitter.SplitByNothing(), null, null, ExtraValues.Error),
                     Expanded = Table.ExpandRecordColumn(ToTable, "Column1", Record.FieldNames(Source{0})),
                     Renamed  = Table.RenameColumns(Expanded, {
                         {"VendorNo",     "Supplier ID"},
                         {"VendorName",   "Supplier Name"},
                         {"CountryCode",  "Country"},
                         {"CurrencyCode", "Currency"},
                         {"Objstate",     "Status"}
                     }, MissingField.Ignore)
                 in Renamed
in Result
