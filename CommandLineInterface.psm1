<#######################################################################
 #######################################################################
 ##																	  ##
 ##			             CommandLineInterface.psm1					  ##
 ##																	  ##
 #######################################################################
 ##																	  ##
 ## Purpose: A module to contain C.L.I. functionality.                ##
 ##																	  ##
 ## Author:  Corey Tattam                                             ##
 ##																	  ##
 #######################################################################
 #######################################################################>


 #Requires -Version 5


 <#
 =======================================================================

                               Classes

 =======================================================================
 #>

#region - - - - - - CLI Display Settings - - - - - - 

class CliColours {

    #region - - - - - - Properties - - - - - - 

    [System.ConsoleColor] $Text
    [System.ConsoleColor] $Highlight
    [System.ConsoleColor] $Option
    [System.ConsoleColor] $Information

    #endregion Properties

} ## CliColours

class CliDisplayOptions {

    #region - - - - - - Properties - - - - - - 
        
    [int] $MenuIndent
    [char] $MenuBorderCharacter
    [CliColours] $Colours 
    [int] $MenuBorderWidth

    #endregion Properties

    #region - - - - - - Constructors - - - - - - 

    CliDisplayOptions () {
        $this.Colours = [CliColours]::new();
    }

    #endregion Constructors

} ## CliDisplayOptions

#endregion CLI Display Settings

#region - - - - - - Menu Items - - - - - - 

class MenuItem {
 
    #region - - - - - - Properties - - - - - - 

    [string] $Text
    
    #endregion Properties

    #region - - - - - - Constructors - - - - - - 
    
    MenuItem() { }

    MenuItem([string] $text) {
        $this.Text = $text
    }     

    #endregion Constructors

    #region - - - - - - Methods - - - - - - 

    [string] ToString() {
        return $this.Text
    }

    #endregion Methods
    
} ## MenuItem

class MenuOptionItem : MenuItem {

    #region - - - - - - Properties - - - - - - 

    [bool] $IsHeading
    [int] $Position

    #endregion Properties

    #region - - - - - - Methods - - - - - - 

    static [MenuOptionItem] CreateMenuOptionHeading ([string] $headingtext) {
        $HeadingItem = New-Object MenuOptionItem
        $HeadingItem.IsHeading = $true
        $HeadingItem.Text = $headingtext

        return $HeadingItem
    } #CreateMenuOptionHeading

    static [MenuOptionItem] CreateMenuOptionItem ([string] $itemText, [int] $position) {
        $OptionItem = New-Object MenuOptionItem
        $OptionItem.Text = $itemText
        $OptionItem.Position = $position
        $OptionItem.IsHeading = $false

        return $OptionItem
    } #CreateMenuOptionItem

    [string] ToString() {
        
        if ($this.IsHeading) { return $this.Text }
        else { return ($this.Position.ToString() + ". " + $this.Text) }               
    } #ToString

    #endregion Methods

} ## MenuOptionItem

class MenuInformationItem : MenuItem {

    #region - - - - - - Properties - - - - - - 

    [bool] $IsHighlighted = $false
    [string] $Label

    #endregion Properties

    #region - - - - - - Constructors - - - - - - 

    MenuInformationItem([string] $text, [bool] $isHighlighted = $false) {

        $this.Text = $text
        $this.IsHighlighted = $isHighlighted
    }

    MenuInformationItem([string] $label, [string] $text, [bool] $isHighlighted = $false) {

        $this.Label = $label
        $this.Text = $text
        $this.IsHighlighted = $isHighlighted
    }

    #endregion Constructors

    #region - - - - - - Methods - - - - - - 

    [string] ToString() {
        [string] $Output = ""
        if (![string]::IsNullOrEmpty($this.Label)) { $Output += $this.Label + ": "; }
        $Output += $this.Text
        return $Output
    }

    #endregion Methods

} ## MenuInformationItem

#endregion Menu Items

#region - - - - - - Menu Options - - - - - - 

class MenuOptions {

    #region - - - - - - Properties - - - - - - 

    [string] $Title
    [string] $SubTitle
        
    [CliDisplayOptions] $DisplayOptions
    [MenuInformationItem[]] $InformationItems = @()
    [MenuOptionItem[]] $OptionItems = @()

    #endregion Properties

    #region - - - - - - Constructors - - - - - - 

    MenuOptions ([CliDisplayOptions] $cliDisplayOptions) {
        $this.DisplayOptions = $cliDisplayOptions
    }

	MenuOptions ([CliDisplayOptions] $cliDisplayOptions, [string] $title) {
        $this.DisplayOptions = $cliDisplayOptions
		$this.Title = $title
    }

    #endregion Constructors

} ## MenuOptions

#endregion Menu Settings


 <#
 =======================================================================

                               Functions

 =======================================================================
 #>

 #region - - - - - - Public Functions - - - - - - 

 <#
  .SYNOPSIS
   Given menu settings and menu items, print the menu.

  .PARAMETER options
   The MenuOptions class that contains the display format, and the menu items to print to screen.

  .EXAMPLE
    # Display a simple menu..
    Show-Menu $menuSettings
 #>
function Show-Menu {
    param (
        [Parameter(Mandatory=$true)]
            [ValidateNotNull()]
            [Alias("MenuOptions")]
            [MenuOptions] $options
    )
    begin {
        $DisplayOptions = $options.DisplayOptions
    }
    process {
              
        ## Border & Title.  
        Write-MenuBorderLine -Width $DisplayOptions.MenuBorderWidth -Character $DisplayOptions.MenuBorderCharacter -Colour $DisplayOptions.Colours.Text -PrependNewLine -AppendNewLine        
        Write-CenterAlignedText -Width $DisplayOptions.MenuBorderWidth -Text $options.Title -Colour $options.DisplayOptions.Colours.Text        
        Write-MenuBorderLine -Width $DisplayOptions.MenuBorderWidth -Character $DisplayOptions.MenuBorderCharacter -Colour $DisplayOptions.Colours.Text -PrependNewLine -AppendNewLine
        
        ## Information Items.
        if ($options.InformationItems.Count -gt 0) {             

            ## Separate the items.
            [MenuInformationItem[]] $HighlightedItems = @($options.InformationItems | ? { $_.IsHighlighted -eq $true })
			[MenuInformationItem[]] $StandardItems    = @($options.InformationItems | ? { $_.IsHighlighted -eq $false })

			## Write the Highlighted Information Items.
            if ($HighlightedItems.Count -gt 0) { Write-InformationItems -Items $HighlightedItems -Colour $DisplayOptions.Colours.Highlight -Indent $DisplayOptions.MenuIndent }
            
			## Add Separator
			if (($HighlightedItems.Count -gt 0) -and ($StandardItems.Count -gt 0)) { Write-Host "" }

            ## Write the Standard Information Items.            
            if ($StandardItems.Count -gt 0) { Write-InformationItems -Items $StandardItems -Colour $DisplayOptions.Colours.Information -Indent $DisplayOptions.MenuIndent }

            ## Ouptut the Border.
            Write-MenuBorderLine -Width $DisplayOptions.MenuBorderWidth -Character $DisplayOptions.MenuBorderCharacter -Colour $DisplayOptions.Colours.Text -PrependNewLine
        }   

        ## Write the Sub Title.
        Write-CenterAlignedText -Width $DisplayOptions.MenuBorderWidth -Text $options.SubTitle -Colour $options.DisplayOptions.Colours.Text
        Write-MenuBorderLine -Width $DisplayOptions.MenuBorderWidth -Character $DisplayOptions.MenuBorderCharacter -Colour $DisplayOptions.Colours.Text
        
        ## Write the menu items.
        Write-MenuOptionItems -Items $options.OptionItems -HeadingColour $DisplayOptions.Colours.Text -OptionColour $DisplayOptions.Colours.Option -Indent $DisplayOptions.MenuIndent -UnderlineCharacter $DisplayOptions.MenuBorderCharacter
        
        ## Write the final border.
        Write-MenuBorderLine -Width $DisplayOptions.MenuBorderWidth -Character $DisplayOptions.MenuBorderCharacter -Colour $DisplayOptions.Colours.Text -PrependNewLine
    }
} Export-ModuleMember -Function Show-Menu

#endregion Public Functions

 #region - - - - - - Private Functions - - - - - - 

function Get-MenuInformationItemOffset {
    param (
        [Parameter(Mandatory=$true)]
            [ValidateNotNull()]
            [Alias("Items")]
            [MenuInformationItem[]] $menuInfoItems, 

        [Parameter(Mandatory=$true)]
            [ValidateScript({$_ -ge 0 -and $_ -lt $menuInfoItems.Count})]
            [Alias("Index")]
            [int] $itemIndex
    )
    begin {
        $Offset = 0;
    }
    process {
        $InfoItem = $menuInfoItems[$itemIndex];
        
        if ($InfoItem.Label -ne $null) { 

            #Get Max Label length of all items.
            $MaxLabelLength = 0;
            foreach ($Item in $menuInfoItems) {
                if ((-not [string]::IsNullOrEmpty($Item.Label)) -and ( $Item.Label.Length -gt $MaxLabelLength)) { $MaxLabelLength = $Item.Label.Length; }
            }

            if ($InfoItem.Label.Count -lt $MaxLabelLength) {
                $Offset = $MaxLabelLength - $InfoItem.Label.Length;
            }
        }
    }
    end {
        $Offset;
    }
} ## Get-MenuInformationItemOffset

function Get-CenterAlignmentStartPosition {
    param (
        [Parameter(Mandatory=$true)] 
            [ValidateScript({$_ -ge 0})] 
            [Alias("Width")]
            [int] $menuWidth,

        [Parameter(Mandatory=$true)] 
            [ValidateNotNull()]
            [Alias("Text")] 
            [string] $inputText
    )
    begin {
        [int] $CenterAlignmentPostion = $null;
    }
    process {
        if (($inputText.Length -eq 0) -or ($inputText.Length -ge $menuWidth)) { $CenterAlignmentPostion = 0; }
        else {
            [int] $MenuMidWidth = $menuWidth / 2;
            [int] $TextMidWidth = $inputText.Length / 2;
            $CenterAlignmentPostion = $MenuMidWidth - $TextMidWidth;
        }
    }
    end {
        $CenterAlignmentPostion;
    }
} ## Get-CenterAlignmentStartPosition

function Write-CenterAlignedText {
    param (
        [Parameter(Mandatory=$true)]
            [ValidateScript({$_ -ge 0})] 
            [Alias("Width")]
            [int] $menuWidth,

        [Parameter(Mandatory=$true)]            
            [ValidateNotNull()] 
            [Alias("Text")]
            [string] $inputText,

        [Parameter(Mandatory=$true)]
            [Alias("Colour")]
            [System.ConsoleColor] $foregroundColour
    )
    begin {
        if ($inputText.Length -eq 0) { return }
        $Whitespace = "";
    }
    process {
        [int] $Indent = Get-CenterAlignmentStartPosition $menuWidth $inputText;
        for ($i = 0; $i -lt $Indent; $i++) { $Whitespace += " " } 
        $Output = $Whitespace + $inputText
        Write-Host $Output -ForegroundColor $foregroundColour
    }
    end {

    }
} ## Write-CenterAlignedText

function Write-InformationItems {
    param (
        [Parameter(ValueFromPipeline=$true, Mandatory=$true)] 
            [ValidateNotNull()] 
            [Alias("Items")] 
            [MenuInformationItem[]] $informationItems,

        [Parameter(Mandatory=$true)] 
            [Alias("Colour")] 
            [System.ConsoleColor] $foregroundColour,

        [Parameter(Mandatory=$true)] 
            [ValidateScript({$_ -ge 0})] 
            [Alias("Indent")] 
            [int] $indentation
    )
    begin {
        if ($informationItems.Count -eq 0) { return }
    }
    process {
        #Write-Host "";
        for ($i = 0; $i -lt $informationItems.Count; $i++) {
            $IndentOffset = (Get-MenuInformationItemOffset $informationItems $i) + $indentation;
            Write-IndentedText -indent $IndentOffset -text $informationItems[$i].ToString() -foregroundColour $foregroundColour 
        }
    }
} ## Write-InformationItems

function Write-IndentedText {
    param (
        [Parameter(Mandatory=$true)] 
            [ValidateScript({$_ -ge 0})] 
            [Alias("Indent")]
            [int] $indentation,

        [Parameter(Mandatory=$true)] 
            [ValidateNotNull()]
            [Alias("Text")] 
            [string] $inputText,

        [Parameter(Mandatory=$true)] 
            [Alias("Colour")]
            [System.ConsoleColor] $foregroundColour
    )
    process {
        for ($i = 0; $i -lt $indentation; $i++) { Write-Host " " -NoNewline }
        Write-Host $inputText -ForegroundColor $foregroundColour;
    }
} ## Write-IndentedText

function Write-MenuBorderLine {
    param (
        [Parameter(Mandatory=$true)]
            [ValidateScript({$_ -ge 0})] 
            [Alias("Width")]
            [int] $menuWidth,

        [Parameter(Mandatory=$true)]
            [ValidateNotNull()]
            [Alias("Character")] 
            [char] $borderCharacter,

        [Parameter(Mandatory=$true)]
            [Alias("Colour")]
            [System.ConsoleColor] $foregroundColour,

        [Parameter(Mandatory=$false)]
            [Alias("PrependNewLine")]
            [switch] $prependLine,

        [Parameter(Mandatory=$false)]
            [Alias("AppendNewLine")]
            [switch] $appendLine
    )
    process {
        if ($prependLine) { Write-Host "" }
        $Border = ""
        for ($i = 0; $i -lt $menuWidth; $i++) { $Border += $borderCharacter }
        Write-Host $Border -ForegroundColor $foregroundColour
        if ($appendLine) { Write-Host "" }
    }
} ## Write-MenuBorder

function Write-MenuOptionItems {
    param (
        [Parameter(ValueFromPipeline=$true, Mandatory=$true)] 
            [ValidateNotNull()] 
            [Alias("Items")] 
            [MenuOptionItem[]] $optionItems,

        [Parameter(Mandatory=$true)] 
            [Alias("OptionColour")] 
            [System.ConsoleColor] $optionItemColour,

        [Parameter(Mandatory=$true)] 
            [Alias("HeadingColour")] 
            [System.ConsoleColor] $headingTextColour,

        [Parameter(Mandatory=$true)] 
            [ValidateScript({$_ -ge 0})] 
            [Alias("Indent")] 
            [int] $indentation,

        [Parameter(Mandatory=$true)]
            [ValidateNotNull()]
            [Alias("UnderlineCharacter")]
            [char] $underlineChar
    )
    process {
        
        for ($i = 0; $i -lt $optionItems.Count; $i++) {            
            $Item = $optionItems[$i]

            ## Output Heading.
            if ($Item.IsHeading) {
                if ($i -ne 0) { Write-Host "" }
                Write-Host ""
                $HeadingIndentation = $indentation
                if ($HeadingIndentation -gt 0) { $HeadingIndentation = $HeadingIndentation / 2 }
                Write-UnderlinedText -Text  $Item.ToString() -Indent $HeadingIndentation -Colour $headingTextColour -UnderlineCharacter $underlineChar
                Write-Host ""
            }
            ## Output Option
            else {
                Write-IndentedText -Text $Item.ToString() -Indent $indentation -Colour $optionItemColour
            }
        }

    }

} ## Write-MenuOptionItems

function Write-UnderlinedText {
    param (
        [Parameter(Mandatory=$true)]            
            [ValidateNotNull()] 
            [Alias("Text")]
            [string] $inputText,

        [Parameter(Mandatory=$true)] 
            [ValidateScript({$_ -ge 0})] 
            [Alias("Indent")] 
            [int] $indentation,

        [Parameter(Mandatory=$true)]
            [Alias("Colour")]
            [System.ConsoleColor] $foregroundColour,
        
        [Parameter(Mandatory=$true)]
            [ValidateNotNullOrEmpty()]
            [Alias("UnderlineCharacter")]
            [char] $underlineChar,
        
        [Parameter(Mandatory=$false)]
            [ValidateScript({$_ -ge 0})] 
            [Alias("BlockMode")]
            [switch] $IsBlockMode
    )
    begin {
        $BlockModeRunLength = 5
        $Underline = "";
    }
    process {
                
        ## Calculate the Underline Block "**** **** ****"
        if ($IsBlockMode) { 
            for ($i = 0; $i -lt $BlockModeRunLength; $i++) { $UnderlineBlock += $underlineChar }

            do {
                $Underline += ($UnderlineBlock + " ")
            } while ($Underline.Length -lt $inputText.Length)
        }
        else {
            for ($i = 0; $i -lt $inputText.Length; $i++) { $Underline += $underlineChar }
        }

        ## Output the header text and underline.
        Write-IndentedText -Indent $indentation -Text $inputText -Colour $foregroundColour
        Write-IndentedText -Indent $indentation -Text $Underline -Colour $foregroundColour
    }
} ## Write-UnderlinedText

#endregion Private Functions