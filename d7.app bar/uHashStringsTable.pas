{***************************************************************
 *
 * Unit Name: uHashStringsTable
 * Purpose  : simple string hashed table implementation
 * Author   : Stanisav Segal
 * History  :

  09/01/2019  sts                                           created
 *
 ****************************************************************}


unit uHashStringsTable;

interface

uses
   Classes, SysUtils;

type
  TSHTForEachStringEvent = procedure(const aStr: string) of object;
  // interface declarations
  IStringsHashTable = interface(IUnknown)
    ['{4269e99c-27ec-4eb6-939c-8343000954c8}']
    procedure Clear;
    procedure SetAllowDuplicates(const aValue: Boolean);
    function Add(const aStr: string): Boolean;
    procedure ForEach(aAction: TSHTForEachStringEvent);
    function Contains(const aStr: string): Boolean;
    function Remove(const aStr: string): Boolean;
    function CountOf(const aStr: string): integer;
    function StringToHash(const aStr: string): integer;
    function GetAllowDuplicates: Boolean;
    function GetStoredItems: integer;
    function GetLongestHash: integer;
    property AllowDuplicates: Boolean read GetAllowDuplicates   write SetAllowDuplicates;
    property StoredItems: integer     read GetStoredItems;
    property LongestHash: integer     read GetlongestHash;
  end;
   // exception declarations
  EStringsHashException = class(Exception);

  // interface declarations
  function GetStringHashTableIntf: IStringsHashTable;

implementation

uses
 dialogs;

type
  PHashHeaderItem = ^THashHeaderItem;
  THashHeaderItem = record
    ItemsCount: integer;
    HashedItems: TStringList;
  end;

  TStringsHashTable = class(TInterfacedObject, IStringsHashTable)
  private
    fData: array[0..523] of THashHeaderItem;
    fAllowDuplicates: Boolean;
    fCaseSensitive: Boolean;
    procedure SetAllowDuplicates(const aValue: Boolean);
    function IncrementCounter(const aStr: string): Boolean;
    function InsertNewString(const aStr: string): boolean;
    function GetAllowDuplicates: Boolean;
    function GetStoredItems: integer;
    function GetLongestHash: integer;
  public
    constructor Create;
    destructor Destroy;             override;
    procedure Clear;
    procedure ForEach(aAction: TSHTForEachStringEvent);
    function Add(const aStr: string): Boolean;
    function Contains(const aStr: string): Boolean;
    function Remove(const aStr: string): Boolean;
    function CountOf(const aStr: string): integer;
    function StringToHash(const aStr: string): integer;
    property AllowDuplicates: Boolean read GetAllowDuplicates   Write SetAllowDuplicates;
    property StoredItems: integer     read GetStoredItems;
    property LongestHash: integer     read GetlongestHash;
  end;

{*****************************************************************************
 TStringsHashTable  class:
******************************************************************************}

/// TStringsHashTable.Create
/// parameters: none
/// result: new hash table objct
/// purpose: create an empty hash table
///
constructor TStringsHashTable.Create;
begin
  inherited;
  fAllowDuplicates := false;
  fCaseSensitive := False;
  Clear;
end;

/// TStringsHashTable.Destroy
/// parameters: none
/// result: none
/// purpose: destory all memory objects and relased used memory
///
destructor TStringsHashTable.Destroy;
begin
  Clear;
  inherited;
end;

/// TStringsHashTable.ForEach
/// parameters: aValue: TSHTForEachStringEvent -> pointer to procedure
/// result: none
/// purpose: execute given method for each string in string hashTable
///
procedure TStringsHashTable.ForEach(aAction: TSHTForEachStringEvent);
var
  i: integer;
  j: integer;
  str: string;
begin
  if Assigned(aAction) then
    for i:= Low(fData) to High(fData) do
    begin
       if fData[i].HashedItems <> nil then
       for J := 0 to fData[i].HashedItems.Count - 1 do
       begin
         aAction(fData[i].HashedItems.Strings[j]);
       end;
    end;
end;

/// TStringsHashTable.SetAllowDuplicates
/// parameters: aValue -> boolean:  property setter
/// result: none
/// purpose: allow add duplicates (increment/decrement item's counter)
///
procedure TStringsHashTable.SetAllowDuplicates(const aValue: Boolean);
begin
  fAllowDuplicates := aValue;
end;

/// TStringsHashTable.GetAllowDuplicated
/// parameters: none
/// result: boolean (property getter)
/// purpose: get current state of preporty AllowDuplicates
///
function TStringsHashTable.GetAllowDuplicates: Boolean;
begin
  Result := fAllowDuplicates;
end;

/// TStringsHashTable.Clear
/// parameters: none;
/// result: none;
/// purpose: clear content of hashtable; zero all counters
///
procedure TStringsHashTable.Clear;
var
  i: integer;
begin
  for i := 0 to High(fData) do
  begin
    fData[i].ItemsCount := 0;
    if Assigned(fData[i].HashedItems) then
    begin
      fData[i].HashedItems.Clear;
      fData[i].HashedItems.Free;
      fData[i].HashedItems := nil;
    end;
  end;
end;

/// TStringsHashTable.Add
/// parameters: aStr: string
/// result: boolean , true if string added successfuly, if = false does not
/// purpose: if not exist in hashtable add item,
///          otherwise if DoAllowDuplicates = true then increment item's counter
//           or do nothing
///
function TStringsHashTable.Add(const aStr: string): boolean;
begin
  result := false;
  if Contains(aStr) then
  begin
    if AllowDuplicates then
      result := IncrementCounter(aStr);
  end
  else
    result := InsertNewString(aStr);
end;

/// TStringsHashTable.Contain
/// parameters: aStr: string -> a string, to check
/// result: boolean
/// purpose: check if given string exist in hashtable (true if exist, false if does not)
///
function TStringsHashTable.Contains(const aStr: string): Boolean;
var
  hCode: integer;
begin
  hCode := StringToHash(aStr);
  Result := fData[hCode].ItemsCount > 0;
  if Result then
   Result := fData[hCode].HashedItems.IndexOf(aStr) > -1;
end;

/// TStringsHashTable.Remove
/// parameters: aStr: string to remove from hashtable
/// result: boolean -> operation result
/// purpose: remove given string from hashtable; if AllowDuplicates = true decrement counters
///          otherwice (or counter = 0) remove item from hashtable
///
function TStringsHashTable.Remove(const aStr: string): Boolean;
var
  hCode: integer;
  ind: integer;
  cnt: integer;
  doDelete: Boolean;
begin
  result := False;
  doDelete := False;
  //get hash code and search it in list
  hCode := StringToHash(aStr);
  if fData[hCode].ItemsCount > 0 then
  begin
    ind := fData[hCode].HashedItems.IndexOf(aStr);
    if fAllowDuplicates then
    begin
      cnt := integer(fData[hCode].HashedItems.Objects[ind]);
      // if last - mark to delete othrewice decrement counter;
      doDelete := cnt = 1;
      if not doDelete then
        fData[hCode].HashedItems.Objects[ind] := Pointer(cnt - 1);
    end;
    if doDelete or (not AllowDuplicates) then
    begin
      fData[hCode].HashedItems.Delete(ind);
      fData[hCode].ItemsCount := fData[hCode].ItemsCount - 1;
    end;
    fData[hCode].ItemsCount := fData[hCode].ItemsCount - 1;
    Result := True;
  end;
end;

/// TStringsHashTable.CountOf
/// parameters: aStr -> string: return count of given string
/// result: integer
/// purpose: return how many times given string added to hashtable
///          ((if AllowDuplicates = false then result will be 1 or 0)
///
function TStringsHashTable.CountOf(const aStr: string): integer;
var
  hCode: integer;
  ind: integer;
begin
  result := 0;
  //get hash code and search it in list
  hCode := StringToHash(aStr);
  if fData[hCode].ItemsCount > 0 then
  begin
    ind := fData[hCode].HashedItems.IndexOf(aStr);
    if ind > 0 then
     Result := integer(fData[hCode].HashedItems.Objects[ind]);
  end;
end;

/// TStringsHashTable.StringToHash
/// parameters: aStr: string - string to hash
/// result: integer  calculated hashcode
/// purpose: calculate hashcode of given string
///
function TStringsHashTable.StringToHash(const aStr: string): integer;
var
  i: integer;
begin
  Result := 0;
  for i := 1 to length(aStr) do
    Result := Result  + Ord(astr[i]);
  Result := Result mod 523;
end;

/// TStringsHashTable.GetStoredItems
/// parameters: none
/// result: integer
/// purpose: get amount of uniqe items stored in string hash table
///
function TStringsHashTable.GetStoredItems: integer;
var
  i: integer;
begin
  result := 0;
  for i := 0 to High(fData) do
    if fData[i].HashedItems <> nil then
      result := result + fData[i].HashedItems.Count;
end;

/// TStringsHashTable.GetLongestHash
/// parameters: none
/// result: integer
/// purpose: get bigest count of items belongs to one hash code
///
function TStringsHashTable.GetLongestHash: integer;
var
  i: integer;
begin
  result := 0;
  for i := 0 to High(fData) do
    if fData[i].HashedItems <> nil then
      if fData[i].HashedItems.Count > Result then
      result := fData[i].HashedItems.Count;
end;

/// TStringsHashTable.IncrementCounter
/// parameters: aStr: string
/// result: boolean; true if counter of string in hashTable was successfuly increased
/// purpose: increase by 1 amount of string duplicates stored in hashtable
///
function TStringsHashTable.IncrementCounter(const aStr: string): Boolean;
var
  hCode: integer;
  ind: integer;
  cnt: integer;
begin
  result := false;
  hCode := StringToHash(aStr);
  ind := fData[hCode].HashedItems.IndexOf(aStr);
  if ind > -1 then
  begin
    cnt := integer(fData[hCode].HashedItems.Objects[ind]);
    fData[hCode].HashedItems.Objects[ind] := Pointer(cnt + 1);
    fData[hCode].ItemsCount := fData[hCode].ItemsCount + 1;
    Result := True;
  end;
end;

/// TStringsHashTable.InsertNewString
/// parameters: aStr: string to add to hash Table
/// result: boolean
/// purpose: add new, not hashed, string to stringHashTable
///
function TStringsHashTable.InsertNewString(const aStr: string): boolean;
var
  hCode: integer;
begin
  result := False;
  hCode := StringToHash(aStr);
  if fData[hCode].HashedItems = nil then
    fData[hCode].HashedItems := TStringList.Create;
  if fData[hCode].HashedItems.IndexOf(aStr) = -1 then
  begin
    fData[hCode].HashedItems.AddObject(aStr, Pointer(1));
    fData[hCode].ItemsCount := fData[hCode].ItemsCount + 1;
    Result := True;
  end;
end;

{*****************************************************************************
 unit interface
******************************************************************************}
/// GetStringHashTableIntf
/// parameters: none
/// result: IStringsHashTable -> interface pointer to TStringHashTable object
/// purpose: hide class TStringHashTable from class customers;
///          interface object will be released by reference counter mechanism,
///          so you do not need create/destroy real TStringHashTable object
///
function GetStringHashTableIntf: IStringsHashTable;
begin
  Result := TStringsHashTable.Create; 
end;

end.
