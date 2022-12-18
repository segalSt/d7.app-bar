program Project1;

uses
  Forms,
  Unit1 in 'Unit1.pas' {ApplicationTaskBar},
  uHashStringsTable in 'uHashStringsTable.pas';

{$R *.RES}

begin
  Application.Initialize;
  Application.CreateForm(TApplicationTaskBar, ApplicationTaskBar);
  Application.Run;
end.
