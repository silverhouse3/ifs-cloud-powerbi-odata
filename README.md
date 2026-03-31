# IFS Cloud OData → Power BI Integration

A complete, working integration between **IFS Cloud** and **Power BI Desktop** using the IFS OData APIs with OAuth2 authentication. Includes Power Query M functions, a PBIT template generator, confirmed EntitySet paths, and a supplier change audit report with drill-through.

> 💡 **Looking for an AI assistant that already knows IFS Cloud inside out?** Check out [Ask Olive](https://askolive.ai) — an AI-powered IFS ERP knowledge assistant with live OData query capabilities.

## Contents

```
README.md                     — This file
generate_pbit.py              — Python script that generates a .pbit Power BI Template
powerquery/
  fnGetToken.m                — OAuth2 token function
  fnCallIFS.m                 — Generic IFS OData caller with pagination
  PO_Header.m                 — Purchase Order headers query
  PO_Lines.m                  — Purchase Order lines (part + no-part combined)
  Suppliers.m                 — Supplier master data
  Customers.m                 — Customer master data
  Supplier_History.m          — Supplier change audit log
  Supplier_History_Details.m  — Field-level changes (old/new values)
docs/
  endpoints.md                — Confirmed working API endpoints
  encoding_rules.md           — PBIT file encoding rules (learned the hard way)
  lunames.md                  — IFS LuName reference for History Log filtering
ask-olive/
  README.md                   — What Ask Olive is and what it can answer
  sample_questions.md         — Example questions Ask Olive can answer about IFS
  ifs_odata_cheatsheet.md     — Quick reference card for IFS Cloud OData
```

## Quick Start

### 1. Authentication

IFS Cloud uses OAuth2 `client_credentials` via Keycloak:

```
POST https://[YOUR-IFS-HOST]/auth/realms/[YOUR-REALM]/protocol/openid-connect/token

grant_type=client_credentials
client_id=[YOUR_CLIENT_ID]
client_secret=[YOUR_CLIENT_SECRET]
```

### 2. Add to Power BI

1. Open Power BI Desktop → Transform data
2. New Source → Blank Query → Advanced Editor
3. Paste the contents of `powerquery/fnGetToken.m` → name it `fnGetToken`
4. Repeat for `fnCallIFS.m`
5. Add a `Parameters` table (see below)
6. Add each data table query

### 3. Parameters table

```m
let
    Source = Table.FromRows(
        {
            {"BaseUrl",      "https://[YOUR-IFS-HOST]"},
            {"TokenUrl",     "https://[YOUR-IFS-HOST]/auth/realms/[YOUR-REALM]/protocol/openid-connect/token"},
            {"ClientId",     "[YOUR-CLIENT-ID]"},
            {"ClientSecret", "[YOUR-CLIENT-SECRET]"},
            {"DaysBack",     "90"}
        },
        type table [Name = text, Value = text]
    )
in
    Source
```

## API Path Patterns

| Type | Base Path |
|---|---|
| Projection API | `/main/ifsapplications/projection/v1/[ProjectionName].svc/[EntitySet]` |
| Entity API | `/int/ifsapplications/entity/v1/[EntityName].svc/[EntitySet]` |

> **Key insight:** Some EntitySets only exist on `/int/` Entity API, not on `/main/` projections. If a set returns 404 on `/main/`, try `/int/`.

## Known OData Limitations

| Limitation | Detail |
|---|---|
| `$expand` not supported | Returns `ODP_NOT_IMPLEMENTED` — use separate queries joined in Power BI |
| Pipelined function sets | GL balance analysis and similar sets require server-side context |
| Some `/int/` services inactive | Test each endpoint individually |

## Data Model

```
PO Header[Order Number]        →  PO Lines[Order Number]          (one-to-many)
PO Header[Supplier]            →  Suppliers[Supplier ID]           (many-to-one)
Supplier_History[Log ID]       →  Supplier_History_Details[Log ID] (one-to-many)
Supplier_History[Supplier ID]  →  Suppliers[Supplier ID]           (many-to-one)
```

## Supplier Change Audit

The included queries power a two-page drill-through report:

- **Page 1:** Q&A visual + summary of all supplier changes by user, date, and area
- **Page 2:** Field-level detail — what changed, old value → new value, who, when

## Related

- [Ask Olive](https://askolive.ai) — AI-powered IFS ERP assistant
- [IFS Community](https://community.ifs.com)
- [pbi-tools](https://github.com/pbi-tools/pbi-tools) — PBIX/PBIT extraction tool

## License

MIT
