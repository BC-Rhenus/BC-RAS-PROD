page 50000 "Interface Setup"

//  RHE-TNA 17-03-2020..14-05-2020 BDS-3866
//  - Added field WMS Version
//  - Removed field "WMS uses Serial Number Table"

//  RHE-TNA 06-04-2020 BDS-4033 BEGIN
//  - Disables field "Send SSCC Info. with Invoice"

//  RHE-TNA 21-08-2020 BDS-4374
//  - Added field "Use Webshop Customer ID"

//  RHE-TNA 15-10-2020..19-10-2020 BDS-4551
//  - Added field "Send Ship Ready Message"
//  - Added field "Ship Ready Export Directory"
//  - Added field "Ship Ready Import Directory"

//  RHE-TNA 14-06-2021..21-06-2021 BDS-5337
//  - Removed FTP tab
//  - Modified Page properties
//  - Modified layout
//  - Added fields

//  RHE-TNA 18-10-2021 BDS-5678
//  - Added fields "Export Inventory Level", "Export Inventory Update", "Export Inventory Availability"
//  - Changed property Tooltip of field "Inv. Export Loc. Filter"
//  - Changed property Editable of field "Inv. Export Loc. Filter"

//  RHE-TNA 16-11-2021..25-02-2022 BDS-5676
//  - Modified layout
//  - Added fields
//  - Modified action("Activate / Deactivate")

//  RHE-TNA 02-02-2022 BDS-5585
//  - Modified fields Type, WMS Version
//  - Modified group "WMS Im-/Export"
//  - Disabled field WMS Version
//  - Added area(Navigation)

//  RHE-TNA 31-03-2022..19-04-2022 BDS-6233
//  - Added field "Order Status to Send"
//  - Added field "Order Version"

//  RHE-TNA 14-04-2022 BDS-6269
//  - Added field "Shipment Confirmation Version"
//  - Disabled fields "Add Line Type", "Add Ship-to/Bill-to Country" & "Add Payment Information"

{
    PageType = Card;
    //RHE-TNA 14-06-2021 BDS-5337 BEGIN
    /*
    ApplicationArea = All;
    UsageCategory = Administration;
    InsertAllowed = false;
    DeleteAllowed = false;
    */
    UsageCategory = None;
    SourceTable = "Interface Setup";
    //RHE-TNA 14-06-2021 BDS-5337 END

    layout
    {
        area(Content)
        {
            group(General)
            {
                Editable = not Active;
                field(Active; Active)
                {
                    Editable = false;
                }
                field(Type; Type)
                {
                    //RHE-TNA 19-01-2022 BDS-5585 BEGIN
                    ToolTip = 'Select option "Blue Yonder WMS" for integration with Blue Yonder WMS systems. Select option "External WMS" for integration with a WMS system other than Blue Yonder.';
                    //RHE-TNA 19-01-2022 BDS-5585 END
                }
                field(Description; Description)
                {

                }
            }
            group("WMS Im-/Export")
            {
                //RHE-TNA 19-01-2022 BDS-5585 BEGIN
                //Visible = (Type = Type::WMS);
                Visible = (Type = Type::"Blue Yonder WMS") or (Type = Type::"External WMS");
                //RHE-TNA 19-01-2022 BDS-5585 END
                Editable = not Active;

                //RHE-TNA 17-03-2020..14-05-2020 BDS-3866 BEGIN
                /*field("WMS Version"; "WMS Version")
                {
                    ApplicationArea = All;
                }*/
                //RHE-TNA 17-03-2020..14-05-2020 BDS-3866 END
                field("WMS Client ID"; "WMS Client ID")
                {
                    ApplicationArea = All;
                }
                field("WMS Site ID"; "WMS Site ID")
                {
                    ApplicationArea = All;
                }
                field("WMS Upload Directory"; "WMS Upload Directory")
                {
                    ApplicationArea = All;
                    ToolTip = 'Set the directory name where Business Central will save the files to be uploaded by WMS. Make sure to set full directory name and end with \.';
                }
                field("WMS Download Directory"; "WMS Download Directory")
                {
                    ApplicationArea = All;
                    ToolTip = 'Set the directory name where WMS will save the files to be uploaded by Business Central. Make sure to set full directory name and end with \.';
                }
                field("WMS Download Directory Processed"; "WMS Download Dir. Processed")
                {
                    ApplicationArea = All;
                    ToolTip = 'Set the directory name where succesfully imported files will be saved. Make sure to set full directory name and end with \.';
                }
            }
            group("Customer Order Import")
            {
                Visible = (Type = Type::Customer);
                Editable = not Active;
                group("Order Import Directories")
                {
                    field("Order Import Directory"; "Order Import Directory")
                    {
                        ApplicationArea = All;
                        ToolTip = 'Set the directory name where order files to import are saved. Make sure to set full directory name and end with \.';
                    }
                    field("Order Import Dir. Processed"; "Order Import Dir. Processed")
                    {
                        ApplicationArea = All;
                        ToolTip = 'Set the directory name where succesfully imported order files will be saved. Make sure to set full directory name and end with \.';
                    }
                    field("Order Import Dir. Error"; "Order Import Dir. Error")
                    {
                        ApplicationArea = All;
                        ToolTip = 'Set the directory name where unsuccesfully imported order files will be saved. Make sure to set full directory name and end with \.';
                    }
                }
                group("Order Import Settings")
                {
                    field("Interface Identifier"; "Interface Identifier")
                    {
                        ApplicationArea = All;
                        ToolTip = 'Set the identifier for interfaces to use settings of current record.';
                    }
                    /*RHE-TNA 06-04-2020 BDS-4033 BEGIN
                    field("Send SSCC info. with Invoice"; "Send SSCC info. with Invoice")
                    {
                        ApplicationArea = All;
                    }
                    RHE-TNA 06-04-2020 BDS-4033 END*/

                    //  RHE-TNA 21-08-2020 BDS-4374 BEGIN
                    field("Disable EDI Customer ID"; "Disable Webshop Customer ID")
                    {
                        ApplicationArea = All;
                        ToolTip = 'If set, customer in Sales Order equals "Order Import Cust. No. B2B/B2C".';
                    }
                    //  RHE-TNA 21-08-2020 BDS-4374 END
                    field("Order Import Cust. No. B2B"; "Order Import Cust. No. B2B")
                    {
                        ApplicationArea = All;
                    }
                    field("Order Import Cust. No. B2C"; "Order Import Cust. No. B2C")
                    {
                        ApplicationArea = All;
                    }
                    field("Order Import Discount Account"; "Order Import Discount Account")
                    {
                        ApplicationArea = All;
                    }
                    field("Order Import Ship Cost Account"; "Order Import Ship Cost Account")
                    {
                        ApplicationArea = All;
                    }
                    field("Order Import Doc. Cost Account"; "Order Import Doc. Cost Account")
                    {
                        ApplicationArea = All;
                    }
                    field("Order Import Order ID Usage"; "Order Import Order ID Usage")
                    {
                        ApplicationArea = All;
                    }
                    field("Order Import Order Nos."; "Order Import Order Nos.")
                    {
                        ApplicationArea = All;
                        Editable = ("Order Import Order ID Usage" = 1); //1 = Option "External Doc. No."
                    }
                    field("Add Error Text"; "Add Error Text")
                    {
                        ApplicationArea = All;
                        ToolTip = 'If set, an error text value will be added to the Order XML file (if applicable).';
                    }
                }
            }
            //RHE-TNA 16-11-2021 BDS-5676 BEGIN
            //group("Customer Shipment Export")
            group("Customer Order/Shipment Export")
            //RHE-TNA 16-11-2021 BDS-5676 END
            {
                Visible = (Type = Type::Customer);
                Editable = not Active;
                group("Order/Shipment Export Directories")
                {
                    field("Sales Order Export Directory"; "Sales Order Export Directory")
                    {
                        ApplicationArea = All;
                        ToolTip = 'Set the directory name where sales order files will be saved. Make sure to set full directory name and end with \.';
                        Editable = "Send Sales Order Message";
                    }
                    field("Ship Confirmation Directory"; "Ship Confirmation Directory")
                    {
                        ApplicationArea = All;
                        ToolTip = 'Set the directory name where shipment confirmation files will be saved. Make sure to set full directory name and end with \.';
                    }
                    field("Ship Ready Directory"; "Ship Ready Export Directory")
                    {
                        ApplicationArea = All;
                        ToolTip = 'Set the directory name where ship ready files will be saved. Make sure to set full directory name and end with \.';
                        Editable = "Send Ship Ready Message";
                    }
                    field("Ship Ready Import Directory"; "Ship Ready Import Directory")
                    {
                        ApplicationArea = All;
                        ToolTip = 'Set the directory name where ship ready files to import are saved. Make sure to set full directory name and end with \.';
                        Editable = "Send Ship Ready Message";
                    }
                    field("Ship Ready Dir. Processed"; "Ship Ready Dir. Processed")
                    {
                        ApplicationArea = All;
                        ToolTip = 'Set the directory name where succesfully imported ship ready files will be saved. Make sure to set full directory name and end with \.';
                        Editable = "Send Ship Ready Message";
                    }
                }
                group("Settings")
                {
                    field("Use for Manually Created Sales Orders"; "Manually Created S.-Orders")
                    {
                        ApplicationArea = All;
                        Caption = 'Use for Manually Created Sales Orders';
                        ToolTip = 'Use these export settings also for manually created Sales Orders.';
                    }
                }
                group("Order Export Settings")
                {
                    field("Send Sales Order Message"; "Send Sales Order Message")
                    {
                        ApplicationArea = All;
                    }
                    field("Qty. of Orders per XML"; "Qty. of Orders per XML")
                    {
                        ApplicationArea = All;
                        ToolTip = 'Set if an XML file will be created per Sales Order or if one XML file containing multiple Sales Orders will be created.';
                        Editable = "Send Sales Order Message";
                    }
                    field("Send New Sales Orders Only"; "Send New Sales Orders Only")
                    {
                        ApplicationArea = All;
                        ToolTip = 'With this setting turned on, only Sales Orders which are not exported before will be send. Otherwise all Sales Orders will be send.';
                        Editable = "Send Sales Order Message";
                    }
                    field("Order Status to Send"; "Order Status to Send")
                    {
                        Editable = "Send New Sales Orders Only";
                    }

                    field("Send IF Received Orders"; "Send IF Received Orders")
                    {
                        ApplicationArea = All;
                        ToolTip = 'With this setting turned on, Sales Orders which are received via an interface from the customer will be send.';
                        Editable = "Send Sales Order Message";
                    }
                    field("Order Version"; "Order Version")
                    {
                        ApplicationArea = All;
                        Editable = "Send Sales Order Message";
                    }
                }
                group("Shipment Export Settings")
                {
                    field("Send Ship Ready Message"; "Send Ship Ready Message")
                    {
                        ApplicationArea = All;
                    }
                    field("Shipment Confirmation Version"; "Shipment Confirmation Version")
                    {
                        ApplicationArea = All;
                    }
                    /*
                    field("Add Line Type"; "Add Line Type")
                    {
                        ApplicationArea = All;
                        Caption = 'Add Line Type to Shipment Confirmation';
                        ToolTip = 'If set, the line type (Item, G/L Account, ...) will be added to the Shipment confirmation file.';
                    }                    
                    field("Add Ship-to/Bill-to Country"; "Add Ship-to/Bill-to Country")
                    {
                        ApplicationArea = All;
                        ToolTip = 'If set, the Ship-to Country and Bill-to Country will be added to the Shipment confirmation file.';
                    }
                    field("Add Payment Information"; "Add Payment Information")
                    {
                        ApplicationArea = All;
                        ToolTip = 'If set, the Payment Terms, Due Date and VAT Number will be added to the Shipment confirmation file.';
                    }
                    */
                }
            }
            group("Customer Inventory Export")
            {
                Visible = (Type = Type::Customer);
                Editable = not Active;
                group("Inventory Export Directories")
                {
                    field("Inv. Export Directory"; "Inv. Export Directory")
                    {
                        ApplicationArea = All;
                        ToolTip = 'Set the directory name where inventory level files will be saved. Make sure to set full directory name and end with \.';
                    }
                }
                group("Inventory Export Settings")
                {
                    field("Export Inventory Level"; "Export Inventory Level")
                    {
                        ApplicationArea = All;
                    }
                    field("Export Inventory Update"; "Export Inventory Update")
                    {
                        ApplicationArea = All;
                        ToolTip = 'Set if an XML file will be created for Inventory Adjustments and Inventory Reclassification entries.';
                    }
                    field("Export Inventory Availability"; "Export Inventory Availability")
                    {
                        ApplicationArea = All;
                    }
                    field("Inv. Export Loc. Filter"; "Inv. Export Loc. Filter")
                    {
                        ApplicationArea = All;
                        ToolTip = 'Set a Location filter to calculate the available inventory level to be exported to the customer. To use multiple Locations in the filter use the pipe sign (|).';
                        Editable = "Export Inventory Availability";
                    }
                }
            }
        }
    }

    actions
    {
        area(Processing)
        {
            action("Activate / Deactivate")
            {
                Image = Approve;
                trigger OnAction()
                var
                    IFSetup: Record "Interface Setup";
                begin
                    if Active then
                        if Dialog.Confirm('Are you sure you want to deactivate this interface setup?') then begin
                            Rec.Validate(Active, false);
                            Rec.Modify(true);
                        end else
                            Message('Process canceled.')
                    else
                        if Dialog.Confirm('Are you sure you want to activate this interface setup?') then begin
                            if Type = Type::Customer then begin
                                IFSetup.SetRange(Type, IFSetup.Type::Customer);
                                IFSetup.SetRange(Active);
                                IFSetup.SetFilter("Entry No.", '<>%1', "Entry No.");
                                if IFSetup.FindSet() then
                                    repeat
                                        if IFSetup."Interface Identifier" = "Interface Identifier" then
                                            Error('"Interface Identifier" cannot contain current value (' + "Interface Identifier" + '), another active record already exists with this value.');
                                        if IFSetup."Order Import Directory" = "Order Import Directory" then
                                            Error('"Order Import Directory" cannot contain current value (' + "Order Import Directory" + '), another active record already exists with this value.');
                                        //RHE-TNA 16-11-2021 BDS-5676 BEGIN
                                        if "Send Ship Ready Message" then
                                            //RHE-TNA 16-11-2021 BDS-5676 END
                                            if (IFSetup."Send Ship Ready Message") and (IFSetup."Ship Ready Import Directory" = "Ship Ready Import Directory") then
                                                Error('"Ship Ready Import Directory" cannot contain current value (' + "Ship Ready Import Directory" + '), another active record already exists with this value.');
                                    until IFSetup.Next() = 0;
                            end;
                            Rec.Validate(Active, true);
                            Rec.Modify(true);
                        end else
                            Message('Process canceled.');
                end;
            }
        }
        area(Navigation)
        {
            action("Condition & Lock Code Setup")
            {
                ToolTip = 'Setup relationships between Locations and WMS Condition & Lock Codes.';
                Image = Change;
                RunObject = page "WMS Inventory Location Setup";
                RunPageLink = "Interface Setup Entry No." = field ("Entry No.");
            }
        }
    }

    trigger OnOpenPage()
    begin
        /*RHE-TNA 14-06-2021 BDS-5337 BEGIN
        Reset();
        if not Get() then begin
            Init();
            Insert();
        end;
        RHE-TNA 14-06-2021 BDS-5337 END*/
    end;
}