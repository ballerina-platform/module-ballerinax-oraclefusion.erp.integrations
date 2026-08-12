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

// Upload a data file to WebCenter Content and then submit an ESS job against it as two
// separate steps. Use this flow instead of `importBulkData` when the upload and the job
// submission need to be decoupled — for example when the same uploaded document is
// consumed by more than one job, or when the job is scheduled after a separate approval.

import ballerina/io;
import ballerinax/oraclefusion.erp.integrations as erp;

// The Oracle Fusion base URL is instance-specific, e.g.
// https://acme.fa.us2.oraclecloud.com/fscmRestApi/resources/11.13.18.05
configurable string serviceUrl = ?;
configurable string username = ?;
configurable string password = ?;

// Path to the data file to upload. Any file type works here; this example uses a zip.
configurable string filePath = ?;

public function main() returns error? {
    erp:Client erpClient = check new ({auth: {username, password}}, serviceUrl);

    // The API expects the file as base64-encoded text, so read it and encode it.
    byte[] fileBytes = check io:fileReadBytes(filePath);
    string documentContent = fileBytes.toBase64();

    // Step 1: Upload the file to WebCenter Content (UCM).
    erp:UploadFileToUCMRequest uploadRequest = {
        documentContent,
        documentAccount: "fin$/payables$/import$",
        contentType: "zip",
        fileName: "APInvoiceImport.zip"
    };
    erp:ErpIntegrationResponse uploadResult = check erpClient->uploadFileToUCM(uploadRequest);

    string? documentId = uploadResult?.documentId;
    if documentId is () {
        return error("The upload response did not include a document id.");
    }
    io:println("Uploaded document id: ", documentId);

    // Step 2: Submit the ESS job that consumes the uploaded document.
    erp:SubmitESSJobRequest jobRequest = {
        jobPackageName: "oracle/apps/ess/financials/payables/invoices/transactions",
        jobDefName: "APXIIMPT",
        documentId,
        essParameters: "#NULL,Vision Operations,#NULL,#NULL,#NULL,#NULL,#NULL,INVOICE GATEWAY"
    };
    erp:ErpIntegrationResponse jobResult = check erpClient->submitESSJobRequest(jobRequest);

    string? requestId = jobResult?.reqstId;
    if requestId is () {
        return error("The job submission response did not include an ESS request id.");
    }
    io:println("Submitted ESS request id: ", requestId);

    // Step 3: Check the status of the submitted job.
    erp:ESSJobStatusResponse jobStatus = check erpClient->getESSJobStatus(requestId);

    erp:ESSJobStatusItem[]? items = jobStatus?.items;
    if items is () || items.length() == 0 {
        io:println("No status returned for request ", requestId, " yet — retry shortly.");
        return;
    }
    io:println("Request status: ", items[0]?.requestStatus);
}
