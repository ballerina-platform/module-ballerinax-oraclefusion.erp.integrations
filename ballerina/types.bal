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

import ballerinax/oraclefusion.erp.integrations.oas;

# Provides a set of configurations for controlling the behaviours when communicating with a remote HTTP endpoint.
public type ConnectionConfig oas:ConnectionConfig;

# Provides settings related to HTTP/1.x protocol.
public type ClientHttp1Settings oas:ClientHttp1Settings;

# Proxy server configurations to be used with the HTTP client endpoint.
public type ProxyConfig oas:ProxyConfig;

# The result of an ERP integration operation.
public type ErpIntegrationResponse oas:ErpIntegrationResponse;

# The status of one ESS job request.
public type ESSJobStatusItem oas:ESSJobStatusItem;

# A collection of ESS job status results.
public type ESSJobStatusResponse oas:ESSJobStatusResponse;

# Uploads a file to WebCenter Content (UCM) without submitting a job.
public type UploadFileToUCMRequest record {|
    # Base64-encoded content of the file to upload
    string documentContent;
    # UCM account the document is filed under, e.g. `fin$/payables$/import$`
    string documentAccount;
    # Content type of the uploaded file, e.g. `zip`
    string contentType;
    # Name of the uploaded file, e.g. `APTEST_0310.zip`
    string fileName;
    # Identifier of an existing UCM document to replace, if any
    string? documentId?;
|};

# Uploads an FBDI file to UCM and submits the matching import job in a single call.
public type ImportBulkDataRequest record {|
    # Base64-encoded content of the FBDI zip to import
    string documentContent;
    # Content type of the uploaded file, e.g. `zip`
    string contentType;
    # Name of the uploaded file, e.g. `APTEST_0310.zip`
    string fileName;
    # UCM account the document is filed under, e.g. `fin$/payables$/import$`
    string documentAccount;
    # Fully qualified ESS job path and definition name, comma separated
    string jobName;
    # Comma-separated ESS job parameters, using `#NULL` for empty positions
    string parameterList;
    # Comma-separated import options, e.g. `ImportOption=Y,PurgeOption=Y`
    string jobOptions?;
    # Notification code controlling when email notifications are sent
    string notificationCode?;
    # URL invoked once the import completes
    string? callbackURL?;
|};

# Submits an ESS job for a document already present in UCM.
public type SubmitESSJobRequest record {|
    # Fully qualified ESS job package path
    string jobPackageName;
    # ESS job definition name, e.g. `APXIIMPT`
    string jobDefName;
    # Identifier of the UCM document the job should process
    string documentId;
    # Comma-separated ESS parameters, using `#NULL` for empty positions
    string essParameters;
|};
