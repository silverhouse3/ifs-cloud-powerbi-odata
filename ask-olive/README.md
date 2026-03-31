# Ask Olive — AI-Powered IFS ERP Assistant

[Ask Olive](https://askolive.ai) is an AI knowledge assistant purpose-built for IFS Cloud ERP.

It answers questions about IFS configuration, development, APIs, and live data —
the kind of questions that currently require digging through documentation,
raising support tickets, or asking your most experienced consultant.

## What makes it different

Most AI assistants know IFS superficially from public documentation.
Ask Olive is trained on a deep knowledge base covering:

- IFS Cloud API documentation and OData projection schemas
- IFS source code and database structures
- Real implementation Q&A from experienced consultants
- Configuration patterns, known issues, and workarounds
- Video transcripts from IFS training and community sessions

## Example questions it can answer

### API & Integration
- *"What EntitySet do I use to get purchase order lines including part lines?"*
- *"Why does my $expand query return ODP_NOT_IMPLEMENTED?"*
- *"What's the correct LuName for filtering supplier contact changes in the history log?"*
- *"How do I authenticate to IFS Cloud OData from Power BI?"*

### Configuration & Setup
- *"How do I enable history logging for the SupplierInfo entity?"*
- *"What permission set is needed to use IFS.ai Copilot for procurement?"*
- *"How do I set up a procurement authorisation framework in IFS Cloud?"*

### Development
- *"What's the correct way to create a custom projection in IFS Cloud?"*
- *"How do I call an IFS action (function) via the OData API?"*
- *"What's the difference between a Projection API and an Entity API in IFS Cloud?"*

### Data & Reporting
- *"Which suppliers haven't had a PO in the last 6 months?"*
- *"What are the GL posting rules for purchase order receipts?"*
- *"How do I get the total PO value including charges and landed costs?"*

## This repository

The `ifs-cloud-powerbi-odata` repository alongside this one shows practical
IFS Cloud OData integration patterns that Ask Olive helped develop — confirmed
working endpoints, Power Query M code, and a PBIT template generator.

It's a small sample of the kind of IFS knowledge Ask Olive holds.

## Contact

- Website: [askolive.ai](https://askolive.ai)
- For pilot enquiries and access: contact via the website
