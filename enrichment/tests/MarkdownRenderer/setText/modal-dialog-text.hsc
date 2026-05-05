// setup

# Startup & health check
/hise
/expect status contains online or abort
playground open
/exit

/builder reset

/script
/callback onInit
// end setup
// Context: A modal dialog uses markdown for its title and body text,
// updating both when the dialog is shown with different messages.

const var dialogPanel = Content.addPanel("DialogPanel", 0, 0);
dialogPanel.set("width", 450);
dialogPanel.set("height", 250);
dialogPanel.set("visible", false);

const var md = Content.createMarkdownRenderer();

// Set initial placeholder text
md.setText("#### Save Preset\nEnter the name of the preset.");

inline function showDialog(title, body)
{
    // Build markdown string with heading + body each time
    md.setText("#### " + title + "\n" + body);
    dialogPanel.set("visible", true);
    dialogPanel.repaint();
}

dialogPanel.setPaintRoutine(function(g)
{
    g.setColour(0xFFDDDDDD);
    g.fillRoundedRectangle(this.getLocalBounds(0), 10);

    local box = [40, 20, this.getWidth() - 80, this.getHeight() - 40];
    md.setTextBounds(box);
    g.drawMarkdownText(md);
});

// Show different dialogs by changing the text
showDialog("Confirm Delete", "Are you sure you want to **delete** this item?");
// test
/compile

# Verify
/expect dialogPanel.get('visible') is true
/expect md.setTextBounds([0, 0, 370, 1000]) > 0 is true
/exit
// end test
