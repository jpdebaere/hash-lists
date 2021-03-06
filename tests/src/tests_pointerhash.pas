unit tests_pointerhash;

{$mode objfpc}{$H+}
{$IFOPT D+}
  {$NOTE debug mode is active}
{$ELSE}
  {$DEFINE speedtests}
{$ENDIF}


interface

uses
  TestFramework
  {$IFDEF speedtests}
  , Generics.Collections
  {$ENDIF}
  , pointerhash;

type
  {$IFDEF speedtests}
  TPMap = Specialize TFastHashMap<String, Pointer>;
  {$ENDIF}
  TTestsPointerHashList = class(TTestCase)
  protected
    {$IFDEF speedtests}
    mpobjs: TPMap;
    {$ENDIF}
    lsthshobjs: TPLPointerHashList;
    //Allover defined Execution Time Limit for 1000 Insertions
    finsertlimit1000: Single;
    //Allover defined Execution Time Limit for 1000 Lookups
    flookuplimit1000: Single;
    //Allover defined Execution Time Limit for 5000 Insertions
    finsertlimit5000: Single;
    //Allover defined Execution Time Limit for 5000 Lookups
    flookuplimit5000: Single;
    procedure SetUp; override;
    procedure Teardown; override;
  published
    (*
    Test Adding 10 Keys and their Values with the Add()-Method (which should grow the List at least once)
    And Looking up their Values (they must match their inserted Values)
    *)
    procedure TestAddCheckElements;
    (*
    Test Adding 3 Keys and their Values with the Add()-Method
    Adding the 4th Value on a duplicate Key.
    The "dupAccept" Bahaviour is enabled which should override the existing Value
    *)
    procedure TestAddDuplicateAccept;
    (*
    Test Adding 3 Keys and their Values with the Add()-Method
    Adding the 4th Value on a duplicate Key.
    The "dupIgnore" Bahaviour is enabled which should drop the new Value
    *)
    procedure TestAddDuplicateIgnore;
    (*
    Test Adding 3 Keys and their Values with the Add()-Method
    Adding the 4th Value on a duplicate Key.
    The "dupError" Bahaviour is enabled which should raise an Exception
    *)
    procedure TestAddDuplicateError;
    (*
    Test Adding 10 Keys and their Values with the setValue()-Method (which should grow the List at least once)
    And Looking up their Values (they must match their inserted Values)
    *)
    procedure TestInsertCheckElements;
    (*
    Test Adding 3 Keys and their Values for a valid List Test
    And Iterating to the First Key (this is not necessary the first inserted key)
    It should return the defined Key and its Value
    *)
    procedure TestCheckFirstElement;
    (*
    Test Adding 3 Keys and their Values for a valid List Test
    And Iterating to the First Key and to the Next Key (they are not necessary
    the first and second inserted keys)
    It should return the defined Keys and their Values
    *)
    procedure TestCheckNextElement;
    (*
    Integrity Test. Inserting 10000 Elements and looking up their Values.
    This Test will grow the List several times.
    Even big Lists must not break or loose memory.
    *)
    procedure TestInsertCheck10000Elements;
    (*
    Clear Function Test. Inserting 10 Elements and Calling the Clear Method.
    This Test will grow the List once.
    The List must be empty and the Capacity must be reset to the minimum.
    The Memory must be freed correctly. (Values must be freed manually)
    *)
    procedure TestInsertClear;
    {$IFDEF speedtests}
    {$NOTE Speed Tests will be run}
    (*
    Reference Performance Test against the Generics.Collections.TFastHashMap
    Adding 1000 Keys and their Values
    Looking Up all their Values
    It should return the defined Keys and their Values
    *)
    procedure TestMapInsert1000Elements;
    (*
    Reference Performance Test against the Generics.Collections.TFastHashMap
    Adding 1000 Keys and their Values
    Looking Up all their Values
    It should return the defined Keys and their Values
    *)
    procedure TestMapLookup1000Elements;
    procedure TestInsert1000Elements;
    procedure TestLookup1000Elements;
    procedure TestMapInsert5000Elements;
    procedure TestMapLookup5000Elements;
    procedure TestInsert5000Elements;
    procedure TestLookup5000Elements;
    {$ENDIF}
  end;

 procedure RegisterTests;






implementation

uses
  Classes, SysUtils, DateUtils;


{ here we register all our test classes }
procedure RegisterTests;
begin
  TestFramework.RegisterTest(TTestsPointerHashList.Suite);
end;

{
  Allover Test Limits are configured
}
procedure TTestsPointerHashList.SetUp;
begin
  {$IFDEF speedtests}
  Self.mpobjs:= TPMap.Create;
  {$ENDIF}
  lsthshobjs := TPLPointerHashList.Create();

  finsertlimit1000 := 1.1;
  flookuplimit1000 := 1.1;
  finsertlimit5000 := 6.1;
  flookuplimit5000 := 4.1;
end;

{
  Free used Memory
}
procedure TTestsPointerHashList.Teardown;
var
  {$IFDEF speedtests}
  sky: String;
  {$ENDIF}
  psvl: PAnsiString;
begin
  {$IFDEF speedtests}
  for sky in self.mpobjs.Keys do
  begin
    psvl := self.mpobjs[sky];

    if psvl <> nil then
      Dispose(psvl);

  end;  //for sky in self.mpobjs.Keys do

  self.mpobjs.Free;
  {$ENDIF}


  if lsthshobjs.moveFirst then
  begin
    repeat  //until not self.lsthshobjs.moveNext();
      psvl := self.lsthshobjs.getCurrentValue();

      if psvl <> nil then Dispose(psvl);
    until not self.lsthshobjs.moveNext();
  end;  //if self.lsthshobjs.moveFirst then

  FreeAndNil(lsthshobjs);
end;

procedure TTestsPointerHashList.TestAddCheckElements;
var
  psvl: PAnsiString;
begin
  New(psvl);
  psvl^ := 'value1';

  self.lsthshobjs.Add('key1', psvl);

  New(psvl);
  psvl^ := 'value2';

  self.lsthshobjs.Add('key2', psvl);

  New(psvl);
  psvl^ := 'value3';

  self.lsthshobjs.Add('key3', psvl);

  New(psvl);
  psvl^ := 'value4';

  self.lsthshobjs.Add('key4', psvl);

  New(psvl);
  psvl^ := 'value5';

  self.lsthshobjs.Add('key5', psvl);

  New(psvl);
  psvl^ := 'value6';

  self.lsthshobjs.Add('key6', psvl);

  New(psvl);
  psvl^ := 'value7';

  self.lsthshobjs.Add('key7', psvl);

  New(psvl);
  psvl^ := 'value8';

  self.lsthshobjs.Add('key8', psvl);

  New(psvl);
  psvl^ := 'value9';

  self.lsthshobjs.Add('key9', psvl);

  New(psvl);
  psvl^ := 'value10';

  self.lsthshobjs.Add('key10', psvl);

  psvl := self.lsthshobjs['key1'];

  CheckEquals('value1', psvl^, 'LKP - key '  + chr(39) + 'key1' + chr(39)
    + ' failed! Value is: ' + chr(39) + psvl^ + chr(39));

  psvl := self.lsthshobjs['key2'];

  CheckEquals('value2', psvl^, 'LKP - key '  + chr(39) + 'key2' + chr(39)
    + ' failed! Value is: ' + chr(39) + psvl^ + chr(39));

  psvl := self.lsthshobjs['key3'];

  CheckEquals('value3', psvl^, 'LKP - key '  + chr(39) + 'key3' + chr(39)
    + ' failed! Value is: ' + chr(39) + psvl^ + chr(39));

  psvl := self.lsthshobjs['key4'];

  CheckEquals('value4', psvl^, 'LKP - key '  + chr(39) + 'key4' + chr(39)
    + ' failed! Value is: ' + chr(39) + psvl^ + chr(39));

  psvl := self.lsthshobjs['key5'];

  CheckEquals('value5', psvl^, 'LKP - key '  + chr(39) + 'key5' + chr(39)
    + ' failed! Value is: ' + chr(39) + psvl^ + chr(39));

  psvl := self.lsthshobjs['key6'];

  CheckEquals('value6', psvl^, 'LKP - key '  + chr(39) + 'key6' + chr(39)
    + ' failed! Value is: ' + chr(39) + psvl^ + chr(39));

  psvl := self.lsthshobjs['key7'];

  CheckEquals('value7', psvl^, 'LKP - key '  + chr(39) + 'key7' + chr(39)
    + ' failed! Value is: ' + chr(39) + psvl^ + chr(39));

  psvl := self.lsthshobjs['key8'];

  CheckEquals('value8', psvl^, 'LKP - key '  + chr(39) + 'key8' + chr(39)
    + ' failed! Value is: ' + chr(39) + psvl^ + chr(39));

  psvl := self.lsthshobjs['key9'];

  CheckEquals('value9', psvl^, 'LKP - key '  + chr(39) + 'key9' + chr(39)
    + ' failed! Value is: ' + chr(39) + psvl^ + chr(39));

  psvl := self.lsthshobjs['key10'];

  CheckEquals('value10', psvl^, 'LKP - key '  + chr(39) + 'key10' + chr(39)
    + ' failed! Value is: ' + chr(39) + psvl^ + chr(39));

end;

procedure TTestsPointerHashList.TestAddDuplicateAccept;
var
  psinvl, psoutvl: PAnsiString;
begin
  //Set Duplicate Key Behaviour to override
  self.lsthshobjs.Duplicates := dupAccept;

  New(psinvl);
  psinvl^ := 'value1';

  self.lsthshobjs.Add('key1', psinvl);

  New(psinvl);
  psinvl^ := 'value2';

  self.lsthshobjs.Add('key2', psinvl);

  New(psinvl);
  psinvl^ := 'value3';

  self.lsthshobjs.Add('key3', psinvl);

  //Free the old Value "value3"
  psoutvl := self.lsthshobjs['key3'];

  //Override the Value with new Data
  New(psinvl);
  psinvl^ := 'value3.2';

  if self.lsthshobjs.Add('key3', psinvl) then
  begin
    //The new Value was added correctly
    //The old Value must be freed
    Dispose(psoutvl);
  end
  else  //The Value was not added
  begin
    //The new Value was unexpectly rejected
    //The new Value must be freed
    Dispose(psoutvl);

    //This is a faulty Behaviour with "dupAccept"
    Check(False, 'INS - TPLPointerHashList.Add() failed!');
  end;  //if self.lsthshobjs.Add('key3', psinvl) then

  //Should yield the new Value "value3.2"
  psoutvl := self.lsthshobjs['key3'];

  CheckEquals('value3.2', psoutvl^, 'LKP - key '  + chr(39) + 'key3' + chr(39)
    + ' failed! Value is: ' + chr(39) + psoutvl^ + chr(39));

end;

procedure TTestsPointerHashList.TestAddDuplicateIgnore;
var
  psinvl, psoutvl: PAnsiString;
begin
  //Set Duplicate Key Behaviour to drop
  self.lsthshobjs.Duplicates := dupIgnore;

  New(psinvl);
  psinvl^ := 'value1';

  self.lsthshobjs.Add('key1', psinvl);

  New(psinvl);
  psinvl^ := 'value2';

  self.lsthshobjs.Add('key2', psinvl);

  New(psinvl);
  psinvl^ := 'value3';

  self.lsthshobjs.Add('key3', psinvl);

  //Should give the existing Value "value3"
  psoutvl := self.lsthshobjs['key3'];

  //Insert a Value for a duplicate Key
  New(psinvl);
  psinvl^ := 'value3.2';

  if self.lsthshobjs.Add('key3', psinvl) then
  begin
    //The Value was unexpectly added and the former Value must be freed
    Dispose(psoutvl);

    //This is a faulty Behaviour with "dupIgnore"
    Check(False, 'INS - TPLPointerHashList.Add() failed!');
  end
  else  //The Value was not added
  begin
    //Ignored Value needs to be freed because it was not accepted in the List
    Dispose(psinvl);
  end;  //if self.lsthshobjs.Add('key3', psinvl) then

  //Should yield the former Value "value3"
  psoutvl := self.lsthshobjs['key3'];

  CheckEquals('value3', psoutvl^, 'LKP - key '  + chr(39) + 'key3' + chr(39)
    + ' failed! Value is: ' + chr(39) + psoutvl^ + chr(39));

end;

procedure TTestsPointerHashList.TestAddDuplicateError;
var
  psinvl, psoutvl: PAnsiString;
begin
  //Set Duplicate Key Behaviour to Exception
  self.lsthshobjs.Duplicates := dupError;

  New(psinvl);
  psinvl^ := 'value1';

  self.lsthshobjs.Add('key1', psinvl);

  New(psinvl);
  psinvl^ := 'value2';

  self.lsthshobjs.Add('key2', psinvl);

  New(psinvl);
  psinvl^ := 'value3';

  self.lsthshobjs.Add('key3', psinvl);

  //Should give the existing Value "value3"
  psoutvl := self.lsthshobjs['key3'];

  New(psinvl);
  psinvl^ := 'value3.2';

  try
    Self.lsthshobjs.Add('key3', psinvl);
    //This is a faulty Behaviour with "dupError"
    Fail('INS - TPLPointerHashList.Add() failed! Duplicate Key was accepted.');
  except
    on e: DuplicateKeyException do
    begin
      //writeln('Duplicate hash key detected. ' + e.Message);
      Dispose(psinvl);
    end;

    on e: EStringListError do
    begin
      //writeln('A generic EStringListError detected. ' + e.Message);
      Dispose(psinvl);
    end
    else
    begin
      //The rejected Value must be freed
      Dispose(psinvl);
      //This is an unexpected Exception
      Fail('INS - TPLPointerHashList.Add() failed! Unexpected Exception.');
    end;

  end;  //try

  //Should yield the former Value "value3"
  psoutvl := self.lsthshobjs['key3'];

  CheckEquals('value3', psoutvl^, 'LKP - key '  + chr(39) + 'key3' + chr(39)
    + ' failed! Value is: ' + chr(39) + psoutvl^ + chr(39));
end;


procedure TTestsPointerHashList.TestInsertCheckElements;
var
  psvl: PAnsiString;
begin
  New(psvl);
  psvl^ := 'value1';

  self.lsthshobjs.setValue('key1', psvl);

  New(psvl);
  psvl^ := 'value2';

  self.lsthshobjs.setValue('key2', psvl);

  New(psvl);
  psvl^ := 'value3';

  self.lsthshobjs.setValue('key3', psvl);

  New(psvl);
  psvl^ := 'value4';

  self.lsthshobjs.setValue('key4', psvl);

  New(psvl);
  psvl^ := 'value5';

  self.lsthshobjs.setValue('key5', psvl);

  New(psvl);
  psvl^ := 'value6';

  self.lsthshobjs.setValue('key6', psvl);

  New(psvl);
  psvl^ := 'value7';

  self.lsthshobjs.setValue('key7', psvl);

  New(psvl);
  psvl^ := 'value8';

  self.lsthshobjs.setValue('key8', psvl);

  New(psvl);
  psvl^ := 'value9';

  self.lsthshobjs.setValue('key9', psvl);

  New(psvl);
  psvl^ := 'value10';

  self.lsthshobjs.setValue('key10', psvl);

  psvl := self.lsthshobjs.getValue('key1');

  CheckEquals('value1', psvl^, 'LKP - key '  + chr(39) + 'key1' + chr(39)
    + ' failed! Value is: ' + chr(39) + psvl^ + chr(39));

  psvl := self.lsthshobjs.getValue('key2');

  CheckEquals('value2', psvl^, 'LKP - key '  + chr(39) + 'key2' + chr(39)
    + ' failed! Value is: ' + chr(39) + psvl^ + chr(39));

  psvl := self.lsthshobjs.getValue('key3');

  CheckEquals('value3', psvl^, 'LKP - key '  + chr(39) + 'key3' + chr(39)
    + ' failed! Value is: ' + chr(39) + psvl^ + chr(39));

  psvl := self.lsthshobjs.getValue('key4');

  CheckEquals('value4', psvl^, 'LKP - key '  + chr(39) + 'key4' + chr(39)
    + ' failed! Value is: ' + chr(39) + psvl^ + chr(39));

  psvl := self.lsthshobjs.getValue('key5');

  CheckEquals('value5', psvl^, 'LKP - key '  + chr(39) + 'key5' + chr(39)
    + ' failed! Value is: ' + chr(39) + psvl^ + chr(39));

  psvl := self.lsthshobjs.getValue('key6');

  CheckEquals('value6', psvl^, 'LKP - key '  + chr(39) + 'key6' + chr(39)
    + ' failed! Value is: ' + chr(39) + psvl^ + chr(39));

  psvl := self.lsthshobjs.getValue('key7');

  CheckEquals('value7', psvl^, 'LKP - key '  + chr(39) + 'key7' + chr(39)
    + ' failed! Value is: ' + chr(39) + psvl^ + chr(39));

  psvl := self.lsthshobjs.getValue('key8');

  CheckEquals('value8', psvl^, 'LKP - key '  + chr(39) + 'key8' + chr(39)
    + ' failed! Value is: ' + chr(39) + psvl^ + chr(39));

  psvl := self.lsthshobjs.getValue('key9');

  CheckEquals('value9', psvl^, 'LKP - key '  + chr(39) + 'key9' + chr(39)
    + ' failed! Value is: ' + chr(39) + psvl^ + chr(39));

  psvl := self.lsthshobjs.getValue('key10');

  CheckEquals('value10', psvl^, 'LKP - key '  + chr(39) + 'key10' + chr(39)
    + ' failed! Value is: ' + chr(39) + psvl^ + chr(39));

end;

procedure TTestsPointerHashList.TestCheckFirstElement;
var
  sky: String;
  psvl: PAnsiString;
begin
  New(psvl);
  psvl^ := 'first_value';

  self.lsthshobjs.setValue('first_key', psvl);

  New(psvl);
  psvl^ := 'next_value';

  self.lsthshobjs.setValue('next_key', psvl);

  New(psvl);
  psvl^ := 'last_value';

  self.lsthshobjs.setValue('last_key', psvl);

  Check(self.lsthshobjs.moveFirst() = True, 'TPLPointerHashList.moveFirst(): failed!');

  sky := self.lsthshobjs.getCurrentKey();

  CheckEquals('first_key', sky, 'TPLPointerHashList.getCurrentKey(): failed! '
    + 'Returned Key: ' + chr(39) + sky + chr(39));

  psvl := self.lsthshobjs.getCurrentValue();

  CheckEquals('first_value', psvl^, 'TPLPointerHashList.getCurrentValue(): failed! '
    + 'Returned Key: ' + chr(39) + psvl^ + chr(39));

end;

procedure TTestsPointerHashList.TestCheckNextElement;
var
  sky: String;
  psvl: PAnsiString;
begin
  New(psvl);
  psvl^ := 'first_value';

  self.lsthshobjs.setValue('first_key', psvl);

  New(psvl);
  psvl^ := 'next_value';

  self.lsthshobjs.setValue('next_key', psvl);

  New(psvl);
  psvl^ := 'last_value';

  self.lsthshobjs.setValue('last_key', psvl);

  Check(self.lsthshobjs.moveNext() = True, 'TPLPointerHashList.moveNext() No. 1 : failed!');

  sky := self.lsthshobjs.getCurrentKey();

  CheckEquals('first_key', sky, 'TPLPointerHashList.getCurrentKey() No. 1 : failed! '
    + 'Returned Key: ' + chr(39) + sky + chr(39));

  psvl := self.lsthshobjs.getCurrentValue();

  CheckEquals('first_value', psvl^, 'TPLPointerHashList.getCurrentValue() No. 1 : failed! '
    + 'Returned Key: ' + chr(39) + psvl^ + chr(39));

  Check(self.lsthshobjs.moveNext() = True, 'TPLPointerHashList.moveNext() No. 2 : failed!');

  sky := self.lsthshobjs.getCurrentKey();

  CheckEquals('next_key', sky, 'TPLPointerHashList.getCurrentKey() No. 2 : failed! '
    + 'Returned Key: ' + chr(39) + sky + chr(39));

  psvl := self.lsthshobjs.getCurrentValue();

  CheckEquals('next_value', psvl^, 'TPLPointerHashList.getCurrentValue() No. 2 : failed! '
    + 'Returned Key: ' + chr(39) + psvl^ + chr(39));

end;

procedure TTestsPointerHashList.TestInsertCheck10000Elements;
var
  sky, schk: String;
  psvl: PAnsiString;
  iky, imtchcnt: Integer;
begin
  //WriteLn('TTestsPointerHashList.TestInsertCheck10000Elements: go ...');

  imtchcnt := -1;

  self.lsthshobjs.LoadFactor := 4;
  self.lsthshobjs.Capacity := 1000;

  for iky := 1 to 10000 do
  begin
    sky := 'key' + IntToStr(iky);

    New(psvl);
    psvl^ := 'value' + IntToStr(iky);

    self.lsthshobjs.setValue(sky, psvl);
  end;  //for iky := 1 to 10000 do

  CheckEquals(self.lsthshobjs.Count, 10000, 'INS - Count failed! Count is: '#39
     + IntToStr(self.lsthshobjs.Count) + ' / 10000'#39);

  for iky := 1 to 10000 do
  begin
    sky := 'key' + IntToStr(iky);
    schk := 'value' + IntToStr(iky);

    psvl := self.lsthshobjs[sky];

    if psvl <> nil then
    begin
      if psvl^ = schk then
      begin
        if imtchcnt = -1 then
          imtchcnt := 1
        else
          inc(imtchcnt);

      end
      else  //if psvl^ = schk then
        CheckEquals(schk, psvl^, 'LKP - key '  + chr(39) + sky + chr(39)
          + ' failed! Value is: ' + chr(39) + psvl^ + chr(39));

    end
    else  //if psvl <> nil then
      Check(psvl <> nil, 'LKP - key '  + chr(39) + sky + chr(39)
        + ' failed! Value is: ' + chr(39) + 'nil' + chr(39));

  end;  //for iky := 1 to 10000 do

  CheckEquals(imtchcnt, 10000, 'LKP - Count failed! Count is: '#39
       + IntToStr(imtchcnt) + ' / 10000'#39);

end;

procedure TTestsPointerHashList.TestInsertClear;
var
  sky: String;
  psvl: PAnsiString;
  iky, imincap, ikymxcnt, ikyttlcnt: Integer;
begin
  //WriteLn('TTestsPointerHashList.TestInsertClear: go ...');

  ikymxcnt := 10;

  Self.lsthshobjs.LoadFactor := 2;

  //WriteLn('TTestsPointerHashList.TestInsertClear: cap 0: '#39, Self.lsthshobjs.Capacity, #39);

  imincap := Self.lsthshobjs.GrowFactor * Self.lsthshobjs.LoadFactor;

  for iky := 1 to ikymxcnt do
  begin
    sky := 'key' + IntToStr(iky);

    New(psvl);
    psvl^ := 'value' + IntToStr(iky);

    Self.lsthshobjs.setValue(sky, psvl);
  end;  //for iky := 1 to ikymxcnt do

  ikyttlcnt := Self.lsthshobjs.Count;

  CheckEquals(ikymxcnt, ikyttlcnt, 'INS - Count failed! Count is: '#39
     + IntToStr(ikyttlcnt) + ' / ' + IntToStr(ikymxcnt) + #39);

  //WriteLn('TTestsPointerHashList.TestInsertClear: cap 1: '#39, Self.lsthshobjs.Capacity, #39);

  Check(Self.lsthshobjs.moveFirst() = True, 'TPLPointerHashList.moveFirst() : failed!');

  iky := 0;

  repeat  //until not Self.lsthshobjs.moveNext();
    inc(iky);

    sky := Self.lsthshobjs.getCurrentKey();
    psvl := PAnsiString(Self.lsthshobjs.getCurrentValue());

    if psvl <> Nil then
    begin
      CheckNotEquals('', psvl^, 'TPLPointerHashList.getCurrentValue() No. ' + IntToStr(iky) + ' : failed! '
        + 'Returned Value: ' + chr(39) + psvl^ + chr(39));
      Dispose(psvl);

      Self.lsthshobjs[sky] := Nil;
    end
    else
      Check(psvl <> Nil, 'TPLPointerHashList.getCurrentValue() No. ' + IntToStr(iky) + ' : failed! '
        + 'Returned Value: '#39'NIL'#39);

  until not Self.lsthshobjs.moveNext();

  Self.lsthshobjs.Clear();

  ikyttlcnt := Self.lsthshobjs.Count;

  CheckEquals(0, ikyttlcnt, 'DEL - TPLPointerHashList.Clear() failed! Count is: '#39
     + IntToStr(ikyttlcnt) + ' / 0'#39);
  CheckEquals(imincap, Self.lsthshobjs.Capacity, 'DEL - TPLPointerHashList.Clear() failed! Capacity is: '#39
     + IntToStr(Self.lsthshobjs.Capacity) + ' / ' + IntToStr(imincap) + #39);

  //WriteLn('TTestsPointerHashList.TestInsertClear: cap 2: '#39, Self.lsthshobjs.Capacity, #39);

end;


//Speed Test make only sense when the Test is not compiled in Debug Mode
{$IFDEF speedtests}

procedure TTestsPointerHashList.TestMapInsert1000Elements;
var
  sky, schk: String;
  psvl: PAnsiString;
  tmstrt, tmend : TDateTime;
  tmins: Double;
  DT : TDateTime;
  TS: TTimeStamp;
  MS : Comp;
  iky: Integer;
begin
  WriteLn('TestMapInsert1000Elements: go ...');

  TS:=DateTimeToTimeStamp(Now);
  Writeln ('INS - Start - Now in days since 1/1/0001      : ',TS.Date);
  Writeln ('INS - Start - Now in millisecs since midnight : ',TS.Time);
  MS:=TimeStampToMSecs(TS);
  Writeln ('Now in millisecs since 1/1/0001 : ',MS);
  MS:=MS-1000*3600*2;
  TS:=MSecsToTimeStamp(MS);
  DT:=TimeStampToDateTime(TS);
  Writeln ('Now minus 1 day : ',DateTimeToStr(DT));


  tmstrt := Now;

  self.mpobjs.Capacity := 1000;

  for iky := 1 to 1000 do
  begin
    sky := 'key' + IntToStr(iky);

    New(psvl);
    psvl^ := 'value' + IntToStr(iky);

    self.mpobjs.Add(sky, psvl);
  end;  //for iky := 1 to 1000 do

  tmend := Now;
  tmins := MilliSecondSpan(tmend, tmstrt);

  TS:=DateTimeToTimeStamp(Now);
  WriteLn ('INS - End - Now in millisecs since midnight : ',TS.Time);

  WriteLn('INS Operation completed in ', chr(39), FloatToStr(tmins), chr(39), ' ms.');

  Check(tmins < Self.finsertlimit1000, 'INS Operation: Operation slower than '
    + chr(39) + FloatToStr(Self.finsertlimit1000) + chr(39) + ' ms! It took: '
    + chr(39) + FloatToStr(tmins) + chr(39) + ' ms.');


  tmstrt := Now;

  for iky := 1 to 1000 do
  begin
    sky := 'key' + IntToStr(iky);
    schk := 'value' + IntToStr(iky);

    psvl := self.mpobjs[sky];

    if psvl <> nil then
    begin
      if psvl^ <> schk then
        CheckEquals(schk, psvl^, 'LKP - key '  + chr(39) + sky + chr(39)
          + ' failed! Value is: ' + chr(39) + psvl^ + chr(39));

    end
    else  //Value is nil
    begin
      Check(psvl <> nil, 'LKP - key '  + chr(39) + sky + chr(39)
        + ' failed! Value is: ' + chr(39) + 'nil' + chr(39));
    end;  //if psvl <> nil then
  end;  //for iky := 1 to 1000 do

  tmend := Now;
  tmins := MilliSecondSpan(tmend, tmstrt);

  TS:=DateTimeToTimeStamp(Now);
  WriteLn ('LKP - End - Now in millisecs since midnight : ',TS.Time);

  WriteLn('LKP Operation completed in ', chr(39), FloatToStr(tmins), chr(39), ' ms.');

  {
  If the Insert Limit fails this check will not be reached
  Check(tmins < Self.flookuplimit1000, 'LKP Operation: Operation slower than '
    + chr(39) + FloatToStr(Self.flookuplimit1000) + chr(39) + ' ms! It took: '
    + chr(39) + FloatToStr(tmins) + chr(39) + ' ms.');
    }
end;

procedure TTestsPointerHashList.TestMapLookup1000Elements;
var
  sky, schk: String;
  psvl: PAnsiString;
  tmstrt, tmend : TDateTime;
  tmins: Double;
  TS: TTimeStamp;
  iky: Integer;
begin
  WriteLn('TestMapLookup1000Elements: do ...');

  TS:=DateTimeToTimeStamp(Now);
  Writeln ('INS - Start - Now in millisecs since midnight : ',TS.Time);


  tmstrt := Now;

  for iky := 1 to 1000 do
  begin
    sky := 'key' + IntToStr(iky);

    New(psvl);
    psvl^ := 'value' + IntToStr(iky);

    self.mpobjs.Add(sky, psvl);
  end;  //for iky := 1 to 1000 do

  tmend := Now;
  tmins := MilliSecondSpan(tmend, tmstrt);

  TS:=DateTimeToTimeStamp(Now);
  WriteLn ('INS - End - Now in millisecs since midnight : ',TS.Time);

  WriteLn('INS Operation completed in ', chr(39), FloatToStr(tmins), chr(39), ' ms.');

  {
  If this Check fails the second Check will not be executed
  Check(tmins < Self.finsertlimit1000, 'INS Operation: Operation slower than '
    + chr(39) + FloatToStr(Self.finsertlimit1000) + chr(39) +' ms! It took: '
    + chr(39) + FloatToStr(tmins) + chr(39) + ' ms.');
    }


  tmstrt := Now;

  self.mpobjs.Capacity := 1000;

  for iky := 1 to 1000 do
  begin
    sky := 'key' + IntToStr(iky);
    schk := 'value' + IntToStr(iky);

    psvl := self.mpobjs[sky];

    if psvl <> nil then
    begin
      if psvl^ <> schk then
        CheckEquals(schk, psvl^, 'LKP - key '  + chr(39) + sky + chr(39)
          + ' failed! Value is: ' + chr(39) + psvl^ + chr(39));

    end
    else  //Value is nil
    begin
      Check(psvl <> nil, 'LKP - key '  + chr(39) + sky + chr(39)
        + ' failed! Value is: ' + chr(39) + 'nil' + chr(39));
    end;  //if psvl <> nil then
  end;  //for iky := 1 to 1000 do

  tmend := Now;
  tmins := MilliSecondSpan(tmend, tmstrt);

  TS:=DateTimeToTimeStamp(Now);
  WriteLn ('LKP - End - Now in millisecs since midnight : ',TS.Time);

  WriteLn('LKP Operation completed in ', chr(39), FloatToStr(tmins), chr(39), ' ms.');

  Check(tmins < Self.flookuplimit1000, 'LKP Operation: Operation slower than '
    + chr(39) + FloatToStr(Self.flookuplimit1000) + chr(39) + ' ms! It took: '
    + chr(39) + FloatToStr(tmins) + chr(39) + ' ms.');

end;

procedure TTestsPointerHashList.TestInsert1000Elements;
var
  sky, schk: String;
  psvl: PAnsiString;
  tmstrt, tmend : TDateTime;
  tmins: Double;
  TS: TTimeStamp;
  iky: Integer;
begin
  WriteLn('TestInsert1000Elements: do ...');

  TS:=DateTimeToTimeStamp(Now);
  Writeln ('INS - Start - Now in millisecs since midnight : ',TS.Time);


  tmstrt := Now;

  self.lsthshobjs.LoadFactor := 2;
  self.lsthshobjs.Capacity := 1000;

  for iky := 1 to 1000 do
  begin
    sky := 'key' + IntToStr(iky);

    New(psvl);
    psvl^ := 'value' + IntToStr(iky);

    self.lsthshobjs.setValue(sky, psvl);

  end;  //for iky := 1 to 1000 do

  tmend := Now;
  tmins := MilliSecondSpan(tmend, tmstrt);

  TS:=DateTimeToTimeStamp(Now);
  WriteLn ('INS - End - Now in millisecs since midnight : ',TS.Time);

  WriteLn('INS Operation completed in ', chr(39), FloatToStr(tmins), chr(39), ' ms.');

  Check(tmins < Self.finsertlimit1000, 'INS Operation: Operation slower than '
    + chr(39) + FloatToStr(Self.finsertlimit1000) + chr(39) + ' ms! It took: '
    + chr(39) + FloatToStr(tmins) + chr(39) + ' ms.');


  tmstrt := Now;

  for iky := 1 to 1000 do
  begin
    sky := 'key' + IntToStr(iky);
    schk := 'value' + IntToStr(iky);

    psvl := self.lsthshobjs.getValue(sky);

    if psvl <> nil then
    begin
      if psvl^ <> schk then
        CheckEquals(schk, psvl^, 'LKP - key '  + chr(39) + sky + chr(39)
          + ' failed! Value is: ' + chr(39) + psvl^ + chr(39));

    end
    else  //Key Lookup failed
    begin
      Check(psvl <> nil, 'LKP - key '  + chr(39) + sky + chr(39)
        + ' failed! Value is: ' + chr(39) + 'nil' + chr(39));
    end; //if psvl <> nil then
  end;  //for iky := 1 to 1000 do

  tmend := Now;
  tmins := MilliSecondSpan(tmend, tmstrt);

  TS:=DateTimeToTimeStamp(Now);
  WriteLn ('LKP - End - Now in millisecs since midnight : ',TS.Time);

  WriteLn('LKP Operation completed in ', chr(39), FloatToStr(tmins), chr(39), ' ms.');

  {
  If the Insert Check fails this Check will not be executed
  Check(tmins < Self.flookuplimit1000, 'LKP Operation: Operation slower than '
    + chr(39) + FloatToStr(Self.flookuplimit1000) + chr(39) + ' ms! It took: '
    + chr(39) + FloatToStr(tmins) + chr(39) + ' ms.');
  }
end;

procedure TTestsPointerHashList.TestLookup1000Elements;
var
  sky, schk: String;
  psvl: PAnsiString;
  tmstrt, tmend : TDateTime;
  tmins: Double;
  TS: TTimeStamp;
  iky: Integer;
begin
  WriteLn('TestLookup1000Elements: go ...');

  TS:=DateTimeToTimeStamp(Now);
  Writeln ('INS - Start - Now in millisecs since midnight : ',TS.Time);


  tmstrt := Now;

  self.lsthshobjs.LoadFactor := 2;
  self.lsthshobjs.Capacity := 1000;

  for iky := 1 to 1000 do
  begin
    sky := 'key' + IntToStr(iky);

    New(psvl);
    psvl^ := 'value' + IntToStr(iky);

    self.lsthshobjs.setValue(sky, psvl);

  end;  //for iky := 1 to 1000 do

  tmend := Now;
  tmins := MilliSecondSpan(tmend, tmstrt);

  TS:=DateTimeToTimeStamp(Now);
  WriteLn ('INS - End - Now in millisecs since midnight : ',TS.Time);

  WriteLn('INS Operation completed in ', chr(39), FloatToStr(tmins), chr(39), ' ms.');

  {
  If this Check fails the second Check will not be reached
  Check(tmins < Self.finsertlimit1000, 'INS Operation: Operation slower than '
    + chr(39) + FloatToStr(Self.finsertlimit1000) + chr(39) + ' ms! It took: '
    + chr(39) + FloatToStr(tmins) + chr(39) + ' ms.');
    }


  tmstrt := Now;

  for iky := 1 to 1000 do
  begin
    sky := 'key' + IntToStr(iky);
    schk := 'value' + IntToStr(iky);

    psvl := self.lsthshobjs.getValue(sky);

    if psvl <> nil then
    begin
      if psvl^ <> schk then
        CheckEquals(schk, psvl^, 'LKP - key '  + chr(39) + sky + chr(39)
          + ' failed! Value is: ' + chr(39) + psvl^ + chr(39));

    end
    else  //Key Lookup failed
    begin
      Check(psvl <> nil, 'LKP - key '  + chr(39) + sky + chr(39)
        + ' failed! Value is: ' + chr(39) + 'nil' + chr(39));
    end; //if psvl <> nil then
  end;  //for iky := 1 to 1000 do

  tmend := Now;
  tmins := MilliSecondSpan(tmend, tmstrt);

  TS:=DateTimeToTimeStamp(Now);
  WriteLn ('LKP - End - Now in millisecs since midnight : ',TS.Time);

  WriteLn('LKP Operation completed in ', chr(39), FloatToStr(tmins), chr(39), ' ms.');

  Check(tmins < Self.flookuplimit1000, 'LKP Operation: Operation slower than '
    + chr(39) + FloatToStr(Self.flookuplimit1000) + chr(39) + ' ms! It took: '
    + chr(39) + FloatToStr(tmins) + chr(39) + ' ms.');

end;


(*
Reference Performance Test against the Generics.Collections.TFastHashMap
Adding 5000 Keys and their Values
Looking Up all their Values
It should return the defined Keys and their Values
*)
procedure TTestsPointerHashList.TestMapInsert5000Elements;
var
  sky, schk: String;
  psvl: PAnsiString;
  tmstrt, tmend : TDateTime;
  tmins: Double;
  TS: TTimeStamp;
  iky: Integer;
begin
  WriteLn('TestMapInsert5000Elements: do ...');

  TS:=DateTimeToTimeStamp(Now);
  Writeln ('INS - Start - Now in millisecs since midnight : ',TS.Time);


  tmstrt := Now;

  self.mpobjs.Capacity := 5000;

  for iky := 1 to 5000 do
  begin
    sky := 'key' + IntToStr(iky);

    New(psvl);
    psvl^ := 'value' + IntToStr(iky);

    self.mpobjs.Add(sky, psvl);
  end;  //for iky := 1 to 1000 do

  tmend := Now;
  tmins := MilliSecondSpan(tmend, tmstrt);

  TS:=DateTimeToTimeStamp(Now);
  WriteLn ('INS - End - Now in millisecs since midnight : ',TS.Time);

  WriteLn('INS Operation completed in ', chr(39), FloatToStr(tmins), chr(39), ' ms.');

  Check(tmins < Self.finsertlimit5000, 'INS Operation: Operation slower than '
    + chr(39) + FloatToStr(Self.finsertlimit5000) + chr(39) + ' ms! It took: '
    + chr(39) + FloatToStr(tmins) + chr(39) + ' ms.');


  tmstrt := Now;

  for iky := 1 to 5000 do
  begin
    sky := 'key' + IntToStr(iky);
    schk := 'value' + IntToStr(iky);

    psvl := self.mpobjs[sky];

    if psvl <> nil then
    begin
      if psvl^ <> schk then
        CheckEquals(schk, psvl^, 'LKP - key '  + chr(39) + sky + chr(39)
          + ' failed! Value is: ' + chr(39) + psvl^ + chr(39));

    end
    else  //Value is nil
    begin
      Check(psvl <> nil, 'LKP - key '  + chr(39) + sky + chr(39)
        + ' failed! Value is: ' + chr(39) + 'nil' + chr(39));
    end;  //if psvl <> nil then
  end;  //for iky := 1 to 1000 do

  tmend := Now;
  tmins := MilliSecondSpan(tmend, tmstrt);

  TS:=DateTimeToTimeStamp(Now);
  WriteLn ('LKP - End - Now in millisecs since midnight : ',TS.Time);

  WriteLn('LKP Operation completed in ', chr(39), FloatToStr(tmins), chr(39), ' ms.');

  {
  If the first Check fails this Check will not be executed
  Check(tmins < Self.flookuplimit5000, 'LKP Operation: Operation slower than '
    + chr(39) + FloatToStr(Self.flookuplimit5000) + chr(39) + '4 ms! It took: '
    + chr(39) + FloatToStr(tmins) + chr(39) + ' ms.');
    }

end;

(*
Reference Performance Test against the Generics.Collections.TFastHashMap
Adding 5000 Keys and their Values
Looking Up all their Values
It should return the defined Keys and their Values
*)
procedure TTestsPointerHashList.TestMapLookup5000Elements;
var
  sky, schk: String;
  psvl: PAnsiString;
  tmstrt, tmend : TDateTime;
  tmins: Double;
  TS: TTimeStamp;
  iky: Integer;
begin
  WriteLn('TestMapLookup5000Elements: do ...');

  TS:=DateTimeToTimeStamp(Now);
  Writeln ('INS - Start - Now in millisecs since midnight : ',TS.Time);


  tmstrt := Now;

  self.mpobjs.Capacity := 5000;

  for iky := 1 to 5000 do
  begin
    sky := 'key' + IntToStr(iky);

    New(psvl);
    psvl^ := 'value' + IntToStr(iky);

    self.mpobjs.Add(sky, psvl);
  end;  //for iky := 1 to 5000 do

  tmend := Now;
  tmins := MilliSecondSpan(tmend, tmstrt);

  TS:=DateTimeToTimeStamp(Now);
  WriteLn ('INS - End - Now in millisecs since midnight : ',TS.Time);

  WriteLn('INS Operation completed in ', chr(39), FloatToStr(tmins), chr(39), ' ms.');

  {
  If this Check fails the second will not be reached
  Check(tmins < Self.finsertlimit5000, 'INS Operation: Operation slower than '
    + chr(39) + FloatToStr(Self.finsertlimit5000) + chr(39) + ' ms! It took: '
    + chr(39) + FloatToStr(tmins) + chr(39) + ' ms.');
    }


  tmstrt := Now;

  for iky := 1 to 5000 do
  begin
    sky := 'key' + IntToStr(iky);
    schk := 'value' + IntToStr(iky);

    psvl := self.mpobjs[sky];

    if psvl <> nil then
    begin
      if psvl^ <> schk then
        CheckEquals(schk, psvl^, 'LKP - key '  + chr(39) + sky + chr(39)
          + ' failed! Value is: ' + chr(39) + psvl^ + chr(39));

    end
    else  //Value is nil
    begin
      Check(psvl <> nil, 'LKP - key '  + chr(39) + sky + chr(39)
        + ' failed! Value is: ' + chr(39) + 'nil' + chr(39));
    end;  //if psvl <> nil then
  end;  //for iky := 1 to 5000 do

  tmend := Now;
  tmins := MilliSecondSpan(tmend, tmstrt);

  TS:=DateTimeToTimeStamp(Now);
  WriteLn ('LKP - End - Now in millisecs since midnight : ',TS.Time);

  WriteLn('LKP Operation completed in ', chr(39), FloatToStr(tmins), chr(39), ' ms.');

  Check(tmins < Self.flookuplimit5000, 'LKP Operation: Operation slower than '
    + chr(39) + FloatToStr(Self.flookuplimit5000) + chr(39) + ' ms! It took: '
    + chr(39) + FloatToStr(tmins) + chr(39) + ' ms.');

end;

procedure TTestsPointerHashList.TestInsert5000Elements;
var
  sky, schk: String;
  psvl: PAnsiString;
  tmstrt, tmend : TDateTime;
  tmins: Double;
  TS: TTimeStamp;
  iky: Integer;
begin
  WriteLn('TestInsert5000Elements: do ...');

  TS:=DateTimeToTimeStamp(Now);
  Writeln ('INS - Start - Now in millisecs since midnight : ',TS.Time);


  tmstrt := Now;

  self.lsthshobjs.LoadFactor := 2;
  self.lsthshobjs.Capacity := 5000;

  for iky := 1 to 5000 do
  begin
    sky := 'key' + IntToStr(iky);

    New(psvl);
    psvl^ := 'value' + IntToStr(iky);

    self.lsthshobjs.setValue(sky, psvl);
  end;  //for iky := 1 to 1000 do

  tmend := Now;
  tmins := MilliSecondSpan(tmend, tmstrt);

  TS:=DateTimeToTimeStamp(Now);
  WriteLn ('INS - End - Now in millisecs since midnight : ',TS.Time);

  WriteLn('INS Operation completed in ', chr(39), FloatToStr(tmins), chr(39), ' ms.');

  Check(tmins < Self.finsertlimit5000, 'INS Operation: Operation slower than '
    + chr(39) + FloatToStr(Self.finsertlimit5000) + chr(39) + ' ms! It took: '
    + chr(39) + FloatToStr(tmins) + chr(39) + ' ms.');


  tmstrt := Now;

  for iky := 1 to 5000 do
  begin
    sky := 'key' + IntToStr(iky);
    schk := 'value' + IntToStr(iky);

    psvl := self.lsthshobjs.getValue(sky);

    if psvl <> nil then
    begin
      if psvl^ <> schk then
        CheckEquals(schk, psvl^, 'LKP - key '  + chr(39) + sky + chr(39)
          + ' failed! Value is: ' + chr(39) + psvl^ + chr(39));

    end
    else  //Key Lookup failed
    begin
      Check(psvl <> nil, 'LKP - key '  + chr(39) + sky + chr(39)
        + ' failed! Value is: ' + chr(39) + 'nil' + chr(39));
    end; //if psvl <> nil then
  end;  //for iky := 1 to 1000 do

  tmend := Now;
  tmins := MilliSecondSpan(tmend, tmstrt);

  TS:=DateTimeToTimeStamp(Now);
  WriteLn ('LKP - End - Now in millisecs since midnight : ',TS.Time);

  WriteLn('LKP Operation completed in ', chr(39), FloatToStr(tmins), chr(39), ' ms.');

  {
  If the Insert Check fails this Check will not be executed
  Check(tmins < Self.flookuplimit5000, 'LKP Operation: Operation slower than '
    + chr(39) + FloatToStr(Self.flookuplimit5000) + chr(39) + ' ms! It took: '
    + chr(39) + FloatToStr(tmins) + chr(39) + ' ms.');
    }

end;

procedure TTestsPointerHashList.TestLookup5000Elements;
var
  sky, schk: String;
  psvl: PAnsiString;
  tmstrt, tmend : TDateTime;
  tmins: Double;
  TS: TTimeStamp;
  iky: Integer;
begin
  WriteLn('TestLookup5000Elements: do ...');

  TS:=DateTimeToTimeStamp(Now);
  Writeln ('INS - Start - Now in millisecs since midnight : ',TS.Time);


  tmstrt := Now;

  self.lsthshobjs.LoadFactor := 2;
  self.lsthshobjs.Capacity := 5000;

  for iky := 1 to 5000 do
  begin
    sky := 'key' + IntToStr(iky);

    New(psvl);
    psvl^ := 'value' + IntToStr(iky);

    self.lsthshobjs.setValue(sky, psvl);
  end;  //for iky := 1 to 1000 do

  tmend := Now;
  tmins := MilliSecondSpan(tmend, tmstrt);

  TS:=DateTimeToTimeStamp(Now);
  WriteLn ('INS - End - Now in millisecs since midnight : ',TS.Time);

  WriteLn('INS Operation completed in ', chr(39), FloatToStr(tmins), chr(39), ' ms.');

  {
  If this Check fails the second will not be reached
  Check(tmins < Self.finsertlimit5000, 'INS Operation: Operation slower than '
    + chr(39) + FloatToStr(Self.finsertlimit5000) + chr(39) + ' ms! It took: '
    + chr(39) + FloatToStr(tmins) + chr(39) + ' ms.');
   }

  tmstrt := Now;

  for iky := 1 to 5000 do
  begin
    sky := 'key' + IntToStr(iky);
    schk := 'value' + IntToStr(iky);

    psvl := self.lsthshobjs.getValue(sky);

    if psvl <> nil then
    begin
      if psvl^ <> schk then
        CheckEquals(schk, psvl^, 'LKP - key '  + chr(39) + sky + chr(39)
          + ' failed! Value is: ' + chr(39) + psvl^ + chr(39));

    end
    else  //Key Lookup failed
    begin
      Check(psvl <> nil, 'LKP - key '  + chr(39) + sky + chr(39)
        + ' failed! Value is: ' + chr(39) + 'nil' + chr(39));
    end; //if psvl <> nil then
  end;  //for iky := 1 to 1000 do

  tmend := Now;
  tmins := MilliSecondSpan(tmend, tmstrt);

  TS:=DateTimeToTimeStamp(Now);
  WriteLn ('LKP - End - Now in millisecs since midnight : ',TS.Time);

  WriteLn('LKP Operation completed in ', chr(39), FloatToStr(tmins), chr(39), ' ms.');

  Check(tmins < Self.flookuplimit5000, 'LKP Operation: Operation slower than '
    + chr(39) + FloatToStr(Self.flookuplimit5000) + chr(39) + ' ms! It took: '
    + chr(39) + FloatToStr(tmins) + chr(39) + ' ms.');


end;
{$ENDIF}

end.

