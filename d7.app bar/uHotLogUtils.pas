unit uHotLogUtils;

interface

type
  TProcNotify = procedure(Sender: TObject) of object;
  TProc = procedure of object;

  IMInterface =  interface(IUnknown)
   ['{f203abdf-b855-47fd-86fe-acd6495732a8}']
  end;

  TScopeExitNotifier = class(TInterfacedObject, IMInterface)
  private
    fProc: TProc;
  public
    constructor Create(const aProc: TProc);
    destructor Destroy; override;
  end;

const
  HLOG_FMT   = '{dhg}{&}.%s{*%d.}{&}{&}.{*%d.}{&}{&}%s.{*%d.}{&}{&}.%s{*7.}{&} ';

implementation

uses
  Classes
  ,Forms
  ,SysUtils
  //,DateUtils
  ;

//var
// Indent: integer;
// LogName: string;

//procedure THotLogHelper.LogIt(const LogStr: string; const FuncStr: string; const ModuleStr: string);
//var
//  StrVal: string;
//begin
//  StrVal := format(HLOG_FMT, [copy(ModuleStr,0, 30), 30, 1 + indent, FuncStr, 40 - indent, '']);
//  Add(StrVal + LogStr);
//end;

//function THotLogHelper.LogItS(const ModuleStr, FuncStr: string): IInterface;
//var
//  StrVal: string;
//  StartDt: TDateTime;
//begin
//  StartDt := now;
//  StrVal := format(HLOG_FMT, [copy(ModuleStr,0, 30), 30, 1 + indent, FuncStr, 40 - indent, 'Start']);
//  Add(StrVal);
//  inc(Indent, 2);
//  // call lazy exit notifier on exit in caller scope - add end of log entry with method duration: Xsec (Xms)
//  result := TScopeExitNotifier.Create(
//    procedure
//    begin
//      inc(Indent, -2);
//      StrVal := format(HLOG_FMT, [copy(ModuleStr,0, 30), 30, 1 + indent, FuncStr, 40 - indent, 'End']);
//      Add(StrVal +
//        IntToStr(SecondsBetween(Now, StartDt)) + 's (' +
//        IntToStr(MilliSecondsBetween(Now, StartDt))  + 'ms)');
//    end);
//end;

{ TScopeExitNotifier ----------------------------------------------------------}

constructor TScopeExitNotifier.Create(const aProc: TProc);
begin
  fProc:= aProc;
end;

destructor TScopeExitNotifier.Destroy;
begin
  if Assigned(fProc)
    then fProc;
  inherited;
end;

end.
