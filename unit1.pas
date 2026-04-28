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
    Memo1: TMemo;
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
var
  i: SizeInt = 0;
begin
  if Assigned(FHintWin) and Assigned(FHintWin.HintPnlTop) then
    begin
      Memo1.Clear;
      if (FHintWin.ResultList.Count > 0) then
        for i:= 0 to Pred(FHintWin.ResultList.Count) do Memo1.Lines.Add(FHintWin.ResultList.Strings[i]);
    end;

  FreeAndNil(FHintWin);
end;

procedure TForm1.Button1Click(Sender: TObject);
const
  Indent = 10; // indentation from button
  BottomIndent = 40;
  HintFormWdt = 400;
var
  BtnScreenRect: TRect;
  HintRect: TRect;
  W, H: SizeInt;
  CurrMonitor: TMonitor;
  WorkR: TRect;
  X, Y: SizeInt;
  Gap: SizeInt = 0;
  BtmIndent: SizeInt = 0;
begin
  if Assigned(FHintWin) then FreeAndNil(FHintWin);

  Gap := ScaleX(Indent, Screen.PixelsPerInch);

  {$IFNDEF DARWIN}
    BtmIndent:= ScaleX(BottomIndent, Screen.PixelsPerInch);
  {$ENDIF}


  FHintWin := TMyHintWindow.Create(Self);

  // Subscribing to the hint closing event
  FHintWin.OnHintClose := @HintClose;

  // Passing the number of panels depending on the selected TDimensionType
  FHintWin.DimensIntType:= Succ(PtrInt(DimensionType));

  FHintWin.CaptLblText := 'test-test-test';

  // Set size of hint window
  W := ScaleX(HintFormWdt, Screen.PixelsPerInch);

  with FHintWin do
  begin
    H := lblCaption.Height + lblCaption.BorderSpacing.Around * 2
        + HintPnlTop.Height
        + BtmIndent;

    if Assigned(HintPnlMiddle) then H:= H + HintPnlMiddle.Height;
    if Assigned(HintPnlBottom) then H:= H + HintPnlBottom.Height;
  end;


  // window position relative to button
  BtnScreenRect := Button1.ClientToScreen(Rect(0, 0, Button1.Width, Button1.Height));

  CurrMonitor := Screen.MonitorFromRect(BtnScreenRect);//on which monitor is the button
  WorkR := CurrMonitor.WorkareaRect;//working area of the current monitor


  //== width ==

  // by default, the hint is to the right of the button.
  X := BtnScreenRect.Right + Gap;

  // if it doesn't fit on the right, then the hint is on the left so
  // that the right edge of the hint is a gap away from the left edge of the button.
  if (X + W > WorkR.Right) then
  begin
    X := BtnScreenRect.Left - W - Gap;

    // If it doesn't fit on the left, then we press it to the left edge of the workspace.
    if X < WorkR.Left then X := WorkR.Left;
  end;

  // == height ==

  // by default, the hint is located below the button.
  Y := BtnScreenRect.Bottom + Gap;

  // if it doesn't fit from the bottom, then place the hint on top so
  // that the bottom edge of the hint is a Gap away from the top edge of the button.
  if (Y + H > WorkR.Bottom) then
  begin
    Y := BtnScreenRect.Top - H - Gap;

    // if it doesn't fit on top either, then press the hint to the top edge of the workspace.
    if Y < WorkR.Top then Y := WorkR.Top;
  end;

  HintRect := Rect(X, Y, X + W, Y + H);

  //show hint window
  FHintWin.ActivateHint(HintRect, '');
end;

procedure TForm1.FormCreate(Sender: TObject);
begin
//
end;

end.

