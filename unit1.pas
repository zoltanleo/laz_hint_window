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
  ;

type
  { Создаем класс-наследник THintWindow }

    { TMyHintWindow }

    TMyHintWindow = class(THintWindow)
    private
        procedure AppMouseDown(Sender: TObject; var Msg: TLMessage);
        // Добавляем обработчик изменения положения ползунка
        procedure TrackBarChange(Sender: TObject);
      public
        TrackBar: TTrackBar;
        Edit: TEdit;
        LabelUnit: TLabel;
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
    FHintWin: TMyHintWindow; // Переменная для хранения экземпляра окна
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
      Form1.Label1.Caption := IntToStr(TrackBar.Position);
      Self.Close;
    end;
  end;
end;

procedure TMyHintWindow.TrackBarChange(Sender: TObject);
begin
  // При перемещении ползунка обновляем текст в Edit
  Edit.Text := IntToStr(TrackBar.Position);
end;

constructor TMyHintWindow.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  // Настройка TrackBar
    TrackBar := TTrackBar.Create(Self);
    TrackBar.Parent := Self;
    TrackBar.Min := 0;
    TrackBar.Max := 100;
    TrackBar.Frequency := 10;
    TrackBar.Position := 0;
    TrackBar.OnChange := @TrackBarChange; // Назначаем обработчик

    // Настройка Edit
    Edit := TEdit.Create(Self);
    Edit.Parent := Self;
    Edit.Text := '0';
    Edit.ReadOnly := True; // Опционально: только для чтения, раз управление через ползунок

    LabelUnit := TLabel.Create(Self);
    LabelUnit.Parent := Self;
    LabelUnit.Caption := 'мм';

    // Регистрируем глобальный обработчик клика мыши
    Application.AddOnUserInputHandler(@AppMouseDown);
end;

destructor TMyHintWindow.Destroy;
begin
  // Обязательно удаляем обработчик перед уничтожением
  Application.RemoveOnUserInputHandler(@AppMouseDown);
  inherited Destroy;
end;

{ TForm1 }

procedure TForm1.FormDestroy(Sender: TObject);
begin
  // Не забываем освободить память при закрытии формы
  if Assigned(FHintWin) then FHintWin.Free;
end;

procedure TForm1.Button1Click(Sender: TObject);
var
  P: TPoint;
  R: TRect;
  W, H: Integer;
begin
  // Если окно уже открыто, при повторном клике тоже обновим Label перед пересозданием
    if Assigned(FHintWin) then
    begin
      Label1.Caption := IntToStr(FHintWin.TrackBar.Position);
      FreeAndNil(FHintWin);
    end;

    FHintWin := TMyHintWindow.Create(Self);

    // Устанавливаем размеры окна подсказки
    W := 400;
    H := 60;

    // Позиционирование окна относительно кнопки
    P := Button1.ClientToScreen(Point(Button1.Width + 10, 0));
    R := Rect(P.X, P.Y, P.X + W, P.Y + H);

    { Настройка расположения внутренних элементов }

    // 1. TrackBar: 10px от левого края, 60% ширины
    FHintWin.TrackBar.Left := 10;
    FHintWin.TrackBar.Width := Round(W * 0.60);
    FHintWin.TrackBar.Top := 10;

    // 2. TEdit: справа от TrackBar на 10px, 20% ширины
    FHintWin.Edit.Left := FHintWin.TrackBar.Left + FHintWin.TrackBar.Width + 10;
    FHintWin.Edit.Width := Round(W * 0.20);
    FHintWin.Edit.Top := 10;

    // 3. Label "мм": 5px от Edit, 10px от правого края окна
    FHintWin.LabelUnit.Left := FHintWin.Edit.Left + FHintWin.Edit.Width + 5;
    FHintWin.LabelUnit.Top := 15; // Небольшое смещение для выравнивания по тексту

    // Активируем окно
    FHintWin.ActivateHint(R, '');
end;

end.

