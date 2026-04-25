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
    { TMyHintWindow }

    TMyHintWindow = class(THintWindow)
    private
        procedure AppMouseDown(Sender: TObject; var Msg: TLMessage);
        procedure TrackBarChange(Sender: TObject);
        {
        due to the implementation features on different widgets
        https://gitlab.com/freepascal.org/lazarus/lazarus/-/work_items/42242#note_3274262545
        }
        // Redefining the method
        procedure WMNCHitTest(var Message: TLMessage); message LM_NCHITTEST;
      public
        pnlTop: TPanel;
        lblCaption: TLabel;

        trbHintCrtl: TTrackBar;
        edtHintCrtl: TEdit;
        lblHintCrtl: TLabel;
        constructor Create(AOwner: TComponent); override;
        destructor Destroy; override;
    end;

  { TForm1 }

  TForm1 = class(TForm)
    Button1: TButton;
    edtTest: TEdit;
    Label1: TLabel;
    lblTest: TLabel;
    pnlTest: TPanel;
    trbTest: TTrackBar;
    procedure Button1Click(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
  private
    FHintWin: TMyHintWindow;
  public

  end;

var
  Form1: TForm1;

implementation

{$R *.lfm}

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
      Form1.Label1.Caption := IntToStr(trbHintCrtl.Position);
      Self.Close;
    end;
  end;
end;

procedure TMyHintWindow.TrackBarChange(Sender: TObject);
begin
  edtHintCrtl.Text := IntToStr(trbHintCrtl.Position);
end;

procedure TMyHintWindow.WMNCHitTest(var Message: TLMessage);
begin
  Message.Result := HTCLIENT;
end;

constructor TMyHintWindow.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);

  // --- Caption label ---
  lblCaption := TLabel.Create(Self);
  with lblCaption do
  begin
    Parent := Self;
    Caption := 'Заголовок';
    Name := 'lblCaption';
    BorderSpacing.Around := 10;
    AnchorSideLeft.Control:= Self;
    AnchorSideLeft.Side:= asrCenter;
    AnchorSideTop.Control:= Self;
    AnchorSideTop.Side:= asrTop;
    Anchors := [akTop, akLeft];
  end;

  // --- Panel ---
  pnlTop := TPanel.Create(Self);
  with pnlTop do
  begin
    Parent:= Self;

    AnchorSideLeft.Control:= Self;
    AnchorSideLeft.Side:= asrLeft;

    AnchorSideTop.Control:= lblCaption;
    AnchorSideTop.Side:= asrBottom;

    AnchorSideRight.Control:= Self;
    AnchorSideRight.Side:= asrRight;

    Anchors := [akTop, akLeft, akRight];

    BevelOuter := bvNone;
    ParentBackground := True;
    Caption := '';
    AutoSize := True;
  end;

  // --- TrackBar ---
  trbHintCrtl:= TTrackBar.Create(Self);
  trbHintCrtl.Parent:= pnlTop;

  edtHintCrtl:= TEdit.Create(Self);
  edtHintCrtl.Parent:= pnlTop;

  lblHintCrtl:= TLabel.Create(Self);
  lblHintCrtl.Parent:= pnlTop;

  with trbHintCrtl do
  begin
    Parent := pnlTop;
    Min := 0;
    Max := 100;
    Frequency := 10;
    Position := 0;
    OnChange := @TrackBarChange;

    BorderSpacing.Left:= 10;

    AnchorSideLeft.Control:= Parent;
    AnchorSideLeft.Side:= asrLeft;

    AnchorSideTop.Control:= edtHintCrtl;
    AnchorSideTop.Side := asrTop;

    AnchorSideRight.Control:= edtHintCrtl;
    AnchorSideRight.Side:= asrLeft;

    AnchorSideBottom.Control:= edtHintCrtl;
    AnchorSideBottom.Side:= asrBottom;

    Anchors:= [akTop, akLeft, akRight, akBottom];
    TabOrder := 0;
  end;

  // --- Label ---

  with lblHintCrtl do
  begin
    Caption := 'мм';

    BorderSpacing.Right:= 10;

    AnchorSideLeft.Control:= Nil;
    AnchorSideBottom.Control:= Nil;

    AnchorSideRight.Control:= Parent;
    AnchorSideRight.Side := asrRight;

    AnchorSideTop.Control:= edtHintCrtl;
    AnchorSideTop.Side:= asrCenter;

    Anchors:= [akTop, akRight];
  end;

  // --- Edit ---

  with edtHintCrtl do
  begin
    Width := Canvas.TextWidth('W') * 3;
    Text := '0';

    BorderSpacing.Around:= 5;
    BorderSpacing.Top:= 5;
    BorderSpacing.Bottom:= 5;

    AnchorSideLeft.Control:= Nil;
    AnchorSideBottom.Control:= Nil;

    AnchorSideTop.Control:= Parent;
    AnchorSideTop.Side := asrTop;

    AnchorSideRight.Control:= lblHintCrtl;
    AnchorSideRight.Side:= asrLeft;

    Anchors:= [akTop, akRight];
    TabOrder := 1;
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

procedure TForm1.Button1Click(Sender: TObject);
var
  P: TPoint;
  R: TRect;
  W, H: Integer;
begin
  if Assigned(FHintWin) then FreeAndNil(FHintWin);

  FHintWin := TMyHintWindow.Create(Self);

  // Set size of hint window
  W := 400;
  H := 400;

  // window position relative to button
  P := Button1.ClientToScreen(Point(Button1.Width + 10, 0));
  R := Rect(P.X, P.Y, P.X + W, P.Y + H);

  //show hint window
  FHintWin.ActivateHint(R, '');
end;

procedure TForm1.FormCreate(Sender: TObject);
begin
  pnlTest.AutoSize := True;
end;

end.

