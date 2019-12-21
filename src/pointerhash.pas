unit pointerhash;

{$mode objfpc}{$H+}

interface

uses
  Classes;

type
  PPLHashNode = ^TPLHashNode;
  TPLHashNode = packed record
    ibucketindex: Integer;
    inodeindex: Integer;
    ihash: Cardinal;
    skey: String;
    pvalue: Pointer;
  end;

  TPLPointerNodeList = class
  protected
    arrnodes: array of PPLHashNode;
    ibucketindex: Integer;
    ilastindex: Integer;
    inextindex: Integer;
    inodecount: Integer;
    imaxcount: Integer;
    igrowfactor: Integer;
    procedure reindexList;
    procedure extendList;
  public
    constructor Create; virtual; overload;
    constructor Create(iindex: Integer); virtual; overload;
    destructor Destroy; override;
    function addNode(pnode: PPLHashNode = nil): PPLHashNode; overload;
    function addNode(ihash: Cardinal; pskey: PAnsiString; ppointer: Pointer): PPLHashNode; overload;
    procedure setValue(ihash: Cardinal; pskey: PAnsiString; ppointer: Pointer); overload;
    procedure setValue(pskey: PAnsiString; ppointer: Pointer); overload;
    procedure unsetIndex(iindex: Integer);
    function removeNode(pnode: PPLHashNode = nil): Boolean; overload;
    function removeNode(ihash: Cardinal; pskey: PAnsiString): Boolean; virtual; overload;
    function removeNode(pskey: PAnsiString): Boolean; virtual; overload;
    procedure Clear; virtual;
    function getNode(iindex: Integer): PPLHashNode; overload;
    function searchNode(ihash: Cardinal; pskey: PAnsiString): PPLHashNode; overload;
    function searchNode(pskey: PAnsiString): PPLHashNode; overload;
    function searchValue(ihash: Cardinal; pskey: PAnsiString): Pointer; overload;
    function searchValue(pskey: PAnsiString): Pointer; overload;
    function searchIndex(ihash: Cardinal; pskey: PAnsiString): Integer; overload;
    function searchIndex(pskey: PAnsiString): Integer; overload;
    function getLastIndex(): Integer;
  end;


  TPLPointerHashList = class
  protected
    arrbuckets: array of TObject;
    pcurrentnode: PPLHashNode;
    psearchednode: PPLHashNode;
    ikeycount: Integer;
    imaxkeycount: Integer;
    ibucketcount: Integer;
    igrowfactor: Integer;
    iloadfactor: Integer;
    procedure extendList(brebuild: Boolean = True); virtual;
    procedure rebuildList();
    function computeHash(pskey: PAnsiString): Cardinal;
  public
    constructor Create;
    destructor Destroy; override;
    procedure setValue(const skey: String; ppointer: Pointer); virtual;
    procedure removeKey(const skey: String); virtual;
    procedure Clear(); virtual;
    function getValue(const skey: String): Pointer; virtual;
    function hasKey(const skey: String): Boolean;
    function moveFirst(): Boolean;
    function moveNext(): Boolean;
    function getCurrentKey(): String;
    function getCurrentValue(): Pointer; virtual;
    function getCount(): Integer;
  end;

implementation

  uses
    sysutils;



  (*==========================================================================*)
  (* Class TPLPointerNodeList *)


  constructor TPLPointerNodeList.Create;
  begin
    self.ibucketindex := -1;
    self.ilastindex := 0;
    self.inextindex := 0;
    self.inodecount := 0;
    self.imaxcount := 3;
    self.igrowfactor := 2;

    SetLength(self.arrnodes, self.imaxcount);
  end;

  constructor TPLPointerNodeList.Create(iindex: Integer);
  begin
    self.ibucketindex := iindex;
    self.ilastindex := 0;
    self.inextindex := 0;
    self.inodecount := 0;
    self.imaxcount := 3;
    self.igrowfactor := 2;

    SetLength(self.arrnodes, self.imaxcount);
  end;

  destructor TPLPointerNodeList.Destroy;
  var
    ind: Integer;
  begin
    for ind := 0 to self.imaxcount - 1 do
    begin
      if self.arrnodes[ind] <> nil then
      begin
        Dispose(self.arrnodes[ind]);
      end;
    end; //for ind := 0 to self.imaxcount - 1 do

    SetLength(self.arrnodes, 0);

    inherited Destroy;
  end;

  procedure TPLPointerNodeList.reindexList;
  var
    plstnd: PPLHashNode;
    ifridx, inxtidx, ilstidx: Integer;
    ind: Integer;
  begin
    ilstidx := -1;
    ind := 0;

    repeat  //until ind = self.inextindex;
      if self.arrnodes[ind] = nil then
      begin
        ifridx := ind;
      end
      else
      begin
        ilstidx := ind;
        ifridx := -1;
      end;

      if (ifridx > -1)
        and (ifridx < self.ilastindex) then
      begin
        plstnd := nil;
        inxtidx := ifridx + 1;

        repeat
          plstnd := self.arrnodes[inxtidx];

          inc(inxtidx);
        until (plstnd <> nil)
          or (inxtidx >= self.inextindex);

        if plstnd <> nil then
        begin
          self.arrnodes[ifridx] := plstnd;

          plstnd^.inodeindex := ifridx;
        end
        else  //There aren't any more Nodes
        begin
          self.inextindex := ifridx;
          self.ilastindex := ifridx - 1;
        end;  //if plstnd <> nil then
      end; //if (ifridx > -1) and (ifridx < self.ilastindex) then

      inc(ind);
    until ind >= self.inextindex;

    if ilstidx > -1 then
    begin
      self.ilastindex := ilstidx;
      self.inextindex := ilstidx + 1;
    end;  //if ilstidx > -1 then
  end;

  procedure TPLPointerNodeList.extendList;
  begin
    self.imaxcount := self.imaxcount + self.igrowfactor;

    SetLength(self.arrnodes, self.imaxcount);
  end;

  function TPLPointerNodeList.addNode(pnode: PPLHashNode = nil): PPLHashNode;
  begin
    if self.inextindex >= self.imaxcount then
    begin
      if self.inodecount < self.imaxcount - self.igrowfactor then
      begin
        //Make Space by Reindexing
        self.reindexList;
      end
      else
      begin
        //Get more Space by Growing
        self.extendList;
      end;
    end;  //if self.inextindex >= self.imaxcount then

    if pnode = nil then
    begin
      New(pnode);

      //Initialize Pointer
      pnode^.pvalue := nil;
    end; //if pnode = nil then

    self.ilastindex := self.inextindex;
    self.arrnodes[self.ilastindex] := pnode;

    pnode^.ibucketindex := self.ibucketindex;
    pnode^.inodeindex := self.ilastindex;

    Result := pnode;

    inc(self.inodecount);
    inc(self.inextindex);
  end;

  function TPLPointerNodeList.addNode(ihash: Cardinal; pskey: PAnsiString; ppointer: Pointer): PPLHashNode;
  var
    plstnd: PPLHashNode;
  begin
    //Create New Node
    New(plstnd);

    //Initialize Values
    plstnd^.ihash := ihash;
    plstnd^.skey := pskey^;
    plstnd^.pvalue := ppointer;

    Result := self.addNode(plstnd);
  end;

  procedure TPLPointerNodeList.setValue(ihash: Cardinal; pskey: PAnsiString; ppointer: Pointer);
  var
    plstnd: PPLHashNode;
  begin
    plstnd := self.searchNode(ihash, pskey);

    if plstnd <> nil then plstnd^.pvalue := ppointer;
  end;

  procedure TPLPointerNodeList.setValue(pskey: PAnsiString; ppointer: Pointer);
  var
    plstnd: PPLHashNode;
  begin
    plstnd := self.searchNode(pskey);

    if plstnd <> nil then plstnd^.pvalue := ppointer;
  end;

  procedure TPLPointerNodeList.unsetIndex(iindex: Integer);
  begin
    if (iindex > -1)
      and (iindex < self.imaxcount) then
    begin
      self.arrnodes[iindex] := nil;

      dec(self.inodecount);
    end; //if (iindex > -1) and (iindex < self.imaxcount) then
  end;

  function TPLPointerNodeList.removeNode(pnode: PPLHashNode): Boolean;
  begin
    Result := False;

    if pnode <> nil then
    begin
      self.unsetIndex(pnode^.inodeindex);
      Dispose(pnode);

      Result := True;
    end;  //if pnode <> nil then
  end;


  function TPLPointerNodeList.removeNode(ihash: Cardinal; pskey: PAnsiString): Boolean;
  begin
    Result := self.removeNode(self.searchNode(ihash, pskey));
  end;

  function TPLPointerNodeList.removeNode(pskey: PAnsiString): Boolean;
  begin
    Result := self.removeNode(self.searchNode(pskey));
  end;

  procedure TPLPointerNodeList.Clear;
  var
     ind: Integer;
  begin
    for ind := 0 to self.imaxcount - 1 do
    begin
     if self.arrnodes[ind] <> nil then
     begin
       Dispose(self.arrnodes[ind]);
       self.arrnodes[ind] := nil;
     end;
    end; //for ind := 0 to self.imaxcount - 1 do

    //Shrink the List to its initial Size
    SetLength(self.arrnodes, self.igrowfactor);
  end;

  function TPLPointerNodeList.getNode(iindex: Integer): PPLHashNode;
  begin
    Result := nil;

    if (iindex > -1)
      and (iindex <= self.ilastindex) then
    begin
      Result := self.arrnodes[iindex];
    end;
  end;

  function TPLPointerNodeList.searchNode(ihash: Cardinal; pskey: PAnsiString): PPLHashNode;
  var
    ind: Integer;
  begin
    Result := nil;
    ind := 0;

    repeat  //while Result = nil and ind = self.inodelast;
      if self.arrnodes[ind] <> nil then
      begin
        if (self.arrnodes[ind]^.ihash = ihash)
          and (self.arrnodes[ind]^.skey = pskey^) then
          Result := self.arrnodes[ind];

      end;  //if self.arrnodes[ind] <> nil then

      inc(ind);
    until (Result <> nil)
      or (ind > self.ilastindex);

  end;

  function TPLPointerNodeList.searchNode(pskey: PAnsiString): PPLHashNode;
  var
    ind: Integer;
  begin
    Result := nil;
    ind := 0;

    repeat  //while Result = nil and ind = self.inodelast;
      if self.arrnodes[ind] <> nil then
      begin
        if self.arrnodes[ind]^.skey = pskey^ then Result := self.arrnodes[ind];
      end;

      inc(ind);
    until (Result <> nil)
      or (ind > self.ilastindex);

  end;

  function TPLPointerNodeList.searchValue(ihash: Cardinal; pskey: PAnsiString): Pointer;
  var
    plstnd: PPLHashNode;
  begin
    Result := nil;
    plstnd := self.searchNode(ihash, pskey);

    if plstnd <> nil then Result := plstnd^.pvalue;
  end;

  function TPLPointerNodeList.searchValue(pskey: PAnsiString): Pointer;
  var
    plstnd: PPLHashNode;
  begin
    Result := nil;
    plstnd := self.searchNode(pskey);

    if plstnd <> nil then Result := plstnd^.pvalue;
  end;

  function TPLPointerNodeList.searchIndex(ihash: Cardinal; pskey: PAnsiString): Integer;
  var
    plstnd: PPLHashNode;
  begin
    Result := -1;
    plstnd := self.searchNode(ihash, pskey);

    if plstnd <> nil then Result := plstnd^.inodeindex;
  end;

  function TPLPointerNodeList.searchIndex(pskey: PAnsiString): Integer;
  var
    plstnd: PPLHashNode;
  begin
    Result := -1;
    plstnd := self.searchNode(pskey);

    if plstnd <> nil then Result := plstnd^.inodeindex;
  end;

  function TPLPointerNodeList.getLastIndex(): Integer;
  begin
    Result := self.ilastindex;
  end;



  (*==========================================================================*)
  (* Class TPLPointerHashList *)


  constructor TPLPointerHashList.Create;
  begin
    self.ikeycount := 0;
    self.imaxkeycount := 0;
    self.ibucketcount := 0;
    self.igrowfactor := 3;
    self.iloadfactor := 3;
    self.pcurrentnode := nil;

    //Create the Buckets
    self.extendList(False);
  end;

  destructor TPLPointerHashList.Destroy;
  var
    ibkt: Integer;
  begin
    for ibkt := 0 to self.ibucketcount - 1 do
    begin
      self.arrbuckets[ibkt].Free;
    end;

    SetLength(self.arrbuckets, 0);

    inherited Destroy;
  end;

  procedure TPLPointerHashList.extendList(brebuild: Boolean = True);
  var
    ibkt: Integer;
  begin
    inc(self.ibucketcount, self.igrowfactor);

    //Forcing a uneven Bucket Count
    if (self.ibucketcount mod 2) = 0 then
      dec(self.ibucketcount);

    self.imaxkeycount := self.ibucketcount * self.iloadfactor;

    SetLength(self.arrbuckets, self.ibucketcount);

    for ibkt := 0 to self.ibucketcount - 1 do
    begin
      if self.arrbuckets[ibkt] = nil then self.arrbuckets[ibkt] := TPLPointerNodeList.Create(ibkt);
    end;

    if brebuild then
      //Reindex the Nodes
      self.rebuildList();

  end;

(*
  # Return the hashed value of a string: $hash = perlhash("key")
  # (Defined by the PERL_HASH macro in hv.h)
  sub perlhash
    {
      $hash = 0;
      foreach (split //, shift) {
          $hash = $hash*33 + ord($_);
      }
      return $hash;
  }

  /* djb2
   * This algorithm was first reported by Dan Bernstein
   * many years ago in comp.lang.c
   */
  unsigned long hash(unsigned char *str)
  {
      unsigned long hash = 5381;
      int c;
      while (c = *str++) hash = ((hash << 5) + hash) + c; // hash*33 + c
      return hash;
  }

  /* This algorithm was created for the sdbm (a reimplementation of ndbm)
   * database library and seems to work relatively well in scrambling bits
   */
  static unsigned long sdbm(unsigned char *str)
  {
      unsigned long hash = 0;
      int c;
      while (c = *str++) hash = c + (hash << 6) + (hash << 16) - hash;
      return hash;
  }
*)
  function TPLPointerHashList.computeHash(pskey: PAnsiString): Cardinal;
  var
    arrbts: TBytes;
    ibt, ibtcnt: Integer;
  begin
    Result := 0;

    if pskey <> nil then
    begin
      arrbts := BytesOf(pskey^);
      ibtcnt := Length(arrbts);

      for ibt := 0 to ibtcnt -1 do
      begin
        Result := arrbts[ibt] + (Result << 6) + (Result << 16) - Result;
      end;
    end;  //if pskey <> nil then
  end;

  procedure TPLPointerHashList.setValue(const skey: String; ppointer: Pointer);
  var
    ihsh: Cardinal;
    ibktidx: Integer;
  begin
    //Build the Hash Index
    ihsh := computeHash(@skey);
    ibktidx := ihsh mod self.ibucketcount;

    if self.psearchednode <> nil then
    begin
      if not ((self.psearchednode^.ihash = ihsh)
        and (self.psearchednode^.skey = skey)) then
        self.psearchednode := nil;

    end;  //if self.psearchednode <> nil then

    if self.psearchednode = nil then
      self.psearchednode := TPLPointerNodeList(self.arrbuckets[ibktidx]).searchNode(ihsh, @skey);

    if self.psearchednode = nil then
    begin
      //Add a New Node

      if self.ikeycount = self.imaxkeycount then
      begin
        self.extendList();

        //Recompute Bucket Index
        ibktidx := ihsh mod self.ibucketcount;
      end;  //if self.ikeycount = self.imaxkeycount then

      self.psearchednode := TPLPointerNodeList(self.arrbuckets[ibktidx]).addNode(ihsh, @skey, ppointer);

      inc(self.ikeycount);
    end
    else  //The Key is already in the List
    begin
      //Update the Node Value

      self.psearchednode^.pvalue := ppointer;
    end;  //if self.psearchednode = nil then
  end;

  procedure TPLPointerHashList.removeKey(const skey: String);
  var
    ihsh: Cardinal;
    ibktidx: Integer;
  begin
    //Build the Hash Index
    ihsh := computeHash(@skey);
    ibktidx := ihsh mod self.ibucketcount;

    if self.psearchednode <> nil then
    begin
      if not ((self.psearchednode^.ihash = ihsh)
        and (self.psearchednode^.skey = skey)) then
        self.psearchednode := nil;

    end;  //if self.psearchednode <> nil then

    if self.psearchednode <> nil then
    begin
      if TPLPointerNodeList(self.arrbuckets[ibktidx]).removeNode(self.psearchednode) then
      begin
        self.psearchednode := nil;

        dec(Self.ikeycount);
      end;  //if TPLPointerNodeList(self.arrbuckets[ibktidx]).removeNode(self.psearchednode) then
    end
    else  //Searched Node does not match
    begin
      if TPLPointerNodeList(self.arrbuckets[ibktidx]).removeNode(ihsh, @skey) then
        dec(Self.ikeycount);

    end;  //if self.psearchednode <> nil then
  end;

  procedure TPLPointerHashList.rebuildList();
  var
    plstnd: PPLHashNode;
    ibktnwidx, ibktidx, indidx, indlstidx: Integer;
  begin
    for ibktidx := 0 to self.ibucketcount -1 do
    begin
      indlstidx := TPLPointerNodeList(self.arrbuckets[ibktidx]).getLastIndex();

      for indidx := 0 to indlstidx do
      begin
        plstnd := TPLPointerNodeList(self.arrbuckets[ibktidx]).getNode(indidx);
        ibktnwidx := -1;

        if plstnd <> nil then
        begin
          ibktnwidx := plstnd^.ihash mod self.ibucketcount;
        end;

        if (ibktnwidx > -1)
          and (ibktnwidx <> ibktidx) then
        begin
          TPLPointerNodeList(self.arrbuckets[ibktidx]).unsetIndex(indidx);
          TPLPointerNodeList(self.arrbuckets[ibktnwidx]).addNode(plstnd);
        end;  //if (ibktnwidx > -1) and (ibktnwidx <> ibktidx) then
      end; //for indidx := 0 to indlstidx do
    end;  //for ibktidx := 0 to self.ibucketcount -1 do
  end;

  procedure TPLPointerHashList.Clear();
  var
    ibkt: Integer;
  begin
    for ibkt := 0 to self.ibucketcount - 1 do
    begin
      TPLPointerNodeList(self.arrbuckets[ibkt]).Clear;

      if ibkt >= self.igrowfactor then
        self.arrbuckets[ibkt].Free;

    end;  //for ibkt := 0 to self.ibucketcount - 1 do

    //Shrink the List to its initial Size
    SetLength(self.arrbuckets, self.igrowfactor);
  end;

  function TPLPointerHashList.getValue(const skey: String): Pointer;
  var
    ihsh: Cardinal;
    ibktidx: Integer;
  begin
    Result := nil;

    //Compute Bucket Index
    ihsh := computeHash(@skey);
    ibktidx := ihsh mod self.ibucketcount;

    if self.psearchednode <> nil then
    begin
      if not ((self.psearchednode^.ihash = ihsh)
        and (self.psearchednode^.skey = skey)) then
        self.psearchednode := nil;

    end; //if self.psearchednode <> nil then

    if self.psearchednode = nil then
      //Search the Hash within the Bucket
      self.psearchednode := TPLPointerNodeList(self.arrbuckets[ibktidx]).searchNode(ihsh, @skey);

    if self.psearchednode <> nil then
      Result := self.psearchednode^.pvalue;

  end;

  function TPLPointerHashList.hasKey(const skey: String): Boolean;
  var
    ihsh: Cardinal;
    ibktidx: Integer;
  begin
    Result := False;

    //Compute Bucket Index
    ihsh := computeHash(@skey);
    ibktidx := ihsh mod self.ibucketcount;

    if self.psearchednode <> nil then
    begin
      if not ((self.psearchednode^.ihash = ihsh)
        and (self.psearchednode^.skey = skey)) then
        self.psearchednode := nil;

    end; //if self.psearchednode <> nil then

    if self.psearchednode = nil then
      //Search the Hash within the Bucket
      self.psearchednode := TPLPointerNodeList(self.arrbuckets[ibktidx]).searchNode(ihsh, @skey);

    if self.psearchednode <> nil then
      Result := True;

  end;

  function TPLPointerHashList.moveFirst(): Boolean;
  var
    ibkt, indidx, indlstidx: Integer;
  begin
    Result := False;
    self.pcurrentnode := nil;
    ibkt := 0;

    repeat //until (self.pcurrentnode <> nil) or (ibkt >= self.ibucketcount);
      indlstidx := TPLPointerNodeList(self.arrbuckets[ibkt]).getLastIndex();
      indidx := 0;

      repeat
        self.pcurrentnode := TPLPointerNodeList(self.arrbuckets[ibkt]).getNode(indidx);

        inc(indidx);
      until (self.pcurrentnode <> nil)
        or (indidx > indlstidx);

      inc(ibkt);
    until (self.pcurrentnode <> nil)
      or (ibkt >= self.ibucketcount);

    if self.pcurrentnode <> nil then
      Result := True;

  end;

  function TPLPointerHashList.moveNext(): Boolean;
  var
    plstnd: PPLHashNode;
    ibktidx, indidx, indlstidx: Integer;
  begin
    Result := False;

    if self.pcurrentnode <> nil then
    begin
      plstnd := nil;
      ibktidx := self.pcurrentnode^.ibucketindex;
      indidx := self.pcurrentnode^.inodeindex;

      if ibktidx < self.ibucketcount then
      begin
        repeat  //until (plstnd <> nil) or (ibktidx >= self.ibucketcount);
          indlstidx := TPLPointerNodeList(self.arrbuckets[ibktidx]).getLastIndex();

          repeat  //until (plstnd <> nil) or (indidx > indlstidx);
            inc(indidx);

            plstnd := TPLPointerNodeList(self.arrbuckets[ibktidx]).getNode(indidx);
          until (plstnd <> nil)
            or (indidx > indlstidx);

          if plstnd = nil then
          begin
            //Check the Next Bucket
            inc(ibktidx);
            indidx := -1;
          end;  //if plstnd = nil then

        until (plstnd <> nil)
          or (ibktidx >= self.ibucketcount);

        self.pcurrentnode := plstnd;

        if self.pcurrentnode <> nil then
          Result := True;

      end;  //if ibktidx < self.ibucketcount then
    end
    else  //The Current Node is not set
    begin
      Result := self.moveFirst();
    end;  //if self.pcurrentnode <> nil then
  end;

  function TPLPointerHashList.getCurrentKey(): String;
  begin
    Result := '';

    if self.pcurrentnode <> nil then
      Result := self.pcurrentnode^.skey;

  end;

  function TPLPointerHashList.getCurrentValue(): Pointer;
  begin
    Result := nil;

    if self.pcurrentnode <> nil then
      Result := self.pcurrentnode^.pvalue;

  end;

  function TPLPointerHashList.getCount(): Integer;
  begin
    Result := self.ikeycount;
  end;

end.

