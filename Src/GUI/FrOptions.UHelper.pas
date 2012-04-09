unit FrOptions.UHelper;

interface

uses
  Classes, Generics.Collections;

type
  TValueMap = class(TObject)
  strict private
    fValues: TList<TPair<string,string>>;
  public
    constructor Create;
    destructor Destroy; override;
    procedure Add(const Desc, Value: string);
    procedure GetDescriptions(const List: TStrings);
    function GetDescFromValue(const Value: string): string;
    function IndexOfValue(const Value: string): Integer;
    function ValueByIndex(const Idx: Integer): string;
  end;

type
  TBooleanLookup = class(TObject)
  strict private
    class var
      fFalseStrValues: TList<string>;
  public
    class constructor Create;
    class destructor Destroy;
    class function ToBoolean(const Value: string): Boolean;
    class function ToString(const Value: Boolean): string; reintroduce;
  end;

implementation

uses
  SysUtils;

{ TValueMap }

procedure TValueMap.Add(const Desc, Value: string);
begin
  fValues.Add(TPair<string,string>.Create(Desc, Value));
end;

constructor TValueMap.Create;
begin
  inherited Create;
  fValues := TList<TPair<string,string>>.Create;
end;

destructor TValueMap.Destroy;
begin
  fValues.Free;
  inherited;
end;

function TValueMap.GetDescFromValue(const Value: string): string;
var
  Idx: Integer;
  Item: TPair<string,string>;
begin
  Result := '';
  for Idx := 0 to Pred(fValues.Count) do
  begin
    Item := fValues[Idx];
    if SameText(Value, Item.Value) then
      Exit(Item.Key);
  end;
end;

procedure TValueMap.GetDescriptions(const List: TStrings);
var
  Item: TPair<string,string>;
begin
  List.Clear;
  for Item in fValues do
    List.Add(Item.Key);
end;

function TValueMap.IndexOfValue(const Value: string): Integer;
var
  Idx: Integer;
begin
  Result := -1;
  for Idx := 0 to Pred(fValues.Count) do
    if SameText(Value, fValues[Idx].Value) then
      Exit(Idx);
end;

function TValueMap.ValueByIndex(const Idx: Integer): string;
begin
  Result := fValues[Idx].Value;
end;

{ TBooleanLookup }

class constructor TBooleanLookup.Create;
begin
  fFalseStrValues := TList<string>.Create;
  fFalseStrValues.Add('off');
  fFalseStrValues.Add('0');
  fFalseStrValues.Add('false');
  fFalseStrValues.Add('no');
  fFalseStrValues.Add('n');
end;

class destructor TBooleanLookup.Destroy;
begin
  fFalseStrValues.Free;
end;

class function TBooleanLookup.ToBoolean(const Value: string): Boolean;
begin
  Result := not fFalseStrValues.Contains(LowerCase(Value));
end;

class function TBooleanLookup.ToString(const Value: Boolean): string;
const
  BoolStrings: array[Boolean] of string = ('off', 'on');
begin
  Result := BoolStrings[Value];
end;

end.
