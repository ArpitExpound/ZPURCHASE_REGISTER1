@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Diagnostic Join Test 1'
define root view entity ZTEST_JOIN_DIAG1
  as select from I_SupplierInvoiceAPI01 as A
    left outer join zzce_pur_tax_agg as k
      on  k.OriginalReferenceDocument = A.SupplierInvoiceWthnFiscalYear
      and k.FiscalYear                = A.FiscalYear
{
    key A.SupplierInvoice,
    A.SupplierInvoiceWthnFiscalYear,
    A.FiscalYear,
    k.AccountingDocument
}
where A.SupplierInvoiceWthnFiscalYear = 'U3I2500082'
