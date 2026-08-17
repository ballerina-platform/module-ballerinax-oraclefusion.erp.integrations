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

import ballerina/http;

listener http:Listener ep0 = new (9090, config = {host: "localhost"});

service / on ep0 {
    # Get ESS job status via finder
    #
    # + finder - Use ESSJobStatusRF;requestId={ReqstId} to check the status of a previously submitted request.
    # + return - Job status result
    resource function get erpintegrations(string finder) returns EssJobStatusResponse {
        return {
            count: 1,
            hasMore: false,
            items: [
                {
                    operationName: "submitESSJobRequest",
                    documentId: "UCMFA00123456",
                    reqstId: "300000012345678",
                    requestStatus: "SUCCEEDED"
                }
            ]
        };
    }

    # Invoke an ERP Integrations operation (upload, import, or submit)
    #
    # + payload - The operation request. The concrete shape is selected by the OperationName field: uploadFileToUCM, importBulkData, or submitESSJobRequest.
    # + return - returns can be any of following types
    # http:Ok (Operation result)
    # http:BadRequest (Invalid request)
    resource function post erpintegrations(@http:Payload json payload) returns ErpIntegrationResponse|http:BadRequest {
        string operation = resolveOperationName(payload);
        match operation {
            "uploadFileToUCM" => {
                return {
                    operationName: "uploadFileToUCM",
                    documentId: "UCMFA00123456",
                    fileName: "SupplierImportTemplate.zip",
                    contentType: "zip",
                    documentAccount: "fin$/supplierInvoice$/import$"
                };
            }
            "importBulkData" => {
                return {
                    operationName: "importBulkData",
                    documentId: "UCMFA00123457",
                    fileName: "SupplierImportTemplate.zip",
                    contentType: "zip",
                    documentAccount: "fin$/supplierInvoice$/import$",
                    jobName: "oracle/apps/ess/financials/payables/invoices/transactions,APXIIMPT",
                    reqstId: "300000012345679",
                    requestStatus: "READY"
                };
            }
            "submitESSJobRequest" => {
                return {
                    operationName: "submitESSJobRequest",
                    documentId: "UCMFA00123456",
                    reqstId: "300000012345680",
                    rqstId: "300000012345680",
                    requestStatus: "WAIT"
                };
            }
        }
        return <http:BadRequest>{
            body: {message: string `Unsupported OperationName: '${operation}'`}
        };
    }
}

# Reads the operation selector from an ERP Integrations request body.
#
# Only the `@jsondata:Name` wire spelling (`OperationName`) is accepted, exactly as Oracle
# Fusion requires. This deliberately does NOT tolerate the Ballerina field name
# (`operationName`): a client that serialises with `value:toJson` instead of honouring the
# `@jsondata:Name` annotations must fail here rather than pass against a lenient mock and
# then break against the live API.
#
# + payload - The raw request body
# + return - The resolved operation name, or an empty string when absent
isolated function resolveOperationName(json payload) returns string {
    json|error wireName = payload.OperationName;
    if wireName is json && wireName !is () {
        return wireName.toString();
    }
    return "";
}
