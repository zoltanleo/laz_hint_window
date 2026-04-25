unit Unit1;

{$mode objfpc}{$H+}

interface

uses
  Classes
  , SysUtils
  , Forms
  , Controls
  , Graphics
  , Dialogs
  , StdCtrls
  , ComCtrls
  , Types
  , LCLIntf
  , LMessages
  , LCLType
  , ExtCtrls
  ;

type

  TDimensionType = (dtSingle, dtDouble, dtTriple);

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
      FDimensionType: TDimensionType;
      FDimensType: TDimensionType;
      FHintPnlTop: TMyHintPanel;
      FHintPnlMiddle: TMyHintPanel;
      FHintPnlBottom: TMyHintPanel;
      FlblCaption: TLabel;
      procedure AppMouseDown(Sender: TObject; var Msg: TLMessage);
      procedure SetCaptLblText(AValue: String);
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
      property DimensType: TDimensionType read FDimensionType write FDimensionType;
    end;

  { TForm1 }

  TForm1 = class(TForm)
    Button1: TButton;
    Label1: TLabel;
    RadioGroup1: TRadioGroup;
    procedure Button1Click(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure RadioGroup1Click(Sender: TObject);
  private
    FDimensionType: TDimensionType;
    FHintWin: TMyHintWindow;
  public
    property DimensionType: TDimensionType read FDimensionType;
  end;

var
  Form1: TForm1;

implementation

{$R *.lfm}

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
      Form1.Label1.Caption := IntToStr(FHintPnlTop.FTrackBar.Position);
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
  DimensType := TForm1(AOwner).DimensionType;

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

  // --- Middle Panel ---
  if (PtrInt(DimensType) >= PtrInt(dtDouble)) then
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

  // --- bottom Panel ---
  if (PtrInt(DimensType) >= PtrInt(dtTriple)) then
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

  Application.AddOnUserInputHandler(@AppMouseDown);
end;

destructor TMyHintWindow.Destroy;
begin
  //deleting the handler before destroying it
  Application.RemoveOnUserInputHandler(@AppMouseDown);
  inherited Destroy;
end;

{ TForm1 }

procedure TForm1.FormDestroy(Sender: TObject);
begin
  if Assigned(FHintWin) then FHintWin.Free;
end;

procedure TForm1.FormShow(Sender: TObject);
begin
  RadioGroup1Click(Sender);
end;

procedure TForm1.RadioGroup1Click(Sender: TObject);
begin
  case RadioGroup1.ItemIndex of
    0: FDimensionType := dtSingle;
    1: FDimensionType := dtDouble;
  else
    FDimensionType := dtTriple;
  end;
end;

procedure TForm1.Button1Click(Sender: TObject);
const
  {$IFDEF DARWIN}
    BottomIndent = 0;
  {$ELSE}
    BottomIndent = 40;
  {$ENDIF}
var
  P: TPoint;
  R: TRect;
  W, H: Integer;
begin
  if Assigned(FHintWin) then FreeAndNil(FHintWin);

  FHintWin := TMyHintWindow.Create(Self);
  FHintWin.CaptLblText := 'test-test-test';

  // Set size of hint window
  W := 400;

  with FHintWin do
  begin
    H := lblCaption.Height + lblCaption.BorderSpacing.Around * 2
        + FHintPnlTop.Height
        + BottomIndent;

    if Assigned(FHintPnlMiddle) then H:= H + FHintPnlMiddle.Height;
    if Assigned(FHintPnlBottom) then H:= H + FHintPnlBottom.Height;
  end;


  // window position relative to button
  P := Button1.ClientToScreen(Point(Button1.Width + 10, 0));
  R := Rect(P.X, P.Y, P.X + W, P.Y + H);

  //show hint window
  FHintWin.ActivateHint(R, '');
end;

procedure TForm1.FormCreate(Sender: TObject);
begin
//
end;

end.

