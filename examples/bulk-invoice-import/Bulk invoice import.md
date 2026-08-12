# Bulk invoice import

This example imports Accounts Payable invoices into Oracle Fusion Cloud ERP from a File-Based Data Import (FBDI) file.

The `importBulkData` operation does the upload and the job submission in a single call: it writes the zip to WebCenter Content (UCM) under the `fin$/payables$/import$` account and submits the `APXIIMPT` Enterprise Scheduler Service job that loads it. The returned ESS request id is then used to check the status of the import.

Use this flow when the upload and the import belong together — it is also the encryption-capable path, unlike `loadAndImportData`.

## Prerequisites

### 1. Set up the Oracle Fusion Cloud instance

Refer to the [Setup guide](https://central.ballerina.io/ballerinax/oraclefusion.erp.integrations/latest#setup-guide) to obtain the base URL and the credentials of a user with the privileges required to load interface files and submit the import job.

### 2. Configuration

Create a `Config.toml` file in the example's root directory and provide your values:

```toml
serviceUrl = "https://<fusionHost>/fscmRestApi/resources/11.13.18.05"
username = "<your-fusion-username>"
password = "<your-fusion-password>"
# Path to the FBDI zip file to import — the example reads it and base64-encodes it for you
filePath = "./APInvoiceImport.zip"
```

Generate the CSV files from the Oracle FBDI template for AP invoices, zip them, and point `filePath` at the resulting archive.

## Run the example

Execute the following command to run the example:

```bash
bal run
```
