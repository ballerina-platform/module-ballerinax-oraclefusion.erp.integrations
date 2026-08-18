# Ballerina Oracle Fusion Cloud ERP connector

[![Build](https://github.com/ballerina-platform/module-ballerinax-oraclefusion.erp.integrations/actions/workflows/ci.yml/badge.svg)](https://github.com/ballerina-platform/module-ballerinax-oraclefusion.erp.integrations/actions/workflows/ci.yml)
[![GitHub Last Commit](https://img.shields.io/github/last-commit/ballerina-platform/module-ballerinax-oraclefusion.erp.integrations.svg)](https://github.com/ballerina-platform/module-ballerinax-oraclefusion.erp.integrations/commits/master)
[![GitHub Issues](https://img.shields.io/github/issues/ballerina-platform/ballerina-library/module/oraclefusion.erp.integrations.svg?label=Open%20Issues)](https://github.com/ballerina-platform/ballerina-library/labels/module%2Foraclefusion.erp.integrations)


## Overview

[Oracle Fusion Cloud ERP](https://www.oracle.com/erp/) is Oracle's cloud application suite for financials, procurement, project management, risk management, and related enterprise processes.

The ERP Integrations REST service (the `erpintegrations` resource) is the entry point for moving bulk data into Fusion. It uploads File-Based Data Import (FBDI) files to Oracle WebCenter Content (UCM), submits the Enterprise Scheduler Service (ESS) jobs that import them, and reports the status of those jobs.

The `ballerinax/oraclefusion.erp.integrations` package provides APIs to connect and interact with the ERP Integrations REST service endpoints of Oracle Fusion Cloud ERP release `11.13.18.05`. It supports the `uploadFileToUcm`, `importBulkData`, and `submitEssJobRequest` operations, together with ESS job status retrieval.

## Setup guide

### Step 1: Identify your Fusion instance base URL

The ERP Integrations base URL is instance-specific and takes the form:

```text
https://{fusionHost}/fscmRestApi/resources/{apiVersion}
```

For example: `https://acme.fa.us2.oraclecloud.com/fscmRestApi/resources/11.13.18.05`

There is no default — the connector requires the full base URL at initialization.

### Step 2: Provision a user with the required privileges

1. Sign in to your Oracle Fusion Cloud instance as a user with security administration rights.
2. Create (or identify) the integration user that will call the service.
3. Grant the roles required for the operations you intend to invoke. Loading and importing data typically requires a role that includes the **Load Interface File for Import** privilege, plus the privileges of the specific ESS jobs you submit. Consult your Fusion security administrator for the exact roles for your module.

### Step 3: Choose an authentication scheme

The connector supports both of the schemes the service accepts. `ConnectionConfig.auth` is a union, so the choice is a configuration change rather than a code change.

**HTTP Basic** over HTTPS, using a Fusion integration user's credentials:

```ballerina
final erp:Client erpClient = check new ({auth: {username, password}}, serviceUrl);
```

**OAuth2 client credentials**, for instances that reject Basic auth. Register a confidential application in Oracle Identity Cloud Service (IDCS), grant it access to the ERP Integrations resource, and use its client id and secret:

```ballerina
final erp:Client erpClient = check new ({
    auth: {
        clientId,
        clientSecret,
        tokenUrl: "https://<your-idcs-host>.identity.oraclecloud.com/oauth2/v1/token"
    }
}, serviceUrl);
```

Ask your Fusion administrator which scheme the instance is configured for — some pods disable Basic auth for integration users.

## Quickstart

To use the `oraclefusion.erp.integrations` connector in your Ballerina application, modify the `.bal` file as follows:

### Step 1: Import the module

```ballerina
import ballerina/io;
import ballerinax/oraclefusion.erp.integrations as erp;
```

### Step 2: Instantiate a new connector

1. Create a `Config.toml` file and, configure the obtained credentials in the above steps as follows:

    ```toml
    serviceUrl = "https://<fusionHost>/fscmRestApi/resources/11.13.18.05"
    username = "<your-fusion-username>"
    password = "<your-fusion-password>"
    ```

2. Create an `erp:Client` with the configuration.

    ```ballerina
    configurable string serviceUrl = ?;
    configurable string username = ?;
    configurable string password = ?;

    final erp:Client erpClient = check new ({auth: {username, password}}, serviceUrl);
    ```

### Step 3: Invoke the connector operation

Now, utilize the available connector operations. The following snippet checks the status of a previously submitted ESS request:

```ballerina
public function main() returns error? {
    erp:EssJobStatusResponse jobStatus = check erpClient->getEssJobStatus("14557");
    io:println(jobStatus);
}
```

### Step 4: Run the Ballerina application

```bash
bal run
```

## Examples

The `Oraclefusion.erp.integrations` connector provides practical examples illustrating usage in various scenarios. Explore these [examples](https://github.com/ballerina-platform/module-ballerinax-oraclefusion.erp.integrations/tree/main/examples/), covering the following use cases:

1. [Bulk invoice import](https://github.com/ballerina-platform/module-ballerinax-oraclefusion.erp.integrations/tree/main/examples/bulk-invoice-import) - Import Accounts Payable invoices from an FBDI file: `importBulkData` uploads the zip and submits the import job in one call, then the ESS request is polled for its status.
2. [ESS job submission](https://github.com/ballerina-platform/module-ballerinax-oraclefusion.erp.integrations/tree/main/examples/ess-job-submission) - Upload a data file to WebCenter Content and submit an ESS job against it as two decoupled steps, then check the resulting request status.

## Build from the source

### Setting up the prerequisites

1. Download and install Java SE Development Kit (JDK) version 21. You can download it from either of the following sources:

    * [Oracle JDK](https://www.oracle.com/java/technologies/downloads/)
    * [OpenJDK](https://adoptium.net/)

   > **Note:** After installation, remember to set the `JAVA_HOME` environment variable to the directory where JDK was installed.

2. Download and install [Ballerina Swan Lake](https://ballerina.io/).

3. Download and install [Docker](https://www.docker.com/get-started).

   > **Note**: Ensure that the Docker daemon is running before executing any tests.

4. Export Github Personal access token with read package permissions as follows,

    ```bash
    export packageUser=<Username>
    export packagePAT=<Personal access token>
    ```

### Build options

Execute the commands below to build from the source.

1. To build the package:

   ```bash
   ./gradlew clean build
   ```

2. To run the tests:

   ```bash
   ./gradlew clean test
   ```

3. To build the without the tests:

   ```bash
   ./gradlew clean build -x test
   ```

4. To run tests against different environments:

   ```bash
   ./gradlew clean test -Pgroups=<Comma separated groups/test cases>
   ```

5. To debug the package with a remote debugger:

   ```bash
   ./gradlew clean build -Pdebug=<port>
   ```

6. To debug with the Ballerina language:

   ```bash
   ./gradlew clean build -PbalJavaDebug=<port>
   ```

7. Publish the generated artifacts to the local Ballerina Central repository:

    ```bash
    ./gradlew clean build -PpublishToLocalCentral=true
    ```

8. Publish the generated artifacts to the Ballerina Central repository:

   ```bash
   ./gradlew clean build -PpublishToCentral=true
   ```

## Contribute to Ballerina

As an open-source project, Ballerina welcomes contributions from the community.

For more information, go to the [contribution guidelines](https://github.com/ballerina-platform/ballerina-lang/blob/master/CONTRIBUTING.md).

## Code of conduct

All the contributors are encouraged to read the [Ballerina Code of Conduct](https://ballerina.io/code-of-conduct).

## Useful links

* For more information go to the [`oraclefusion.erp.integrations` package](https://central.ballerina.io/ballerinax/oraclefusion.erp.integrations/latest).
* For example demonstrations of the usage, go to [Ballerina By Examples](https://ballerina.io/learn/by-example/).
* Chat live with us via our [Discord server](https://discord.gg/ballerinalang).
* Post all technical questions on Stack Overflow with the [#ballerina](https://stackoverflow.com/questions/tagged/ballerina) tag.
