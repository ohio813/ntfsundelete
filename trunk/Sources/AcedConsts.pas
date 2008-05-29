
/////////////////////////////////////////////////////////////
//                                                         //
//   AcedConsts 1.14                                       //
//                                                         //
//   ����� ���� � �������, ������������ ������� ��������   //
//   � ������� ���������� AcedUtils, � ����� ������ ���    //
//   ��������� ����������.                                 //
//                                                         //
//   mailto: acedutils@yandex.ru                           //
//                                                         //
/////////////////////////////////////////////////////////////

unit AcedConsts;

interface

{ ���� ��������, ���������� ������������ ����� ���������, � ���������������
  �� ���������. }

const

{ ������������ ������ � ������� ���� }

  ByteListUpperLimit = 536870911;

{ ������������ ������ � ������� 2-������� ��������� }

  WordListUpperLimit = 268435455;

{ ������������ ������ � ������� 4-������� ��������� }

  DWordListUpperLimit = 134217727;

{ ������������ ������ � ������� 8-������� ��������� }

  QWordListUpperLimit = 67108863;

type

{ ��� ������� � ��������� �� ������ ��������� ���� Integer }

  PIntegerItemList = ^TIntegerItemList;
  TIntegerItemList = array[0..DWordListUpperLimit] of Integer;

{ ��� ������� � ��������� �� ������ ��������� ���� LongWord }

  PLongWordItemList = ^TLongWordItemList;
  TLongWordItemList = array[0..DWordListUpperLimit] of LongWord;

{ ��� ������� � ��������� �� ������ ��������� ���� TObject }

  PObjectItemList = ^TObjectItemList;
  TObjectItemList = array[0..DWordListUpperLimit] of TObject;

{ ��� ������� � ��������� �� ������ ��������� ���� Pointer }

  PPointerItemList = ^TPointerItemList;
  TPointerItemList = array[0..DWordListUpperLimit] of Pointer;

{ ��� ������� � ��������� �� ������ ��������� ���� String }

  PStringItemList = ^TStringItemList;
  TStringItemList = array[0..DWordListUpperLimit] of string;

{ ��� ������� � ��������� �� ������ ��������� ���� Word }

  PWordItemList = ^TWordItemList;
  TWordItemList = array[0..WordListUpperLimit] of Word;

{ ��� ������� � ��������� �� ������ ��������� ���� Currency }

  PCurrencyItemList = ^TCurrencyItemList;
  TCurrencyItemList = array[0..QWordListUpperLimit] of Currency;

{ ��� ������� � ��������� �� ������ ��������� ���� Double }

  PDoubleItemList = ^TDoubleItemList;
  TDoubleItemList = array[0..QWordListUpperLimit] of Double;

{ ��� ������� � ��������� �� ������ ��������� ���� Int64 }

  PInt64ItemList = ^TInt64ItemList;
  TInt64ItemList = array[0..QWordListUpperLimit] of Int64;

{ ��� ������� � ��������� �� ������ ��������� ���� Byte }

  PBytes = ^TBytes;
  TBytes = array[0..ByteListUpperLimit] of Byte;

{ ��� ������� � ��������� �� ������ ��������� ���� Char }

  PChars = ^TChars;
  TChars = array[0..ByteListUpperLimit] of Char;


{ ������� ��� ������ ������������ ������� ����������� ������� ��������
  � ������������� �������. }

{ G_EnlargeCapacity ���������� ����� ���������� ����� ��������� ���������
  ��� ������������� ���������� ������ �������� � ���������, ����� �� ������
  ������ ����������� ��������, ������� Capacity. }

function G_EnlargeCapacity(Capacity: Integer): Integer;

{ G_NormalizeCapacity ���������� ���������� ����� ��������� ���������, �������
  ��� ������ �������� ��������� Capacity. ��� ����� ����������� ����� �������,
  ����� �������������� ���������� ����������������� ������ ��� ���������
  ������� ���������� ���������. }

function G_NormalizeCapacity(Capacity: Integer): Integer;

{ G_EnlargePrimeCapacity ���������� ����� ���������� ����� ���������
  ������������� ������� ��� ������������� ���������� ������ ��������, �����
  ������������ ������ ���� ������ ����������� ��������, ������� Capacity. }

function G_EnlargePrimeCapacity(Capacity: Integer): Integer;


{ ��������� � ������ ��� ��������� ���������� }

const
  SErrArgumentNull = '�������� "%s", ������������ � ������� "%s", �� ����� ���� ����� nil.';
  SErrBinaryStreamCorrupted = '������ � �������� ������ ��������� � �� ����� ���� ���������.';
  SErrCodesToStrConversionFault = '������ ��� �������������� ������ ����������������� ����� � ������ ��������.';
  SErrCountDiffersInTBitLists = '��� ���������� ������ TBitList ����� ��������� �������� �������� Count.';
  SErrFileCreateError = '������ ��� �������� ����� "%s"';
  SErrFileOpenedForWrite = '���������� ������� ���� "%s", �.�. ���� ������ ��������� ��� ������ ��� ������.';
  SErrFileReadError = '������ ��� ������ ����� "%s".';
  SErrFileRereadError = '������ ��� ��������� ������ ������ �� �����.';
  SErrFileWriteError = '������ ��� ������ �����.';
  SErrFileWriteErrorFmt = '������ ��� ������ ����� "%s".';
  SErrFrameNotInitialized = 'Grid-����� �� ��� ���������������.';
  SErrFreeUnusedBlock = '������� ���������� ��������� ������� ������.';
  SErrHexToIntConversionFault = '������ � ���� �������������� ������������������ ����� %s � ����� �����.';
  SErrIndexOutOfRange = '������� ���������� � ��������������� �������� ������ ��� �������.';
  SErrInsertionNotAllowed = '����������� ������� ��������� � ������ ��� (MaintainSorted = True).';
  SErrKeyDuplicatesInAssociationList = '��������� ������������ ����� � ������ %s.';
  SErrMSExcelNotFound = '��� ���������� ������� �� ���������� ������ ���� ���������� Microsoft Excel.';
  SErrNoAvailableTimers = '���������� ������� ������ � Grid-������.';
  SErrNodeBelongsToAnotherList = '���� �� ����������� ������� ���������� ������.';
  SErrNodeBelongsToAnotherTree = '���� �� ����������� ������� ������-������� ������.';
  SErrNoFileOpenedForWrite = '���� �� ��� ������ ��� ������.';
  SErrNoHighResolutionPC = '� ������ ������������ ����������� ������ �������� ����������.';
  SErrNoMoreAvailableID = '� ��������� ����������� ���������� ��������������.';
  SErrOnDelayedSelectItemNotAssigned = '�� �������� ���������� ��� ������� OnDelayedSelectItem.';
  SErrOnGetDataNotAssigned = '�� �������� ���������� ��� ������� OnGetData.';
  SErrPeekFromEmptyList = '������� ������� ����� Peek ��� Pop ��� ������� ������ ��� �������.';
  SErrReadNotComplete = '������ �� ��������� ������ �� ��������� (���� "%s").';
  SErrReadBeyondTheEndOfStream = '������� ��������� ������ �� ��������� ��������� ������.';
  SErrRereadNotComplete = '��������� ������ �� ��������� ������ �� ���������.';
  SErrStreamIsReadOnly = '���������� ���������� ������ � �������� �����, �������� � ������ "������ ��� ������".';
  SErrStreamIsWriteOnly = '���������� ���������� ������ �� ��������� ������, ��������� � ������ "������ ��� ������".';
  SErrUnorderedRemovalNotAllowed = '����������� unordered-�������� �� ������� ��� (MaintainSorted = True).';
  SErrVersionNotSupported = '����� %s �� ������������ ������ ������ %d.';
  SErrWrongArgumentInReplaceChars = '� ������� G_ReplaceChars �������� ������������ ���������.';
  SErrWrongBase64EncodedString = '������ ������ �� ������������� ������� ����������� Base64.';
  SErrWrongDecryptionKey = '������������ ���� ������������ ��� ����������� ������ ��������� ������.';
  SErrWrongGridColumnIndex = '������������ ����� ������� � Grid-������.';
  SErrWrongGridRowIndex = '������������ ����� ������ � Grid-������.';
  SErrWrongNumberOfGridColumns = '�������� ����� �������� � Grid-������.';
  SErrWrongStreamLength = '������������ ����� ������� ��� �������� ��������� ������.';

{ ���������� ���������� � ���������� � ���, ��� ����������� ������ �������
  �� ����� ���� ���������. ������ ���������� �� ������ Load �������,
  ����������� �� TSerializableObject. � ��������� O ���������� Self. }

procedure RaiseVersionNotSupported(O: TObject; Version: Integer);

{ ������, ������������ ���������� ���� Exception � EConvertError. }

procedure RaiseErrorFmt(const msg, S: string); overload;
procedure RaiseErrorFmt(const msg, S1, S2: string); overload;
procedure RaiseConvertErrorFmt(const msg, S: string);
procedure RaiseError(const msg: string);
procedure RaiseConvertError(const msg: string);

implementation

uses SysUtils, AcedBinary;

{ ������� ��� ������ ������������ ������� ����������� ������� ��������
  � ������������� �������. }

function G_EnlargeCapacity(Capacity: Integer): Integer;
begin
  Inc(Capacity, 10);
  if Capacity >= 8192 then
    Result := (((Capacity shr 1) + Capacity + $FFF) and $7FFFF000) - 8
  else
    Result := G_IncPowerOfTwo(Capacity);
end;

function G_NormalizeCapacity(Capacity: Integer): Integer;
begin
  if Capacity <= 8 then
    Result := 16
  else if Capacity <= 8192 then
    Result := G_CeilPowerOfTwo(Capacity)
  else
    Result := ((Capacity + $1007) and $7FFFF000) - 8;
end;

function G_EnlargePrimeCapacity(Capacity: Integer): Integer;
begin
  if Capacity < 2729 then
  begin
    if Capacity < 163 then
    begin
      if Capacity < 37 then
      begin
        if Capacity < 17 then
        begin
          Result := 17;
          Exit;
        end else
        begin
          Result := 37;
          Exit;
        end;
      end
      else if Capacity < 79 then
      begin
        Result := 79;
        Exit;
      end else
      begin
        Result := 163;
        Exit;
      end;
    end else
    begin
      if Capacity < 673 then
      begin
        if Capacity < 331 then
        begin
          Result := 331;
          Exit;
        end else
        begin
          Result := 673;
          Exit;
        end;
      end
      else if Capacity < 1361 then
      begin
        Result := 1361;
        Exit;
      end else
      begin
        Result := 2729;
        Exit;
      end;
    end;
  end
  else if Capacity < 701819 then
  begin
    if Capacity < 43853 then
    begin
      if Capacity < 10949 then
      begin
        if Capacity < 5471 then
        begin
          Result := 5471;
          Exit;
        end else
        begin
          Result := 10949;
          Exit;
        end;
      end
      else if Capacity < 21911 then
      begin
        Result := 21911;
        Exit;
      end else
      begin
        Result := 43853;
        Exit;
      end;
    end else
    begin
      if Capacity < 175447 then
      begin
        if Capacity < 87719 then
        begin
          Result := 87719;
          Exit;
        end else
        begin
          Result := 175447;
          Exit;
        end;
      end
      else if Capacity < 350899 then
      begin
        Result := 350899;
        Exit;
      end else
      begin
        Result := 701819;
        Exit;
      end;
    end;
  end
  else if Capacity < 179669557 then
  begin
    if Capacity < 11229331 then
    begin
      if Capacity < 2807303 then
      begin
        if Capacity < 1403641 then
        begin
          Result := 1403641;
          Exit;
        end else
        begin
          Result := 2807303;
          Exit;
        end;
      end
      else if Capacity < 5614657 then
      begin
        Result := 5614657;
        Exit;
      end else
      begin
        Result := 11229331;
        Exit;
      end;
    end else
    begin
      if Capacity < 44917381 then
      begin
        if Capacity < 22458671 then
        begin
          Result := 22458671;
          Exit;
        end else
        begin
          Result := 44917381;
          Exit;
        end;
      end
      else if Capacity < 89834777 then
      begin
        Result := 89834777;
        Exit;
      end else
      begin
        Result := 179669557;
        Exit;
      end;
    end;
  end
  else if Capacity < 718678369 then
  begin
    if Capacity < 359339171 then
    begin
      Result := 359339171;
      Exit;
    end else
    begin
      Result := 718678369;
      Exit;
    end;
  end
  else if Capacity < 1437356741 then
  begin
    Result := 1437356741;
    Exit;
  end else
    Result := 0;
end;

{ ������ ��� ��������� ���������� }

procedure RaiseVersionNotSupported(O: TObject; Version: Integer);
begin
  raise Exception.CreateFmt(SErrVersionNotSupported, [O.ClassName, Version]);
end;

procedure RaiseErrorFmt(const msg, S: string);
begin
  raise Exception.CreateFmt(msg, [S]);
end;

procedure RaiseErrorFmt(const msg, S1, S2: string);
begin
  raise Exception.CreateFmt(msg, [S1, S2]);
end;

procedure RaiseConvertErrorFmt(const msg, S: string);
begin
  raise EConvertError.CreateFmt(msg, [S]);
end;

procedure RaiseError(const msg: string);
begin
  raise Exception.Create(msg);
end;

procedure RaiseConvertError(const msg: string);
begin
  raise EConvertError.Create(msg);
end;

end.

