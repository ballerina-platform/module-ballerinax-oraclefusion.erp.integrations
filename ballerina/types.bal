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

# Provides a set of configurations for controlling the behaviours when communicating with a remote HTTP endpoint.
@display {label: "Connection Config"}
public type ConnectionConfig record {|
    # Configurations related to client authentication
    http:OAuth2ClientCredentialsGrantConfig|http:CredentialsConfig auth;
    # The HTTP version understood by the client
    http:HttpVersion httpVersion = http:HTTP_2_0;
    # Configurations related to HTTP/1.x protocol
    ClientHttp1Settings http1Settings?;
    # Configurations related to HTTP/2 protocol
    http:ClientHttp2Settings http2Settings?;
    # The maximum time to wait (in seconds) for a response before closing the connection
    decimal timeout = 60;
    # The choice of setting `forwarded`/`x-forwarded` header
    string forwarded = "disable";
    # Configurations associated with request pooling
    http:PoolConfiguration poolConfig?;
    # HTTP caching related configurations
    http:CacheConfig cache?;
    # Specifies the way of handling compression (`accept-encoding`) header
    http:Compression compression = http:COMPRESSION_AUTO;
    # Configurations associated with the behaviour of the Circuit Breaker
    http:CircuitBreakerConfig circuitBreaker?;
    # Configurations associated with retrying
    http:RetryConfig retryConfig?;
    # Configurations associated with inbound response size limits
    http:ResponseLimitConfigs responseLimits?;
    # SSL/TLS-related options
    http:ClientSecureSocket secureSocket?;
    # Proxy server related options
    http:ProxyConfig proxy?;
    # Enables the inbound payload validation functionality which provided by the constraint package. Enabled by default
    boolean validation = true;
    # Enables relaxed data binding on the client side. When enabled, `nil` values are treated as optional,
    # and absent fields are handled as `nilable` types. Enabled by default.
    boolean laxDataBinding = true;
|};

# Provides settings related to HTTP/1.x protocol.
public type ClientHttp1Settings record {|
    # Specifies whether to reuse a connection for multiple requests
    http:KeepAlive keepAlive = http:KEEPALIVE_AUTO;
    # The chunking behaviour of the request
    http:Chunking chunking = http:CHUNKING_AUTO;
    # Proxy server related options
    ProxyConfig proxy?;
|};

# Proxy server configurations to be used with the HTTP client endpoint.
public type ProxyConfig record {|
    # Host name of the proxy server
    string host = "";
    # Proxy server port
    int port = 0;
    # Proxy server username
    string userName = "";
    # Proxy server password
    @display {label: "", kind: "password"}
    string password = "";
|};

# The result of an ERP integration operation.
public type ErpIntegrationResponse record {
    # Name of the operation that produced this result, e.g. `uploadFileToUCM`
    string operationName?;
    # Identifier of the UCM document the operation uploaded or acted on
    string? documentId?;
    # Identifier of the submitted ESS job request, returned by `importBulkData` and `submitEssJobRequest`
    string reqstId?;
    # Identifier of the ERP integration request
    string rqstId?;
    # Status of the submitted request
    string? requestStatus?;
    # Name of the uploaded file
    string fileName?;
    # Content type of the uploaded file
    string contentType?;
    # UCM account the document was filed under
    string documentAccount?;
    # Fully qualified ESS job path and definition name of the submitted job
    string jobName?;
};

# The status of one ESS job request.
public type EssJobStatusItem record {
    # Name of the operation that submitted the job
    string operationName?;
    # Identifier of the ESS job request
    string reqstId?;
    # Status of the job, e.g `SUCCEEDED`, `ERROR`, `WARNING`
    string requestStatus?;
    # Identifier of the UCM document the job processed
    string? documentId?;
};

# A collection of ESS job status results.
public type EssJobStatusResponse record {
    # The matching job status entries
    EssJobStatusItem[] items?;
    # Number of entries in `items`
    int count?;
    # Whether more entries are available beyond the ones returned
    boolean hasMore?;
};

# Uploads a file to WebCenter Content (UCM) without submitting a job.
public type UploadFileToUcmRequest record {|
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
public type SubmitEssJobRequest record {|
    # Fully qualified ESS job package path
    string jobPackageName;
    # ESS job definition name, e.g. `APXIIMPT`
    string jobDefName;
    # Identifier of the UCM document the job should process
    string documentId;
    # Comma-separated ESS parameters, using `#NULL` for empty positions
    string essParameters;
|};
