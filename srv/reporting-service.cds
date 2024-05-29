using my.ariba as ariba from '../db/data-model';

service ReportingService {
  @readonly
  entity C_Requisitions                     as projection on ariba.C_Requisitions;

  @readonly
  entity C_Requisitions__to_ApprovalRecords as projection on ariba.C_Requisitions__to_ApprovalRecords;

  @readonly
  entity C_Requisitions__to_LineItems       as projection on ariba.C_Requisitions__to_LineItems;

  @readonly
  entity C_Invoices                         as projection on ariba.C_Invoices;

  annotate C_Requisitions__to_ApprovalRecords with @(UI: {
    HeaderInfo: {
      $Type         : 'UI.HeaderInfoType',
      TypeName      : '承認履歴',
      TypeNamePlural: '承認履歴'
    },
    LineItem  : [
      // {
      //   $Type: 'UI.DataField',
      //   Value: RealUser,
      //   Label: '購買依頼',
      // },
      {
        $Type: 'UI.DataField',
        Value: RealUser,
        Label: '承認者',
      },
      {
        $Type: 'UI.DataField',
        Value: State,
        Label: '状態',
      },
      {
        $Type: 'UI.DataField',
        Value: Comment,
        Label: 'コメント',
      },
      {
        $Type: 'UI.DataField',
        Value: ActivationDate,
        Label: '有効化日時',
      }
    ],
    SelectionFields   : [
      createdDateFrom,
      createdDateTo
    ],
  });

  annotate C_Requisitions__to_LineItems with @(UI: {
    HeaderInfo: {
      $Type         : 'UI.HeaderInfoType',
      TypeName      : '品目',
      TypeNamePlural: '品目'
    },
    LineItem  : [
      {
        $Type: 'UI.DataField',
        Value: OrderID,
        Label: '購買発注番号',
      },
      {
        $Type: 'UI.DataField',
        Value: DeliverTo,
        Label: '配送先'
      },
      {
        $Type: 'UI.DataField',
        Value: VATAmount,
        Label: 'VAT数量',
      }
    ],
  });

  annotate C_Requisitions with @(UI: {
    // UpdateHidden             : false,
    // DeleteHidden             : false,
    // CreateHidden             : false,
    Identification    : [{Value: InitialUniqueName}],
    SelectionFields   : [
      Name,
      ApprovedState,
      // ここ消す↓
      // createdDateFrom,
      // createdDateTo
    ],
    LineItem          : [
      {
        $Type: 'UI.DataField',
        Value: InitialUniqueName
      },
      {
        $Type: 'UI.DataField',
        Value: Name
      },
      {
        $Type: 'UI.DataField',
        Value: ApprovedState
      },
      {
        $Type: 'UI.DataField',
        Value: CreateDate
      },
      {
        $Type: 'UI.DataFieldWithUrl',
        // このValueに、日本語や特殊文字を入れるとエラーが出る : {}あたりはダメ。
        Value: 'Go To SAP Ariba',
        Url  : 'https://s1.ariba.com/gb/viewRequisition/{InitialUniqueName}?realm=StratusPacific',
        Label: 'SAP Aribaへ移動'
      },
    ],

    HeaderInfo        : {
      $Type         : 'UI.HeaderInfoType',
      Title         : {
        $Type: 'UI.DataField',
        Value: InitialUniqueName
      },
      ImageUrl      : 'https://tempbucket-aribabtpws-material.s3.ap-northeast-1.amazonaws.com/unknownmaterial.png',
      TypeName      : '購買依頼',
      TypeNamePlural: '購買依頼',
      Description   : {
        $Type: 'UI.DataField',
        Value: Name
      }
    },

    HeaderFacets      : [{
      $Type : 'UI.ReferenceFacet',
      Target: '@UI.FieldGroup#Header'
    }],
    FieldGroup #Header: {
      $Type: 'UI.FieldGroupType',
      Label: 'ヘッダー',
      Data : [
        {
          Value             : InitialUniqueName,
          Label             : '購買依頼ID',
          ![@UI.Importance] : #High
        },
        {
          Value: Name,
          Label: '伝票名'
        },
        {
          Value: ApprovedState,
          Label: '承認状況'
        },
        {
          Value: CreateDate,
          Label: '作成日時'
        },
      ]
    },

    Facets            : [
                         // {
                         //   $Type : 'UI.ReferenceFacet',
                         //   Label : 'ヘッダ',
                         //   Target: '@UI.FieldGroup#Header',
                         // },
                        {
      $Type : 'UI.CollectionFacet',
      ID    : 'approvals',
      Label : '明細',
      Facets: [
        {
          $Type : 'UI.ReferenceFacet',
          Target: 'ApprovalRecords/@UI.LineItem',
          ID    : 'ApprovalRecordsFacet',
        },
        {
          $Type : 'UI.ReferenceFacet',
          Target: 'LineItems/@UI.LineItem',
          ID    : 'LineItemsFacet',
        // ![@UI.PartOfPreview] : false
        }
      ]
    }]
  });

  annotate C_Invoices with @(UI: {
    UpdateHidden   : false,
    DeleteHidden   : false,
    CreateHidden   : false,
    Identification : [{Value: InitialUniqueName}],
    SelectionFields: [
      Name,
      ApprovedState,
      createdDateFrom,
      createdDateTo
    ],
    LineItem       : [
      {
        $Type: 'UI.DataField',
        Value: InitialUniqueName
      },
      {
        $Type: 'UI.DataField',
        Value: Name
      },
      {
        $Type: 'UI.DataField',
        Value: ApprovedState
      },
      {
        $Type: 'UI.DataField',
        Value: CreateDate
      },
      {
        $Type: 'UI.DataField',
        Value: SubmitDate
      },
    ],
  })

}
