@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Tax aggergate'
@Metadata.ignorePropagatedAnnotations: true
@ObjectModel.usageType:{
    serviceQuality: #X,
    sizeCategory: #S,
    dataClass: #MIXED
}
define view entity zzce_pur_tax_agg
  as select from ZCE_PUR_REG4
{
  TaxItemGroup,
  AccountingDocument,
  OriginalReferenceDocument,
  FiscalYear,
  @Semantics: { amount : {currencyCode: 'TransactionCurrency'} }
  sum( AmountInTransactionCurrency ) as AmountInTransactionCurrency,
  -- include currency so we can annotate amounts correctly
  TransactionCurrency,

  @Semantics.amount.currencyCode: 'TransactionCurrency'
  sum(
    case when TransactionTypeDetermination = 'JIC'
         then cast( AmountInTransactionCurrency as abap.dec(15,2) )
         else cast( 0 as abap.dec(15,2) )
    end
  )                                  as CGST,

  @Semantics.amount.currencyCode: 'TransactionCurrency'
  sum(
    case when TransactionTypeDetermination = 'JIU'
         then cast( AmountInTransactionCurrency as abap.dec(15,2) )
         else cast( 0 as abap.dec(15,2) )
    end
  )                                  as UGST,

  @Semantics.amount.currencyCode: 'TransactionCurrency'
  sum(
    case when TransactionTypeDetermination = 'JII'
         then cast( AmountInTransactionCurrency as abap.dec(15,2) )
         else cast( 0 as abap.dec(15,2) )
    end
  )                                  as IGST,

  @Semantics.amount.currencyCode: 'TransactionCurrency'
  sum(
    case when TransactionTypeDetermination = 'JIS'
         then cast( AmountInTransactionCurrency as abap.dec(15,2) )
         else cast( 0 as abap.dec(15,2) )
    end
  )                                  as SGST,

  @Semantics.amount.currencyCode: 'TransactionCurrency'
  sum(
    case when TransactionTypeDetermination = 'WIT'
         then cast( AmountInTransactionCurrency as abap.dec(15,2) )
         else cast( 0 as abap.dec(15,2) )
    end
  )                                  as TDS,

  @Semantics.amount.currencyCode: 'TransactionCurrency'
  sum(
    case when TransactionTypeDetermination = 'JRC'
         then cast( AmountInTransactionCurrency as abap.dec(15,2) )
         else cast( 0 as abap.dec(15,2) )
    end
  )                                  as RMCGST,

  @Semantics.amount.currencyCode: 'TransactionCurrency'
  sum(
    case when TransactionTypeDetermination = 'JRS'
         then cast( AmountInTransactionCurrency as abap.dec(15,2) )
         else cast( 0 as abap.dec(15,2) )
    end
  )                                  as RMSGST,


  @Semantics.amount.currencyCode: 'TransactionCurrency'
  sum(
    case when TransactionTypeDetermination = 'JRI'
         then cast( AmountInTransactionCurrency as abap.dec(15,2) )
         else cast( 0 as abap.dec(15,2) )
    end
  )                                  as RMIGST,


  @Semantics.amount.currencyCode: 'TransactionCurrency'
  sum(
    case when TransactionTypeDetermination = 'JRU'
         then cast( AmountInTransactionCurrency as abap.dec(15,2) )
         else cast( 0 as abap.dec(15,2) )
    end
  )                                  as RMUGST,


  max(
    case
      when TransactionTypeDetermination = 'JIC'
           and cast(AmountInTransactionCurrency as abap.dec(15,2)) > 0
      then GLAccount
      when TransactionTypeDetermination = 'JIU'
           and cast(AmountInTransactionCurrency as abap.dec(15,2)) > 0
      then GLAccount
      when TransactionTypeDetermination = 'JII'
           and cast(AmountInTransactionCurrency as abap.dec(15,2)) > 0
      then GLAccount
      else ''
    end
  )                                  as GLAccount
}
group by
  TaxItemGroup,
  AccountingDocument,
  OriginalReferenceDocument,
  FiscalYear,
//  IN_HSNOrSACCode,
//  AmountInTransactionCurrency,
  TransactionCurrency
