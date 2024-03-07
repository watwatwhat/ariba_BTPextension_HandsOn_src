namespace my.ariba;

using {managed} from '@sap/cds/common';

@cds.search: {
  createdDateFrom: true,
  createdDateTo  : true,
  ApprovedState  : false
}
entity C_Requisitions {
      // ============== Filter Fields ==============
      createdDateFrom        : DateTime       @mandatory                              @title        : '検索開始日付';
      createdDateTo          : DateTime       @cds.on.insert: '2023-07-30T00:00:00Z'  @cds.on.update: '2023-07-30T00:00:00Z'  @title: '検索終了日付';
      // ============== Data Fields ==============
  key InitialUniqueName      : String         @title        : '購買依頼ID';
      ApprovedState          : Integer        @title        : '承認状況';
      Name                   : String         @title        : '購買依頼名';
      SubmitDate             : DateTime       @title        : '提出日時';
      CreateDate             : DateTime       @title        : '作成日時';
      SourcingStatus         : Integer        @title        : '見積ステータス';
      HoldTillDate           : DateTime       @title        : '有効期限';
      ReceivedState          : Integer        @title        : '受領状況';
      ExternalReqId          : String         @title        : '外部購買依頼ID';
      NumberReceivableOrders : Integer        @title        : '受領可能発注番号';
      SentDate               : DateTime       @title        : '送信日時';
      ChargeAmount           : Integer        @title        : '請求数量';
      BlanketOrderID         : String         @title        : 'ブランケットオーダーID';
      LastModified           : DateTime       @title        : '最終編集日時';
      ExternalReqUrl         : String         @title        : '外部購買依頼URL';
      TimeCreated            : DateTime       @title        : '作成日時';
      VATAmount              : Integer        @title        : 'VAT数量';
      InvoicedDate           : DateTime       @title        : '請求日付';
      AmountAccepted         : Integer        @title        : '受諾数量';
      TotalCost              : {
        AmountInReportingCurrency  : Integer  @title        : '総コスト - 金額(請求通貨)';
        ApproxAmountInBaseCurrency : Integer  @title        : '総コスト - 金額(基準通貨)';
        Amount                     : Integer  @title        : '総コスト - 金額';
        ConversionDate             : DateTime @title        : '総コスト - 換金日時';
        Currency                   : {
          UniqueName               : String   @title        : '総コスト - 通貨';
        };
      };
      TaxAmount              : {
        AmountInReportingCurrency  : Integer  @title        : '税額 - 金額(請求通貨)';
        ApproxAmountInBaseCurrency : Integer  @title        : '税額 - 金額(基準通貨)';
        Amount                     : Integer  @title        : '税額 - 金額';
        ConversionDate             : DateTime @title        : '税額 - 換金日時';
        Currency                   : {
          UniqueName               : String   @title        : '税額 - 通貨';
        }
      };
      Requester              : {
        UniqueName                 : String   @title        : '依頼者 - 名前';
        PasswordAdapter            : String   @title        : '依頼者 - パスワードアダプタ';
      };
      LineItems              : Association[1, * ] to C_Requisitions__to_LineItems
                                 on LineItems.parent = $self;
      ApprovalRecords        : Association[1, * ] to C_Requisitions__to_ApprovalRecords
                                 on ApprovalRecords.parent = $self;

// ApprovalRecords        : String;

// action openAribaPage()
// returns String;
}

entity C_Requisitions__to_ApprovalRecords {
      // ============== Filter Fields ==============
      createdDateFrom   : DateTime  @mandatory                              @title        : '検索開始日付';
      createdDateTo     : DateTime  @cds.on.insert: '2023-07-30T00:00:00Z'  @cds.on.update: '2023-07-30T00:00:00Z'  @title: '検索終了日付';
      // ============== Data Fields ==============
  key parent            : Association to C_Requisitions;
      Comment           : String    @title        : 'コメント';
      State             : Integer   @title        : '承認状態';
      ActivationDate    : DateTime  @title        : '有効化日付';
      ReceivedFromEmail : String    @title        : 'Emailから受領';
      Date              : DateTime  @title        : '承認日付';
      RealUser          : String    @title        : 'リアルユーザー';
      User              : {
        UniqueName      : String    @title        : '承認者 - 名前';
        PasswordAdapter : String    @title        : '承認者 - パスワードアダプタ';
      }
}

entity C_Requisitions__to_LineItems {
  key parent                             :      Association to C_Requisitions;
      Description_ShortName              :      String;
      Description_UnitOfMeasure          : String;
      // Custom Supplier: 本来はオブジェクトだが、Supplier.Nameをハンドラで抽出した
      Supplier                           : String;

      Description_ExtAttributesBitMask   :      Integer;
      GBFormDocumentId                   :      String;
      ExternalLineNumber                 :      Integer;
      OriginalPrice                      : {
        AmountInReportingCurrency  : Integer;
        ApproxAmountInBaseCurrency : Integer;
        Amount                     : Integer;
        ConversionDate             : DateTime;
        Currency                   : {
          UniqueName               : String;
        };
        AccountCategory            : {
          UniqueName               : String;
        };
      };
      Description_CommonCommodityCode    :      String;
      NumberConfirmedAccepted            :      String;
      ChargeAmount                       :      Integer;
      SplitAccountings                   : many C_Requisitions_LineItems_SplitAccountings;
      TaxAmount                          :      String;
      ItemCategory                       : {
        UniqueName                 : String;
      };
      VATAmount                          :      String;
      ERSAllowed                         :      Boolean;
      AccountingTemplate                 :      String;
      DueOn                              :      DateTime;
      PurchaseOrg                        : {
        UniqueName                 : String;
      };
      DiscountAmount                     :      Integer;
      QuickSourced                       :      Boolean;
      OverallLimit                       :      String;
      MasterAgreement                    :      String;
      PODeliveryDate                     :      DateTime;
      NumberOnPO                         :      Integer;
      IsAdHoc                            :      Boolean;
      OriginatingSystem                  :      String;
      POStatus                           :      Integer;
      POUnitOfMeasure                    :      String;
      NumberConfirmedAcceptedWithChanges :      String;
      BillingAddress                     : {
        State                      : String;
        Phone                      : String;
        Country                    : {
          UniqueName               : String;
        };
        PostalCode                 : String;
        City                       : String;
        Fax                        : String;
        UniqueName                 : String;
        Name                       : String;
        Lines                      : String
      };
      NumberInCollection                 :      String;
      NumberShipped                      :      Integer;
      SourcingRequest                    :      String;
      CommodityCode                      : {
        UniqueName                 : String;
      };
      QuotePricingTermsNumber            :      Integer;
      DeliverTo                          :      String;
      UsedInReqPush                      :      Boolean;
      CarrierMethod                      :      String;
      Amount                             : {
        AmountInReportingCurrency  : Integer;
        ApproxAmountInBaseCurrency : Integer;
        Amount                     : Integer;
        ConversionDate             : DateTime;
        Currency                   : {
          UniqueName               : String;
        };
      };
      EndDate                            :      DateTime;
      QuantityInKitItem                  :      String;
      ParentKit                          :      Boolean;
      NeedBy                             :      DateTime;
      KitRequiredItem                    :      Boolean;
      ShipTo                             : {
        State                      : String;
        Phone                      : String;
        Country                    : {
          UniqueName               : String;
        };
        PostalCode                 : String;
        City                       : String;
        Fax                        : String;
        UniqueName                 : String;
        Name                       : String;
        Lines                      : String;
      };
      ItemMasterID                       :      String;
      POUnitPrice                        :      Integer;
      CommodityExportMapEntry            : {
        CommodityCode              : {
          UniqueName               : String;
          Name                     : String;
        };
        AccountType                : {
          UniqueName               : String;
          Name                     : String;
        };
        UniqueName                 : String;
      };
      BasePrice                          :      Integer;
      IsPriceModifiedByUser              :      Boolean;
      SupplierLocation                   : {
        UniqueName                 : String;
      };
      OrderID                            :      String @title: '購買伝票番号';
      KitInstanceId                      :      String;
      StartDate                          :      DateTime;
      ParentLineNumber                   :      Integer;
      IsRecurring                        :      Boolean;
      NumberConfirmedSubstituted         :      String;
      BuyerName                          :      String;
      Carrier                            :      String;
      NumberConfirmedBackOrdered         :      String;
      OriginatingSystemLineNumber        :      Integer;
      ERPLineItemNumber                  :      Integer;
      Kit                                :      String;
      PurchaseGroup                      : {
        UniqueName                 : String;
      };
      Form                               :      String;
      BuyerItemMaster                    :      String;
      NumberConfirmedRejected            :      String;
      PaymentTerms                       : {
        UniqueName                 : String;
      };
      SAPPOLineNumber                    :      Integer;
      PushStatus                         :      Integer;
      TaxCode                            :      String;
      LineType                           : {
        UniqueName                 : String;
      };
      ERPPONumber                        :      String;
      BoughtFromPreferredSupplier        :      Boolean;
      Quantity                           :      Integer;
      OrderInfo                          :      String;
      ExpectedValue                      :      String;
      POQuantity                         :      Integer;
      ChangedBy                          : {
        UniqueName                 : String;
        PasswordAdapter            : String;
      };
//           "ApprovedDate": "2021-10-05T02:01:37Z",
//           "LastCheckDate": null,
//           "OrderedState": 4,
//           "PreviousApprovalRequestsVersion": 16,
//           "ResubmitDate": null,
//           "NumberCleared": 0E-10,
//           "DiscountAmount": null,
//           "RealTimeBudgetResponse": null,
//           "ApprovalRequests": [
//               {
//                   "AllowEscalationPeriodExtension": false,
//                   "IsEscalatedToList": false,
//                   "IsEscalationExtended": false,
//                   "Creator": null,
//                   "ExtendEscalationUserComments": "",
//                   "EscalationExtensionDate": null,
//                   "ApproverComment": "",
//                   "Reason": "@ruleReasons/FinanceOverLimit",
//                   "AssignedTo": null,
//                   "EscalationWarningDate": null,
//                   "ReportingReason": "Finance must approve approvable above certain limits",
//                   "ManuallyAdded": false,
//                   "AssignedDate": null,
//                   "EscalationDate": null,
//                   "State": 8,
//                   "ExtendEscalationReasonCode": "",
//                   "ReportingExtendEscalationReason": "",
//                   "ApprovedBy": {
//                       "UniqueName": "ywang",
//                       "PasswordAdapter": "ThirdPartyUser"
//                   },
//                   "ApprovalRequired": true,
//                   "Approver": {
//                       "UniqueName": "Finance"
//                   },
//                   "ActivationDate": "2021-10-05T02:00:55Z",
//                   "RuleName": "Requisition Cap Rule",
//                   "EscalationExtendedByUser": null
//               }
//           ],
//           "Active": true,
//           "ReceivedDate": null,
//           "ProcurementUnit": {
//               "UniqueName": "100"
//           },
//           "AmountBilled": null,
//           "NextVersion": null,
//           "ERPRequisitionID": "",
//           "NumberBilled": 0E-10,
//           "UniqueName": "PR185",
//           "IsForecast": false,
//           "ReportingCurrency": {
//               "UniqueName": "JPY"
//           },
//           "BudgetCheckStatus": 0,
//           "OrderedDate": "2021-10-05T02:01:40Z",
//           "SourcingStatusMessage": "",
//           "IsServiceRequisition": false,
//           "AreOrdersStuck": false,
//           "AmountCleared": null,
//           "ProjectID": "",
//           "OriginatingSystem": "",
//           "PaymentTerms": null,
//           "CustomCatalogPurchaseOrg": {
//               "UniqueName": "1000"
//           },
//           "SourcingStatusString": "",
//           "AmountReconciled": null,
//           "ExternalSourcingId": "",
//           "PreCollaborationTotalCost": null,
//           "AmountRejected": null,
//           "Supplier": null,
//           "BlanketOrder": null,
//           "BudgetRefID": "",
//           "StatusString": "Ordered",
//           "PreviousVersion": null,
//           "ApprovalRequestsVersion": 18,
//           "AmountInvoiced": null,
//           "TimeUpdated": "2021-10-05T02:24:43Z",
//           "VersionNumber": 1,
//           "OriginatingSystemReferenceID": "",
//           "CollaborationState": {
//               "Order": null,
//               "Supplier": null,
//               "CancelReason": null,
//               "Reason": null,
//               "State": 1,
//               "Mode": 0
//           },
//           "IsExternalReq": false,
//           "Type": "ariba.purchasing.core.Requisition",
//           "ProjectTitle": "",
//           "Attachments.Attachments": null,
//           "IsServiceOrder": false,
//           "BudgetCheckStatusMessage": null,
//           "Preparer": {
//               "UniqueName": "ywang",
//               "PasswordAdapter": "ThirdPartyUser"
//           },
//           "CompanyCode": {
//               "UniqueName": "1000"
//           }
}

type C_Requisitions_ApprovalRecords {
  Comment           : String;
  State             : Integer;
  ActivationDate    : DateTime;
  ReceivedFromEmail : String;
  Date              : DateTime;
  RealUser          : String;
  User              : {
    UniqueName      : String;
    PasswordAdapter : String;
  }
}

type C_Requisitions_LineItems_SplitAccountings {
  // Custom UnitOfMeasureをLineItemsの階層から移動
  Description_UnitOfMeasure: String;

  PONumber                     : String;
  ERPSplitValue                : String;
  WBSElement                   : String;
  Percentage                   : Integer;
  Quantity                     : Integer;
  InternalOrder                : String;
  NumberInCollection           : Integer;
  Type                         : {
    UniqueName                 : String;
  };
  ProcurementUnit              : {
    UniqueName                 : Integer;
  };
  CostCenter                   : {
    ProcurementUnit            : String;
    UniqueName                 : String;
    CompanyCode                : {
      UniqueName               : String;
    };
    CostCenterDescription      : String;
  };
  POLineNumber                 : String;
  Amount                       : {
    AmountInReportingCurrency  : Integer;
    ApproxAmountInBaseCurrency : Integer;
    Amount                     : Integer;
    ConversionDate             : DateTime;
    Currency                   : {
      UniqueName               : String;
    }
  };
  GeneralLedger                : {
    GeneralLedgerDescription   : String;
    GeneralLedgerDescription2  : String;
    UniqueName                 : String;
    CompanyCode                : {
      UniqueName               : String;
    };
    FieldStatusGroup           : String;
    ExternalId                 : String;
  };
  Asset                        : String;
  CompanyCode                  : String;
}

// type C_Requisitions_TotalCost {
//   AmountInReportingCurrency  : Integer;
//   ApproxAmountInBaseCurrency : Integer;
//   Amount                     : Integer;
//   ConversionDate             : DateTime;
//   Currency                   : {
//     UniqueName               : String;
//   }
// }

// type C_Requisitions_TaxAmount {
//   AmountInReportingCurrency  : Integer;
//   ApproxAmountInBaseCurrency : Integer;
//   Amount                     : Integer;
//   ConversionDate             : DateTime;
//   Currency                   : {
//     UniqueName               : String;
//   }
// }

// type C_Requisitions_Requester {
//   UniqueName      : String;
//   PasswordAdapter : String;
// }

type C_Requisitions_LineItems {
  GBFormDocumentId                   :      String;
  ExternalLineNumber                 :      Integer;
  OriginalPrice                      : {
    AmountInReportingCurrency        :      Integer;
    ApproxAmountInBaseCurrency       :      Integer;
    Amount                           :      Integer;
    ConversionDate                   :      DateTime;
    Currency                         : {
      UniqueName                     :      String;
    };
    AccountCategory                  : {
      UniqueName                     :      String;
    };
  };
  NumberConfirmedAccepted            :      String;
  ChargeAmount                       :      Integer;
  SplitAccountings                   : many C_Requisitions_LineItems_SplitAccountings;
  TaxAmount                          :      String;
  ItemCategory                       : {
    UniqueName                       :      String;
  };
  VATAmount                          :      String;
  ERSAllowed                         :      Boolean;
  AccountingTemplate                 :      String;
  DueOn                              :      DateTime;
  PurchaseOrg                        : {
    UniqueName                       :      String;
  };
  DiscountAmount                     :      Integer;
  QuickSourced                       :      Boolean;
  OverallLimit                       :      String;
  MasterAgreement                    :      String;
  PODeliveryDate                     :      DateTime;
  NumberOnPO                         :      Integer;
  IsAdHoc                            :      Boolean;
  OriginatingSystem                  :      String;
  POStatus                           :      Integer;
  POUnitOfMeasure                    :      String;
  NumberConfirmedAcceptedWithChanges :      String;
  BillingAddress                     : {
    State                            :      String;
    Phone                            :      String;
    Country                          : {
      UniqueName                     :      String;
    };
    PostalCode                       :      String;
    City                             :      String;
    Fax                              :      String;
    UniqueName                       :      String;
    Name                             :      String;
    Lines                            :      String
  };
  NumberInCollection                 :      String;
  NumberShipped                      :      Integer;
  SourcingRequest                    :      String;
  CommodityCode                      : {
    UniqueName                       :      String;
  };
  QuotePricingTermsNumber            :      Integer;
  Supplier                           : {
    UniqueName                       :      String;
    Name                             :      String;
  };
  DeliverTo                          :      String;
  UsedInReqPush                      :      Boolean;
  CarrierMethod                      :      String;
  Amount                             : {
    AmountInReportingCurrency        :      Integer;
    ApproxAmountInBaseCurrency       :      Integer;
    Amount                           :      Integer;
    ConversionDate                   :      DateTime;
    Currency                         : {
      UniqueName                     :      String;
    };
  };
  EndDate                            :      DateTime;
  QuantityInKitItem                  :      String;
  ParentKit                          :      Boolean;
  NeedBy                             :      DateTime;
  KitRequiredItem                    :      Boolean;
  ShipTo                             : {
    State                            :      String;
    Phone                            :      String;
    Country                          : {
      UniqueName                     :      String;
    };
    PostalCode                       :      String;
    City                             :      String;
    Fax                              :      String;
    UniqueName                       :      String;
    Name                             :      String;
    Lines                            :      String;
  };
  ItemMasterID                       :      String;
  POUnitPrice                        :      Integer;
  CommodityExportMapEntry            : {
    CommodityCode                    : {
      UniqueName                     :      String;
      Name                           :      String;
    };
    AccountType                      : {
      UniqueName                     :      String;
      Name                           :      String;
    };
    UniqueName                       :      String;
  };
  BasePrice                          :      Integer;
  IsPriceModifiedByUser              :      Boolean;
  SupplierLocation                   : {
    UniqueName                       :      String;
  };
  OrderID                            :      String;
  KitInstanceId                      :      String;
  StartDate                          :      DateTime;
  ParentLineNumber                   :      Integer;
  IsRecurring                        :      Boolean;
  NumberConfirmedSubstituted         :      String;
  BuyerName                          :      String;
  Carrier                            :      String;
  NumberConfirmedBackOrdered         :      String;
  OriginatingSystemLineNumber        :      Integer;
  ERPLineItemNumber                  :      Integer;
  Kit                                :      String;
  PurchaseGroup                      : {
    UniqueName                       :      String;
  };
  Form                               :      String;
  BuyerItemMaster                    :      String;
  NumberConfirmedRejected            :      String;
  PaymentTerms                       : {
    UniqueName                       :      String;
  };
  SAPPOLineNumber                    :      Integer;
  PushStatus                         :      Integer;
  TaxCode                            :      String;
  LineType                           : {
    UniqueName                       :      String;
  };
  ERPPONumber                        :      String;
  BoughtFromPreferredSupplier        :      Boolean;
  Quantity                           :      Integer;
  OrderInfo                          :      String;
  ExpectedValue                      :      String;
  POQuantity                         :      Integer;
  ChangedBy                          : {
    UniqueName                       :      String;
    PasswordAdapter                  :      String;
  };
//           "ApprovedDate": "2021-10-05T02:01:37Z",
//           "LastCheckDate": null,
//           "OrderedState": 4,
//           "PreviousApprovalRequestsVersion": 16,
//           "ResubmitDate": null,
//           "NumberCleared": 0E-10,
//           "DiscountAmount": null,
//           "RealTimeBudgetResponse": null,
//           "ApprovalRequests": [
//               {
//                   "AllowEscalationPeriodExtension": false,
//                   "IsEscalatedToList": false,
//                   "IsEscalationExtended": false,
//                   "Creator": null,
//                   "ExtendEscalationUserComments": "",
//                   "EscalationExtensionDate": null,
//                   "ApproverComment": "",
//                   "Reason": "@ruleReasons/FinanceOverLimit",
//                   "AssignedTo": null,
//                   "EscalationWarningDate": null,
//                   "ReportingReason": "Finance must approve approvable above certain limits",
//                   "ManuallyAdded": false,
//                   "AssignedDate": null,
//                   "EscalationDate": null,
//                   "State": 8,
//                   "ExtendEscalationReasonCode": "",
//                   "ReportingExtendEscalationReason": "",
//                   "ApprovedBy": {
//                       "UniqueName": "ywang",
//                       "PasswordAdapter": "ThirdPartyUser"
//                   },
//                   "ApprovalRequired": true,
//                   "Approver": {
//                       "UniqueName": "Finance"
//                   },
//                   "ActivationDate": "2021-10-05T02:00:55Z",
//                   "RuleName": "Requisition Cap Rule",
//                   "EscalationExtendedByUser": null
//               }
//           ],
//           "Active": true,
//           "ReceivedDate": null,
//           "ProcurementUnit": {
//               "UniqueName": "100"
//           },
//           "AmountBilled": null,
//           "NextVersion": null,
//           "ERPRequisitionID": "",
//           "NumberBilled": 0E-10,
//           "UniqueName": "PR185",
//           "IsForecast": false,
//           "ReportingCurrency": {
//               "UniqueName": "JPY"
//           },
//           "BudgetCheckStatus": 0,
//           "OrderedDate": "2021-10-05T02:01:40Z",
//           "SourcingStatusMessage": "",
//           "IsServiceRequisition": false,
//           "AreOrdersStuck": false,
//           "AmountCleared": null,
//           "ProjectID": "",
//           "OriginatingSystem": "",
//           "PaymentTerms": null,
//           "CustomCatalogPurchaseOrg": {
//               "UniqueName": "1000"
//           },
//           "SourcingStatusString": "",
//           "AmountReconciled": null,
//           "ExternalSourcingId": "",
//           "PreCollaborationTotalCost": null,
//           "AmountRejected": null,
//           "Supplier": null,
//           "BlanketOrder": null,
//           "BudgetRefID": "",
//           "StatusString": "Ordered",
//           "PreviousVersion": null,
//           "ApprovalRequestsVersion": 18,
//           "AmountInvoiced": null,
//           "TimeUpdated": "2021-10-05T02:24:43Z",
//           "VersionNumber": 1,
//           "OriginatingSystemReferenceID": "",
//           "CollaborationState": {
//               "Order": null,
//               "Supplier": null,
//               "CancelReason": null,
//               "Reason": null,
//               "State": 1,
//               "Mode": 0
//           },
//           "IsExternalReq": false,
//           "Type": "ariba.purchasing.core.Requisition",
//           "ProjectTitle": "",
//           "Attachments.Attachments": null,
//           "IsServiceOrder": false,
//           "BudgetCheckStatusMessage": null,
//           "Preparer": {
//               "UniqueName": "ywang",
//               "PasswordAdapter": "ThirdPartyUser"
//           },
//           "CompanyCode": {
//               "UniqueName": "1000"
//           }
}


entity C_Invoices : managed {
      // ============== Filter Fields ==============
      createdDateFrom   : DateTime  @mandatory;
      createdDateTo     : DateTime  @mandatory  @cds.on.insert: $now;
      // ============== Data Fields ==============
  key InitialUniqueName : String    @title: '請求書ID';
      ApprovedState     : Integer   @title: '承認状況';
      Name              : String    @title: '名前';
      SubmitDate        : String    @title: '提出日時';
      CreateDate        : String    @title: '作成日時';
}
