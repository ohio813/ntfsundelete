(*
    NTFS Undelete
    Copyright (C) 2008 Atola Technology.
    http://ntfsundelete.com

    Authors:
      Alexander Malashonok
      Fedir Nepyivoda


    This program is free software; you can redistribute it and/or modify
    it under the terms of the GNU General Public License as published by
    the Free Software Foundation; either version 2 of the License, or
    (at your option) any later version.
    This program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU General Public License for more details.
    You should have received a copy of the GNU General Public License
    along with this program; if not, write to the Free Software
    Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
*)

unit AboutDlgUnit;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, ExtCtrls;

const
    crSystemHand = 5;
  

type
  TAboutForm = class(TForm)
    Image1: TImage;
    Shape1: TShape;
    Label1: TLabel;
    Label2: TLabel;
    lbHomePage: TLabel;
    Button1: TButton;
    procedure lbHomePageClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  AboutForm: TAboutForm;

implementation

uses ShellApi;

{$R *.dfm}

procedure TAboutForm.lbHomePageClick(Sender: TObject);
begin
    ShellExecute(Handle, 'open', 'http://www.ntfsundelete.com/', Nil,
                 Nil, SW_SHOW);
end;

procedure TAboutForm.FormCreate(Sender: TObject);
begin
    Screen.Cursors[crSystemHand] := LoadCursor(0, IDC_HAND);
    lbHomePage.Cursor := crSystemHand;
end;

end.
