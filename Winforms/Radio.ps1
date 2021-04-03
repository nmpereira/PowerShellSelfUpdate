Add-Type -AssemblyName System.Windows.Forms
[System.Reflection.Assembly]::LoadWithPartialName("System.windows.forms")
Add-Type -AssemblyName System.Drawing
$form1=New-Object System.Windows.Forms.Form
$form1.StartPosition='CenterScreen'

$gb = New-Object System.Windows.Forms.GroupBox
$form1.Controls.Add($gb)

$rb1 = New-Object System.Windows.Forms.RadioButton
$gb.Controls.Add($rb1)
$rb1.Text = 'One'
$rb1.Location = '10,10'
$rb1.Checked =$true

$rb2 = New-Object System.Windows.Forms.RadioButton
$gb.Controls.Add($rb2)
$rb2.Text = 'Two'
$rb2.Location = '10,30'

$rb3 = New-Object System.Windows.Forms.RadioButton
$gb.Controls.Add($rb3)
$rb3.Text = 'Three'
$rb3.Location = '10,50'

$button1 = New-Object System.Windows.Forms.Button

$button1.Text = 'ok'
$button1.width                       = 240
$button1.height                      = 30
$button1.location                    = New-Object System.Drawing.Point(120,36)
$button1.Text = "Show Dialog Box"



$Form1.controls.AddRange(@($button1))
function check {
 
   $value=  $gb.Controls | Where-Object{ $_.Checked } | Select-Object Text
     #Use the $this variable to access the calling control
    #Only set the Label if this radio button is checked
        if($rb1.Checked -eq$true)
        {
            #Use the Radio Button's Text to set the label
           # write-host $value  
        }
       # write-host $value  
}


$button1.Add_Click(

      $gb.Controls | Where-Object{ $_.Checked } | Select-Object Text

)



$form1.ShowDialog()
#$value=$gb.Controls | Where-Object{ $_.Checked } | Select-Object Text



    
    
