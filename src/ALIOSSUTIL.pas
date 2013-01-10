unit ALIOSSUTIL;

{
  OSS (Open Storage Services) Delphi SDK v1.0.0 - Utilities

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

uses IdCoderMIME, IdHashMessageDigest, IdHMACSHA1, SysUtils, Classes, XMLIntf, XMLDoc;

const
  LOG_FILE = 'log.txt';

//Date Utilities
function GMDate(dummy: string): string;
function FullDateTimeDecode(date: string): TDateTime;

//Encryption Utilities
function Base64Encode(const Input: TBytes): string; overload;
function HexBase64Encode(const Input: string): string;
function MD5(const Input: String): String;
function EncryptHMACSha1(const Input,AKey:AnsiString): TBytes;

//Log Utilities
procedure LogFile(const log: String);

//OS Utilities
function GetOSVersion: string;
function GetFilesInDirectory(const path: PChar;vFileList:TStrings; const recursive: boolean; const exclude: string = '.|..|'): Longint; stdcall;
function GetTempDirectory: string;

//String Utilities
function LastPos(const SubStr, S: string): Integer;
function HTMLEscape(const S: string): string;
function FormatXml(const xml: IXMLDocument): string;
function RemoveRootPrefix(const S: string): string;
function PureASCIIString(const S: string): boolean;

implementation

uses SysConst, Windows;

const
  DefShortDayNames: array[1..7] of string = (SShortDayNameSun,
    SShortDayNameMon, SShortDayNameTue, SShortDayNameWed,
    SShortDayNameThu, SShortDayNameFri, SShortDayNameSat);

  DefShortMonthNames: array[1..12] of string = (SShortMonthNameJan,
    SShortMonthNameFeb, SShortMonthNameMar, SShortMonthNameApr,
    SShortMonthNameMay, SShortMonthNameJun, SShortMonthNameJul,
    SShortMonthNameAug, SShortMonthNameSep, SShortMonthNameOct,
    SShortMonthNameNov, SShortMonthNameDec);

var
  vOldShortDayNames: array[1..7] of string;
  vOldShortMonthNames: array[1..12] of string;

procedure SaveDateSettings;
var
  i: integer;
begin
  for I := 1 to 7 do
  begin
    vOldShortDayNames[I] := FormatSettings.ShortDayNames[I];
    FormatSettings.ShortDayNames[I] := DefShortDayNames[I];
  end;
  for I := 1 to 12 do
  begin
    vOldShortMonthNames[I] := FormatSettings.ShortMonthNames[I];
    FormatSettings.ShortMonthNames[I] := DefShortMonthNames[I];
  end;
end;

procedure RestoreDateSettings;
var
  i: integer;
begin
  for I := 1 to 7 do
    FormatSettings.ShortDayNames[I] := vOldShortDayNames[I];
  for I := 1 to 12 do
    FormatSettings.ShortMonthNames[I] := vOldShortMonthNames[I];
end;

function GMDate(dummy: string): string;
var
  system_datetime: TSystemTime;
  gmt: TDateTime;
begin
  //ignore parameter, just return current time
  //D, d M Y H:i:s GMT

  GetSystemTime(system_datetime);
  gmt := SystemTimeToDateTime(system_datetime);

  SaveDateSettings;
  result := FormatDateTime('ddd, dd mmm yyyy hh:nn:ss "GMT"', gmt);
  RestoreDateSettings;
end;

function FullDateTimeDecode(date: string): TDateTime;
var
  oldDateSeparator: char;
begin
  oldDateSeparator := FormatSettings.DateSeparator;
  FormatSettings.DateSeparator := '-';
  result := StrToDateTime(date); //2012-02-24T02:53:26.000Z
  FormatSettings.DateSeparator := oldDateSeparator;
end;

function MD5(const Input: String): String;
var
  md5: TIdHashMessageDigest5; //md5 engine
begin
  //initialize md5 engine
  md5 := TIdHashMessageDigest5.Create;

  Result := md5.HashStringAsHex(Input);

  md5.Destroy;
end;

function EncryptHMACSha1(const Input, AKey:AnsiString): TBytes;
var
  Key: TBytes;
begin
  with TIdHMACSHA1.Create do
  try
    Key := BytesOf(AKey);
    Result := HashValue(BytesOf(Input));
  finally
    Free;
  end;
end;

function Base64Encode(const Input: TBytes): string;
begin
  Result := TIdEncoderMIME.EncodeBytes(Input);
end;

function HexBase64Encode(const Input: string): string;
var
  I: integer;
  h: Byte;
  bytes: TBytes;
begin
  setlength(bytes, length(Input) div 2);
  for I := 1 to length(Input) div 2 do
  begin
    h := StrToInt('$'+copy(Input, i*2-1, 2));
    bytes[i-1] := h;
  end;
  Result := Base64Encode(bytes);
end;

procedure LogFile(const log: String);
var
  f: TextFile;
begin
  AssignFile(f, LOG_FILE);
  if FileExists(LOG_FILE) then
    Append(f)
  else
    ReWrite(f);

  Writeln(f, log);
  CloseFile(f);
end;

function GetOSVersion: string;
Var
  OSVI:OSVERSIONINFO;
begin
  OSVI.dwOSversioninfoSize:=Sizeof(OSVERSIONINFO);
  GetVersionEx(OSVI);
  result := 'Windows NT ' + IntToStr(OSVI.dwMajorVersion)+'.'+IntToStr(OSVI.dwMinorVersion);
end;

function LastPos(const SubStr, S: string): Integer;
var
  Found, Len, Pos: integer;
begin
  Pos := Length(S);
  Len := Length(SubStr);
  Found := 0;
  while (Pos > 0) and (Found = 0) do
  begin
    if Copy(S, Pos, Len) = SubStr then
      Found := Pos;
    Dec(Pos);
  end;
  LastPos := Found;
end;

function GetFilesInDirectory(const path: PChar;vFileList:TStrings; const recursive: boolean; const exclude: string): Longint; stdcall;
var
  searchRec: TSearchRec;
  found: Integer;
  tmpStr: string;
begin
  tmpStr := StrPas(path) + '\*.*';

  found := FindFirst(tmpStr, faAnyFile, searchRec);
  while found = 0 do
  begin
    if Pos('|'+searchRec.Name+'|', '|'+exclude+'|') <> 0 then
    begin
      found := FindNext(searchRec);
      continue;
    end;

    if (searchRec.Attr and faDirectory) <> 0 then
    begin
      if (searchRec.Name <> '.') and (searchRec.Name <> '..') then
      begin
        tmpStr := StrPas(path) + '\' + searchRec.Name;
        if recursive then
          Result := Result + GetFilesInDirectory(PChar(tmpStr),vFileList, recursive, exclude); //recursive invoke
      end;
    end
    else begin
      Result := Result + 1;
      //append files
      vFileList.Add(StrPas(path) + '\' + searchRec.Name);
    end;
    found := FindNext(searchRec);
  end;
  SysUtils.FindClose(searchRec);
end;

function GetTempDirectory: string;
var
  arr: array[0..MAX_PATH] of Char;
  num: DWORD;
begin
  num := GetTempPath(MAX_PATH, arr);
  result := arr;
end;

function HTMLEscape(const S: string): string;
const
  search: array[1..5] of string =  ('<', '>', '&', '''', '"');
  replace: array[1..5] of string = ('&lt;','&gt;','&amp;','&apos;','&quot;');
var
  I: integer;
begin
  result := S;
  for I := Low(search) to High(search) do
  begin
    result := StringReplace(result, search[i], replace[i], [rfReplaceAll]);
  end;
end;

function FormatXml(const xml: IXMLDocument): string;
begin
  //bug fix: force to add encoding attribute
  result := StringReplace(xml.XML.Text, '?>', ' encoding="utf-8"?>', [rfReplaceAll]);
end;

function RemoveRootPrefix(const S: string): string;
begin
  if Copy(S, 1, 1) = '/' then
    result := Copy(S, 2, MaxInt)
  else
    result := S;
end;

function PureASCIIString(const S: string): boolean;
var
  temp: AnsiString;
begin
  temp := S;

  result := length(s) = length(temp);
end;

end.
