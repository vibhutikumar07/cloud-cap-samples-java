using {sap.common.Languages as CommonLanguages} from '@sap/cds/common';
using {my.bookshop as my} from '../db/index';
using {sap.changelog as changelog} from 'com.sap.cds/change-tracking';

extend my.Orders with changelog.changeTracked;

@path : 'admin'
service AdminService @(requires: [
    'admin',
    'system-user'
]) {
  entity Books   as projection on my.Books excluding { reviews } actions {
    action addToOrder(order_ID : UUID, quantity : Integer) returns Orders;
  }

  entity Books.attachments as projection on my.Books.attachments
  actions {
    @(Common.SideEffects : {TargetEntities: ['']},)
    action copyAttachments(in:many $self,up__ID:String,objectIds:String);
  }

  entity Books.references as projection on my.Books.references
  actions {
    @(Common.SideEffects : {TargetEntities: ['']},)
    action copyAttachments(in:many $self,up__ID:String,objectIds:String);
  }

  entity Books.footnotes as projection on my.Books.footnotes
  actions {
    @(Common.SideEffects : {TargetEntities: ['']},)
    action copyAttachments(in:many $self,up__ID:String,objectIds:String);
  }

  entity Authors as projection on my.Authors;
  entity Orders  as select from my.Orders;

  @cds.persistence.skip
  entity Upload @odata.singleton {
    csv : LargeBinary @Core.MediaType : 'text/csv';
  }
}

// Deep Search Items
annotate AdminService.Orders with @cds.search : {
  OrderNo,
  Items
};

annotate AdminService.OrderItems with @cds.search : {book};

annotate AdminService.Books with @cds.search : {
  descr,
  title
};

// Enable Fiori Draft for Orders
annotate AdminService.Orders with @odata.draft.enabled;
annotate AdminService.Books with @odata.draft.enabled;

// workaround to enable the value help for languages
// Necessary because auto exposure is currently not working
// for if Languages is only referenced by the generated
// _texts table
extend service AdminService with {
  entity Languages as projection on CommonLanguages;
}

// Change-track orders and items
annotate AdminService.Orders {
  OrderNo @changelog;
};

annotate AdminService.OrderItems {
  quantity @changelog;
  book @changelog: [
    book.title,
    book.isbn
  ]
};

// Assign identifiers to the tracked entities
annotate AdminService.Orders with @changelog: [OrderNo];
annotate AdminService.OrderItems with @changelog: [
    parent.OrderNo,
    book.title,
  ];
