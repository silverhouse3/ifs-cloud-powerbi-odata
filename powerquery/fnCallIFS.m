// fnCallIFS — Generic IFS Cloud OData caller with pagination
// ===========================================================
// Create as a Blank Query named "fnCallIFS"
// Handles @odata.nextLink pagination automatically

let
    fnCallIFS = (relPath as text) =>
        let
            baseUrl = Parameters{[Name="BaseUrl"]}[Value],
            token   = fnGetToken(),
            headers = [Authorization = "Bearer " & token, Accept = "application/json"],
            GetPage = (url as text) =>
                let
                    raw  = Web.Contents(url, [Headers = headers]),
                    doc  = Json.Document(raw),
                    rows = doc[value],
                    next = try doc[#"@odata.nextLink"] otherwise null,
                    rest = if next = null then {} else @GetPage(next),
                    all  = rows & rest
                in all,
            result = GetPage(baseUrl & relPath)
        in result
in fnCallIFS
