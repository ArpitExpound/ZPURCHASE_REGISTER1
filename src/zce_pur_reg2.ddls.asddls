@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Purchase Register'
@Metadata.ignorePropagatedAnnotations: true
@ObjectModel.usageType:{
    serviceQuality: #X,
    sizeCategory: #S,
    dataClass: #MIXED
}
@Metadata.allowExtensions: true
define view entity ZCE_PUR_REG2
  with parameters
    @Consumption.hidden: true
    @Environment.systemField: #SYSTEM_LANGUAGE
    P_Language : sylangu
  as select from    I_SupplierInvoiceAPI01                                            as A

    left outer join I_SuplrInvcItemPurOrdRefAPI01                                     as b      on  b.SupplierInvoice = A.SupplierInvoice
                                                                                                and b.FiscalYear      = A.FiscalYear

  //    left outer join zzce_pur_tax_agg                                                  as k   on  k.OriginalReferenceDocument = A.SupplierInvoiceWthnFiscalYear
  //                                                                                             and k.FiscalYear                = A.FiscalYear
  //                                                                                             and (
  //                                                                                                k.TaxItemGroup               = substring(
  //                                                                                                  b.SupplierInvoiceItem, 4, 3
  //                                                                                                )
  //                                                                                                or k.TaxItemGroup            = '000' -- default
  //                                                                                                or k.TaxItemGroup            is null
  //                                                                                              )

    left outer join zzce_pur_tax_agg                                                  as k      on(
           k.OriginalReferenceDocument    = A.SupplierInvoiceWthnFiscalYear
           or k.OriginalReferenceDocument = b.PurchaseOrder
           or k.OriginalReferenceDocument = concat(
             b.PurchaseOrder, b.PurchaseOrderItem
           )
         )

    left outer join I_PurchaseOrderAPI01                                              as d      on d.PurchaseOrder = b.PurchaseOrder

    left outer join I_Businesspartnertaxnumber                                        as e      on e.BusinessPartner = d.Supplier

    left outer join I_Supplier                                                        as f      on f.Supplier = A.InvoicingParty

    left outer join I_PurchaseOrderItemAPI01                                          as g      on  g.PurchaseOrder     = d.PurchaseOrder
                                                                                                and g.PurchaseOrderItem = b.PurchaseOrderItem

    left outer join I_TaxCodeText                                                     as h      on  h.TaxCode                 = b.TaxCode
                                                                                                and h.TaxCalculationProcedure = '0TXIN'
                                                                                                and h.Language                = 'E'

    left outer join zfit_tax_perc                                                     as j      on j.taxcode = b.TaxCode

    inner join      I_ProductTypeCodeText                                             as i      on  i.ProductTypeCode = g.ProductType
                                                                                                and i.Language        = 'E'

    left outer join zce_pur_reg3                                                      as k1     on  k1.OriginalReferenceDocument = A.SupplierInvoiceWthnFiscalYear
                                                                                                and k1.FiscalYear                = A.FiscalYear

    left outer join I_BuPaIdentification                                              as L      on  L.BusinessPartner      = d.Supplier
                                                                                                and L.BPIdentificationType = 'MSME V'

    left outer join I_Supplier                                                        as M      on M.Supplier = d.Supplier

    left outer join I_JournalEntry                                                    as n      on  n.AccountingDocument = k.AccountingDocument
                                                                                                and n.FiscalYear         = k.FiscalYear

    left outer join I_ProductPlantIntlTrd                                             as p      on  p.Plant   = b.Plant
                                                                                                and p.Product = g.Material

    left outer join I_PurOrdItmPricingElementAPI01                                    as pe     on  pe.PurchaseOrder     = b.PurchaseOrder
                                                                                                and pe.PurchaseOrderItem = b.PurchaseOrderItem
    left outer join I_PurOrdItmPricingElementAPI01                                    as pe_ins on  pe_ins.PurchaseOrder     = b.PurchaseOrder
                                                                                                and pe_ins.PurchaseOrderItem = b.PurchaseOrderItem
                                                                                                and pe_ins.ConditionType     = 'ZINS'

    left outer join I_PurOrdItmPricingElementAPI01                                    as pe_dis on  pe_dis.PurchaseOrder     = b.PurchaseOrder
                                                                                                and pe_dis.PurchaseOrderItem = b.PurchaseOrderItem
                                                                                                and pe_dis.ConditionType     = 'ZDIS'

    left outer join I_PurOrdItmPricingElementAPI01                                    as pe_com on  pe_com.PurchaseOrder     = b.PurchaseOrder
                                                                                                and pe_com.PurchaseOrderItem = b.PurchaseOrderItem
                                                                                                and pe_com.ConditionType     = 'ZCOM'

    left outer join I_PurOrdItmPricingElementAPI01                                    as pe_pnf on  pe_pnf.PurchaseOrder     = b.PurchaseOrder
                                                                                                and pe_pnf.PurchaseOrderItem = b.PurchaseOrderItem
                                                                                                and pe_pnf.ConditionType     = 'ZP&F'

    left outer join I_AccountingDocumentJournal( P_Language: $parameters.P_Language ) as jo     on  jo.AccountingDocument = k.AccountingDocument
                                                                                                and jo.CompanyCode        = A.CompanyCode
                                                                                                and jo.FiscalYear         = A.FiscalYear
    left outer join I_OperationalAcctgDocItem                                         as acc    on  acc.FiscalYear                = A.FiscalYear
                                                                                                and acc.CompanyCode               = A.CompanyCode
                                                                                                and acc.OriginalReferenceDocument = A.SupplierInvoiceWthnFiscalYear

{

      /* --- GROUP BY FIELDS --- */

  key A.InvoicingParty,
  key A.CompanyCode,
  key A.FiscalYear,
  key A.SupplierInvoice,
  key b.SupplierInvoiceItem,
  key d.PurchaseOrder,
  key g.PurchaseOrderItem,
  key k.AccountingDocument,
      max(d.PurchaseOrderType)                                        as PurchaseOrderType,
      max(A.SupplierInvoiceWthnFiscalYear)                            as SupplierInvoiceWthnFiscalYear,
      max(b.Plant)                                                    as Plant,
      max(A.DocumentDate)                                             as DocumentDate,
      max(A.PostingDate)                                              as PostingDate,
      /* --- NON-KEY FIELDS (AGGREGATED) --- */

      max(k.OriginalReferenceDocument)                                as OriginalReferenceDocument,
      max(k1.AccountingDocumentItem)                                  as AccountingDocumentItem,
      max( f.Supplier )                                               as Supplier,
      max(jo.Supplier)                                                as Supplier1,
      max(jo.DebitCreditCode)                                         as DebitCreditCode,
      max(jo.PostingKey)                                              as PostingKey,
      max(k.GLAccount)                                                as GLAccount,
      max(A.SupplierInvoiceIDByInvcgParty)                            as SupplierInvoiceIDByInvcgParty,
      max(A.PaymentTerms)                                             as PaymentTerms,
      A.DocumentCurrency                                              as DocumentCurrency,
      k.TransactionCurrency                                           as TransactionCurrency,
      @Semantics.amount.currencyCode: 'TransactionCurrency'
      max(k.AmountInTransactionCurrency)                              as AmountInTransactionCurrency,
      max(pe.ConditionRateValue)                                      as ConditionRateValue,
      pe.ConditionCurrency                                            as ConditionCurrency,
      max(n.AccountingDocumentType)                                   as AccountingDocumentType,
      max(n.AccountingDocumentHeaderText)                             as AccountingDocumentHeaderText,
      max(p.ConsumptionTaxCtrlCode)                                   as ConsumptionTaxCtrlCode,
      max(A.YY1_Note1_MIH)                                            as Notes,
      @Semantics.amount.currencyCode: 'DocumentCurrency'
      max(g.NetPriceAmount)                                           as NetPriceAmount,

      max(cast( A.ExchangeRate as abap.dec(9,5) )   )                 as ExchangeRate,

      cast( 'USD' as abap.cuky )                                      as DisplayCurrencyUSD,
      cast( 'INR' as abap.cuky )                                      as DisplayCurrencyINR,

      /* --- Invoice Gross Amount --- */
      @Semantics.amount.currencyCode: 'DisplayCurrencyINR'
      max(
      (
        case
            when A.DocumentCurrency = 'INR'
                 then cast(A.InvoiceGrossAmount as abap.dec(15,2))
            when A.DocumentCurrency = 'USD'
                 then cast(A.InvoiceGrossAmount as abap.dec(15,2)) * A.ExchangeRate
            else 0
        end
      )
      * case when n.IsReversed = 'X' then -1 else 1 end
      )                                                               as InvoiceGrossAmount,
      /* --- Invoice Amount fields --- */

      @Semantics.amount.currencyCode: 'DisplayCurrencyINR'
      max(
      (
        case when A.DocumentCurrency = 'INR'
             then cast(A.InvoiceGrossAmount as abap.dec(15,2))
             else 0
        end
      )
      * case when n.IsReversed = 'X' then -1 else 1 end
      )                                                               as InvoiceAmount,

      @Semantics.amount.currencyCode: 'DisplayCurrencyUSD'
      max(
      (
        case when A.DocumentCurrency = 'USD'
             then cast(A.InvoiceGrossAmount as abap.dec(15,2))
             else 0
        end
      )
      * case when n.IsReversed = 'X' then -1 else 1 end
      )                                                               as invoicegrossamount1,

      /* --- Supplier Item Amount --- */
      @Semantics.amount.currencyCode: 'DisplayCurrencyINR'
      max(
        cast(
          case
            when b.SuplrInvcDeliveryCostCndnType = '' or b.SuplrInvcDeliveryCostCndnType is null
              then case
                     when A.DocumentCurrency = 'INR' then cast(b.SupplierInvoiceItemAmount as abap.dec(15,2))
                     when A.DocumentCurrency <> 'INR' then cast(b.SupplierInvoiceItemAmount as abap.dec(15,2)) * cast(A.ExchangeRate as abap.dec(15,6))
                     else 0
                   end
            else 0
          end
        as abap.dec(15,2))
        * case when n.IsReversed = 'X' then -1 else 1 end
      )                                                               as SupplierInvoiceItemAmount,

      @Semantics.amount.currencyCode: 'DocumentCurrency'
      sum(
        cast(
          case
            when b.SuplrInvcDeliveryCostCndnType = 'ZFVI' or b.SuplrInvcDeliveryCostCndnType = 'ZIF1'
              then cast(b.SupplierInvoiceItemAmount as abap.dec(15,2))
            else 0
          end as abap.dec(15,2))
      )                                                               as impfcharge,

      @Semantics.amount.currencyCode: 'DisplayCurrencyINR'
      sum(
        case
          when k.GLAccount = '0000410109' and b.DocumentCurrency = 'INR'
          then cast( k.AmountInTransactionCurrency as abap.dec(15,2) )
          else cast( 0 as abap.dec(15,2) )
        end
      )                                                               as parkcharge_inr,

      @Semantics.amount.currencyCode: 'DisplayCurrencyUSD'
      sum(
        case
          when k.GLAccount = '0000410109' and b.DocumentCurrency = 'USD'
          then cast( k.AmountInTransactionCurrency as abap.dec(15,2) )
      else cast( 0 as abap.dec(15,2) )
      end
      )                                                               as parkcharge_usd,

      @Semantics.amount.currencyCode: 'DocumentCurrency'
      sum(
          case
              when k1.GLAccount = '0000450034'
                  then cast( k1.AmountInTransactionCurrency as abap.dec(15,2) )
              else
                  cast( 0 as abap.dec(15,2) )
          end
      )                                                               as round,

      @Semantics.amount.currencyCode: 'DocumentCurrency'
      sum(
          case
              when b.SuplrInvcDeliveryCostCndnType = 'ZIIV'
                  then cast( b.SupplierInvoiceItemAmount as abap.dec(15,2) )
              else
                  cast( 0 as abap.dec(15,2) )
          end
      )                                                               as inscharge,

      @Semantics.amount.currencyCode: 'DocumentCurrency'
      sum(
          case
              when b.SuplrInvcDeliveryCostCndnType = 'ZOTC'
                  then cast( b.SupplierInvoiceItemAmount as abap.dec(15,2) )
              else
                  cast( 0 as abap.dec(15,2) )
          end
      )                                                               as otherexp,

      @Semantics.amount.currencyCode: 'DocumentCurrency'
      sum(
          case
              when b.SuplrInvcDeliveryCostCndnType = 'ZBCD'
                or b.SuplrInvcDeliveryCostCndnType = 'ZIOT'
              then cast( b.SupplierInvoiceItemAmount as abap.dec(15,2) )
              else cast( 0 as abap.dec(15,2) )
          end
      )                                                               as custdcharge,

      @Semantics.amount.currencyCode: 'DocumentCurrency'
      sum(
          case
              when b.SuplrInvcDeliveryCostCndnType = 'ZSWC'
              then cast( b.SupplierInvoiceItemAmount as abap.dec(15,2) )
              else cast( 0 as abap.dec(15,2) )
          end
      )                                                               as swscharge,

      @Semantics.amount.currencyCode: 'DocumentCurrency'
      sum(
        case
        when b.SuplrInvcDeliveryCostCndnType = 'ZCHA'
          or b.SuplrInvcDeliveryCostCndnType = 'ZTCH'
          or b.SuplrInvcDeliveryCostCndnType = 'ZSTD'
          or b.SuplrInvcDeliveryCostCndnType = 'ZSLC'
          or b.SuplrInvcDeliveryCostCndnType = 'ZCFS'

        then cast( b.SupplierInvoiceItemAmount as abap.dec(15,2) )
        else cast( 0 as abap.dec(15,2) )
      end
      )                                                               as chacharge,

      /* --- Basic fields (MAX used) --- */

      max(b.TaxCode)                                                  as TaxCode,
      max(b.SuplrInvcDeliveryCostCndnType)                            as SuplrInvcDeliveryCostCndnType,
      max(b.SupplierInvoiceItemText)                                  as SupplierInvoiceItemText,
      @Semantics.amount.currencyCode: 'DocumentCurrency'
      max(b.SuplrInvcItmUnplndDelivCost)                              as SuplrInvcItmUnplndDelivCost,

      max(e.BPTaxNumber)                                              as BPTaxNumber,
      max(f.CityName)                                                 as CityName,
      max(f.BPSupplierFullName)                                       as fullname,
      max(h.TaxCodeName)                                              as TaxCodeName,
      max(i.Name)                                                     as Name,
      max(g.ProductType)                                              as ProductType,
      max(g.PurchaseOrderItemText)                                    as PurchaseOrderItemText,

      /* GST Based on Plant/Company */
      max(
      case A.CompanyCode
      when 'MPPL' then (
      case A.BusinessPlace
        when 'MUD1' then '26AAOCM3634M1ZZ'
            when 'MUD2' then '26AAOCM3634M1ZZ'
            when 'MUD3' then '26AAOCM3634M1ZZ'
            when 'MUD4' then '26AAOCM3634M1ZZ'
            when 'MUV1' then '24AAOCM3634M2Z2'
            when 'MUV2' then '24AAOCM3634M2Z2'
            when 'MDAM' then '24AAOCM3634M1Z3'
            when 'MDHR' then '05AAOCM3634M1Z3'
            when 'MDHY' then '36AAOCM3634M1ZY'
            when 'MDKN' then '09AAOCM3634M1ZV'
            when 'MDKL' then '19AAOCM3634M1ZU'
          end
      )
      end
      )                                                               as plantgstin,

      max( j.igst_rate )                                              as igst_rate,
      max( j.sgst_rate )                                              as sgst_rate,
      max( j.cgst_rate )                                              as cgst_rate,
      max( j.ugst_rate )                                              as ugst_rate,
      max( j.rcm_igst_rate )                                          as rcm_igst_rate,
      max( j.rcm_cgst_rate )                                          as rcm_cgst_rate,
      max( j.rcm_sgst_rate )                                          as rcm_sgst_rate,
      max( j.rcm_ugst_rate )                                          as rcm_ugst_rate,




      max(L.BPIdentificationNumber)                                   as MSME,
      max(M.BusinessPartnerPanNumber)                                 as Suppan,
      max(f.BPAddrStreetName)                                         as Address,

      max(pe.ConditionType)                                           as ConditionType,

      @Semantics.amount.currencyCode: 'ConditionCurrency'
      max(pe.ConditionAmount)                                         as ConditionAmount,

      @Semantics.amount.currencyCode: 'ConditionCurrency'
      max(pe_ins.ConditionAmount)                                     as Insurance,
      @Semantics.amount.currencyCode: 'ConditionCurrency'
      max(pe_dis.ConditionAmount)                                     as Discount,
      @Semantics.amount.currencyCode: 'ConditionCurrency'
      max(pe_com.ConditionAmount)                                     as Commission,
      @Semantics.amount.currencyCode: 'ConditionCurrency'
      max(pe_pnf.ConditionAmount)                                     as PackingForwarding,



      @Semantics.amount.currencyCode: 'DocumentCurrency'
      max(
          (
              case
                  when b.TaxCode = 'R1' or b.TaxCode = 'R2' or b.TaxCode = 'R3'
                   or b.TaxCode = 'R4' or b.TaxCode = 'RA' or b.TaxCode = 'RB'
                   or b.TaxCode = 'RC' or b.TaxCode = 'RD'
                      then cast(0 as abap.dec(15,2))
                  else cast(k.CGST as abap.dec(15,2))
              end
          )
          * case when n.IsReversed = 'X' then -1 else 1 end
      )                                                               as cgstamt,

      @Semantics.amount.currencyCode: 'DocumentCurrency'
      max(
          (
              case
                  when b.TaxCode = 'R1' or b.TaxCode = 'R2' or b.TaxCode = 'R3' or b.TaxCode = 'R4'
                      then cast(0 as abap.dec(15,2))
                  else cast(k.SGST as abap.dec(15,2))
              end
          )
          * case when n.IsReversed = 'X' then -1 else 1 end
      )                                                               as sgstamt,

      @Semantics.amount.currencyCode: 'DocumentCurrency'
      max(
          (
              case
                  when b.TaxCode = 'R5' or b.TaxCode = 'R6' or b.TaxCode = 'R7' or b.TaxCode = 'R8' or b.TaxCode = 'R9'
                      then cast(0 as abap.dec(15,2))
                  else cast(k.IGST as abap.dec(15,2))
              end
          )
          * case when n.IsReversed = 'X' then -1 else 1 end
      )                                                               as igstamt,

      @Semantics.amount.currencyCode: 'DocumentCurrency'
      max(
          (
              case
                  when b.TaxCode = 'RA' or b.TaxCode = 'RB' or b.TaxCode = 'RC' or b.TaxCode = 'RD'
                      then cast(0 as abap.dec(15,2))
                  else cast(k.UGST as abap.dec(15,2))
              end
          )
          * case when n.IsReversed = 'X' then -1 else 1 end
      )                                                               as ugstamt,

      @Semantics.amount.currencyCode: 'DocumentCurrency'
      sum(
          (
              case
                  when k1.TransactionTypeDetermination = 'WIT'
                      then abs(cast(k1.AmountInTransactionCurrency as abap.dec(15,2)))
                  else cast(0 as abap.dec(15,2))
              end
          )
          * case when n.IsReversed = 'X' then -1 else 1 end
      )                                                               as tds,

      @Semantics.amount.currencyCode: 'DocumentCurrency'
      max(k.RMCGST * case when n.IsReversed = 'X' then -1 else 1 end) as rcmcgst,

      @Semantics.amount.currencyCode: 'DocumentCurrency'
      max(k.RMSGST * case when n.IsReversed = 'X' then -1 else 1 end) as rcmsgst,

      @Semantics.amount.currencyCode: 'DocumentCurrency'
      max(k.RMIGST * case when n.IsReversed = 'X' then -1 else 1 end) as rcmigst,

      @Semantics.amount.currencyCode: 'DocumentCurrency'
      max(k.RMUGST * case when n.IsReversed = 'X' then -1 else 1 end) as rcmugst,


      max(g.IncotermsClassification)                                  as IncotermsClassification,

      @Semantics.amount.currencyCode: 'DocumentCurrency'
      sum(
        case
          when A.DocumentCurrency = 'INR' then
            (
              case when b.SuplrInvcDeliveryCostCndnType = '' or b.SuplrInvcDeliveryCostCndnType is null
                   then cast( b.SupplierInvoiceItemAmount as abap.dec(15,2) )
                   else cast(0 as abap.dec(15,2)) end
              +
              case when b.SuplrInvcDeliveryCostCndnType = 'ZFVA'
                   then cast( b.SupplierInvoiceItemAmount as abap.dec(15,2) )
                   else cast(0 as abap.dec(15,2)) end
              +
              case when k.GLAccount = '0000410109'
                   then cast( k.AmountInTransactionCurrency as abap.dec(15,2) )
                   else cast(0 as abap.dec(15,2)) end
            )
          when A.DocumentCurrency = 'USD' then
            (
              (
                case when b.SuplrInvcDeliveryCostCndnType = '' or b.SuplrInvcDeliveryCostCndnType is null
                     then cast( b.SupplierInvoiceItemAmount as abap.dec(15,2) )
                     else cast(0 as abap.dec(15,2)) end
                +
                case when b.SuplrInvcDeliveryCostCndnType = 'ZFVA'
                     then cast( b.SupplierInvoiceItemAmount as abap.dec(15,2) )
                     else cast(0 as abap.dec(15,2)) end
                +
                case when k.GLAccount = '0000410109'
                     then cast( k.AmountInTransactionCurrency as abap.dec(15,2) )
                     else cast(0 as abap.dec(15,2)) end
              ) * cast( A.ExchangeRate as abap.dec(15,6) )
            )
          else cast( 0 as abap.dec(15,2) )
        end
        * case when n.IsReversed = 'X' then -1 else 1 end
      )                                                               as totaltax,

      @Semantics.amount.currencyCode: 'DisplayCurrencyUSD'
      sum(
        case
          when A.DocumentCurrency = 'USD' then
            (
              case when b.SuplrInvcDeliveryCostCndnType = '' or b.SuplrInvcDeliveryCostCndnType is null
                   then cast( b.SupplierInvoiceItemAmount as abap.dec(15,2) )
                   else cast(0 as abap.dec(15,2)) end
              +
              case when b.SuplrInvcDeliveryCostCndnType = 'ZFVA'
                   then cast( b.SupplierInvoiceItemAmount as abap.dec(15,2) )
                   else cast(0 as abap.dec(15,2)) end
              +
              case when k.GLAccount = '0000410109'
                   then cast( k.AmountInTransactionCurrency as abap.dec(15,2) )
                   else cast(0 as abap.dec(15,2)) end
            ) * cast(A.ExchangeRate as abap.dec(15,6))
          else cast(0 as abap.dec(15,2))
        end
        * case when n.IsReversed = 'X' then -1 else 1 end
      )                                                               as totaltax1,

      @Semantics.amount.currencyCode: 'DocumentCurrency'
      max(
          (
              case
                  when b.TaxCode = 'R1' or b.TaxCode = 'R2' or b.TaxCode = 'R3' or b.TaxCode = 'R4'
                   or b.TaxCode = 'RA' or b.TaxCode = 'RB' or b.TaxCode = 'RC' or b.TaxCode = 'RD'
                      then cast(0 as abap.dec(15,2))
                  else cast( coalesce(k.CGST, 0 ) + coalesce( k.UGST, 0 ) + coalesce( k.IGST, 0 ) + coalesce( k.SGST, 0 ) as abap.dec(15,2) )
              end
          )
          * case when n.IsReversed = 'X' then -1 else 1 end
      )                                                               as totaltaxamt

}
group by
  A.InvoicingParty,
  A.CompanyCode,
  A.FiscalYear,
  A.SupplierInvoice,
  k.AccountingDocument,
  b.SupplierInvoiceItem,
  d.PurchaseOrder,
  g.PurchaseOrderItem,
  A.DocumentCurrency,
  pe.ConditionCurrency,
  k.TransactionCurrency
