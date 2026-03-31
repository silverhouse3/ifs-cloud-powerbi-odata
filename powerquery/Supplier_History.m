// Supplier_History — Supplier change audit log
// ==============================================
// Fetches history log entries for all supplier LuNames
// filtered by DaysBack parameter (default 90 days)
//
// Covered LuNames:
//   SupplierInfo          — core supplier record (name, status)
//   SupplierInfoAddress   — address changes
//   ContactSupplierInfo   — contact changes  
//   SupplierInfoGeneral   — payment terms, currency, category

let
    LuNames  = {"SupplierInfo", "SupplierInfoAddress", "ContactSupplierInfo", "SupplierInfoGeneral"},
    DaysBack = Value.FromText(Parameters{[Name="DaysBack"]}[Value]),
    CutOff   = DateTime.ToText(
                   DateTime.From(Date.AddDays(DateTime.Date(DateTime.LocalNow()), -DaysBack)),
                   "yyyy-MM-dd'T'HH:mm:ss'Z'"),

    FetchLu  = (luName as text) =>
        let
            filter  = "LuName eq '" & luName & "' and TimeStamp gt " & CutOff,
            encoded = Text.Replace(filter, " ", "%20"),
            rows    = fnCallIFS(
                "/main/ifsapplications/projection/v1/HistoryLogHandling.svc/" &
                "HistoryLogOverviewSet?$filter=" & encoded)
        in rows,

    AllRows  = List.Combine(List.Transform(LuNames, FetchLu)),

    Result   = if List.IsEmpty(AllRows) then
                   #table({"No Data"}, {{"No supplier history in date range"}})
               else
                   let
                       ToTable      = Table.FromList(AllRows, Splitter.SplitByNothing(), null, null, ExtraValues.Error),
                       Expanded     = Table.ExpandRecordColumn(ToTable, "Column1", Record.FieldNames(AllRows{0})),

                       // Parse Supplier ID out of Keys field e.g. "VENDOR_NO=A001^"
                       WithSupplier = Table.AddColumn(Expanded, "Supplier ID",
                           each let
                                    k        = Text.From([Keys]),
                                    eqPos    = Text.PositionOf(k, "="),
                                    colPos   = Text.PositionOf(k, ":"),
                                    sepPos   = if eqPos >= 0 then eqPos else colPos,
                                    afterSep = Text.Middle(k, sepPos + 1),
                                    cleaned  = Text.Trim(Text.BeforeDelimiter(afterSep, "^"))
                                in cleaned,
                           type text),

                       Renamed      = Table.RenameColumns(WithSupplier, {
                           {"LogId",       "Log ID"},
                           {"LuName",      "Area"},
                           {"TimeStamp",   "Changed On"},
                           {"Username",    "Changed By"},
                           {"HistoryType", "Change Type"},
                           {"Keys",        "Record Key"},
                           {"Note",        "Note"}
                       }, MissingField.Ignore),

                       TypedDate    = Table.TransformColumnTypes(Renamed,
                           {{"Changed On", type datetimezone}})
                   in TypedDate
in Result
