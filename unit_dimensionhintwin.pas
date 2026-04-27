unit unit_DimensionHintWin;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, Forms, Controls, Graphics, Dialogs, StdCtrls, ComCtrls,
  Types, LCLIntf, LMessages, LCLType, ExtCtrls;

type
  //TDimensionType = (dtSingle, dtDouble, dtTriple);

  { TMyHintPanel }

  TMyHintPanel = class(TPanel)
  private
    FTrackBar: TTrackBar;
    FEdit: TEdit;
    FLabel: TLabel;
    procedure TrackBarChange(Sender: TObject);
  protected
    procedure SetParent(AParent: TWinControl); override;
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;

    property TrackBar: TTrackBar read FTrackBar;
    property EditControl: TEdit read FEdit;
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
    procedure AppMouseDown(Sender: TObject; var Msg: TLMessage);
    procedure SetCaptLblText(AValue: String);
    procedure SetDimensIntType(AValue: SizeInt);
    procedure TrackBarChange(Sender: TObject);
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
  end;

implementation

// Подключаем Unit1 в секции реализации для доступа к TForm1 и объекту Form1
uses
  Unit1;

{ TMyHintPanel }

procedure TMyHintPanel.TrackBarChange(Sender: TObject);
begin
  FEdit.Text := IntToStr(FTrackBar.Position);
end;

procedure TMyHintPanel.SetParent(AParent: TWinControl);
begin
  inherited SetParent(AParent);
  if (AParent <> nil) and Assigned(FEdit) then
    FEdit.Width := Canvas.TextWidth('W') * 3;
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
  FLabel := TLabel.Create(Self);

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

    BorderSpacing.Left := 10;

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
    Caption := 'мм';
    BorderSpacing.Right := 10;

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

    BorderSpacing.Around := 5;
    BorderSpacing.Top := 5;
    BorderSpacing.Bottom := 5;

    AnchorSideLeft.Control := Nil;
    AnchorSideBottom.Control := Nil;
    AnchorSideTop.Control := Self;
    AnchorSideTop.Side := asrTop;
    AnchorSideRight.Control := FLabel;
    AnchorSideRight.Side := asrLeft;

    Anchors := [akTop, akRight];
    TabOrder := 1;
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
      // Calling an external event if it is assigned
      if Assigned(FOnHintClose) then FOnHintClose(Self);
      Self.Close;
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
  if (AValue < 1) or (AValue > 3) or (FDimensIntType = AValue) then Exit;
  FDimensIntType := AValue;

  // --- Middle Panel ---
  if (DimensIntType >= 2) and not Assigned(FHintPnlMiddle) then
  begin
    FHintPnlMiddle := TMyHintPanel.Create(Self);
    with FHintPnlMiddle do
    begin
      Name := 'pnlMiddle';
      Caption := '';
      Parent := Self;
      AnchorSideLeft.Control := Self; AnchorSideLeft.Side := asrLeft;
      AnchorSideRight.Control := Self; AnchorSideRight.Side := asrRight;
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
      AnchorSideLeft.Control := Self; AnchorSideLeft.Side := asrLeft;
      AnchorSideRight.Control := Self; AnchorSideRight.Side := asrRight;
      if Assigned(FHintPnlMiddle) then
      begin
        AnchorSideTop.Control := FHintPnlMiddle;
        AnchorSideTop.Side := asrBottom;
      end;
      Anchors := [akTop, akLeft, akRight];
    end;
  end;
end;

procedure TMyHintWindow.TrackBarChange(Sender: TObject);
begin
  FHintPnlTop.FEdit.Text := IntToStr(FHintPnlTop.FTrackBar.Position);
end;

procedure TMyHintWindow.WMNCHitTest(var Message: TLMessage);
begin
  Message.Result := HTCLIENT;
end;

constructor TMyHintWindow.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);

  FOnHintClose := nil;
  FDimensIntType := 1;

  FHintPnlMiddle:= Nil;
  FHintPnlBottom:= Nil;

  // --- lblCaption ---
  FlblCaption := TLabel.Create(Self);
  with lblCaption do
  begin
    Parent := Self;
    //Caption := CaptLblText;
    Name := 'lblCaptText';
    BorderSpacing.Around := 10;
    AnchorSideLeft.Control:= Self;
    AnchorSideLeft.Side:= asrCenter;
    AnchorSideTop.Control:= Self;
    AnchorSideTop.Side:= asrTop;
    Anchors := [akTop, akLeft];
  end;

  // --- Top Panel ---
  FHintPnlTop := TMyHintPanel.Create(Self);
  with FHintPnlTop do
  begin
    Name := 'pnlTop';
    Caption := '';
    Parent := Self;

    AnchorSideLeft.Control := Self;
    AnchorSideLeft.Side := asrLeft;
    AnchorSideTop.Control := lblCaption;
    AnchorSideTop.Side := asrBottom;
    AnchorSideRight.Control := Self;
    AnchorSideRight.Side := asrRight;

    Anchors := [akTop, akLeft, akRight];
  end;

  Application.AddOnUserInputHandler(@AppMouseDown);
end;

destructor TMyHintWindow.Destroy;
begin
  //deleting the handler before destroying it
  Application.RemoveOnUserInputHandler(@AppMouseDown);
  inherited Destroy;
end;

end.
