// Supplier_History_Details — Field-level change details
// =======================================================
// For each LogId in Supplier_History, fetches the HistoryLogAttributeArray
// which contains old value / new value per field changed.
//
// WARNING: Makes one API call per log entry — use DaysBack parameter
// to limit volume. 90 days is a good starting point.
//
// ColumnNamePrompt gives the human-readable field label
// e.g. "Vendor Name" instead of "VENDOR_NAME"

let
    Overview = Supplier_History,
    Result   = if Table.IsEmpty(Overview) or
                  not Table.HasColumns(Overview, {"Log ID"}) then
                   #table({"No Data"}, {{"No log entries to expand"}})
               else
                   let
                       LogIds       = List.Distinct(Table.Column(Overview, "Log ID")),

                       FetchAttribs = (logId) =>
                           let
                               path   = "/main/ifsapplications/projection/v1/" &
                                        "HistoryLogHandling.svc/HistoryLogDetailsSet(LogId=" &
                                        Text.From(logId) & ")/HistoryLogAttributeArray",
                               rows   = fnCallIFS(path),
                               Tagged = if List.IsEmpty(rows) then {} else
                                   List.Transform(rows, each Record.AddField(_, "_LogId", logId))
                           in Tagged,

                       AllAttribs = List.Combine(List.Transform(LogIds, FetchAttribs)),
                       ToTable    = Table.FromList(AllAttribs, Splitter.SplitByNothing(), null, null, ExtraValues.Error),
                       Expanded   = Table.ExpandRecordColumn(ToTable, "Column1", Record.FieldNames(AllAttribs{0})),
                       Renamed    = Table.RenameColumns(Expanded, {
                           {"_LogId",           "Log ID"},
                           {"ColumnName",        "Field Name"},
                           {"ColumnNamePrompt",  "Field Label"},
                           {"OldValue",          "Old Value"},
                           {"NewValue",          "New Value"}
                       }, MissingField.Ignore)
                   in Renamed
in Result
