_Author_:  DimuthuMadushan \
_Created_: 2026-08-12 \
_Updated_: 2026-08-13 \
_Edition_: Swan Lake

# Sanitation for OpenAPI specification

This document records the sanitation done on top of the official OpenAPI specification from Oracle Fusion Cloud ERP Integrations.
The OpenAPI specification is hand-authored (Oracle does not publish a machine-readable spec for the `erpintegrations` resource); it was reconstructed from Oracle's public REST API reference documentation — [ERP Integrations REST Service](https://docs.oracle.com/en/cloud/saas/financials/25c/fasop/erp-integrations-rest-service.html) and [Import Bulk Data / ERP processes](https://docs.oracle.com/en/cloud/saas/financials/25c/farfa/api-erp-processes.html).
These changes are done in order to improve the overall usability, and as workarounds for some known language limitations.

<!-- auto-generated -->
1. **Remove the placeholder `servers` entry**: `bal openapi flatten` injects a default server when the source specification has none.
    - Original: `servers: [{ url: "/" }]` (injected — the source specification deliberately has no `servers` block)
    - Updated: `servers` removed entirely
    - Reason: The Oracle Fusion base URL is instance-specific
      (`https://{fusionHost}/fscmRestApi/resources/{apiVersion}`, e.g.
      `https://acme.fa.us2.oraclecloud.com/fscmRestApi/resources/11.13.18.05`). A `/` default
      would generate a non-working `serviceUrl` default in the client. With no `servers` entry
      the generated `Client` init requires the caller to supply the full base URL explicitly.

<!-- auto-generated -->
2. **Rename the auto-generated request body schema**: The `POST /erpintegrations` request body is an inline `oneOf`, so flattening extracts it under a positional name.
    - Original: `ErpintegrationsBody`
    - Updated: `ErpIntegrationRequest`
    - Reason: The generated name is derived from the path segment and carries no meaning for the
      API consumer. `ErpIntegrationRequest` describes what the payload is and matches the
      response type name `ErpIntegrationResponse`.

<!-- auto-generated -->
3. **Rename the auto-generated array item schema**: `ESSJobStatusResponse.items` is an inline object schema, so flattening extracts it as a suffixed type.
    - Original: `ESSJobStatusResponseItems`
    - Updated: `ESSJobStatusItem`
    - Reason: The generated name reads as a plural collection while the type models a *single*
      job-status entry. The singular name is accurate and shorter at the call site.

<!-- auto-generated -->
4. **Flatten inline schemas into named components** (applied by `bal openapi flatten`): All inline
   request/response schemas were extracted into `components/schemas`.
    - Reason: Inline schemas generate anonymous inline record types in Ballerina. Named components
      produce reusable, documented record types in `types.bal`.

<!-- auto-generated -->
5. **Add `x-ballerina-name` extensions** (applied by `bal openapi align`): Oracle's payload fields
   use PascalCase (`OperationName`, `DocumentContent`, `ReqstId`, ...).
    - Original: `OperationName`, `DocumentContent`, `DocumentAccount`, ...
    - Updated: same wire names, annotated with `x-ballerina-name: operationName`, `documentContent`,
      `documentAccount`, ...
    - Reason: Produces idiomatic camelCase Ballerina record fields while preserving the exact
      wire-format field names Oracle expects.

<!-- auto-generated -->
6. **Override the generated Ballerina name for `ESSParameters`**: The default lowering of a
   leading acronym produces an awkward field name.
    - Original: `x-ballerina-name: eSSParameters`
    - Updated: `x-ballerina-name: essParameters`
    - Reason: `eSSParameters` reads as a typo at the call site. `essParameters` matches the
      acronym-lowering convention used elsewhere in the connector.

<!-- auto-generated -->
7. **Add a `requestBody` description for `POST /erpintegrations`**: Applied to the source
   specification (`docs/spec/openapi.yaml`), not only the aligned output.
    - Original: no `description` on the request body
    - Updated: describes the multiplexed payload and how `OperationName` selects the shape
    - Reason: Without it, `bal build` emits `WARNING: undocumented parameter 'payload'` for the
      generated `invokeErpIntegrationOperation` remote method.

## OpenAPI cli command

The following commands were used to produce the aligned specification and generate the Ballerina client from it. They should be executed from the repository root directory. Sanitations 1, 2, 3 and 6 above are applied by hand to `aligned_ballerina_openapi.yaml` after the `align` step and before the `client` step.

```bash
# 1. Flatten and align (intermediate flattened_openapi.yaml is not committed)
cd ballerina
bal openapi flatten -i ../docs/spec/openapi.yaml -o ../docs/spec
bal openapi align -i ../docs/spec/flattened_openapi.yaml -o ../docs/spec

# 2. Generate the client from the sanitized, aligned specification into the `oas` submodule
bal openapi -i ../docs/spec/aligned_ballerina_openapi.yaml --mode client \
    --license ../docs/license.txt -o ./modules/oas --client-methods remote
```

Note: The license year is hardcoded to 2026 in `docs/license.txt`, change if necessary.

> **Do not regenerate into the package root.** The generated client is confined to
> `ballerina/modules/oas`. The root module's `client.bal` and `types.bal` are hand-written (see
> below) and running the command above with `-o .` would silently overwrite them.

## Post-generation patches

Unlike the sanitations above, these are edits to **generated code**. They are not expressed in the
specification and the generator does not produce them, so **they must be re-applied by hand after
every regeneration**.

1. **`modules/oas/client.bal` — serialise the request body with its `@jsondata:Name` wire names.**
    - Generated:
      ```ballerina
      http:Request request = new;
      json jsonBody = payload.toJson();
      request.setPayload(jsonBody, "application/json");
      return self.clientEp->post(resourcePath, request, headers);
      ```
    - Patched:
      ```ballerina
      return self.clientEp->post(resourcePath, payload, headers);
      ```
    - Reason: `payload.toJson()` is langlib `value:toJson`, which **ignores `@jsondata:Name`**. The
      request went out with Ballerina field names (`{"operationName": ..., "documentContent": ...}`)
      where Oracle Fusion requires the wire names (`{"OperationName": ..., "DocumentContent": ...}`),
      so every `POST /erpintegrations` call — `uploadFileToUCM`, `importBulkData` and
      `submitESSJobRequest` — would fail against a live instance. Passing the record directly lets
      `http` serialise it, which *is* annotation-aware. (`jsondata:toJson(payload)` is an equivalent
      fix; passing the record is simpler and needs no extra import.)
    - Only the request direction was affected: `http`'s inbound response binding already honours
      `@jsondata:Name`, and `getESSJobStatus` sends no body.
    - Regression guard: `tests/mock_service.bal` accepts **only** the `OperationName` wire spelling.
      If this patch is lost, three mock tests fail with `Unsupported OperationName: ''` instead of
      passing silently and breaking only in production.

2. **`modules/oas/types.bal` — delete the unused `OAuth2ClientCredentialsGrantConfig` record.**
    - Generated:
      ```ballerina
      # OAuth2 Client Credentials Grant Configs
      public type OAuth2ClientCredentialsGrantConfig record {|
          *http:OAuth2ClientCredentialsGrantConfig;
          # Token URL
          string tokenUrl = "";
      |};
      ```
    - Patched: removed entirely, leaving a comment in its place.
    - Reason: nothing references it. `ConnectionConfig.auth` is generated as
      `http:OAuth2ClientCredentialsGrantConfig|http:CredentialsConfig`, using the `http` type
      directly, so the local record is dead public API that would otherwise show up in the module's
      API documentation.
    - Why the generator emits it: the record is produced from the mere presence of the `oauth2`
      `clientCredentials` scheme, regardless of what `tokenUrl` contains. It cannot be suppressed
      from the specification. With a placeholder `tokenUrl` the generator *does* reference the local
      record (to carry the default); with `tokenUrl: ""` — see the note below — it references the
      `http` type instead and the local record is left orphaned.
    - **No regression guard exists.** Unlike patch 1, nothing fails if this patch is lost: the
      regenerated record is unused, so it compiles and every test still passes. It has to be
      re-deleted by hand, and the only symptom of forgetting is a stray public type in the API docs.

### Why the specification sets `tokenUrl: ""`

The `oauth2` scheme in the source specification sets an empty `tokenUrl`, because the token endpoint
is an instance-specific IDCS host and any default would be a non-working placeholder. Given an empty
`tokenUrl` the generator resolves `auth` to `http:OAuth2ClientCredentialsGrantConfig`, on which
`tokenUrl` is a **required** field — so omitting it is a compile error rather than a runtime failure
against a host that does not exist.

Neither alternative works: removing `tokenUrl` from the specification makes `bal openapi` reject it
outright (`attribute components.securitySchemes.oauth2.tokenUrl is missing`), and leaving a
placeholder URL makes the generator inject it as a **default** on the local record, which then has
to be stripped by hand after every regeneration.

## Hand-written wrapper layer

These are code-level additions on top of the generated client, not sanitations of the
specification — they are listed here so the two layers are not confused during regeneration.

| Layer | Files | Regenerated? |
|-------|-------|--------------|
| Generated client | `ballerina/modules/oas/{client,types,utils}.bal` | Yes — by the command above |
| Hand-written wrapper | `ballerina/{client,types}.bal` | No — edit by hand |

The root module wraps `oas:Client` and exists because `POST /erpintegrations` is a single
multiplexed endpoint whose behaviour is selected by an `OperationName` discriminator field:

1. **Split the multiplexed operation into four remote methods**: `uploadFileToUCM`,
   `importBulkData`, `submitESSJobRequest` and `getESSJobStatus`, in place of the generated
   `invokeErpIntegrationOperation`.
    - Reason: The discriminator is an artifact of the API's transport shape, not a decision the
      caller should have to make. Each wrapper method sets `OperationName` itself.
2. **Redefine the three request records without `operationName`**: the root
   `UploadFileToUCMRequest`, `ImportBulkDataRequest` and `SubmitESSJobRequest` omit the field,
   which is applied via a spread (`{...payload, operationName: "..."}`) when delegating.
    - Reason: The field is a required singleton-typed constant, so callers were forced to restate a
      value the method name already implies. The generated records remain the source of truth for
      field names and `@jsondata:Name` wire mappings.
3. **Take an ESS request id instead of a finder expression**: `getESSJobStatus(string requestId)`
   builds `ESSJobStatusRF;requestId=${requestId}` internally.
    - Reason: The finder syntax is an Oracle query convention the caller would otherwise have to
      construct by hand from a value the connector already returned.
4. **Re-export the response and configuration types**: `ConnectionConfig`, `ClientHttp1Settings`,
   `ProxyConfig`, `ErpIntegrationResponse`, `ESSJobStatusItem` and `ESSJobStatusResponse` are
   aliases of their `oas` counterparts.
    - Reason: Consumers import a single module and never reference `oas` directly.
