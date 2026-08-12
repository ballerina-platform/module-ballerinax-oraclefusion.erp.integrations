// Copyright (c) 2026, WSO2 LLC. (http://www.wso2.com).
//
// WSO2 LLC. licenses this file to you under the Apache License,
// Version 2.0 (the "License"); you may not use this file except
// in compliance with the License.
// You may obtain a copy of the License at
//
// http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing,
// software distributed under the License is distributed on an
// "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY
// KIND, either express or implied.  See the License for the
// specific language governing permissions and limitations
// under the License.

// Import Accounts Payable invoices into Oracle Fusion from an FBDI file. `importBulkData`
// uploads the zip to WebCenter Content and submits the import job in a single call; the
// returned request id is then used to poll the ESS job until it leaves the running state.

import ballerina/io;
import ballerinax/oraclefusion.erp.integrations as erp;

// The Oracle Fusion base URL is instance-specific, e.g.
// https://acme.fa.us2.oraclecloud.com/fscmRestApi/resources/11.13.18.05
configurable string serviceUrl = ?;
configurable string username = ?;
configurable string password = ?;

// Path to the FBDI zip file to import. Generate the CSV files from the Oracle FBDI
// template, zip them, and point this at the resulting archive.
configurable string filePath = ?;

public function main() returns error? {
    erp:Client erpClient = check new ({auth: {username, password}}, serviceUrl);

    // The API expects the file as base64-encoded text, so read the zip and encode it.
    byte[] fileBytes = check io:fileReadBytes(filePath);
    string documentContent = fileBytes.toBase64();

    // Step 1: Upload the FBDI zip and submit the AP invoice import job in one call.
    erp:ImportBulkDataRequest importRequest = {
        documentContent,
        contentType: "zip",
        fileName: "APInvoiceImport.zip",
        documentAccount: "fin$/payables$/import$",
        jobName: "oracle/apps/ess/financials/payables/invoices/transactions,APXIIMPT",
        parameterList: "#NULL,Vision Operations,#NULL,#NULL,#NULL,#NULL,#NULL,INVOICE GATEWAY,#NULL,#NULL,#NULL,1,#NULL",
        notificationCode: "10",
        jobOptions: "InterfaceDetails=1,ImportOption=Y,PurgeOption=Y,ExtractFileType=ALL"
    };
    erp:ErpIntegrationResponse importResult = check erpClient->importBulkData(importRequest);
    io:println("Uploaded document id: ", importResult?.documentId);

    string? requestId = importResult?.reqstId;
    if requestId is () {
        return error("The import response did not include an ESS request id.");
    }
    io:println("Submitted ESS request id: ", requestId);

    // Step 2: Check the status of the import job.
    erp:ESSJobStatusResponse jobStatus = check erpClient->getESSJobStatus(requestId);

    erp:ESSJobStatusItem[]? items = jobStatus?.items;
    if items is () || items.length() == 0 {
        io:println("No status returned for request ", requestId, " yet — retry shortly.");
        return;
    }
    io:println("Request status: ", items[0]?.requestStatus);
}
