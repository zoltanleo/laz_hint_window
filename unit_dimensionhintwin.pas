unit unit_dimensionhintwin;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, Forms, Controls, Graphics, Dialogs, StdCtrls, ComCtrls,
  Types, LCLIntf, LMessages, LCLType, ExtCtrls;

const
  IndentDimension = 10; // indentation

type
  { TMyHintPanel }

  TMyHintPanel = class(TPanel)
  private
    {$IFDEF MSWINDOWS}
    FEdit: TEdit;
    {$ELSE}
    FPosLabel: TLabel;
    {$ENDIF}
    FTrackBar: TTrackBar;
    FLabel: TLabel;
    procedure TrackBarChange(Sender: TObject);

    {$IFDEF MSWINDOWS}
    procedure EditEditingDone(Sender: TObject);
    procedure EditKeyPress(Sender: TObject; var Key: char);
    {$ENDIF}
  protected
    procedure SetParent(AParent: TWinControl); override;
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;

    function GetPreferredHeight: Integer;

    property TrackBar: TTrackBar read FTrackBar;
    {$IFDEF MSWINDOWS}
    property Edit: TEdit read FEdit;
    {$ELSE}
    property PosLabel: TLabel read FPosLabel;
    {$ENDIF}
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
  Indent = 10;

{ TMyHintPanel }

procedure TMyHintPanel.TrackBarChange(Sender: TObject);
begin
  {$IFDEF MSWINDOWS}
  FEdit.Text := IntToStr(FTrackBar.Position);
  {$ELSE}
  FPosLabel.Caption := IntToStr(FTrackBar.Position);
  {$ENDIF}
end;

procedure TMyHintPanel.SetParent(AParent: TWinControl);
begin
  inherited SetParent(AParent);
  {$IFDEF MSWINDOWS}
  if (AParent <> nil) and Assigned(FEdit) then
  begin
    FEdit.Width := Canvas.TextWidth('W') * 3;
    //Edit.Anchors := Edit.Anchors;
    //FLabel.Anchors := FLabel.Anchors;
  end;
  {$ELSE}
  if (AParent <> nil) and Assigned(FPosLabel) then
  begin
    PosLabel.AutoSize := False;
    PosLabel.Height := Canvas.TextрHeight('0');
    PosLabel.Width := Canvas.TextWidth('000');
    PosLabel.Alignment := taRightJustify;
    PosLabel.Caption := IntToStr(TrackBar.Position);
  end;
  {$ENDIF}
end;

{$IFDEF MSWINDOWS}
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
  if not (Key in ['0'..'9', #8]) then Key := #0;
end;
{$ENDIF}

constructor TMyHintPanel.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);

  Self.BevelOuter := bvNone;
  Self.ParentBackground := True;
  Self.AutoSize := True;

  // Creating child elements
  FTrackBar := TTrackBar.Create(Self);
  FLabel:= TLabel.Create(Self);

  {$IFDEF MSWINDOWS}
  FEdit := TEdit.Create(Self);
  {$ELSE}
  FPosLabel := TLabel.Create(Self);
  {$ENDIF}

  FTrackBar.Parent := Self;
  FLabel.Parent := Self;

  {$IFDEF MSWINDOWS}
  FEdit.Parent := Self;
  {$ELSE}
  FPosLabel.Parent := Self;
  {$ENDIF}


  // --- Label ---
  with FLabel do
  begin
    Caption := 'mm';
    BorderSpacing.Right := ScaleX(Indent,Screen.PixelsPerInch);

    AnchorSideLeft.Control := Nil;
    AnchorSideBottom.Control := Nil;
    AnchorSideRight.Control := Self;
    AnchorSideRight.Side := asrRight;

    {$IFDEF MSWINDOWS}
    AnchorSideTop.Control := FEdit;
    {$ELSE}
    AnchorSideTop.Control := FPosLabel;
    {$ENDIF}

    AnchorSideTop.Side:= asrCenter;

    Anchors:= [akTop, akRight];
  end;

  // --- TrackBar ---
  with FTrackBar do
  begin
    Min := 0;
    Max := 100;
    Frequency := 10;
    Position := 0;

    {$IF DEFINED(LCLgtk3)}
    Height := FLabel.Height * 3;
    {$ELSE}
    Height := FLabel.Height * 2;
    {$ENDIF}

    OnChange := @TrackBarChange;

    {$IFDEF MSWINDOWS}
    BorderSpacing.Around := ScaleX(Indent,Screen.PixelsPerInch);
    BorderSpacing.Top := ScaleX(Indent,Screen.PixelsPerInch);
    BorderSpacing.Bottom := ScaleX(Indent div 2,Screen.PixelsPerInch);
    {$ELSE}
    BorderSpacing.Top := ScaleX(Indent * 2,Screen.PixelsPerInch);
    BorderSpacing.Bottom := ScaleX(Indent,Screen.PixelsPerInch);
    BorderSpacing.Left := ScaleX(Indent,Screen.PixelsPerInch);
    BorderSpacing.Right := 0;
    {$ENDIF}

    AnchorSideLeft.Control := Self;
    AnchorSideLeft.Side := asrLeft;
    AnchorSideTop.Control := Self;
    AnchorSideTop.Side := asrTop;

    {$IFDEF MSWINDOWS}
    AnchorSideRight.Control := FEdit;
    {$ELSE}
    AnchorSideRight.Control := FPosLabel;
    {$ENDIF}
    AnchorSideRight.Side := asrLeft;
    AnchorSideBottom.Control := nil;
    AnchorSideBottom.Side := asrBottom;

    Anchors := [akTop, akLeft, akRight];
    TabOrder := 0;
  end;

  {$IFDEF MSWINDOWS}
  // --- Edit ---
  with FEdit do
  begin
    Text := '0';

    BorderSpacing.Left := ScaleX(Indent div 2,Screen.PixelsPerInch);
    BorderSpacing.Right := ScaleX(Indent div 2,Screen.PixelsPerInch);

    AnchorSideLeft.Control := Nil;
    AnchorSideTop.Control := Nil;
    AnchorSideBottom.Control := TrackBar;
    AnchorSideBottom.Side := asrCenter;
    AnchorSideRight.Control := FLabel;
    AnchorSideRight.Side := asrLeft;

    Anchors := [akBottom, akRight];
    TabOrder := 1;

    OnEditingDone := @EditEditingDone;
    OnKeyPress := @EditKeyPress;
    ReadOnly := False;
  end;
  {$ELSE}
  // --- PosLabel ---
  with FPosLabel do
  begin
    BorderSpacing.Right := ScaleX(Indent div 2,Screen.PixelsPerInch);

    AnchorSideLeft.Control := Nil;
    AnchorSideTop.Control := Nil;
    AnchorSideBottom.Control := TrackBar;
    AnchorSideBottom.Side := asrBottom;
    AnchorSideRight.Control := FLabel;
    AnchorSideRight.Side := asrLeft;

    Anchors := [akBottom, akRight];
  end;
  {$ENDIF}


end;

destructor TMyHintPanel.Destroy;
begin
  inherited Destroy;
end;

function TMyHintPanel.GetPreferredHeight: Integer;
begin
  if not Assigned(FTrackBar) then Exit(ScaleY(IndentDimension * 5, Screen.PixelsPerInch)); // fallback

    // TrackBar height + margins + small margin
    Result := FTrackBar.Height + BorderSpacing.Top + BorderSpacing.Bottom +
              ScaleY(IndentDimension, Screen.PixelsPerInch); // margin for Edit and visual indentation
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
      {$IFDEF MSWINDOWS}
      if (FHintPnlTop.Edit.Text <> '0') then ResultList.Add(FHintPnlTop.Edit.Text);

      if Assigned(FHintPnlMiddle) then
        if (FHintPnlMiddle.Edit.Text <> '0') then ResultList.Add(FHintPnlMiddle.Edit.Text);

      if Assigned(FHintPnlBottom) then
        if (FHintPnlBottom.Edit.Text <> '0') then ResultList.Add(FHintPnlBottom.Edit.Text);
      {$ELSE}
      if (FHintPnlTop.PosLabel.Caption <> '0') then ResultList.Add(FHintPnlTop.PosLabel.Caption);

      if Assigned(FHintPnlMiddle) then
        if (FHintPnlMiddle.PosLabel.Caption <> '0') then ResultList.Add(FHintPnlMiddle.PosLabel.Caption);

      if Assigned(FHintPnlBottom) then
        if (FHintPnlBottom.PosLabel.Caption <> '0') then ResultList.Add(FHintPnlBottom.PosLabel.Caption);
      {$ENDIF}

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

  Application.AddOnUserInputHandler(@AppMouseDown);
end;

destructor TMyHintWindow.Destroy;
begin
  FResultList.Free;
  Application.RemoveOnUserInputHandler(@AppMouseDown);//deleting the handler before destroying it
  inherited Destroy;
end;

end.
