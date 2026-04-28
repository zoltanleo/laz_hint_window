unit unit_dimensionhintwin;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, Forms, Controls, Graphics, Dialogs, StdCtrls, ComCtrls,
  Types, LCLIntf, LMessages, LCLType, ExtCtrls;

type
  { TMyHintPanel }

  TMyHintPanel = class(TPanel)
  private
    FTrackBar: TTrackBar;
    FEdit: TEdit;
    FLabel: TLabel;
    procedure TrackBarChange(Sender: TObject);
    procedure EditEditingDone(Sender: TObject);
    procedure EditKeyPress(Sender: TObject; var Key: char);
  protected
    procedure SetParent(AParent: TWinControl); override;
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;

    property TrackBar: TTrackBar read FTrackBar;
    property Edit: TEdit read FEdit;
  end;

  { TMyHintWindow }

  TMyHintWindow = class(THintWindow)
  private
    FCaptLblText: String;
    FDimensIntType: SizeInt;
    FHintPnlTop: TMyHintPanel;
    FHintPnlMiddle: TMyHintPanel;
    FHintPnlBottom: TMyHintPanel;
    FlblCaption: TLabel;
    FOnHintClose: TNotifyEvent;
    FResultList: TStringList;
    procedure AppMouseDown(Sender: TObject; var Msg: TLMessage);
    procedure SetCaptLblText(AValue: String);
    procedure SetDimensIntType(AValue: SizeInt);
    {
    due to the implementation features on different widgets
    https://gitlab.com/freepascal.org/lazarus/lazarus/-/work_items/42242#note_3274262545
    }
    // Redefining the method
    procedure WMNCHitTest(var Message: TLMessage); message LM_NCHITTEST;
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
    property lblCaption: TLabel read FlblCaption write FlblCaption;
    property CaptLblText: String read FCaptLblText write SetCaptLblText;
    property DimensIntType: SizeInt read FDimensIntType write SetDimensIntType;
    property HintPnlTop: TMyHintPanel read FHintPnlTop;
    property HintPnlMiddle: TMyHintPanel read FHintPnlMiddle;
    property HintPnlBottom: TMyHintPanel read FHintPnlBottom;
    property OnHintClose: TNotifyEvent read FOnHintClose write FOnHintClose;
    property ResultList: TStringList read FResultList;
  end;

implementation

const
  semiIndent = 5;
  Indent = 10;

{ TMyHintPanel }

procedure TMyHintPanel.TrackBarChange(Sender: TObject);
begin
  FEdit.Text := IntToStr(FTrackBar.Position);
end;

procedure TMyHintPanel.EditEditingDone(Sender: TObject);
var
  Value: LongInt = 0;
begin
  if not TryStrToInt(Edit.Text,Value) then Value:= 0;

  if (Value > TrackBar.Max)
    then Value:= TrackBar.Max
    else
      if (Value < TrackBar.Min) then  Value:= TrackBar.Min;

  TrackBar.OnChange:= nil;
  TrackBar.Position:= Value;
  TrackBar.OnChange:= @TrackBarChange;

  Edit.Text:= IntToStr(Value);
end;

procedure TMyHintPanel.EditKeyPress(Sender: TObject; var Key: char);
begin
  if not (Key in ['0'..'9']) then Key:= #0;
end;

procedure TMyHintPanel.SetParent(AParent: TWinControl);
begin
  inherited SetParent(AParent);
  if (AParent <> nil) and Assigned(FEdit) then
  begin
    //FEdit.Width := Canvas.TextWidth('W') * 3;
    Edit.Width := Canvas.TextWidth('000') + ScaleX(Indent, Screen.PixelsPerInch);
    Edit.Anchors := Edit.Anchors;
    FLabel.Anchors := FLabel.Anchors;
  end;
end;

constructor TMyHintPanel.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);

  Self.BevelOuter := bvNone;
  Self.ParentBackground := True;
  Self.AutoSize := True;

  // Creating child elements
  FTrackBar := TTrackBar.Create(Self);
  FEdit := TEdit.Create(Self);
  FLabel:= TLabel.Create(Self);

  FTrackBar.Parent := Self;
  FEdit.Parent := Self;
  FLabel.Parent := Self;

  // --- TrackBar ---
  with FTrackBar do
  begin
    Min := 0;
    Max := 100;
    Frequency := 10;
    Position := 0;
    OnChange := @TrackBarChange;

    BorderSpacing.Left := ScaleX(Indent,Screen.PixelsPerInch);

    AnchorSideLeft.Control := Self;
    AnchorSideLeft.Side := asrLeft;
    AnchorSideTop.Control := FEdit;
    AnchorSideTop.Side := asrTop;
    AnchorSideRight.Control := FEdit;
    AnchorSideRight.Side := asrLeft;
    AnchorSideBottom.Control := FEdit;
    AnchorSideBottom.Side := asrBottom;

    Anchors := [akTop, akLeft, akRight, akBottom];
    TabOrder := 0;
  end;

  // --- Label ---
  with FLabel do
  begin
    Caption := 'mm';
    BorderSpacing.Right := ScaleX(Indent,Screen.PixelsPerInch);

    AnchorSideLeft.Control := Nil;
    AnchorSideBottom.Control := Nil;
    AnchorSideRight.Control := Self;
    AnchorSideRight.Side := asrRight;
    AnchorSideTop.Control := FEdit;
    AnchorSideTop.Side:= asrCenter;

    Anchors:= [akTop, akRight];
  end;

  // --- Edit ---
  with FEdit do
  begin
    Text := '0';

    BorderSpacing.Around := ScaleX(semiIndent,Screen.PixelsPerInch);
    BorderSpacing.Top := ScaleX(semiIndent,Screen.PixelsPerInch);
    BorderSpacing.Bottom := ScaleX(semiIndent,Screen.PixelsPerInch);

    AnchorSideLeft.Control := Nil;
    AnchorSideBottom.Control := Nil;
    AnchorSideTop.Control := Self;
    AnchorSideTop.Side := asrTop;
    AnchorSideRight.Control := FLabel;
    AnchorSideRight.Side := asrLeft;

    Anchors := [akTop, akRight];
    TabOrder := 1;

    OnEditingDone := @EditEditingDone;
    OnKeyPress := @EditKeyPress;
  end;
end;

destructor TMyHintPanel.Destroy;
begin
  inherited Destroy;
end;

{ TMyHintWindow }

procedure TMyHintWindow.AppMouseDown(Sender: TObject; var Msg: TLMessage);
var
  P: TPoint;
begin
  if (Msg.msg = LM_LBUTTONDOWN) or (Msg.msg = LM_RBUTTONDOWN) or (Msg.msg = LM_MBUTTONDOWN) then
  begin
    P := Mouse.CursorPos;
    if not PtInRect(Self.BoundsRect, P) then
    begin
      ResultList.Clear;
      if (FHintPnlTop.Edit.Text <> '0') then ResultList.Add(FHintPnlTop.Edit.Text);

      if Assigned(FHintPnlMiddle) then
        if (FHintPnlMiddle.Edit.Text <> '0') then ResultList.Add(FHintPnlMiddle.Edit.Text);

      if Assigned(FHintPnlBottom) then
        if (FHintPnlBottom.Edit.Text <> '0') then ResultList.Add(FHintPnlBottom.Edit.Text);

      // Calling an external event if it is assigned
      if Assigned(FOnHintClose) then FOnHintClose(Self);
    end;
  end;
end;

procedure TMyHintWindow.SetCaptLblText(AValue: String);
begin
  if FCaptLblText = AValue then Exit;
  FCaptLblText := AValue;

  if Assigned(lblCaption) then lblCaption.Caption := FCaptLblText;
end;

procedure TMyHintWindow.SetDimensIntType(AValue: SizeInt);
begin
  if (AValue = 0) or (AValue > 3) or (FDimensIntType = AValue) then Exit;
  FDimensIntType := AValue;

  // --- Top Panel ---
  if (DimensIntType >= 1) and not Assigned(FHintPnlTop) then
  begin
    FHintPnlTop := TMyHintPanel.Create(Self);
    with FHintPnlTop do
    begin
      Name := 'pnlTop';
      Caption := '';
      Parent := Self;

      AnchorSideLeft.Control := Self;
      AnchorSideLeft.Side := asrLeft;
      AnchorSideRight.Control := Self;
      AnchorSideRight.Side := asrRight;

      AnchorSideTop.Control := lblCaption;
      AnchorSideTop.Side := asrBottom;

      Anchors := [akTop, akLeft, akRight];
    end;
  end;

  // --- Middle Panel ---
  if (DimensIntType >= 2) and not Assigned(FHintPnlMiddle) then
  begin
    FHintPnlMiddle := TMyHintPanel.Create(Self);
    with FHintPnlMiddle do
    begin
      Name := 'pnlMiddle';
      Caption := '';
      Parent := Self;

      AnchorSideLeft.Control := Self;
      AnchorSideLeft.Side := asrLeft;
      AnchorSideRight.Control := Self;
      AnchorSideRight.Side := asrRight;

      if Assigned(FHintPnlTop) then
      begin
        AnchorSideTop.Control := FHintPnlTop;
        AnchorSideTop.Side := asrBottom;
      end;
      Anchors := [akTop, akLeft, akRight];
    end;
  end;

  // --- Bottom Panel ---
  if (DimensIntType >= 3) and not Assigned(FHintPnlBottom) then
  begin
    FHintPnlBottom := TMyHintPanel.Create(Self);
    with FHintPnlBottom do
    begin
      Name := 'pnlBottom';
      Caption := '';
      Parent := Self;

      AnchorSideLeft.Control := Self;
      AnchorSideLeft.Side := asrLeft;
      AnchorSideRight.Control := Self;
      AnchorSideRight.Side := asrRight;

      if Assigned(FHintPnlMiddle) then
      begin
        AnchorSideTop.Control := FHintPnlMiddle;
        AnchorSideTop.Side := asrBottom;
      end;
      Anchors := [akTop, akLeft, akRight];
    end;
  end;
end;

procedure TMyHintWindow.WMNCHitTest(var Message: TLMessage);
begin
  Message.Result := HTCLIENT;
end;

constructor TMyHintWindow.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  FResultList:= TStringList.Create;

  FOnHintClose := nil;
  FDimensIntType := 0;

  FHintPnlTop:= Nil;
  FHintPnlMiddle:= Nil;
  FHintPnlBottom:= Nil;

  // --- lblCaption ---
  FlblCaption := TLabel.Create(Self);
  with lblCaption do
  begin
    Parent := Self;
    //Caption := CaptLblText;
    Name := 'lblCaptText';
    //BorderSpacing.Around := 10;
    AnchorSideLeft.Control:= Self;
    AnchorSideLeft.Side:= asrCenter;
    AnchorSideTop.Control:= Self;
    AnchorSideTop.Side:= asrTop;
    Anchors := [akTop, akLeft];
  end;

  // --- Top Panel ---
  //FHintPnlTop := TMyHintPanel.Create(Self);
  //with FHintPnlTop do
  //begin
  //  Name := 'pnlTop';
  //  Caption := '';
  //  Parent := Self;
  //
  //  FLabel.BorderSpacing.Right := 10;
  //
  //  AnchorSideLeft.Control := Self;
  //  AnchorSideLeft.Side := asrLeft;
  //  AnchorSideRight.Control := Self;
  //  AnchorSideRight.Side := asrRight;
  //
  //  AnchorSideTop.Control := lblCaption;
  //  AnchorSideTop.Side := asrBottom;
  //
  //  Anchors := [akTop, akLeft, akRight];
  //end;

  Application.AddOnUserInputHandler(@AppMouseDown);
end;

destructor TMyHintWindow.Destroy;
begin
  FResultList.Free;
  Application.RemoveOnUserInputHandler(@AppMouseDown);//deleting the handler before destroying it
  inherited Destroy;
end;

end.
