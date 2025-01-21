unit Unit1;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, Forms, Controls, Graphics, Dialogs;

type

  { TForm1 }

  TForm1 = class(TForm)
    procedure FormClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure FormMouseMove(Sender: TObject; Shift: TShiftState; X, Y: Integer);
  private
    Fhw: THintWindow;
    procedure ShowHintWindow(X, Y: Integer; const HintText: string);
  public

  end;

var
  Form1: TForm1;

implementation


{$R *.lfm}

{ TForm1 }

procedure TForm1.FormClick(Sender: TObject);
var
  mp: TPoint;
begin
  mp:= Mouse.CursorPos;
  ShowHintWindow(mp.X, mp.Y, FormatDateTime('hh:mm:ss.zzz', Now));
end;

procedure TForm1.FormCreate(Sender: TObject);
begin
  Fhw := THintWindow.Create(Self);
end;

procedure TForm1.FormDestroy(Sender: TObject);
begin
  Fhw.Free;
end;

procedure TForm1.FormMouseMove(Sender: TObject; Shift: TShiftState; X,
  Y: Integer);
const
  os = 20;
var
  hr: TRect;
  LeftTop, RightBottom: TPoint;
begin
  if (((X <=0)) or ( Y <= 0)
     or ((X > (Self.Left + Self.Width)) or (Y > (Self.Top + Self.Height)))
  ) then
  begin
    //if Fhw.Visible then Fhw.Close;
    Exit;
  end;

  hr:= Bounds(Fhw.Left,Fhw.Top,Fhw.Width,Fhw.Height);
  LeftTop:= ScreenToClient(Point(Fhw.Left, Fhw.Top));
  RightBottom:= ScreenToClient(Point(Fhw.Left + Fhw.Width,Fhw.Top + Fhw.Height));
  Caption:= Format('mc X:Y %d:%d | hint bound L:T %d:%d:%d:%d',[X,Y,
  LeftTop.X, LeftTop.Y,
  RightBottom.X, RightBottom.Y]);
  if ((((LeftTop.X - os) > X) or ((LeftTop.Y - os) > Y))
     or (((RightBottom.X + os) < X) or ((RightBottom.Y + os) <Y))
     ) then
  Fhw.Close;
end;

procedure TForm1.ShowHintWindow(X, Y: Integer; const HintText: string);
begin
  Fhw.ActivateHint(Bounds(X, Y, 300, 100), HintText);
end;

end.

