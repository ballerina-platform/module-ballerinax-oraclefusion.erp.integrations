# Running Tests

## Prerequisites

You need a user with the required privileges on an Oracle Fusion Cloud instance, and that instance's base URL, to run the live tests.

To run the tests against the mock server, no credentials are required.

## Test environments

There are two test environments for running the connector tests. The default environment is the mock server for the Oracle Fusion Cloud ERP Integrations REST service. The other environment is a live Fusion instance.

You can run the tests in either of these environments, and each has its own compile-time configuration.

| Test Group   | Environment                                          |
|--------------|------------------------------------------------------|
| `mock_tests` | Mock server for the ERP Integrations REST service (default) |
| `live_tests` | Oracle Fusion Cloud instance                          |

## Test coverage

The suite covers every operation exposed by the connector:

- `uploadFileToUcm` — uploads a file to WebCenter Content and asserts a document id is returned.
- `importBulkData` — uploads and submits an import job in one call, asserting an ESS request id is returned.
- `submitEssJobRequest` — submits an ESS job for a previously uploaded document.
- `getEssJobStatus` — retrieves the status of a submitted request through the `ESSJobStatusRF` finder.

Each of the first three maps onto the API's single multiplexed `POST /erpintegrations` endpoint; the connector sets the `OperationName` discriminator, so the tests call the operations directly.

## Running tests in the mock server

To execute the tests on the mock server, ensure that the `IS_LIVE_SERVER` environment variable is either set to `false` or unset before running the tests.

This is the default behavior:

```bash
bal test
```

## Running tests against a live Fusion instance

Set the following environment variables:

```bash
export IS_LIVE_SERVER=true
export ORACLE_FUSION_SERVICE_URL="https://<fusionHost>/fscmRestApi/resources/11.13.18.05"
export ORACLE_FUSION_USERNAME="<your-fusion-username>"
export ORACLE_FUSION_PASSWORD="<your-fusion-password>"
```

Then, run the following command to run the tests:

```bash
bal test --groups live_tests
```

> **Note:** The live tests submit real ESS jobs and upload real documents to WebCenter Content. Run them only against a development or test instance.
