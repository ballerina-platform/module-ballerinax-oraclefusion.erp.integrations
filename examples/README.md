# Examples

The `ballerinax/oraclefusion.erp.integrations` connector provides practical examples illustrating usage in various scenarios.

| Example | Description |
|---------|-------------|
| [`bulk-invoice-import`](./bulk-invoice-import) | Import Accounts Payable invoices from an FBDI file — `importBulkData` uploads the zip and submits the import job in one call, then the ESS request is polled for its status. |
| [`ess-job-submission`](./ess-job-submission) | Upload a data file to WebCenter Content and submit an ESS job against it as two decoupled steps, then check the resulting request status. |

## Prerequisites

1. An Oracle Fusion Cloud instance and a user with the privileges required to call the
   `erpintegrations` resource. The base URL is instance-specific and has the form
   `https://{fusionHost}/fscmRestApi/resources/{apiVersion}`, for example
   `https://acme.fa.us2.oraclecloud.com/fscmRestApi/resources/11.13.18.05`.

2. For each example, create a `Config.toml` in the example directory:

   ```toml
   serviceUrl = "https://<fusionHost>/fscmRestApi/resources/11.13.18.05"
   username = "<your-fusion-username>"
   password = "<your-fusion-password>"
   # Path to the file to upload — the example reads it and base64-encodes it for you
   filePath = "./APInvoiceImport.zip"
   ```

   `Config.toml` is git-ignored — never commit real credentials.

## Running an example

Execute the following commands to build an example from the source:

* To build an example:

    ```bash
    bal build
    ```

* To run an example:

    ```bash
    bal run
    ```

## Building the examples with the local module

**Warning**: Due to the absence of support for reading local repositories for single Ballerina files, the Bala of the module is manually written to the central repository as a workaround. Consequently, the bash script may modify your local Ballerina repositories.

Execute the following commands to build all the examples against the changes you have made to the module locally:

* To build all the examples:

    ```bash
    ./build.sh build
    ```

* To run all the examples:

    ```bash
    ./build.sh run
    ```
