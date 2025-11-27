@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Purchase Register'
@Metadata.ignorePropagatedAnnotations: true
@ObjectModel.usageType:{
    serviceQuality: #X,
    sizeCategory: #S,
    dataClass: #MIXED
}
define view entity ZCE_PUR_REG5 
as select from zce_pur_reg3
{
  key TaxItemGroup,
  key min( AccountingDocument )  as AccountingDocument,  
  key FiscalYear,
  key OriginalReferenceDocument,
  TransactionTypeDetermination,
  GLAccount,
  TransactionCurrency,
  
  IN_HSNOrSACCode,
  @Semantics: { amount : {currencyCode: 'TransactionCurrency'} }
  sum( AmountInTransactionCurrency )                     as AmountInTransactionCurrency
//  min( AccountingDocument )                              as AccountingDocument
}
where TransactionTypeDetermination ='WRX' 
group by
  OriginalReferenceDocument,
  TransactionTypeDetermination,
  GLAccount,
  TransactionCurrency,
  TaxItemGroup,
  IN_HSNOrSACCode,
  FiscalYear
 
