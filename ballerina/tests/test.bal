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

import ballerina/os;
import ballerina/test;

final boolean isLiveServer = os:getEnv("IS_LIVE_SERVER") == "true";

// The Oracle Fusion base URL is instance-specific
// (https://{fusionHost}/fscmRestApi/resources/{apiVersion}), so there is no default.
final string serviceUrl = isLiveServer ? os:getEnv("ORACLE_FUSION_SERVICE_URL") : "http://localhost:9090";

final string username = isLiveServer ? os:getEnv("ORACLE_FUSION_USERNAME") : "test_user";
final string password = isLiveServer ? os:getEnv("ORACLE_FUSION_PASSWORD") : "test_password";

final Client erpClient = check initClient();

isolated function initClient() returns Client|error {
    ConnectionConfig config = {
        auth: {
            username,
            password
        }
    };
    return new (config, serviceUrl);
}

// A small base64-encoded placeholder standing in for an FBDI zip.
const string SAMPLE_DOCUMENT_CONTENT = "UEsDBBQAAAAIABCInEgIHJSKCgAAAAgAAAAIAAAAdGVzdC50eHQ=";

@test:Config {
    groups: ["live_tests", "mock_tests"]
}
isolated function testUploadFileToUCM() returns error? {
    UploadFileToUCMRequest payload = {
        documentContent: SAMPLE_DOCUMENT_CONTENT,
        documentAccount: "fin$/payables$/import$",
        contentType: "zip",
        fileName: "APTEST_0310.zip"
    };
    ErpIntegrationResponse response = check erpClient->uploadFileToUCM(payload);
    test:assertTrue(response?.documentId !is ());
    test:assertEquals(response?.operationName, "uploadFileToUCM");
}

@test:Config {
    groups: ["live_tests", "mock_tests"]
}
isolated function testImportBulkData() returns error? {
    ImportBulkDataRequest payload = {
        documentContent: SAMPLE_DOCUMENT_CONTENT,
        contentType: "zip",
        fileName: "APTEST_0310.zip",
        documentAccount: "fin$/payables$/import$",
        jobName: "oracle/apps/ess/financials/payables/invoices/transactions,APXIIMPT",
        parameterList: "#NULL,Vision Operations,#NULL,#NULL,#NULL,#NULL,#NULL,INVOICE GATEWAY,#NULL,#NULL,#NULL,1,#NULL",
        notificationCode: "10",
        jobOptions: "InterfaceDetails=1,ImportOption=Y,PurgeOption=Y,ExtractFileType=ALL"
    };
    ErpIntegrationResponse response = check erpClient->importBulkData(payload);
    test:assertTrue(response?.reqstId !is ());
    test:assertEquals(response?.operationName, "importBulkData");
}

@test:Config {
    groups: ["live_tests", "mock_tests"]
}
isolated function testSubmitESSJobRequest() returns error? {
    SubmitESSJobRequest payload = {
        jobPackageName: "oracle/apps/ess/financials/payables/invoices/transactions",
        jobDefName: "APXIIMPT",
        documentId: "UCMFA00123456",
        essParameters: "#NULL,Vision Operations,#NULL,#NULL,#NULL,#NULL,#NULL,INVOICE GATEWAY"
    };
    ErpIntegrationResponse response = check erpClient->submitESSJobRequest(payload);
    test:assertTrue(response?.reqstId !is ());
    test:assertEquals(response?.operationName, "submitESSJobRequest");
}

@test:Config {
    groups: ["live_tests", "mock_tests"]
}
isolated function testGetESSJobStatus() returns error? {
    ESSJobStatusResponse response = check erpClient->getESSJobStatus("14557");
    ESSJobStatusItem[]? items = response?.items;
    test:assertTrue(items !is ());
    if items is ESSJobStatusItem[] {
        test:assertTrue(items.length() > 0);
        test:assertTrue(items[0]?.requestStatus !is ());
    }
}
