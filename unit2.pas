unit Unit2;

{$mode ObjFPC}{$H+}

interface

uses
  Classes, SysUtils, Forms, Controls, Graphics, Dialogs, ExtCtrls, ComCtrls,
  StdCtrls;

type

  { TForm2 }

  TForm2 = class(TForm)
    Edit1: TEdit;
    Label1: TLabel;
    Panel1: TPanel;
    TrackBar1: TTrackBar;
    procedure FormCreate(Sender: TObject);
  private

  public

  end;

var
  Form2: TForm2;

implementation

{$R *.lfm}

{ TForm2 }

procedure TForm2.FormCreate(Sender: TObject);
begin
  Panel1.AutoSize :=  True;
  Panel1.Caption := '';
  Self.Position := poDesktopCenter;
end;

end.

