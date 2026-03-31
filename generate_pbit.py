#!/usr/bin/env python3
"""
IFS Cloud Power BI Template Generator
======================================
Generates a valid .pbit file for Power BI Desktop.

Usage:
    python3 generate_pbit.py [source.pbit]

    source.pbit — a real .pbit file saved by Power BI Desktop on your machine
                  (needed to copy SecurityBindings and theme — cannot be generated)

Output:
    IFS_Cloud_Procurement.pbit

Requirements:
    Python 3.8+, no external dependencies
"""

import zipfile, json, uuid, sys, os

def col(name, dtype="string"):
    return {
        "name": name, "dataType": dtype, "sourceColumn": name,
        "lineageTag": str(uuid.uuid4()), "summarizeBy": "none",
        "annotations": [{"name": "SummarizationSetBy", "value": "Automatic"}]
    }

def numcol(name):
    return {
        "name": name, "dataType": "double", "sourceColumn": name,
        "lineageTag": str(uuid.uuid4()), "summarizeBy": "sum",
        "annotations": [{"name": "SummarizationSetBy", "value": "Automatic"}]
    }

def mktable(name, expr_lines, columns, hidden=False, annotations=None):
    t = {
        "name": name, "lineageTag": str(uuid.uuid4()),
        "columns": columns,
        "partitions": [{"name": name, "mode": "import",
                        "source": {"type": "m", "expression": expr_lines}}]
    }
    if hidden: t["isHidden"] = True
    if annotations: t["annotations"] = annotations
    return t

NAV = [{"name":"PBI_NavigationStepName","value":"Navigation"},
       {"name":"PBI_ResultType","value":"Text"}]

schema = {
    "name": str(uuid.uuid4()),
    "compatibilityLevel": 1600,
    "model": {
        "culture": "en-GB",
        "dataAccessOptions": {"legacyRedirects": True, "returnErrorValuesAsNull": True, "fastCombine": True},
        "defaultPowerBIDataSourceVersion": "powerBI_V3",
        "sourceQueryCulture": "en-GB",
        "tables": [
            mktable("Parameters", [
                'let',
                '    Source = Table.FromRows(',
                '        {',
                '            {"BaseUrl",      "https://[YOUR-IFS-HOST]"},',
                '            {"TokenUrl",     "https://[YOUR-IFS-HOST]/auth/realms/[YOUR-REALM]/protocol/openid-connect/token"},',
                '            {"ClientId",     ""},',
                '            {"ClientSecret", ""},',
                '            {"DaysBack",     "90"}',
                '        },',
                '        type table [Name = text, Value = text]',
                '    )',
                'in',
                '    Source'
            ], [col("Name"), col("Value")]),

            mktable("fnGetToken", [
                'let',
                '    fnGetToken = () =>',
                '        let',
                '            tokenUrl = Parameters{[Name="TokenUrl"]}[Value],',
                '            clientId = Parameters{[Name="ClientId"]}[Value],',
                '            secret   = Parameters{[Name="ClientSecret"]}[Value],',
                '            body     = "grant_type=client_credentials&client_id=" & clientId & "&client_secret=" & secret,',
                '            response = Web.Contents(tokenUrl, [',
                '                Headers = [#"Content-Type" = "application/x-www-form-urlencoded"],',
                '                Content  = Text.ToBinary(body)',
                '            ]),',
                '            parsed   = Json.Document(response),',
                '            token    = parsed[access_token]',
                '        in token',
                'in fnGetToken'
            ], [col("fnGetToken")], hidden=True, annotations=NAV),

            mktable("fnCallIFS", [
                'let',
                '    fnCallIFS = (relPath as text) =>',
                '        let',
                '            baseUrl = Parameters{[Name="BaseUrl"]}[Value],',
                '            token   = fnGetToken(),',
                '            headers = [Authorization = "Bearer " & token, Accept = "application/json"],',
                '            GetPage = (url as text) =>',
                '                let',
                '                    raw  = Web.Contents(url, [Headers = headers]),',
                '                    doc  = Json.Document(raw),',
                '                    rows = doc[value],',
                '                    next = try doc[#"@odata.nextLink"] otherwise null,',
                '                    rest = if next = null then {} else @GetPage(next),',
                '                    all  = rows & rest',
                '                in all,',
                '            result = GetPage(baseUrl & relPath)',
                '        in result',
                'in fnCallIFS'
            ], [col("fnCallIFS")], hidden=True, annotations=NAV),
        ],
        "relationships": [],
        "annotations": [
            {"name": "__PBI_TimeIntelligenceEnabled", "value": "0"},
            {"name": "PBI_QueryOrder", "value": json.dumps(["Parameters","fnGetToken","fnCallIFS"])}
        ]
    }
}

def build(source_pbit):
    print(f"Reading SecurityBindings and theme from: {source_pbit}")
    with zipfile.ZipFile(source_pbit) as zin:
        files = {name: zin.read(name) for name in zin.namelist()}

    schema_str = json.dumps(schema, ensure_ascii=False, indent=2).replace("\n", "\r\n")
    files["DataModelSchema"] = schema_str.encode("utf-16-le")

    output = "IFS_Cloud_Procurement.pbit"
    with zipfile.ZipFile(output, "w", zipfile.ZIP_DEFLATED) as zout:
        for name, data in files.items():
            zout.writestr(name, data)
    print(f"Created: {output} ({os.path.getsize(output):,} bytes)")
    print("Open in Power BI Desktop and fill in ClientId/ClientSecret in the Parameters table.")

if __name__ == "__main__":
    if len(sys.argv) < 2:
        print("Usage: python3 generate_pbit.py source.pbit")
        print("")
        print("You need to provide a .pbit file saved by Power BI Desktop")
        print("to supply the SecurityBindings and theme files.")
        sys.exit(1)
    if not os.path.exists(sys.argv[1]):
        print(f"File not found: {sys.argv[1]}")
        sys.exit(1)
    build(sys.argv[1])
