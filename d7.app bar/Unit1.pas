unit Unit1;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  StdCtrls;

type
  TApplicationTaskBar = class(TForm)
    Button1: TButton;
    Button2: TButton;
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure Button1Click(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure Button2Click(Sender: TObject);
  private
    procedure RegisterAtLeftEdge;
    procedure RegisterAtBottomEdge;
    procedure RegisterAtTopEdge;
  protected
    procedure CreateParams(var Params: TCreateParams); override;
  public
    { Public declarations }
  end;

var
  ApplicationTaskBar: TApplicationTaskBar;

implementation

{$R *.DFM}

Uses
  ShellAPI, uHashStringsTable;

procedure TApplicationTaskBar.CreateParams(var Params: TCreateParams);
begin
  inherited;
  Params.ExStyle  := Params.ExStyle or WS_EX_TOOLWINDOW;
  Params.Style    := (Params.Style OR WS_POPUP) AND (NOT WS_DLGFRAME);  //Remove title Bar
end;

procedure TApplicationTaskBar.RegisterAtLeftEdge;
var
  MyTaskBar  : TAppBarData;
begin
  Left:=0;
  Top :=0;
  Width := 60;
  Height:= Screen.Height;
  FillChar(MyTaskBar, SizeOf(TAppBarData), 0);
  MyTaskBar.cbSize := SizeOf(TAppBarData);
  MyTaskBar.hWnd   := Handle;
  MyTaskBar.uCallbackMessage := WM_USER+777;  //Define my own Mesaage
  MyTaskBar.uEdge  := ABE_right;
  MyTaskBar.rc     := Rect(0, 0, Width, Height);
  SHAppBarMessage(ABM_NEW, MyTaskBar);
  SHAppBarMessage(ABM_ACTIVATE, MyTaskBar);
  SHAppBarMessage(ABM_SETPOS, MyTaskBar);
  Application.ProcessMessages;
end;

procedure TApplicationTaskBar.RegisterAtBottomEdge;
var
  AppData  : TAppBarData;
begin
  Self.Left := 0;
  Self.Top := Screen.height - self.Height - 50;

  AppData.cbSize := 20;
  Appdata.hWnd := self.Handle;
  AppData.uEdge := ABE_Bottom;
  AppData.rc.Left := 0;
  AppData.rc.Top := Self.top;
  AppData.rc.Right := self.Width;
  AppData.rc.Bottom := screen.Height - 20;

  SHAppBarMessage(ABM_NEW, AppData); //Add to system list
  SHAppBarMessage(ABM_ACTIVATE, AppData); //Activate it
  SHAppBarMessage(ABM_SETPOS, AppData); //Position it

  application.ProcessMessages;
end;

procedure TApplicationTaskBar.RegisterAtTopEdge;
var
  AppData  : TAppBarData;
begin
  // set self position and size
  self.Left := 0;
  Self.Top := 0;
  self.Width := screen.Width;

  AppData.cbSize :=  SizeOf(TAppBarData);
  Appdata.hWnd := self.Handle;
  AppData.uEdge := ABE_TOP;
  // set app bar position and size
  AppData.rc.Left := 0;
  AppData.rc.Top := Self.top;
  AppData.rc.Right := self.Width;
  AppData.rc.Bottom := Self.Height + 5 ;
  // register  app bar
  SHAppBarMessage(ABM_NEW, AppData); //Add to system list
  SHAppBarMessage(ABM_ACTIVATE, AppData); //Activate it
  SHAppBarMessage(ABM_SETPOS, AppData); //Position it

  application.ProcessMessages;
end;


procedure TApplicationTaskBar.FormCreate(Sender: TObject);
begin
  case 1 of
    0: RegisterAtLeftEdge;
    2: RegisterAtBottomEdge;
    1: RegisterAtTopEdge;
  end;
end;

procedure TApplicationTaskBar.FormDestroy(Sender: TObject);
var
  MyTaskBar : TAppBarData;
begin
  FillChar(MyTaskBar, SizeOf(TAppBarData), 0);
  MyTaskBar.cbSize := SizeOf(TAppBarData);
  MyTaskBar.hWnd   := Self.Handle;
  SHAppBarMessage(ABM_Remove, MyTaskBar);
end;

procedure TApplicationTaskBar.Button1Click(Sender: TObject);
begin
  Close;
end;

procedure TApplicationTaskBar.FormClose(Sender: TObject;
  var Action: TCloseAction);
begin
  Action := caFree;
end;

procedure TApplicationTaskBar.Button2Click(Sender: TObject);
var
  sl: TStringList;
  ht: IStringsHashTable;
  i, z: integer;
begin
  ht := GetStringHashTableIntf;
  sl := TStringList.Create;
  try
    ht.AllowDuplicates := False;
    sl.LoadFromFile('c:\temp\1.txt');
    for i := 0 to sl.Count - 1 do
    begin
      ht.Add(sl.Strings[i]);
      if i = 2998 then
        z:= i;
    end;
    z := ht.GetStoredItems;
    i := ht.GetLongestHash;
  finally
    sl.Free;
  end;
end;

end.
