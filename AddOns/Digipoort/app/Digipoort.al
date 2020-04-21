// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
codeunit 50102 "Digipoort"
{
    trigger OnRun()
    var
    begin
    end;

    procedure FuncSubmitTax(ParMessageType: Text; XmlContent: Text; FileName: Text; Reference: Text; RequestUrl: Text; ClientCertName: Text; ServiceCertName: Text; MessageType: Text; VATReg: Text; Var MessageID: Text; VAR ParError: Text)
    var
        DeliveryService: DotNet digipoortServices;
        Request: DotNet aanleverRequest;
        Response: DotNet aanleverResponse;
        Identity: DotNet identiteitType;
        Content: DotNet berichtInhoudType;
        Fault: DotNet foutType;
        UTF8Encoding: DotNet UTF8Encoding;
        PreviewFile: File;
        UseVATRegNo: Text[20];
        VarServicePointManagerLoc: DotNet ServicePointManager;
        VarSecurityProtocolTypeLoc: DotNet SecurityProtocolType;
        VarEncoding: Option "UTF-8","UTF-16","ISO-8859-1";
    begin
        Request := Request.aanleverRequest;
        Response := Response.aanleverResponse;
        Identity := Identity.identiteitType;
        Content := Content.berichtInhoudType;
        Fault := Fault.foutType;
        VarServicePointManagerLoc.SecurityProtocol := VarSecurityProtocolTypeLoc.Tls12;  //SGN4172

        UTF8Encoding := UTF8Encoding.UTF8Encoding;

        with Identity do begin
            nummer := VATReg;
            type := 'LHnr'; //SGN2835
        end;

        with Content do begin
            mimeType := 'application/xml';
            bestandsnaam := StrSubstNo('%1.xbrl', MessageType);
            inhoud := UTF8Encoding.GetBytes(XmlContent);
        end;

        with Request do begin
            berichtsoort := MessageType;
            aanleverkenmerk := Reference;
            identiteitBelanghebbende := Identity;
            rolBelanghebbende := 'Bedrijf';
            berichtInhoud := Content;
            autorisatieAdres := 'http://geenausp.nl'
        end;

        Response := DeliveryService.Deliver(Request,
            RequestUrl,
            ClientCertName,
            ServiceCertName,
            30);

        Fault := Response.statusFoutcode;
        ParError := Fault.foutcode;
        MessageID := Response.kenmerk;
    end;
}