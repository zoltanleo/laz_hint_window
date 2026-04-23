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
        trbHintCrtl: TTrackBar;
        edtHintCrtl: TEdit;
        lblHintCrtl: TLabel;
        constructor Create(AOwner: TComponent); override;
        destructor Destroy; override;
    end;

  { TForm1 }

  TForm1 = class(TForm)
    Button1: TButton;
    Label1: TLabel;
    procedure Button1Click(Sender: TObject);
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

  trbHintCrtl := TTrackBar.Create(Self);
  with trbHintCrtl do
  begin
    Parent := Self;
    Min := 0;
    Max := 100;
    Frequency := 10;
    Position := 0;
    OnChange := @TrackBarChange;
  end;

  // setting Edit
  edtHintCrtl := TEdit.Create(Self);
  with edtHintCrtl do
  begin
    Parent := Self;
    Text := '0';
    ReadOnly := False;
  end;

  lblHintCrtl := TLabel.Create(Self);
  with lblHintCrtl do
  begin
    Parent := Self;
    Caption := 'мм';
  end;

  // Registering the global mouse click handler
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
  H := 60;

  // window position relative to button
  P := Button1.ClientToScreen(Point(Button1.Width + 10, 0));
  R := Rect(P.X, P.Y, P.X + W, P.Y + H);

  { we arrange the internal elements }

  //TTrackbar: 10px from the left edge, 60% of the width
  FHintWin.trbHintCrtl.Left := 10;
  FHintWin.trbHintCrtl.Width := Round(W * 0.60);
  FHintWin.trbHintCrtl.Top := 10;

  //TEdit: to the right of trbHintCrtl by 10px, 20% width
  FHintWin.edtHintCrtl.Left := FHintWin.trbHintCrtl.Left + FHintWin.trbHintCrtl.Width + 10;
  FHintWin.edtHintCrtl.Width := Round(W * 0.20);
  FHintWin.edtHintCrtl.Top := 10;

  //label "mm": 5px from Edit, 10px from the right edge of the window
  FHintWin.lblHintCrtl.Left := FHintWin.edtHintCrtl.Left + FHintWin.edtHintCrtl.Width + 5;
  FHintWin.lblHintCrtl.Top := 15; // Небольшое смещение для выравнивания по тексту

  //show hint window
  FHintWin.ActivateHint(R, '');
end;

end.

