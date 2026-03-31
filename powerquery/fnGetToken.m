// fnGetToken — IFS Cloud OAuth2 token function
// ================================================
// Create as a Blank Query named "fnGetToken"
// Requires a "Parameters" table with TokenUrl, ClientId, ClientSecret rows

let
    fnGetToken = () =>
        let
            tokenUrl = Parameters{[Name="TokenUrl"]}[Value],
            clientId = Parameters{[Name="ClientId"]}[Value],
            secret   = Parameters{[Name="ClientSecret"]}[Value],
            body     = "grant_type=client_credentials&client_id=" & clientId & "&client_secret=" & secret,
            response = Web.Contents(tokenUrl, [
                Headers = [#"Content-Type" = "application/x-www-form-urlencoded"],
                Content  = Text.ToBinary(body)
            ]),
            parsed   = Json.Document(response),
            token    = parsed[access_token]
        in token
in fnGetToken
