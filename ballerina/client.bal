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

import oraclefusion.erp.integrations.oas;

# Connects to Oracle Fusion Cloud's `erpintegrations` REST resource to upload FBDI files to
# WebCenter Content (UCM) and to submit and monitor the ESS jobs that import them.
public isolated client class Client {
    private final oas:Client oasClient;

    # Gets invoked to initialize the `connector`.
    #
    # + config - The configurations to be used when initializing the `connector`
    # + serviceUrl - URL of the target service, e.g. `https://{fusionHost}/fscmRestApi/resources/11.13.18.05`
    # + return - An error if connector initialization failed
    public isolated function init(ConnectionConfig config, string serviceUrl) returns error? {
        self.oasClient = check new (config, serviceUrl);
    }

    # Uploads a file to WebCenter Content (UCM) without submitting a job.
    #
    # + payload - The file to upload and the UCM account to file it under
    # + headers - Headers to be sent with the request
    # + return - The upload result, carrying the assigned `documentId`, or an error
    remote isolated function uploadFileToUcm(UploadFileToUcmRequest payload, map<string|string[]> headers = {})
        returns ErpIntegrationResponse|error {
        oas:UploadFileToUCMRequest request = {...payload, operationName: "uploadFileToUCM"};
        return self.oasClient->invokeErpIntegrationOperation(request, headers);
    }

    # Uploads an FBDI file to UCM and submits the matching import job in a single call.
    #
    # Prefer this over `submitEssJobRequest` for Supply Chain Planning data, as it is the
    # encryption-capable path.
    #
    # + payload - The FBDI file to import and the ESS job that should process it
    # + headers - Headers to be sent with the request
    # + return - The import result, carrying the submitted `reqstId`, or an error
    remote isolated function importBulkData(ImportBulkDataRequest payload, map<string|string[]> headers = {})
        returns ErpIntegrationResponse|error {
        oas:ImportBulkDataRequest request = {...payload, operationName: "importBulkData"};
        return self.oasClient->invokeErpIntegrationOperation(request, headers);
    }

    # Submits an ESS job for a document already present in UCM.
    #
    # + payload - The ESS job to submit and the UCM document it should process
    # + headers - Headers to be sent with the request
    # + return - The submission result, carrying the submitted `reqstId`, or an error
    remote isolated function submitEssJobRequest(SubmitEssJobRequest payload, map<string|string[]> headers = {})
        returns ErpIntegrationResponse|error {
        oas:SubmitESSJobRequest request = {...payload, operationName: "submitESSJobRequest"};
        return self.oasClient->invokeErpIntegrationOperation(request, headers);
    }

    # Retrieves the status of a previously submitted ESS job request.
    #
    # + requestId - The `reqstId` returned when the job was submitted
    # + headers - Headers to be sent with the request
    # + return - The job status result, or an error
    remote isolated function getEssJobStatus(string requestId, map<string|string[]> headers = {})
        returns EssJobStatusResponse|error {
        return self.oasClient->getESSJobStatus(headers, {
            finder: string `ESSJobStatusRF;requestId=${requestId}`
        });
    }
}
