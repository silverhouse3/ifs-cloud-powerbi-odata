// Customers — Customer master data
// ===================================
// Projection API: CustomersHandling.svc

let
    Source = fnCallIFS("/main/ifsapplications/projection/v1/CustomersHandling.svc/CustomerInfoSet"),
    Result = if List.IsEmpty(Source) then
                 #table({"No Data"}, {{"No records returned"}})
             else
                 let
                     ToTable  = Table.FromList(Source, Splitter.SplitByNothing(), null, null, ExtraValues.Error),
                     Expanded = Table.ExpandRecordColumn(ToTable, "Column1", Record.FieldNames(Source{0})),
                     Renamed  = Table.RenameColumns(Expanded, {
                         {"CustomerId",   "Customer ID"},
                         {"Name",         "Customer Name"},
                         {"CountryCode",  "Country"},
                         {"CurrencyCode", "Currency"},
                         {"Objstate",     "Status"}
                     }, MissingField.Ignore)
                 in Renamed
in Result
