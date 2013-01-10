unit ALIOSS;

{
  OSS (Open Storage Services) Delphi SDK v1.0.0 - Library

  The MIT License (MIT)
  Copyright (c) 2012 Guangzhou Cloudstrust Software Development Co., Ltd
  http://cloudstrust.com/

  Permission is hereby granted, free of charge, to any person obtaining
  a copy of this software and associated documentation files (the
  "Software"), to deal in the Software without restriction, including
  without limitation the rights to use, copy, modify, merge, publish,
  distribute, sublicense, and/or sell copies of the Software, and to
  permit persons to whom the Software is furnished to do so, subject to
  the following conditions:

  The above copyright notice and this permission notice shall be
  included in all copies or substantial portions of the Software.

  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
  EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
  MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
  NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE
  LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION
  OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION
  WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
}

interface

uses ALIOSSEXP, ALIOSSOPT, SysUtils, IniFiles, Classes, IdHTTP, IdHeaderList;

//*************************************************************************************
//Consts

//Delphi SDK Consts
const OSS_NAME = 'oss-sdk-delphi';
const OSS_VERSION = '1.0.0';
const OSS_BUILD = '201209230045';
const OSS_AUTHOR = 'menway@gmail.com';

//OSS Server Address
const DEFAULT_OSS_HOST = 'oss.aliyuncs.com';

// OSS Consts
const OSS_BUCKET = 'bucket';
const OSS_OBJECT = 'object';
const OSS_HEADERS = 'headers';
const OSS_METHOD = 'method';
const OSS_QUERY = 'query';
const OSS_BASENAME = 'basename';
const OSS_MAX_KEYS = 'max-keys';
const OSS_UPLOAD_ID = 'uploadId';
const OSS_PART_NUMBER = 'partNumber';
const OSS_MAX_KEYS_VALUE = 1000;
const OSS_MAX_OBJECT_GROUP_VALUE = 1000;
const OSS_FILE_SLICE_SIZE = 8192;
const OSS_PREFIX = 'prefix';
const OSS_DELIMITER = 'delimiter';
const OSS_MARKER = 'marker';
const OSS_CONTENT_MD5 = 'Content-Md5';
const OSS_CONTENT_TYPE = 'Content-Type';
const OSS_CONTENT_TYPE_DEFAULT = 'application/x-www-form-urlencoded'; //new
const OSS_CONTENT_LENGTH = 'Content-Length';
const OSS_IF_MODIFIED_SINCE = 'If-Modified-Since';
const OSS_IF_UNMODIFIED_SINCE = 'If-Unmodified-Since';
const OSS_IF_MATCH = 'If-Match';
const OSS_IF_NONE_MATCH = 'If-None-Match';
const OSS_CACHE_CONTROL = 'Cache-Control';
const OSS_EXPIRES = 'Expires';
const OSS_PREAUTH = 'preauth';
const OSS_CONTENT_COING = 'Content-Coding';
const OSS_CONTENT_DISPOSTION = 'Content-Disposition';
const OSS_RANGE = 'Range';
const OS_CONTENT_RANGE = 'Content-Range';
const OSS_CONTENT = 'content';
const OSS_BODY = 'body';
const OSS_LENGTH = 'length';
const OSS_HOST = 'Host';
const OSS_DATE = 'Date';
const OSS_AUTHORIZATION = 'Authorization';
const OSS_FILE_DOWNLOAD = 'fileDownload';
const OSS_FILE_UPLOAD = 'fileUpload';
const OSS_PART_SIZE = 'partSize';
const OSS_SEEK_TO = 'seekTo';
const OSS_SIZE = 'size';
const OSS_QUERY_STRING = 'query_string';
const OSS_SUB_RESOURCE = 'sub_resource';
const OSS_DEFAULT_PREFIX = 'x-oss-';

// URL Consts
const OSS_URL_ACCESS_KEY_ID = 'OSSAccessKeyId';
const OSS_URL_EXPIRES = 'Expires';
const OSS_URL_SIGNATURE = 'Signature';

// HTTP Method Consts
const OSS_HTTP_GET = 'GET';
const OSS_HTTP_PUT = 'PUT';
const OSS_HTTP_HEAD = 'HEAD';
const OSS_HTTP_POST = 'POST';
const OSS_HTTP_DELETE = 'DELETE';

//x-oss
const OSS_ACL = 'x-oss-acl';

//OBJECT GROUP
const OSS_OBJECT_GROUP = 'x-oss-file-group';

//Multi Part
const OSS_MULTI_PART = 'uploads';

//Multi Delete
const OSS_MULTI_DELETE = 'delete';

//OBJECT COPY SOURCE
const OSS_OBJECT_COPY_SOURCE = 'x-oss-copy-source';

//private,only owner
const OSS_ACL_TYPE_PRIVATE = 'private';

//public reand
const OSS_ACL_TYPE_PUBLIC_READ = 'public-read';

//public read write
const OSS_ACL_TYPE_PUBLIC_READ_WRITE = 'public-read-write';

//OSS ACL Definition
const OSS_ACL_TYPES: array[1..3] of string = (
  OSS_ACL_TYPE_PRIVATE,
  OSS_ACL_TYPE_PUBLIC_READ,
  OSS_ACL_TYPE_PUBLIC_READ_WRITE
);


type
  TAliOssReturnType = record
    status: integer;
    header: TIdHeaderList;
    body: TStringStream;
  end;

  // class: TAliOss
  // converted from php sdk
  TAliOss = class(TObject)
  private
    //Internal attributes
    debug_mode: boolean; //debug mode?
    max_retries: Integer; //maximum retry count
    redirects: Integer; //current retry count
    vhost: string; //virtual address
    enable_domain_style: boolean; //if true, 3-level subdomain is enabled, ie, bucket.oss.aliyuncs.com
    request_url: string; //requested URL
    access_id: string; //OSS API ACCESS ID
    access_key: string; //OSS API ACCESS KEY
    hostname: string; //hostname
    port: Integer;

    //Internal methods
    function ValidateBucket(const bucket: string): boolean;
    function ValidateObject(const obj: string): boolean;
    function ValidateOptions(const options: TAliOssOption): boolean;
    function ValidateContent(const options: TAliOssOption): boolean;
    function ValidateContentLength(const options: TAliOssOption): boolean;

    function ValidateAndAuth(const opt1, opt2: TAliOssOption): TAliOssReturnType;

    function GetMultipartCounts(filesize: Int64; part_size: Int64 = 5242880): TAliOssOption;
    function InitiateMultipartUpload(const bucket, obj: string; const options: TAliOssOption = nil): TAliOssReturnType;
    function UploadPart(const bucket, obj, path, seek_to, len, upload_id, part_number: string; const options: TAliOssOption = nil): TAliOssReturnType;
    function CompleteMultipartUpload(const bucket, obj, upload_id: string; const ETags: TStringList; const options: TAliOssOption = nil): TAliOssReturnType;

    function MakeObjectGroupXml(const bucket: string; const object_array: TStringList): string;
  public
    //*************************************************************************************
    //Getters and Setters
    procedure SetDebugMode(const debug_mode: boolean);
    procedure SetMaxRetries(const max_retries: Integer = 3);
    function GetMaxRetries: Integer;
    procedure SetHostname(const hostname: string; const port: Integer = -1);
    procedure SetVHost(const vhost: string);
    procedure SetEnableDomainStyle(const enable_domain_style: boolean = true);


    //*************************************************************************************
    //Requests
    function Auth(const options: TAliOssOption): TAliOssReturnType;

    //*************************************************************************************
    //Service Operations
    function ListBucket(const options: TAliOssOption = nil): TAliOssReturnType;

    //*************************************************************************************
    //Bucket Operations
    function CreateBucket(const bucket: string; const acl: string = OSS_ACL_TYPE_PRIVATE; const options: TAliOssOption = nil): TAliOssReturnType;
    function DeleteBucket(const bucket: string; const options: TAliOssOption = nil): TAliOssReturnType;
    function GetBucketACL(const bucket: string; const options: TAliOssOption = nil): TAliOssReturnType;
    function SetBucketACL(const bucket: string; const acl: string = OSS_ACL_TYPE_PRIVATE; const options: TAliOssOption = nil): TAliOssReturnType;

    //*************************************************************************************
    //Object Operations
    function ListObject(const bucket: string; const options: TAliOssOption = nil): TAliOssReturnType;
    function CreateObjectDir(const bucket, obj: string; const options: TAliOssOption = nil): TAliOssReturnType;
    function UploadFileByContent(const bucket, obj: string; const options: TAliOssOption = nil): TAliOssReturnType;
    function UploadFileByFile(const bucket, obj, path: string; const options: TAliOssOption = nil): TAliOssReturnType;
    function CopyObject(const from_bucket, from_obj, to_bucket, to_obj: string; const options: TAliOssOption = nil): TAliOssReturnType;
    function GetObjectMeta(const bucket, obj: string; const options: TAliOssOption = nil): TAliOssReturnType;
    function DeleteObject(const bucket, obj: string; const options: TAliOssOption = nil): TAliOssReturnType;
    function DeleteObjects(const bucket: string; const objs: TStringList; const options: TAliOssOption = nil): TAliOssReturnType;
    function GetObject(const bucket, obj: string; const options: TAliOssOption = nil): TAliOssReturnType;
    function ObjectExists(const bucket, obj: string; const options: TAliOssOption = nil): Boolean;

    //*************************************************************************************
    //Multi Part Operations
    function UploadFileByMultipart(const bucket, obj, path: string; part_size: Int64 = 5242880): TAliOssReturnType; overload;
    function ListMultipartUploads(const bucket: string; const options: TAliOssOption = nil): TAliOssReturnType;
    function AbortMultipartUpload(const bucket, obj, upload_id: string; const options: TAliOssOption = nil): TAliOssReturnType;
    function UploadDirByMultipart(const bucket, dir: string; const recursive: boolean = false; const exclude: string = '.|..|.svn'; const options: TAliOssOption = nil): TAliOssReturnType;

    //*************************************************************************************
    //Object Group Operations
    function CreateObjectGroup(const bucket, object_group: string; const object_array: TStringList; const options: TAliOssOption = nil): TAliOssReturnType;

    //*************************************************************************************
    //Constructor
    constructor Create(const access_id, access_key: string; const hostname: string = '');

    //*************************************************************************************
    //Destructor
    destructor Destroy; override;

  protected
    use_ssl: boolean; //use SSL?

  end;

  TAliOssVolumnPermission = (vPrivate, vPublicRead, vPublicReadWrite);

  TAliOssVolumnInfo = record
    name: string;
    created: TDateTime;
  end;
  TAliOssVolumnInfoList = array of TAliOssVolumnInfo;
  PAliOssVolumnInfoList = ^TAliOssVolumnInfoList;

  TAliOssFileInfo = record
    name: string;
    modified: TDateTime;
    size: Int64;
    isDir: boolean;
    isFile: boolean;
  end;
  TAliOssFileInfoList = array of TAliOssFileInfo;

  // class: TAliOssFileSystem
  // based on TAliOss
  // provides file-system-like APIs and hides XML details
  TAliOssFileSystem = class(TObject)
  private
    current_volumn: string;
    oss: TAliOss;

  public
    //*************************************************************************************
    //Constructor
    constructor Create(const access_id, access_key: string; const hostname: string = ''; const debug: boolean = false);

    //*************************************************************************************
    //Destructor
    destructor Destroy; override;

    //*************************************************************************************
    //Account Validation
    function Validate: boolean;

    //*************************************************************************************
    //Volumn Operations (i.e., bucket in AliOss)
    function ListVolumns(var volumns: TAliOssVolumnInfoList): boolean;
    function CreateVolumn(const volumn: string; const permission: TAliOssVolumnPermission = vPrivate): boolean;
    function GetVolumnPermission(const volumn: string; var permission: TAliOssVolumnPermission): boolean;
    function SetVolumnPermission(const volumn: string; const permission: TAliOssVolumnPermission): boolean;
    function RemoveVolumn(const volumn: string; const force: boolean = false): boolean;
    function ChangeVolumn(const volumn: string): boolean;

    //*************************************************************************************
    //Directory Operations
    function CreateDirectory(const directory: string): boolean;
    function ListDirectory(const directory: string; var files: TAliOssFileInfoList; const dirNames: boolean = true): boolean;
    function RemoveDirectory(const directory: string): boolean;

    //*************************************************************************************
    //File Operations
    function ReadFile(const filename: string; var content: string): boolean; overload;
    function ReadFile(const filename: string; var content: TStream): boolean; overload;
    function WriteFile(const filename: string; const content: TStream; const append: boolean = false): boolean; overload;
    function WriteFile(const filename, content: string; const append: boolean = false): boolean; overload;
    function RenameFile(const src, dest: string): boolean;
    function RemoveFile(const filename: string): boolean;
    function UploadFile(const localfile, filename: string): boolean;
    function DownloadFile(const filename, localfile: string): boolean;
    function FileExists(const filename: string): boolean;
  end;

implementation

uses ALIOSSUTIL, ALIOSSMIME, IdGlobalProtocols, IdURI,
  Math, XMLIntf, XMLDoc, RegularExpressions, ActiveX, HTTPApp;

{ TAliOss }

constructor TAliOss.Create(const access_id, access_key, hostname: string);
begin
  inherited Create;

  //initialize default values
  self.use_ssl := false;
  self.debug_mode := false;
  self.max_retries := 3;
  self.redirects := 0;
  self.enable_domain_style := false;
  self.vhost := '';

  //validate access_id and access_key
  if access_id = '' then
    raise EAliOssException.Create(EAliOssException.NOT_SET_OSS_ACCESS_ID);

  if access_key = '' then
    raise EAliOssException.Create(EAliOssException.NOT_SET_OSS_ACCESS_KEY);

  self.access_id := access_id;
  self.access_key := access_key;

  //validate hostname
  if hostname = '' then
    self.hostname := DEFAULT_OSS_HOST
  else
    self.hostname := hostname;
end;

procedure TAliOss.SetDebugMode(const debug_mode: boolean);
begin
  self.debug_mode := debug_mode;
end;

procedure TAliOss.SetEnableDomainStyle(const enable_domain_style: boolean);
begin
  self.enable_domain_style := enable_domain_style;
end;

procedure TAliOss.SetMaxRetries(const max_retries: Integer);
begin
  self.max_retries := max_retries;
end;

procedure TAliOss.SetVHost(const vhost: string);
begin
  self.vhost := vhost;
end;

function TAliOss.ValidateBucket(const bucket: string): boolean;
var
  pattern: string;
begin
{
  bucket naming rules:
  1. can contain only lowercase letters, numbers, underline(_) and dash(-)
  2. first character must be a lowercase letter or number
  3. length must be between 3 to 255
}
  pattern := '^[a-z0-9][a-z0-9_\\-]{2,254}$';

  result := TRegEx.Match(bucket, pattern).Success;
end;

function TAliOss.ValidateContent(const options: TAliOssOption): boolean;
begin
  if (options <> nil) and (options.IndexOfName(OSS_CONTENT) <> -1) then
  begin
    if options.Values[OSS_CONTENT] = '' then
      raise EAliOssException.Create(EAliOssException.OSS_INVALID_HTTP_BODY_CONTENT);
  end
  else
    raise EAliOssException.Create(EAliOssException.OSS_NOT_SET_HTTP_CONTENT);

  result := true;
end;

function TAliOss.ValidateContentLength(const options: TAliOssOption): boolean;
var
  i, errorPos: Integer;
begin
  if (options <> nil) and (options.IndexOfName(OSS_LENGTH) <> -1) then
  begin
    val(options.Values[OSS_LENGTH], i, errorPos);
    if errorPos <> 0 then
      raise EAliOssException.Create(EAliOssException.OSS_INVALID_CONTENT_LENGTH);
    if not(i > 0) then
      raise EAliOssException.Create(EAliOssException.OSS_CONTENT_LENGTH_MUST_MORE_THAN_ZERO);
  end
  else
    raise EAliOssException.Create(EAliOssException.OSS_INVALID_CONTENT_LENGTH);

  result := true;
end;

function TAliOss.ValidateObject(const obj: string): boolean;
var
  pattern: string;
begin
{
  object naming rules:
  1. length must be between 1 to 1023
  2. must use UTF-8 encoding
}
  pattern := '^.{1,1023}$';

  result := (obj <> '') and (TRegEx.Match(obj, pattern).Success);
end;

function TAliOss.ValidateOptions(const options: TAliOssOption): boolean;
begin
  result := true;
end;

function TAliOss.GetMaxRetries: Integer;
begin
  result := self.max_retries;
end;

procedure TAliOss.SetHostname(const hostname: string; const port: Integer);
begin
  if port = -1 then
  begin
    self.hostname := hostname;
  end
  else
  begin
    self.hostname := hostname + ':' + IntToStr(port);
    self.port := port;
  end;
end;

function TAliOss.Auth(const options: TAliOssOption): TAliOssReturnType;
var
  temp: string;
  msg: string;
  list_bucket: boolean;
  found: boolean;
  i: integer;
  scheme: string;
  hostname: string;
  resource: string;
  sub_resource: string;
  signable_resource: string;
  string_to_sign: AnsiString;
  headers: TAliOssOption;
  query_string: string;
  signable_query_string: string;
  conjunction: string;
  non_signable_resource: string;
  header_key: string;
  header_value: string;
  signature: string;
  data: string;

  fullfile: TStringStream;
  request: TStringStream;

  http: TIdHttp; //HTTP engine
begin
  //create request and response streams
  request := TStringStream.Create('', TEncoding.UTF8);
  result.body := TStringStream.Create('', TEncoding.UTF8);

  //strat logging
  msg := '---LOG START---------------------------------------------------------------------------'#10;

  //validate Bucket (except list_bucket)
  list_bucket := ('/' = options.Values[OSS_OBJECT]) and ('' = options.Values[OSS_BUCKET]) and (OSS_HTTP_GET = options.Values[OSS_METHOD]);
  if (not list_bucket) and (not self.ValidateBucket(options.Values[OSS_BUCKET])) then
    raise EAliOssException.Create('"'+options.Values[OSS_BUCKET]+'"'+EAliOssException.OSS_BUCKET_NAME_INVALID);

  //validate Object
  if (options.IndexOfName(OSS_OBJECT) <> -1) and (not self.ValidateObject(options.Values[OSS_OBJECT])) then
    raise EAliOssException.Create('"'+options.Values[OSS_OBJECT]+'"'+EAliOssException.OSS_OBJECT_NAME_INVALID);

  //validate ACL
  if options.Lists[OSS_HEADERS].Values[OSS_ACL] <> '' then
  begin
    temp := lowercase(options.Lists[OSS_HEADERS].Values[OSS_ACL]);
    found := false;
    for I := Low(OSS_ACL_TYPES) to High(OSS_ACL_TYPES) do
      if temp = OSS_ACL_TYPES[i] then
      begin
        found := true;
        break;
      end;
    if not found then
      raise EAliOssException.Create(options.Values[OSS_HEADERS+':'+OSS_ACL]+':'+EAliOssException.OSS_ACL_INVALID);
  end;

  //define scheme
  if self.use_ssl then
    scheme := 'https://'
  else
    scheme := 'http://';

  if self.enable_domain_style then
  begin
    if self.vhost <> '' then
      hostname := self.vhost
    else
    begin
      if options.Values[OSS_BUCKET] <> '' then
        hostname := options.Values[OSS_BUCKET] + '.' + self.hostname
      else
        hostname := self.hostname;
    end;
  end
  else
  begin
    if options.Values[OSS_BUCKET] <> '' then
      hostname := self.hostname + '/' + options.Values[OSS_BUCKET]
    else
      hostname := self.hostname;
  end;

  //request parameters
  resource := '';
  sub_resource := '';
  signable_resource := '';
  string_to_sign := '';

  //initialize headers
  headers := TAliOssOption.Create;
  headers.Values[OSS_CONTENT_MD5] := '';
  if options.IndexOfName(OSS_CONTENT_TYPE) <> -1 then
    headers.Values[OSS_CONTENT_TYPE] := options.Values[OSS_CONTENT_TYPE]
  else
    headers.Values[OSS_CONTENT_TYPE] := OSS_CONTENT_TYPE_DEFAULT;

  if options.IndexOfName(OSS_DATE) <> -1 then
    headers.Values[OSS_DATE] := options.Values[OSS_DATE]
  else
    headers.Values[OSS_DATE] := gmdate('D, d M Y H:i:s \G\M\T');

  if enable_domain_style then
    headers.Values[OSS_HOST] := hostname
  else
    headers.Values[OSS_HOST] := self.hostname;

  if (options.IndexOfName(OSS_OBJECT) <> -1) and (options.Values[OSS_OBJECT] <> '/') then
    signable_resource := '/' +
      StringReplace(
        StringReplace(TIdURI.PathEncode(options.Values[OSS_OBJECT]), '%2F', '/', [rfReplaceAll]),
        '&', '%26', [rfReplaceAll]);

  if options.Lists[OSS_QUERY_STRING]<>nil then
  begin
    query_string := options.Lists[OSS_QUERY_STRING].MergeQueries;
  end;

  signable_query_string := '';
  if options.IndexOfName(OSS_PART_NUMBER) <> -1 then
  begin
    signable_query_string := OSS_PART_NUMBER + '=' + options.Values[OSS_PART_NUMBER];
  end;
  if options.IndexOfName(OSS_UPLOAD_ID) <> -1 then
  begin
    if signable_query_string <> '' then
      signable_query_string := signable_query_string + '&';
    signable_query_string := signable_query_string + OSS_UPLOAD_ID + '=' + options.Values[OSS_UPLOAD_ID];
  end;

  //combine HTTP headers
  if options.Lists[OSS_HEADERS].Count <> 0 then
  begin
    headers.Merge(options.Lists[OSS_HEADERS]);
  end;

  //generate request URL
  conjunction := '?';

  non_signable_resource := '';

  if options.IndexOfName(OSS_SUB_RESOURCE) <> -1 then
  begin
    signable_resource := signable_resource + conjunction + options.Values[OSS_SUB_RESOURCE];
    conjunction := '&';
  end;

  if signable_query_string <> '' then
  begin
    signable_query_string := conjunction + signable_query_string;
    conjunction := '&';
  end;

  if query_string <> '' then
  begin
    non_signable_resource := non_signable_resource + conjunction + query_string;
    conjunction := '&';
  end;

  self.request_url := scheme + hostname + signable_resource + signable_query_string + non_signable_resource;

	msg := msg + '--REQUEST URL:-------------------------------------------------'#10+self.request_url+#10;

  //create request
  http := TIdHttp.Create;
  http.ProtocolVersion := pv1_1;
//  http.Request.

  //initialize http engine
  http.Request.UserAgent := 'Mozilla/3.0'
    +' (compatible; '
    +OSS_NAME+'/'+OSS_VERSION+'; '
    +GetOSVersion+')';    //default: Mozilla/3.0 (compatible; Indy Library)

  //streaming uploads
  if options.IndexOfName(OSS_FILE_UPLOAD) <> -1 then
  begin
    if options.IndexOfName(OSS_SEEK_TO) <> -1 then
    begin
      //multipart upload
      fullfile := TStringStream.Create;

      fullfile.LoadFromFile(options.Values[OSS_FILE_UPLOAD]);
      fullfile.Seek(StrToInt64(options.Values[OSS_SEEK_TO]), soFromBeginning);
      request.CopyFrom(fullfile, StrToInt64(options.Values[OSS_LENGTH]));
      fullfile.Free;
    end
    else
    begin
      //direct upload
      request.LoadFromFile(options.Values[OSS_FILE_UPLOAD]);
    end;

    if options.Values[OSS_CONTENT_TYPE] = 'application/x-www-form-urlencoded' then
      options.Values[OSS_CONTENT_TYPE] := 'application/octet-stream';

    options.Values[OSS_CONTENT_MD5] := '';
  end;

  {
  //not used
  if options.Values[OSS_FILE_DOWNLOAD] <> '' then
  begin
  end;
  }

  if options.IndexOfName(OSS_METHOD) <> -1 then
  begin
    http.Request.Method := options.Values[OSS_METHOD];
    string_to_sign := string_to_sign + options.Values[OSS_METHOD] + #10;
  end;

  if options.IndexOfName(OSS_CONTENT) <> -1 then
  begin
    request.WriteString(options.Values[OSS_CONTENT]);

    http.Request.ContentLength := Length(options.Values[OSS_CONTENT]);
    headers.Values[OSS_CONTENT_MD5] := HexBase64Encode(MD5(options.Values[OSS_CONTENT]));
  end;

  headers.Sort;

  for I := 0 to headers.Count - 1 do
  begin
    header_key := headers.Names[I];
    header_value := headers.ValueFromIndex[I];
    if header_value = #0 then
      header_value := '';

    if header_value <> '' then
      http.Request.CustomHeaders.AddValue(header_key, header_value);

    if (lowercase(header_key) = 'content-md5') or
       (lowercase(header_key) = 'content-type') or
       (lowercase(header_key) = 'date') or
       (options.IndexOfName(OSS_PREAUTH) <> -1) then
      string_to_sign := string_to_sign + header_value + #10
    else if copy(lowercase(header_key), 1, 6) = OSS_DEFAULT_PREFIX then
      string_to_sign := string_to_sign + lowercase(header_key) + ':' + header_value + #10;

  end;

  string_to_sign := string_to_sign + '/' + options.Values[OSS_BUCKET];

  if (self.enable_domain_style) and (options.Values[OSS_BUCKET]<>'') and (options.Values[OSS_OBJECT] = '/') then
    string_to_sign := string_to_sign + '/';

  string_to_sign := string_to_sign + TIdURI.URLDecode(signable_resource) + TIdURI.URLDecode(signable_query_string);

  msg := msg + '--STRING TO SIGN:----------------------------------------------'#10+String(string_to_sign)+#10;

  //convert encoding to UTF-8
  string_to_sign := UTF8Encode(string_to_sign);

  signature := Base64Encode(EncryptHMACSha1(string_to_sign, self.access_key));
  http.Request.CustomHeaders.AddValue('Authorization', 'OSS ' + self.access_id + ':' + signature);

  if options.Values[OSS_PREAUTH] > '0' then
  begin
    result.body := TStringStream.Create(self.request_url + conjunction + OSS_URL_ACCESS_KEY_ID + '=' + self.access_id + '&' + OSS_URL_EXPIRES + '=' + options.Values[OSS_PREAUTH] + '&' + OSS_URL_SIGNATURE + signature);
    exit;
  end
  else if options.Values[OSS_PREAUTH] <> '' then
  begin
    result.body := TStringStream.Create(self.request_url);
    exit;
  end;

  msg := msg + '--REQUEST HEADERS:---------------------------------------------'#10 + http.Request.CustomHeaders.Text + #10;
	msg := msg + '--REQUEST DATA:-----------------------------------------------'#10 + request.DataString + #10;

  try
    if http.Request.Method = OSS_HTTP_GET then
      http.Get(self.request_url, result.body)
    else if http.Request.Method = OSS_HTTP_PUT then
      http.Put(self.request_url, request, result.body)
    else if http.Request.Method = OSS_HTTP_HEAD then
      http.Head(self.request_url)
    else if http.Request.Method = OSS_HTTP_POST then
      http.Post(self.request_url, request, result.body)
    else if http.Request.Method = OSS_HTTP_DELETE then
      http.Delete(self.request_url);
  except
    //do nothing
  end;

  msg := msg + '--RESPONSE HEADERS:--------------------------------------------'#10 + http.Response.RawHeaders.Text + #10;

  msg := msg + '--RESPONSE TEXT:--------------------------------------------'#10 + http.Response.ResponseText + #10;

  data := result.body.DataString;

	msg := msg + '--RESPONSE DATA:-----------------------------------------------'#10 + data + #10;
	msg := msg + DateTimeToStr(now) + ':'#10'---LOG END---------------------------------------------------------------------------'#10#10;

  if self.debug_mode then
    LogFile(msg);

  self.redirects := 0;
  result.status := http.ResponseCode;
  result.header := TIdHeaderList.Create(QuoteHTTP);
  result.header.Assign(http.Response.RawHeaders);

  if (http.ResponseCode = 400 {Bad Request}) or
     (http.ResponseCode = 500 {Internal Error}) or
     (http.ResponseCode = 503 {Service Unavailable}) then
  begin
    if self.redirects <= self.max_retries then
    begin
      Sleep(Trunc(100 * Power(4, self.redirects)));
      inc(self.redirects);
      result := self.Auth(options);
    end;

  end;

  //release resources
  http.Free;
  request.Free;
end;

function TAliOss.ValidateAndAuth(const opt1, opt2: TAliOssOption): TAliOssReturnType;
var
  opt: TAliOssOption;
begin
  //options
  self.ValidateOptions(opt1);

  if opt2 = nil then
    opt := TAliOssOption.Create
  else
    opt := opt2;

  opt.Merge(opt1);

  result := self.Auth(opt);

  if opt2 = nil then
    opt.Free;
end;

function TAliOss.MakeObjectGroupXml(const bucket: string;
  const object_array: TStringList): string;
var
  xml: string;
  index: integer;
  I: Integer;
  object_meta: TAliOssReturnType;
begin
  xml := '<CreateFileGroup>';
  if object_array.Count > OSS_MAX_OBJECT_GROUP_VALUE then
    raise EAliOssException.Create(EAliOssException.OSS_OBJECT_GROUP_TOO_MANY_OBJECT);

  index := 1;
  for I := 0 to object_array.Count - 1 do
  begin
    object_meta := self.GetObjectMeta(bucket, object_array[I]);
    if (object_meta.status = 200) and (object_meta.header.Values['etag'] <> '') then
    begin
      xml := xml + '<Part>';
      xml := xml + '<PartNumber>'+IntToStr(index)+'</PartNumber>';
      xml := xml + '<PartName>'+object_array[I]+'</PartName>';
      xml := xml + '<ETag>'+object_meta.header.Values['etag']+'</ETag>';
      xml := xml + '</Part>';

      inc(index);
    end;
  end;

  xml := xml + '</CreateFileGroup>';
  result := xml;
end;

function TAliOss.ListBucket(const options: TAliOssOption): TAliOssReturnType;
var
  opt: TAliOssOption;
begin
  opt := TAliOssOption.Create;
  opt.Values[OSS_BUCKET] := '';
  opt.Values[OSS_METHOD] := OSS_HTTP_GET;
  opt.Values[OSS_OBJECT] := '/';

  result := ValidateAndAuth(options, opt);

  opt.Free;
end;

function TAliOss.CreateBucket(const bucket: string;
  const acl: string = OSS_ACL_TYPE_PRIVATE ; const options: TAliOssOption = nil): TAliOssReturnType;
var
  opt: TAliOssOption;
begin
  IsEmpty(bucket, EAliOssException.OSS_BUCKET_IS_NOT_ALLOWED_EMPTY);

  opt := TAliOssOption.Create;
  opt.Values[OSS_BUCKET] := bucket;
  opt.Values[OSS_METHOD] := OSS_HTTP_PUT;
  opt.Values[OSS_OBJECT] := '/';
  opt.Lists[OSS_HEADERS].Values[OSS_ACL] := acl;

  result := ValidateAndAuth(options, opt);

  opt.Free;
end;

function TAliOss.DeleteBucket(const bucket: string;
  const options: TAliOssOption = nil): TAliOssReturnType;
var
  opt: TAliOssOption;
begin
  IsEmpty(bucket, EAliOssException.OSS_BUCKET_IS_NOT_ALLOWED_EMPTY);

  opt := TAliOssOption.Create;
  opt.Values[OSS_BUCKET] := bucket;
  opt.Values[OSS_METHOD] := OSS_HTTP_DELETE;
  opt.Values[OSS_OBJECT] := '/';

  result := ValidateAndAuth(options, opt);

  opt.Free;
end;

function TAliOss.GetBucketACL(const bucket: string;
  const options: TAliOssOption): TAliOssReturnType;
var
  opt: TAliOssOption;
begin
  IsEmpty(bucket, EAliOssException.OSS_BUCKET_IS_NOT_ALLOWED_EMPTY);

  opt := TAliOssOption.Create;
  opt.Values[OSS_BUCKET] := bucket;
  opt.Values[OSS_METHOD] := OSS_HTTP_GET;
  opt.Values[OSS_OBJECT] := '/';
  opt.Values[OSS_SUB_RESOURCE] := 'acl';

  result := ValidateAndAuth(options, opt);

  opt.Free;
end;

function TAliOss.SetBucketACL(const bucket: string; const acl: string;
  const options: TAliOssOption): TAliOssReturnType;
var
  opt: TAliOssOption;
begin
  IsEmpty(bucket, EAliOssException.OSS_BUCKET_IS_NOT_ALLOWED_EMPTY);

  opt := TAliOssOption.Create;
  opt.Values[OSS_BUCKET] := bucket;
  opt.Values[OSS_METHOD] := OSS_HTTP_PUT;
  opt.Values[OSS_OBJECT] := '/';
  opt.Lists[OSS_HEADERS].Values[OSS_ACL] := acl;

  result := ValidateAndAuth(options, opt);

  opt.Free;
end;

function TAliOss.ListObject(const bucket: string;
  const options: TAliOssOption): TAliOssReturnType;
var
  opt: TAliOssOption;
begin
  IsEmpty(bucket, EAliOssException.OSS_BUCKET_IS_NOT_ALLOWED_EMPTY);

  opt := TAliOssOption.Create;
  opt.Values[OSS_BUCKET] := bucket;
  opt.Values[OSS_METHOD] := OSS_HTTP_GET;
  opt.Values[OSS_OBJECT] := '/';

  if options <> nil then
  begin
    if options.IndexOfName(OSS_DELIMITER) <> -1 then
      opt.Lists[OSS_HEADERS].Values[OSS_DELIMITER] := options.Values[OSS_DELIMITER]
    else
      opt.Lists[OSS_HEADERS].Values[OSS_DELIMITER] := '/';

    if options.IndexOfName(OSS_PREFIX) <> -1 then
      opt.Lists[OSS_HEADERS].Values[OSS_PREFIX] := options.Values[OSS_PREFIX]
    else
      opt.Lists[OSS_HEADERS].Values[OSS_PREFIX] := '';

    if options.IndexOfName(OSS_MAX_KEYS) <> -1 then
      opt.Lists[OSS_HEADERS].Values[OSS_MAX_KEYS] := options.Values[OSS_MAX_KEYS]
    else
      opt.Lists[OSS_HEADERS].Values[OSS_MAX_KEYS] := IntToStr(OSS_MAX_KEYS_VALUE);

    if options.IndexOfName(OSS_MARKER) <> -1 then
      opt.Lists[OSS_HEADERS].Values[OSS_MARKER] := options.Values[OSS_MARKER]
    else
      opt.Lists[OSS_HEADERS].Values[OSS_MARKER] := '';
  end;

  result := ValidateAndAuth(options, opt);

  opt.Free;
end;

function TAliOss.CreateObjectDir(const bucket, obj: string;
  const options: TAliOssOption): TAliOssReturnType;
var
  opt: TAliOssOption;
begin
  IsEmpty(bucket, EAliOssException.OSS_BUCKET_IS_NOT_ALLOWED_EMPTY);
  IsEmpty(obj, EAliOssException.OSS_OBJECT_IS_NOT_ALLOWED_EMPTY);

  opt := TAliOssOption.Create;
  opt.Values[OSS_BUCKET] := bucket;
  opt.Values[OSS_METHOD] := OSS_HTTP_PUT;
  opt.Values[OSS_OBJECT] := obj + '/';
  opt.Lists[OSS_CONTENT_LENGTH].Values[OSS_CONTENT_LENGTH] := IntToStr(0);

  result := ValidateAndAuth(options, opt);

  opt.Free;
end;

function TAliOss.UploadFileByContent(const bucket, obj: string;
  const options: TAliOssOption): TAliOssReturnType;
var
  opt: TAliOssOption;
  p: Integer;
  basename: string;
  extension: string;
  content_type: string;
begin
  IsEmpty(bucket, EAliOssException.OSS_BUCKET_IS_NOT_ALLOWED_EMPTY);
  IsEmpty(obj, EAliOssException.OSS_OBJECT_IS_NOT_ALLOWED_EMPTY);
  self.ValidateContent(options);

  p := LastPos('/', obj);
  basename := copy(obj, p+1, MaxInt);
  p := LastPos('.', basename);
  extension := copy(basename, p+1, MaxInt);
  content_type := GetMimeType(LowerCase(extension));

  opt := TAliOssOption.Create;
  opt.Values[OSS_BUCKET] := bucket;
  opt.Values[OSS_METHOD] := OSS_HTTP_PUT;
  opt.Values[OSS_OBJECT] := obj;

  if options <> nil then
  begin
    if options.Values[OSS_LENGTH] <> '' then
      opt.Values[OSS_CONTENT_LENGTH] := IntToStr(Length(options.Values[OSS_CONTENT]))
    else
      opt.Values[OSS_CONTENT_LENGTH] := options.Values[OSS_CONTENT_LENGTH];

    if (options.Values[OSS_CONTENT_TYPE] = '') and (content_type <> '') then
      opt.Values[OSS_CONTENT_TYPE] := content_type;
  end;

  result := ValidateAndAuth(options, opt);

  opt.Free;
end;

function TAliOss.UploadFileByFile(const bucket, obj, path: string;
  const options: TAliOssOption): TAliOssReturnType;
var
  opt: TAliOssOption;
  filesize: Int64;
  p: Integer;
  extension: string;
  content_type: string;
begin
  IsEmpty(bucket, EAliOssException.OSS_BUCKET_IS_NOT_ALLOWED_EMPTY);
  IsEmpty(obj, EAliOssException.OSS_OBJECT_IS_NOT_ALLOWED_EMPTY);
  IsEmpty(path, EAliOssException.OSS_FILE_PATH_IS_NOT_ALLOWED_EMPTY);

  if not FileExists(path) then
    raise EAliOssException.Create(EAliOssException.OSS_FILE_NOT_EXIST);

  filesize := FileSizeByName(path);

  p := LastPos('.', path);
  extension := copy(path, p+1, MaxInt);
  content_type := GetMimeType(LowerCase(extension));

  opt := TAliOssOption.Create;
  opt.Values[OSS_BUCKET] := bucket;
  opt.Values[OSS_METHOD] := OSS_HTTP_PUT;
  opt.Values[OSS_OBJECT] := obj;
  opt.Values[OSS_FILE_UPLOAD] := path;
  opt.Values[OSS_CONTENT_TYPE] := content_type;
  opt.Values[OSS_CONTENT_LENGTH] := IntToStr(filesize);

  if options <> nil then
  begin
    if options.Values[OSS_LENGTH] <> '' then
      opt.Values[OSS_CONTENT_LENGTH] := IntToStr(Length(options.Values[OSS_CONTENT]))
    else
      opt.Values[OSS_CONTENT_LENGTH] := options.Values[OSS_CONTENT_LENGTH];

    if (options.Values[OSS_CONTENT_TYPE] = '') and (content_type <> '') then
      opt.Values[OSS_CONTENT_TYPE] := content_type;
  end;

  result := ValidateAndAuth(options, opt);

  opt.Free;
end;

function TAliOss.CopyObject(const from_bucket, from_obj, to_bucket,
  to_obj: string; const options: TAliOssOption): TAliOssReturnType;
var
  opt: TAliOssOption;
begin
  IsEmpty(from_bucket, EAliOssException.OSS_BUCKET_IS_NOT_ALLOWED_EMPTY);
  IsEmpty(to_bucket, EAliOssException.OSS_BUCKET_IS_NOT_ALLOWED_EMPTY);
  IsEmpty(from_obj, EAliOssException.OSS_OBJECT_IS_NOT_ALLOWED_EMPTY);
  IsEmpty(to_obj, EAliOssException.OSS_OBJECT_IS_NOT_ALLOWED_EMPTY);

  opt := TAliOssOption.Create;
  opt.Values[OSS_BUCKET] := to_bucket;
  opt.Values[OSS_METHOD] := OSS_HTTP_PUT;
  opt.Values[OSS_OBJECT] := to_obj;
  opt.Lists[OSS_HEADERS].Values[OSS_OBJECT_COPY_SOURCE] := '/'+from_bucket+'/'+from_obj;

  result := ValidateAndAuth(options, opt);

  opt.Free;
end;

function TAliOss.GetObjectMeta(const bucket, obj: string;
  const options: TAliOssOption): TAliOssReturnType;
var
  opt: TAliOssOption;
begin
  IsEmpty(bucket, EAliOssException.OSS_BUCKET_IS_NOT_ALLOWED_EMPTY);
  IsEmpty(obj, EAliOssException.OSS_OBJECT_IS_NOT_ALLOWED_EMPTY);

  opt := TAliOssOption.Create;
  opt.Values[OSS_BUCKET] := bucket;
  opt.Values[OSS_METHOD] := OSS_HTTP_HEAD;
  opt.Values[OSS_OBJECT] := obj;

  result := ValidateAndAuth(options, opt);

  opt.Free;
end;

function TAliOss.DeleteObject(const bucket, obj: string;
  const options: TAliOssOption): TAliOssReturnType;
var
  opt: TAliOssOption;
begin
  IsEmpty(bucket, EAliOssException.OSS_BUCKET_IS_NOT_ALLOWED_EMPTY);
  IsEmpty(obj, EAliOssException.OSS_OBJECT_IS_NOT_ALLOWED_EMPTY);

  opt := TAliOssOption.Create;
  opt.Values[OSS_BUCKET] := bucket;
  opt.Values[OSS_METHOD] := OSS_HTTP_DELETE;
  opt.Values[OSS_OBJECT] := obj;

  result := ValidateAndAuth(options, opt);

  opt.Free;
end;

function TAliOss.DeleteObjects(const bucket: string; const objs: TStringList;
  const options: TAliOssOption): TAliOssReturnType;
var
  opt: TAliOssOption;
  xml: IXMLDocument;
  del: IXMLNode;
  node: IXMLNode;
  quiet: string;
  I: integer;
begin
  IsEmpty(bucket, EAliOssException.OSS_BUCKET_IS_NOT_ALLOWED_EMPTY);

  opt := TAliOssOption.Create;
  opt.Values[OSS_BUCKET] := bucket;
  opt.Values[OSS_METHOD] := OSS_HTTP_POST;
  opt.Values[OSS_OBJECT] := '/';
  opt.Values[OSS_SUB_RESOURCE] := 'delete';
  opt.Values[OSS_CONTENT_TYPE] := 'application/xml';

  CoInitialize(nil);
  begin
    xml := NewXMLDocument;
    xml.LoadFromXML('<?xml version="1.0" encoding="utf-8"?><Delete></Delete>');

    //Quiet mode?
    if options <> nil then
    begin
      if options.Values['quiet'] <> '' then
      begin
        if options.Values['quiet'] = 'true' then
          quiet := 'true'
        else
          quiet := 'false';

        xml.AddChild('Quiet', quiet);
      end;
    end;
    del := xml.ChildNodes.FindNode('Delete');

    // Add the objects
    for I := 0 to objs.Count - 1 do
    begin
      node := del.AddChild('Object');
      node := node.AddChild('Key');
      node.Text := HTMLEscape(objs[i]);
    end;

    opt.Values[OSS_CONTENT] := FormatXml(xml);
  end;
  CoInitialize(nil);

  result := ValidateAndAuth(options, opt);

  opt.Free;
end;

function TAliOss.GetObject(const bucket, obj: string;
  const options: TAliOssOption): TAliOssReturnType;
var
  opt: TAliOssOption;
begin
  IsEmpty(bucket, EAliOssException.OSS_BUCKET_IS_NOT_ALLOWED_EMPTY);
  IsEmpty(obj, EAliOssException.OSS_OBJECT_IS_NOT_ALLOWED_EMPTY);

  opt := TAliOssOption.Create;
  opt.Values[OSS_BUCKET] := bucket;
  opt.Values[OSS_METHOD] := OSS_HTTP_GET;
  opt.Values[OSS_OBJECT] := obj;

  if options <> nil then
  begin
    if options.Values['lastmodified'] <> '' then
    begin
      opt.Lists[OSS_HEADERS].Values[OSS_IF_MODIFIED_SINCE] := options.Values['lastmodified'];
      options.Values['lastmodified'] := '';
    end;

    if options.Values['etag'] <> '' then
    begin
      opt.Lists[OSS_HEADERS].Values[OSS_IF_NONE_MATCH] := options.Values['etag'];
      options.Values['etag'] := '';
    end;

    if options.Values['range'] <> '' then
    begin
      opt.Lists[OSS_HEADERS].Values[OSS_RANGE] := 'bytes=' + options.Values['range'];
      options.Values['range'] := '';
    end;
  end;

  result := ValidateAndAuth(options, opt);

  opt.Free;
end;

function TAliOss.ObjectExists(const bucket, obj: string;
  const options: TAliOssOption): Boolean;
var
  opt: TAliOssOption;
begin
  IsEmpty(bucket, EAliOssException.OSS_BUCKET_IS_NOT_ALLOWED_EMPTY);
  IsEmpty(obj, EAliOssException.OSS_OBJECT_IS_NOT_ALLOWED_EMPTY);

  opt := TAliOssOption.Create;
  opt.Values[OSS_BUCKET] := bucket;
  opt.Values[OSS_METHOD] := OSS_HTTP_HEAD;
  opt.Values[OSS_OBJECT] := obj;

  result := self.GetObjectMeta(bucket, obj ,opt).status = 200;

  opt.Free;
end;

function TAliOss.UploadFileByMultipart(const bucket, obj, path: string;
  part_size: Int64): TAliOssReturnType;
var
  response: TAliOssReturnType;
  xml: IXMLDocument;
  UploadId: string;
  parts: TAliOssOption;
  I: Integer;
  ETags: TStringList;
begin
  IsEmpty(bucket, EAliOssException.OSS_BUCKET_IS_NOT_ALLOWED_EMPTY);
  IsEmpty(obj, EAliOssException.OSS_OBJECT_IS_NOT_ALLOWED_EMPTY);

  if not FileExists(path) then
    raise EAliOssException.Create(EAliOssException.OSS_FILE_NOT_EXIST);

  if FileSizeByName(path) < 5242880 then //<5M, use direct upload
  begin
    result := self.UploadFileByFile(bucket, obj, path, nil);
  end
  else
  begin
    //initiate multipart upload
    response := self.InitiateMultipartUpload(bucket, obj, nil);
    if response.status = 200 then
    begin
      CoInitialize(nil);
      begin
        xml := NewXMLDocument;
        xml.LoadFromXML(response.body.DataString);
        //get upload id
        UploadId := xml.ChildNodes.FindNode('InitiateMultipartUploadResult').ChildNodes.FindNode('UploadId').Text;
      end;
      CoUninitialize;

      //calculate part size
      parts := self.GetMultipartCounts(FileSizeByName(path), part_size);

      //part upload
      ETags := TStringList.Create;
      //TODO: multi-thread
      for I := 0 to parts.Count - 1 do //for each part
      begin
        response := UploadPart(bucket, obj, path,
          parts.Lists[IntToStr(i)].Values[OSS_SEEK_TO],
          parts.Lists[IntToStr(i)].Values[OSS_LENGTH], UploadId, IntToStr(i+1));
        ETags.Add(response.header.Values['ETag']);
      end;

      //complete multipart upload
      self.CompleteMultipartUpload(bucket, obj, UploadId, ETags);
    end;
  end;
end;

function TAliOss.GetMultipartCounts(filesize, part_size: Int64): TAliOssOption;
var
  i: integer;
  sizecount: Int64;
begin
  result := TAliOssOption.Create;

  i := 0;
  sizecount := filesize;

  if part_size <= 5242880 then
    part_size := 5242880        //5M
  else if part_size > 524288000 then
    part_size := 524288000      //500M
  else
    part_size := 52428800;      //50M

  while sizecount > 0 do
  begin
    sizecount := sizecount - part_size;
    result.Lists[IntToStr(i)].Values[OSS_SEEK_TO] := IntToStr(part_size * i);
    if sizecount > 0 then
      result.Lists[IntToStr(i)].Values[OSS_LENGTH] := IntToStr(part_size)
    else
      result.Lists[IntToStr(i)].Values[OSS_LENGTH] := IntToStr(sizecount + part_size);

    inc(i);
  end;
end;

function TAliOss.InitiateMultipartUpload(const bucket: string;
  const obj: string;
  const options: TAliOssOption): TAliOssReturnType;
var
  opt: TAliOssOption;
begin
  IsEmpty(bucket, EAliOssException.OSS_BUCKET_IS_NOT_ALLOWED_EMPTY);
  IsEmpty(obj, EAliOssException.OSS_OBJECT_IS_NOT_ALLOWED_EMPTY);

  opt := TAliOssOption.Create;
  opt.Values[OSS_BUCKET] := bucket;
  opt.Values[OSS_METHOD] := OSS_HTTP_POST;
  opt.Values[OSS_OBJECT] := obj;
  opt.Values[OSS_SUB_RESOURCE] := 'uploads';
  opt.Values[OSS_CONTENT] := '';
  opt.Lists[OSS_HEADERS].Values[OSS_CONTENT_TYPE] := 'application/octet-stream';

  result := ValidateAndAuth(options, opt);

  opt.Free;
end;

function TAliOss.UploadPart(const bucket, obj, path, seek_to, len, upload_id, part_number: string;
  const options: TAliOssOption): TAliOssReturnType;
var
  opt: TAliOssOption;
begin
  IsEmpty(bucket, EAliOssException.OSS_BUCKET_IS_NOT_ALLOWED_EMPTY);
  IsEmpty(obj, EAliOssException.OSS_OBJECT_IS_NOT_ALLOWED_EMPTY);

  opt := TAliOssOption.Create;
  opt.Values[OSS_BUCKET] := bucket;
  opt.Values[OSS_METHOD] := OSS_HTTP_PUT;
  opt.Values[OSS_OBJECT] := obj;
  opt.Values[OSS_UPLOAD_ID] := upload_id;
  opt.Values[OSS_PART_NUMBER] := part_number;
  opt.Values[OSS_FILE_UPLOAD] := path;
  opt.Values[OSS_SEEK_TO] := seek_to;
  opt.Values[OSS_LENGTH] := len;

  if options <> nil then
  begin
    if options.Values[OSS_LENGTH]<>'' then
      opt.Values[OSS_CONTENT_LENGTH] := options.Values[OSS_LENGTH];
  end;

  result := ValidateAndAuth(options, opt);

  opt.Free;
end;

function TAliOss.CompleteMultipartUpload(const bucket, obj, upload_id: string;
  const ETags: TStringList;
  const options: TAliOssOption): TAliOssReturnType;
var
  opt: TAliOssOption;
  xml: IXMLDocument;
  root, node: IXMLNode;
  I: Integer;
begin

  opt := TAliOssOption.Create;
  opt.Values[OSS_BUCKET] := bucket;
  opt.Values[OSS_METHOD] := OSS_HTTP_POST;
  opt.Values[OSS_OBJECT] := obj;
  opt.Values[OSS_UPLOAD_ID] := upload_id;
  opt.Values[OSS_CONTENT_TYPE] := 'application/xml';

  CoInitialize(nil);
  begin
    xml := NewXMLDocument;
    xml.LoadFromXML('<?xml version="1.0" encoding="utf-8"?><CompleteMultipartUpload></CompleteMultipartUpload>');

    root := xml.ChildNodes.FindNode('CompleteMultipartUpload');
    for I := 0 to ETags.Count-1 do
    begin
      node := root.AddChild('Part');
      node.AddChild('PartNumber').Text := IntToStr(i+1);
      node.AddChild('ETag').Text := ETags[i];
    end;

    opt.Values[OSS_CONTENT] := FormatXml(xml);
  end;
  CoUninitialize;

  result := ValidateAndAuth(options, opt);

  opt.Free;
end;

function TAliOss.ListMultipartUploads(const bucket: string;
  const options: TAliOssOption): TAliOssReturnType;
var
  opt: TAliOssOption;
begin
  IsEmpty(bucket, EAliOssException.OSS_BUCKET_IS_NOT_ALLOWED_EMPTY);

  opt := TAliOssOption.Create;
  opt.Values[OSS_BUCKET] := bucket;
  opt.Values[OSS_METHOD] := OSS_HTTP_GET;
  opt.Values[OSS_OBJECT] := '/';
  opt.Values[OSS_SUB_RESOURCE] := 'uploads';

  if options <> nil then
  begin
    if options.Values['key-marker'] <> '' then
    begin
      options.Lists[OSS_QUERY_STRING].Values['key-marker'] := options.Values['key-marker'];
      options.Values['key-marker'] := '';
    end;

    if options.Values['max-uploads'] <> '' then
    begin
      options.Lists[OSS_QUERY_STRING].Values['max-uploads'] := options.Values['max-uploads'];
      options.Values['max-uploads'] := '';
    end;

    if options.Values['upload-id-marker'] <> '' then
    begin
      options.Lists[OSS_QUERY_STRING].Values['upload-id-marker'] := options.Values['upload-id-marker'];
      options.Values['upload-id-marker'] := '';
    end;
  end;

  result := self.ValidateAndAuth(options, opt);

  opt.Free;
end;

function TAliOss.AbortMultipartUpload(const bucket, obj, upload_id: string;
  const options: TAliOssOption): TAliOssReturnType;
var
  opt: TAliOssOption;
begin
  IsEmpty(bucket, EAliOssException.OSS_BUCKET_IS_NOT_ALLOWED_EMPTY);
  IsEmpty(obj, EAliOssException.OSS_OBJECT_IS_NOT_ALLOWED_EMPTY);

  opt := TAliOssOption.Create;
  opt.Values[OSS_BUCKET] := bucket;
  opt.Values[OSS_METHOD] := OSS_HTTP_DELETE;
  opt.Values[OSS_OBJECT] := obj;
  opt.Values[OSS_UPLOAD_ID] := upload_id;

  result := self.ValidateAndAuth(options, opt);

  opt.Free;
end;

function TAliOss.UploadDirByMultipart(const bucket, dir: string;
  const recursive: boolean; const exclude: string;
  const options: TAliOssOption): TAliOssReturnType;
var
  files: TStringList;
  filename: String;
  I: Integer;
  dir2: string;
begin
  if Copy(dir, length(dir), 1) = '\' then
    dir2 := Copy(dir, 1, length(dir) - 1)
  else
    dir2 := dir;

  //validate dir
  if not DirectoryExists(dir2) then
    raise EAliOssException.Create(EAliOssException.OSS_INVALID_DIRECTORY);

  //get file list
  files := TStringList.Create;
  GetFilesInDirectory(PChar(dir), files, recursive, exclude);

  if files.Count = 0 then
    exit;

  for I := 0 to files.Count-1 do
  begin
    filename := Copy(files[I], length(dir2)+2, MaxInt);
    filename := StringReplace(filename, '\', '/', [rfReplaceAll]);

    self.UploadFileByMultipart(bucket, filename, files[I]);
  end;

  files.Free;
end;

function TAliOss.CreateObjectGroup(const bucket, object_group: string;
  const object_array: TStringList;
  const options: TAliOssOption): TAliOssReturnType;
var
  opt: TAliOssOption;
begin
  IsEmpty(bucket, EAliOssException.OSS_BUCKET_IS_NOT_ALLOWED_EMPTY);
  IsEmpty(object_group, EAliOssException.OSS_OBJECT_GROUP_IS_NOT_ALLOWED_EMPTY);

  opt := TAliOssOption.Create;
  opt.Values[OSS_BUCKET] := bucket;
  opt.Values[OSS_METHOD] := OSS_HTTP_POST;
  opt.Values[OSS_OBJECT] := object_group;
  opt.Values[OSS_CONTENT_TYPE] := 'txt/xml';
  opt.Values[OSS_SUB_RESOURCE] := 'group';
  opt.Values[OSS_CONTENT] := self.MakeObjectGroupXml(bucket, object_array);

  result := self.ValidateAndAuth(options, opt);

  opt.Free;
end;

destructor TAliOss.Destroy;
begin
  //release internal reources

  inherited Destroy;
end;

{ TAliOssFileSystem }

function TAliOssFileSystem.ChangeVolumn(const volumn: string): boolean;
begin
  self.current_volumn := volumn;
  result := true;
end;

constructor TAliOssFileSystem.Create(const access_id, access_key, hostname: string; const debug: boolean);
begin
  inherited Create;

  self.current_volumn := '';
  self.oss := TAliOss.Create(access_id, access_key);
  if hostname <> '' then
    self.oss.SetHostname(hostname);
  self.oss.SetDebugMode(debug);
end;

function TAliOssFileSystem.CreateDirectory(const directory: string): boolean;
var
  ret: TAliOssReturnType;
begin
  result := false;

  try
    if self.current_volumn = '' then exit;

    ret := self.oss.CreateObjectDir(self.current_volumn, RemoveRootPrefix(directory));

    if ret.status = 200 then
      result := true;
  except

  end;
end;

function TAliOssFileSystem.CreateVolumn(const volumn: string;
  const permission: TAliOssVolumnPermission): boolean;
var
  ret: TAliOssReturnType;
begin
  result := false;

  try
    if permission = vPrivate then
      ret := self.oss.CreateBucket(volumn, OSS_ACL_TYPE_PRIVATE)
    else if permission = vPublicRead then
      ret := self.oss.CreateBucket(volumn, OSS_ACL_TYPE_PUBLIC_READ)
    else if permission = vPublicReadWrite then
      ret := self.oss.CreateBucket(volumn, OSS_ACL_TYPE_PUBLIC_READ_WRITE);

    if ret.status = 200 then
      result := true;
  except

  end;
end;

destructor TAliOssFileSystem.Destroy;
begin
  //release internal reources
  self.oss.Free;

  inherited Destroy;
end;

function TAliOssFileSystem.DownloadFile(const filename,
  localfile: string): boolean;
var
  content: TStringStream;
begin
  result := false;
  try
    if self.ReadFile(filename, TStream(content)) then
    begin
      //create directory
      ForceDirectories(ExtractFilePath(localfile));
      //save file
      content.SaveToFile(localfile);
      content.Free;

      result := true;
    end;
  except

  end;
end;

function TAliOssFileSystem.FileExists(const filename: string): boolean;
begin
  result := false;

  try
    if self.current_volumn = '' then exit;

    result := self.oss.ObjectExists(self.current_volumn, RemoveRootPrefix(filename));
  except

  end;
end;

function TAliOssFileSystem.GetVolumnPermission(const volumn: string;
  var permission: TAliOssVolumnPermission): boolean;
var
  ret: TAliOssReturnType;
  xml: IXMLDocument;
  grant: string;
begin
  result := false;

  try
    if self.current_volumn = '' then exit;

    ret := self.oss.GetBucketACL(self.current_volumn);

    if ret.status = 200 then
    begin
      CoInitialize(nil);
      begin
        xml := NewXMLDocument;
        xml.LoadFromXML(ret.body.DataString);

        grant :=
          xml.ChildNodes.FindNode('AccessControlPolicy').ChildNodes.FindNode('AccessControlList').ChildNodes.FindNode('Grant').Text;
        if grant = OSS_ACL_TYPE_PRIVATE then
        begin
          permission := vPrivate;
          result := true;
        end
        else if grant = OSS_ACL_TYPE_PUBLIC_READ then
        begin
          permission := vPublicRead;
          result := true;
        end
        else if grant = OSS_ACL_TYPE_PUBLIC_READ_WRITE then
        begin
          permission := vPublicReadWrite;
          result := true;
        end
      end;
      CoUninitialize;
    end;
  except

  end;
end;

function TAliOssFileSystem.ListDirectory(const directory: string;
  var files: TAliOssFileInfoList; const dirNames: boolean): boolean;
var
  ansi: AnsiString;
  options: TAliOssOption;
  ret: TAliOssReturnType;
  xml: IXMLDocument;
  contents, node: IXMLNode;
  key, size, modified: String;
  I: Integer;
  dir, newdir: String;
  dirs: TStringList;
  p, len: Integer;
begin
  result := false;

  try
    if self.current_volumn = '' then exit;

    options := TAliOssOption.Create;

    //remove prefix /
    dir := RemoveRootPrefix(directory);

    if copy(dir, length(dir), 1) <> '/' then
      dir := dir + '/';

    //remove non-ASCII characters
    ansi := dir;

    for I := 1 to length(ansi) do
      if Ord(ansi[I]) > 127 then
      begin
        options.Values[OSS_PREFIX] := Copy(dir, 1, I-1);
        break;
      end;

    options.Values[OSS_DELIMITER] := '';
    ret := self.oss.ListObject(self.current_volumn, options);
    options.Free;

    if ret.status = 200 then
    begin
      CoInitialize(nil);
      begin
        xml := NewXMLDocument;

        xml.LoadFromXML(ret.body.DataString);
        contents := xml.ChildNodes.FindNode('ListBucketResult');

        SetLength(files, contents.ChildNodes.Count);
        len := 0;
        dirs := TStringList.Create;

        for I := 0 to contents.ChildNodes.Count - 1 do
        begin
          node := contents.ChildNodes[I];
          if node.NodeName = 'Contents' then
          begin
            key := node.ChildNodes.FindNode('Key').Text;

            if (dir <> '/') and (Copy(key, 1, length(dir)) <> dir) then
              continue;

            if dir <> '/' then
              Delete(key, 1, length(dir));

            if key = '' then
              continue;

            modified := node.ChildNodes.FindNode('LastModified').Text;
            size := node.ChildNodes.FindNode('Size').Text;

            p := Pos('/', key);

            if (p = 0) or (not dirNames) then
            begin
              //file
              files[len].name := key;
              files[len].isDir := false;
              files[len].isFile := true;
              files[len].modified := FullDateTimeDecode(modified); //2012-02-24T02:53:26.000Z
              files[len].size := StrToInt64(size);
              inc(len);
            end
            else
            begin
              newdir := Copy(key, 1, p-1);
              if dirs.IndexOf(newdir) = -1 then
              begin
                //new dir
                files[len].name := newdir;
                files[len].isDir := true;
                files[len].isFile := false;
                files[len].modified := FullDateTimeDecode('1900-01-01T00:00:00.000Z');
                files[len].size := 0;
                inc(len);

                dirs.Add(newdir);
              end;
            end;
          end;
        end;
        dirs.Free;
        SetLength(files, len);
      end;
      CoUninitialize;

      result := true;
    end;
  except

  end;
end;

function TAliOssFileSystem.ListVolumns(var volumns: TAliOssVolumnInfoList): boolean;
var
  ret: TAliOssReturnType;
  xml: IXMLDocument;
  buckets: IXMLNode;
  bucket, created: String;
  I: Integer;
begin
  result := false;

  try
    ret := oss.ListBucket;
    if ret.status = 200 then
    begin
      CoInitialize(nil);
      begin
        xml := NewXMLDocument;
        xml.LoadFromXML(ret.body.DataString);
        buckets := xml.ChildNodes.FindNode('ListAllMyBucketsResult').ChildNodes.FindNode('Buckets');

        SetLength(volumns, buckets.ChildNodes.Count);
        for I := 0 to buckets.ChildNodes.Count - 1 do
        begin
          bucket := buckets.ChildNodes[I].ChildNodes.FindNode('Name').Text;
          created := buckets.ChildNodes[I].ChildNodes.FindNode('CreationDate').Text;
          volumns[I].name := bucket;
          volumns[I].created := FullDateTimeDecode(created); //2012-02-24T02:53:26.000Z
        end;
      end;
      CoUninitialize;

      result := true;
    end;
  except

  end;
end;

function TAliOssFileSystem.RenameFile(const src, dest: string): boolean;
var
  ret: TAliOssReturnType;
  localfile: string;
begin
  result := false;

  try
    if self.current_volumn = '' then exit;

    if PureASCIIString(src) then
    begin
      //the simple way: copy-delete
      //copy file to dest
      ret := self.oss.CopyObject(self.current_volumn, RemoveRootPrefix(src), self.current_volumn, RemoveRootPrefix(dest));

      if ret.status = 200 then
      begin
        //remove src
        result := self.RemoveFile(src);
      end;
    end
    else
    begin
      //the hard way: download-upload-delete
      localfile := StringReplace(src, '/', '\', [rfReplaceAll]);
      localfile := GetTempDirectory + ExtractFilename(localfile);

      if self.DownloadFile(src, localfile) then
      begin
        if self.UploadFile(localfile, dest) then
        begin
          result := self.RemoveFile(src);
        end;
      end;
    end;

  except

  end;
end;

function TAliOssFileSystem.ReadFile(const filename: string;
  var content: TStream): boolean;
var
  ret: TAliOssReturnType;
begin
  result := false;

  try
    if self.current_volumn = '' then exit;

    ret := self.oss.GetObject(self.current_volumn, RemoveRootPrefix(filename));
    if ret.status = 200 then
    begin
      TStringStream(content) := ret.body;

      result := true;
    end;
  except

  end;
end;

function TAliOssFileSystem.ReadFile(const filename: string;
  var content: string): boolean;
var
  Stream: TStringStream;
begin
  result := false;

  try
    if self.ReadFile(filename, TStream(Stream)) then
    begin
      content := Stream.DataString;
      Stream.Free;

      result := true;
    end;
  except

  end;
end;

// remove directory and all files in it
function TAliOssFileSystem.RemoveDirectory(const directory: string): boolean;
var
  dir: string;
  ret: TAliOssReturnType;
  files: TAliOssFileInfoList;
  filenames: TStringList;
  I: Integer;
  options: TAliOssOption;
begin
  result := false;

  try
    if self.current_volumn = '' then exit;
    if Copy(directory, length(directory), 1) <> '/' then
      dir := directory + '/'
    else
      dir := directory;

    //list files
    self.ListDirectory(dir, files);

    if Length(files) <> 0 then
    begin
      options := TAliOssOption.Create;
      options.Values['quiet'] := 'true';

      filenames := TStringList.Create;
      for I := Low(files) to High(files) do
        filenames.Add(files[I].name);
      ret := self.oss.DeleteObjects(self.current_volumn, filenames, options);

      options.Free;
      filenames.Free;
    end;

    //may have a object with the directory name
    self.RemoveFile(dir);

    result := true;
  except

  end;
end;

function TAliOssFileSystem.RemoveFile(const filename: string): boolean;
var
  ret: TAliOssReturnType;
begin
  result := false;

  try
    if self.current_volumn = '' then exit;

    ret := self.oss.DeleteObject(self.current_volumn, RemoveRootPrefix(filename));

    if ret.status = 204 then
      result := true;
  except

  end;
end;

function TAliOssFileSystem.RemoveVolumn(const volumn: string; const force: boolean): boolean;
var
  old_volumn: string;
  ret: TAliOssReturnType;
  files: TAliOssFileInfoList;
  filenames: TStringList;
  I: Integer;
  options: TAliOssOption;
begin
  result := false;

  try
    if volumn = '' then exit;
    old_volumn := self.current_volumn;
    self.ChangeVolumn(volumn);

    //list files
    self.ListDirectory('', files);

    self.ChangeVolumn(old_volumn);

    //delete files
    if Length(files) <> 0 then
    begin
      options := TAliOssOption.Create;
      options.Values['quiet'] := 'true';

      filenames := TStringList.Create;
      for I := Low(files) to High(files) do
        filenames.Add(files[I].name);
      self.oss.DeleteObjects(self.current_volumn, filenames, options);

      options.Free;
      filenames.Free;
    end;

    //delete volumn
    ret := self.oss.DeleteBucket(volumn);

    if ret.status = 200 then
      result := true;
  except

  end;
end;

function TAliOssFileSystem.WriteFile(const filename: string;
  const content: TStream; const append: boolean): boolean;
begin
  result := self.WriteFile(filename, TStringStream(content).DataString, append);
end;

function TAliOssFileSystem.WriteFile(const filename, content: string;
  const append: boolean): boolean;
var
  options: TAliOssOption;
  ret: TAliOssReturnType;
begin
  result := false;

  try
    if self.current_volumn = '' then exit;

    options := TAliOssOption.Create;
    options.Values[OSS_CONTENT] := content;

    ret := self.oss.UploadFileByContent(self.current_volumn, RemoveRootPrefix(filename), options);

    options.Free;

    if ret.status = 200 then
      result := true;
  except

  end;
end;
function TAliOssFileSystem.SetVolumnPermission(const volumn: string;
  const permission: TAliOssVolumnPermission): boolean;
var
  ret: TAliOssReturnType;
begin
  result := false;

  try
    if self.current_volumn = '' then exit;

    if permission = vPrivate then
      ret := self.oss.SetBucketACL(volumn, OSS_ACL_TYPE_PRIVATE)
    else if permission = vPublicRead then
      ret := self.oss.SetBucketACL(volumn, OSS_ACL_TYPE_PUBLIC_READ)
    else if permission = vPublicReadWrite then
      ret := self.oss.SetBucketACL(volumn, OSS_ACL_TYPE_PUBLIC_READ_WRITE);

    if ret.status = 200 then
      result := true;
  except

  end;
end;

function TAliOssFileSystem.UploadFile(const localfile,
  filename: string): boolean;
var
  ret: TAliOssReturnType;
begin
  result := false;

  try
    if self.current_volumn = '' then exit;

    //upload by multipart
    ret := self.oss.UploadFileByMultipart(self.current_volumn, RemoveRootPrefix(filename), localfile);
    if ret.status = 200 then
      result := true;
  except

  end;
end;

function TAliOssFileSystem.Validate: boolean;
var
  ret: TAliOssReturnType;
begin
  result := false;

  try
    ret := self.oss.ListBucket;

    if ret.status = 200 then
      result := true;
  except

  end;
end;

end.
