using my.bookshop as my from '../db/books';
using {sap.attachments.Attachments, sap.attachments.StatusCode} from`com.sap.cds/sdm`;

extend entity my.Books with {
    attachments : Composition of many Attachments  @SDM.Attachments:{maxCount: 2, maxCountError:'You are allowed to upload only 2 attachments in this section'};
}

entity Statuses @cds.autoexpose @readonly {
    key code : StatusCode;
        text : localized String(255);
}

extend Attachments with {
    statusText : Association to Statuses on statusText.code = $self.status;
}

annotate Books.attachments with {
    status @(
        Common.Text: {
            $value: ![statusText.text],
            ![@UI.TextArrangement]: #TextOnly
        },
        ValueList: {entity:'Statuses'},
        sap.value.list: 'fixed-values'
    );
}