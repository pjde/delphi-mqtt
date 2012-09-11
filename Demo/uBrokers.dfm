object BrokerForm: TBrokerForm
  Left = 0
  Top = 0
  BorderStyle = bsToolWindow
  Caption = ' Other Brokers'
  ClientHeight = 297
  ClientWidth = 310
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  OnCreate = FormCreate
  OnShow = FormShow
  PixelsPerInch = 96
  TextHeight = 13
  object Label1: TLabel
    Left = 4
    Top = 221
    Width = 52
    Height = 13
    Caption = 'IP Address'
  end
  object Label2: TLabel
    Left = 146
    Top = 221
    Width = 20
    Height = 13
    Caption = 'Port'
  end
  object MonTree: TVirtualStringTree
    Left = 4
    Top = 4
    Width = 299
    Height = 199
    Colors.UnfocusedSelectionColor = clHighlight
    Colors.UnfocusedSelectionBorderColor = clHighlight
    Header.AutoSizeIndex = 0
    Header.DefaultHeight = 17
    Header.Font.Charset = DEFAULT_CHARSET
    Header.Font.Color = clWindowText
    Header.Font.Height = -11
    Header.Font.Name = 'Tahoma'
    Header.Font.Style = []
    Header.Options = [hoColumnResize, hoDrag, hoShowSortGlyphs, hoVisible]
    RootNodeCount = 3
    TabOrder = 0
    TreeOptions.PaintOptions = [toShowButtons, toShowDropmark, toShowHorzGridLines, toShowVertGridLines, toThemeAware, toUseBlendedImages, toFullVertGridLines]
    TreeOptions.SelectionOptions = [toFullRowSelect]
    OnChange = MonTreeChange
    OnGetText = MonTreeGetText
    OnGetNodeDataSize = MonTreeGetNodeDataSize
    Columns = <
      item
        Position = 0
        Width = 100
        WideText = 'IP Address'
      end
      item
        Position = 1
        Width = 60
        WideText = 'Port'
      end
      item
        Position = 2
        Width = 60
        WideText = 'Enabled'
      end
      item
        Position = 3
        WideText = 'Online'
      end>
  end
  object IPTxt: TEdit
    Left = 4
    Top = 235
    Width = 127
    Height = 21
    TabOrder = 1
    OnChange = IPTxtChange
  end
  object PortTxt: TEdit
    Left = 146
    Top = 235
    Width = 71
    Height = 21
    TabOrder = 2
    OnChange = IPTxtChange
    OnKeyPress = PortTxtKeyPress
  end
  object DelBtn: TButton
    Left = 231
    Top = 205
    Width = 71
    Height = 23
    Caption = 'Del'
    TabOrder = 3
    OnClick = DelBtnClick
  end
  object AddBtn: TButton
    Left = 232
    Top = 234
    Width = 71
    Height = 23
    Caption = 'Add'
    TabOrder = 4
    OnClick = AddBtnClick
  end
  object BitBtn1: TBitBtn
    Left = 211
    Top = 263
    Width = 91
    Height = 27
    Caption = 'Close'
    DoubleBuffered = True
    Kind = bkCancel
    NumGlyphs = 2
    ParentDoubleBuffered = False
    TabOrder = 5
    OnClick = BitBtn1Click
  end
  object StartBtn: TButton
    Left = 4
    Top = 271
    Width = 71
    Height = 23
    Caption = 'Start'
    TabOrder = 6
    OnClick = StartBtnClick
  end
  object StopBtn: TButton
    Left = 81
    Top = 271
    Width = 71
    Height = 23
    Caption = 'Stop'
    TabOrder = 7
    OnClick = StopBtnClick
  end
end
