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
  , unit_DimensionHintWin
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
var
  P: TPoint;
  R: TRect;
  W, H: Integer;
begin
  if Assigned(FHintWin) then FreeAndNil(FHintWin);

  FHintWin := TMyHintWindow.Create(Self);

  // Subscribing to the hint closing event
  FHintWin.OnHintClose := @HintClose;

  // Passing the number of panels depending on the selected TDimensionType
  //case FDimensionType of
  //  dtSingle: FHintWin.DimensIntType := 1;
  //  dtDouble: FHintWin.DimensIntType := 2;
  //  dtTriple: FHintWin.DimensIntType := 3;
  //end;
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

