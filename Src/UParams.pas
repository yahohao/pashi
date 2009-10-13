{
 * UParams.dpr
 *
 * Implements class that parses command line and records details.
 *
 * v1.0 of 10 Mar 2007  - Original version.
 * v1.1 of 29 May 2009  - Moved error messages to resource strings.
 *                      - Added support for -hidecss switch.
 *
 *
 * ***** BEGIN LICENSE BLOCK *****
 *
 * Version: MPL 1.1
 *
 * The contents of this file are subject to the Mozilla Public License Version
 * 1.1 (the "License"); you may not use this file except in compliance with the
 * License. You may obtain a copy of the License at http://www.mozilla.org/MPL/
 *
 * Software distributed under the License is distributed on an "AS IS" basis,
 * WITHOUT WARRANTY OF ANY KIND, either express or implied. See the License for
 * the specific language governing rights and limitations under the License.
 *
 * The Original Code is UParams.pas.
 *
 * The Initial Developer of the Original Code is Peter Johnson
 * (http://www.delphidabbler.com/).
 *
 * Portions created by the Initial Developer are Copyright (C) 2007-2009 Peter
 * Johnson. All Rights Reserved.
 *
 * ***** END LICENSE BLOCK *****
}


unit UParams;


interface

{
  SWITCHES:
    -rc
      Takes input from clipboard rather than standard input.
    -wc
      Writes XHTML output to clipboard (CF_TEXT format) rather than standard
      output.
    -frag
      Writes XHTML fragment rather than complete XHTML document - code contains
      only <pre> tag enclosing highlighted containing source code. User must
      provide style sheet with required style names.
    -hidecss
      Wraps embedded CSS in HTML comments.
    -q
      Quiet mode. Inhibits writing to console. This setting is ignored when
      help screen is displayed or if error occurs while parsing command line.
    -h
      Displays help screen.
}


uses
  // Delphi
  Classes,
  // Project
  UConfig;


type

  {
  TSwitchId:
    Ids representing each valid command line switch.
  }
  TSwitchId = (
    siInputClipboard,     // read input from clipboard
    siOutputClipboard,    // write output to clipboard
    siDocTypeXHTMLFrag,   // write output as XHTML document fragment
    siDocTypeHideCSS,     // hide embedded CSS in comments
    siHelp,               // display help
    siQuiet               // don't display any output to console
  );

  {
  TParams:
    Class that parses command line and stores settings according to switches
    provided.
  }
  TParams = class(TObject)
  private
    fParams: TStringList;   // List of command line parameters
    fConfig: TConfig;       // Reference to program's configuration object
    function SwitchToId(const Switch: string; out Id: TSwitchId): Boolean;
      {Finds id of a switch.
        @param Switch [in] Text defining switch.
        @param Id [out] Id of switch. Undefined if switch is invalid.
        @return True if switch is valid, False otherwise.
      }
    procedure HandleSwitch(const Id: TSwitchId; var ParamIdx: Integer);
      {Processes switch, updating config file.
        @param Id [in] Id of switch to handle.
        @param ParamIdx [in/out]. Index of current switch in fParams[]. ParamIdx
          should be incremented if an addition parameter is read.
      }
  public
    constructor Create(const Config: TConfig);
      {Class constructor. Initialises object.
        @param Config [in] Configuration object to be updated from command line.
      }
    destructor Destroy; override;
      {Class destructor. Tears down object.
      }
    procedure Parse;
      {Parses the command line.
        @except Exception raised if error in command line.
      }
  end;


implementation


uses
  // Delphi
  StrUtils, SysUtils;


const
  // Map of switches onto switch id.
  cSwitches: array[1..6] of record
    Switch: string;   // switch
    Id: TSwitchId;    // switch id
  end = (
    // Input switches ----------------------------------------------------------
    // -rc causes input to be taken from clipboard
    (Switch: '-rc';       Id: siInputClipboard;),

    // Output switches ---------------------------------------------------------
    // -wc writes output to clipboard
    (Switch: '-wc';       Id: siOutputClipboard;),

    // Document type switches --------------------------------------------------
    // -frag causes XHTML code fragment to be generated
    (Switch: '-frag';     Id: siDocTypeXHTMLFrag;),
    // -hidecss causes styles embedded in XHTML head section to be protected by
    //    comments
    (Switch: '-hidecss';  Id: siDocTypeHideCSS;),

    // Help switch -------------------------------------------------------------
    // -h causes help text to be displayed on standard error
    (Switch: '-h';        Id: siHelp;),

    // Screen output control switch --------------------------------------------
    // -q inhibits output - ignored if help displayed or if errors parsing
    //    program parameters.
    (Switch: '-q';        Id: siQuiet;)
  );


{ TParams }

constructor TParams.Create(const Config: TConfig);
  {Class constructor. Initialises object.
    @param Config [in] Configuration object to be updated from command line.
  }
var
  Idx: Integer; // loops through all parameters
begin
  Assert(Assigned(Config), 'TParams.Create: Config is nil');
  inherited Create;
  fConfig := Config;
  // Stores program parameters
  fParams := TStringList.Create;
  for Idx := 1 to ParamCount do
    fParams.Add(Trim(ParamStr(Idx)));
end;

destructor TParams.Destroy;
  {Class destructor. Tears down object.
  }
begin
  FreeAndNil(fParams);
  inherited;
end;

procedure TParams.HandleSwitch(const Id: TSwitchId; var ParamIdx: Integer);
  {Processes switch, updating config file.
    @param Id [in] Id of switch to handle.
    @param ParamIdx [in/out]. Index of current switch in fParams[]. ParamIdx
      should be incremented if an addition parameter is read.
  }
begin
  case Id of
    siInputClipboard:
      fConfig.InputSource := isClipboard;
    siOutputClipboard:
      fConfig.OutputSink := osClipboard;
    siDocTypeXHTMLFrag:
      fConfig.DocType := dtXHTMLFragment;
    siDocTypeHideCSS:
      fConfig.DocType := dtXHTMLHideCSS;
    siHelp:
      fConfig.ShowHelp := True;
    siQuiet:
      fConfig.Quiet := True;
  end;
end;

procedure TParams.Parse;
  {Parses the command line.
    @except Exception raised if error in command line.
  }
var
  Idx: Integer;         // loops through all parameters on command line
  SwitchId: TSwitchId;  // id of each switch
resourcestring
  // Error messages
  sNoSwitch = 'Invalid parameter "%s" - switch expected';
  sBadSwitch = 'Invalid switch "%s"';
begin
  // Loop through all switches on command line
  Idx := 0;
  while Idx < fParams.Count do
  begin
    // Check we have a switch
    if not AnsiStartsStr('-', fParams[Idx]) then
      raise Exception.CreateFmt(sNoSwitch, [fParams[Idx]]);
    // Get id of switch, checking it is valid
    if not SwitchToId(fParams[Idx], SwitchId) then
      raise Exception.CreateFmt(sBadSwitch, [fParams[Idx]]);
    // Parse the switch, updating configuration object
    HandleSwitch(SwitchId, Idx);
    // Next switch parameter
    Inc(Idx);
  end;
end;

function TParams.SwitchToId(const Switch: string; out Id: TSwitchId): Boolean;
  {Finds id of a switch.
    @param Switch [in] Text defining switch.
    @param Id [out] Id of switch. Undefined if switch is invalid.
    @return True if switch is valid, False otherwise.
  }
var
  Idx: Integer; // loops through list of valid switches
begin
  Result := False;
  for Idx := Low(cSwitches) to High(cSwitches) do
  begin
    if Switch = cSwitches[Idx].Switch then
    begin
      Id := cSwitches[Idx].Id;
      Result := True;
      Break;
    end;
  end;
end;

end.
