@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Purchase Register'
@Metadata.ignorePropagatedAnnotations: true
@ObjectModel.usageType:{
    serviceQuality: #X,
    sizeCategory: #S,
    dataClass: #MIXED
}
define view entity zce_pur_reg3 as select from I_OperationalAcctgDocItem
{
    key CompanyCode,
    key AccountingDocument,
    key FiscalYear,
    key AccountingDocumentItem,
    key OriginalReferenceDocument,
    AccountingDocumentItemType,
    FinancialAccountType,
    TransactionCurrency,
    @Semantics: { amount : {currencyCode: 'TransactionCurrency'} }
    AmountInTransactionCurrency,
    @Semantics: { amount : {currencyCode: 'TransactionCurrency'} }
    AmountInFunctionalCurrency,
    BusinessPlace,
    @Semantics: { amount : {currencyCode: 'TransactionCurrency'} }
    CashDiscountAbsoluteBaseAmount,
    GLAccount,
    IN_HSNOrSACCode,
    DocumentDate,
    AccountingDocumentType,
    Material,
    Plant,
    PostingDate,
    ProfitCenter,
    PurchasingDocument,
    PurchasingDocumentItem,
    BaseUnit,
    @Semantics: { quantity : {unitOfMeasure: 'BaseUnit'} }
    Quantity,
    Supplier,
    TaxCode,
    @Semantics: { amount : {currencyCode: 'TransactionCurrency'} }
    TaxAbsltAmountInCoCodeCrcy,
    @Semantics: { amount : {currencyCode: 'TransactionCurrency'} }
    TaxAbsltBaseAmountInTransCrcy,
    TaxItemGroup,
    PaymentTerms,
    TransactionTypeDetermination
     
    
    
    
    
    
}
