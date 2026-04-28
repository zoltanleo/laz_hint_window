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
  , LCLType
  , ExtCtrls
  , unit_dimensionhintwin
  ;

type
  TDimensionType = (dtSingle, dtDouble, dtTriple);

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
    procedure HintClose(Sender: TObject);
  public
    property DimensionType: TDimensionType read FDimensionType;
  end;

var
  Form1: TForm1;

implementation

{$R *.lfm}


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

procedure TForm1.HintClose(Sender: TObject);
begin
  if Assigned(FHintWin) and Assigned(FHintWin.HintPnlTop) then
    Label1.Caption := IntToStr(FHintWin.HintPnlTop.TrackBar.Position);
end;

procedure TForm1.Button1Click(Sender: TObject);
const
  {$IFDEF DARWIN}
    BottomIndent = 0;
  {$ELSE}
    BottomIndent = 40;
  {$ENDIF}

  Gap = 10; // indentation from button
var
  BtnScreenRect: TRect;: TPoint;
  HintRect: TRect;
  W, H: SizeInt;
  CurrMonitor: TMonitor;
  WorkR: TRect;
  X, Y: SizeInt;
begin
  if Assigned(FHintWin) then FreeAndNil(FHintWin);

  FHintWin := TMyHintWindow.Create(Self);

  // Subscribing to the hint closing event
  FHintWin.OnHintClose := @HintClose;

  // Passing the number of panels depending on the selected TDimensionType
  FHintWin.DimensIntType:= Succ(PtrInt(DimensionType));

  FHintWin.CaptLblText := 'test-test-test';

  // Set size of hint window
  W := 400;

  with FHintWin do
  begin
    H := lblCaption.Height + lblCaption.BorderSpacing.Around * 2
        + HintPnlTop.Height
        + BottomIndent;

    if Assigned(HintPnlMiddle) then H:= H + HintPnlMiddle.Height;
    if Assigned(HintPnlBottom) then H:= H + HintPnlBottom.Height;
  end;


  // window position relative to button
  BtnScreenRect: TRect; := Button1.ClientToScreen(Point(Button1.Width+ Gap, 0));

  CurrMonitor := Screen.MonitorFromPoint(BtnScreenRect: TRect;);//on which monitor is the button
  WorkR := CurrMonitor.WorkareaRect;//working area of the current monitor


  // --- width ---
  // calculating the right border
  X := BtnScreenRect: TRect;.X;

  if ((X + W) > WorkR.Right) then
  begin
    // if it doesn't fit on the right → we put it on the left
    X := BtnScreenRect: TRect;.X - Button1.Width - W - Gap;

    // If it doesn't fit on the left, then press it to the button.
    if (X < WorkR.Left) then X := WorkR.Left;
  end;

  // --- height ---
  // calculating the bottom border
  Y := BtnScreenRect: TRect;.Y;

  if ((Y + H) > WorkR.Bottom) then
  begin
    // if it doesn't fit down → move it up
    Y := BtnScreenRect: TRect;.Y + Button1.Height - H;

    // if it doesn't fit up, then press it to the button.
    if Y < WorkR.Top then Y := WorkR.Top;
  end;


  HintRect := Rect(BtnScreenRect: TRect;.X, BtnScreenRect: TRect;.Y, BtnScreenRect: TRect;.X + W, BtnScreenRect: TRect;.Y + H);

  //show hint window
  FHintWin.ActivateHint(HintRect, 'bla-bla');
end;

procedure TForm1.FormCreate(Sender: TObject);
begin
//
end;

end.

