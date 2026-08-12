# ESS job submission

This example uploads a data file to Oracle WebCenter Content (UCM) and then submits an Enterprise Scheduler Service (ESS) job against it as two separate steps.

`uploadFileToUCM` returns a `DocumentId`, which is passed to `submitESSJobRequest` to run the `APXIIMPT` job over the uploaded document. The status of the resulting request is then retrieved through the `ESSJobStatusRF` finder.

Use this flow instead of `importBulkData` when the upload and the job submission need to be decoupled — for example when the same uploaded document is consumed by more than one job, or when the job runs after a separate approval step.

## Prerequisites

### 1. Set up the Oracle Fusion Cloud instance

Refer to the [Setup guide](https://central.ballerina.io/ballerinax/oraclefusion.erp.integrations/latest#setup-guide) to obtain the base URL and the credentials of a user with the privileges required to load interface files and submit ESS jobs.

### 2. Configuration

Create a `Config.toml` file in the example's root directory and provide your values:

```toml
serviceUrl = "https://<fusionHost>/fscmRestApi/resources/11.13.18.05"
username = "<your-fusion-username>"
password = "<your-fusion-password>"
# Path to the file to upload — the example reads it and base64-encodes it for you
filePath = "./APInvoiceImport.zip"
```

## Run the example

Execute the following command to run the example:

```bash
bal run
```
