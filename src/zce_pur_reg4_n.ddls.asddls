@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Purchase Register Aggregated by Tax Type'
@Metadata.ignorePropagatedAnnotations: true
@ObjectModel.usageType: {
  serviceQuality: #X,
  sizeCategory: #S,
  dataClass: #MIXED
}
define view entity ZCE_PUR_REG4_n
  as select from zce_pur_reg3
{
  key TaxItemGroup,
  key min( AccountingDocument )                                                                                       as AccountingDocument,
  key FiscalYear,
  key OriginalReferenceDocument,
      TransactionTypeDetermination,
      //      GLAccount,
      TransactionCurrency,
      //      IN_HSNOrSACCode,

      /* cast CURR -> decimal inside the aggregate (CURR not allowed directly in SUM) */
      @Semantics.amount.currencyCode: 'TransactionCurrency'
      sum( case when GLAccount = '0000148003' then cast( AmountInTransactionCurrency as abap.dec(15,2) ) else 0 end ) as CGSTAmount,

      @Semantics.amount.currencyCode: 'TransactionCurrency'
      sum( case when GLAccount = '0000148002' then cast( AmountInTransactionCurrency as abap.dec(15,2) ) else 0 end ) as SGSTAmount,

      @Semantics.amount.currencyCode: 'TransactionCurrency'
      sum( case when GLAccount = 'IGST' then cast( AmountInTransactionCurrency as abap.dec(15,2) ) else 0 end )       as IGSTAmount,

      @Semantics.amount.currencyCode: 'TransactionCurrency'
      sum( case when GLAccount = 'IGST' then cast( AmountInTransactionCurrency as abap.dec(15,2) ) else 0 end )       as UGSTAmount
}
group by
  OriginalReferenceDocument,
  TransactionTypeDetermination,
  //  GLAccount,
  TransactionCurrency,
  TaxItemGroup,
  //  IN_HSNOrSACCode,
  FiscalYear
