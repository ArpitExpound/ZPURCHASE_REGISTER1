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
  as select from    I_SupplierInvoiceAPI01        as A


    left outer join I_SuplrInvcItemPurOrdRefAPI01 as b  on  b.SupplierInvoice = A.SupplierInvoice
                                                        and b.FiscalYear      = A.FiscalYear

    left outer join I_PurchaseOrderAPI01          as d  on d.PurchaseOrder = b.PurchaseOrder

    left outer join I_Businesspartnertaxnumber    as e  on e.BusinessPartner = d.Supplier

    left outer join I_Supplier                    as f  on f.Supplier = A.InvoicingParty

    inner join      I_PurchaseOrderItemAPI01      as g  on  g.PurchaseOrder     = d.PurchaseOrder
                                                        and g.PurchaseOrderItem = b.PurchaseOrderItem

    left outer join I_TaxCodeText                 as h  on  h.TaxCode                 = b.TaxCode
                                                        and h.TaxCalculationProcedure = '0TXIN'
                                                        and h.Language                = 'E'

    left outer join zfit_tax_perc                 as j  on j.taxcode = b.TaxCode

    inner join      I_ProductTypeCodeText         as i  on  i.ProductTypeCode = g.ProductType
                                                        and i.Language        = 'E'

  /* JOIN TO AGGREGATED REG3 (pre-aggregated to avoid duplicates) */
  ///////////////////////////////////START OF COMMENT SANKET KHAVARE//////////////////////////////////
  //    left outer join ZCE_PUR_REG4                  as k  on  k.OriginalReferenceDocument = A.SupplierInvoiceWthnFiscalYear
  //                                                        and k.FiscalYear                = A.FiscalYear
  //                                                        and k.TaxItemGroup              = substring(
  //      b.SupplierInvoiceItem, 4, 3
  //      //      b.SupplierInvoiceItem, 1, 3
  //    )
    left outer join zzce_pur_tax_agg              as k  on  k.OriginalReferenceDocument = A.SupplierInvoiceWthnFiscalYear
                                                        and k.FiscalYear                = A.FiscalYear
                                                        and k.TaxItemGroup              = substring(
      b.SupplierInvoiceItem, 4, 3
      //      b.SupplierInvoiceItem, 1, 3
    )
  ///////////////////////////////////START OF COMMENT SANKET KHAVARE//////////////////////////////////

  //    left outer join ZCE_PUR_REG5                  as kl  on  k.OriginalReferenceDocument = A.SupplierInvoiceWthnFiscalYear
  //                                                        and k.FiscalYear                = A.FiscalYear
  //                                                        and k.TaxItemGroup              = substring(
  //      b.SupplierInvoiceItem, 4, 6
  //      //      b.SupplierInvoiceItem, 1, 3
  //    )

    left outer join zce_pur_reg3                  as k1 on  k1.OriginalReferenceDocument = A.SupplierInvoiceWthnFiscalYear
                                                        and k1.FiscalYear                = A.FiscalYear
  //    left outer join ZCE_PUR_REG5                  as k2 on k2.OriginalReferenceDocument = A.SupplierInvoiceWthnFiscalYear
  //    left outer join ZCE_PUR_REG4                  as k on k.OriginalReferenceDocument = A.SupplierInvoiceWthnFiscalYear

    left outer join I_BuPaIdentification          as L  on  L.BusinessPartner      = d.Supplier
                                                        and L.BPIdentificationType = 'MSME V'

    left outer join I_Supplier                    as M  on M.Supplier = d.Supplier
    left outer join I_JournalEntry                as n  on  n.AccountingDocument = k.AccountingDocument
                                                        and n.FiscalYear         = k.FiscalYear

{

  key A.InvoicingParty,
  key A.FiscalYear,
  key A.SupplierInvoiceWthnFiscalYear,
  key A.SupplierInvoice,
  key b.SupplierInvoiceItem,
  key b.PurchaseOrder,
  key b.PurchaseOrderItem,
  key d.Supplier,
  key b.Plant,
  key A.DocumentDate,
  key A.PostingDate,
      k.GLAccount,
      A.SupplierInvoiceIDByInvcgParty,
      A.PaymentTerms,
      d.PurchaseOrderType,
      A.DocumentCurrency,
      @Semantics.amount.currencyCode: 'DocumentCurrency'
      //      A.InvoiceGrossAmount,
      cast( A.ExchangeRate as abap.dec(9,5) )                     as ExchangeRate,
      @Semantics.amount.currencyCode: 'DocumentCurrency'
      ( case
       when A.DocumentCurrency = 'INR' then cast( A.InvoiceGrossAmount as abap.dec(15,2) )
       when A.DocumentCurrency = 'USD' then cast( A.InvoiceGrossAmount as abap.dec(15,2) ) * A.ExchangeRate
       else cast(0 as abap.dec(15,2))
       end ) * case when n.IsReversed = 'X' then -1 else 1 end    as InvoiceGrossAmount,

      @Semantics.amount.currencyCode: 'DocumentCurrency'
      ( case
       when A.DocumentCurrency = 'USD' then cast( A.InvoiceGrossAmount as abap.dec(15,2) )
       else cast(0 as abap.dec(15,2))
       end )   * case when n.IsReversed = 'X' then -1 else 1  end as invoicegrossamount1,

      b.PurchaseOrderItemMaterial,
      b.PurchaseOrderQuantityUnit,
      @Semantics.quantity.unitOfMeasure: 'PurchaseOrderQuantityUnit'
      b.QuantityInPurchaseOrderUnit,

      @Semantics.amount.currencyCode: 'DocumentCurrency'
      case
        when b.SuplrInvcDeliveryCostCndnType = 'ZFVA'
            then b.SupplierInvoiceItemAmount
        else cast(0 as abap.curr(15,2))
      end                                                         as locfcharge,



      @Semantics.amount.currencyCode: 'DocumentCurrency'
      ( case
       when b.SuplrInvcDeliveryCostCndnType = '' or b.SuplrInvcDeliveryCostCndnType is null then
         case
             when A.DocumentCurrency = 'INR' then cast( b.SupplierInvoiceItemAmount as abap.dec(15,2) )
             when A.DocumentCurrency <> 'INR' then cast( b.SupplierInvoiceItemAmount as abap.dec(15,2) ) * A.ExchangeRate
             else cast(0 as abap.dec(15,2))
         end
       else cast(0 as abap.dec(15,2))
       end ) * case when n.IsReversed = 'X' then -1 else 1 end    as SupplierInvoiceItemAmount,
      //      case
      //      when ( b.SuplrInvcDeliveryCostCndnType = '' or b.SuplrInvcDeliveryCostCndnType is null )
      //         and A.DocumentCurrency = 'INR'
      //        then b.SupplierInvoiceItemAmount
      //      else cast(0 as abap.curr(15,2))
      //      end                                     as SupplierInvoiceItemAmount,

      @Semantics.amount.currencyCode: 'DocumentCurrency'
      case
          when ( b.SuplrInvcDeliveryCostCndnType = '' or b.SuplrInvcDeliveryCostCndnType is null )
               and A.DocumentCurrency = 'USD'
              then b.SupplierInvoiceItemAmount
          else cast(0 as abap.curr(15,2))
      end                                                         as NetUSD,

      //      @Semantics.amount.currencyCode: 'DocumentCurrency'
      //      case
      //          when b.SuplrInvcDeliveryCostCndnType = '' or b.SuplrInvcDeliveryCostCndnType is null
      //              then b.SupplierInvoiceItemAmount
      //          else cast(0 as abap.curr(15,2))
      //      end                                     as SupplierInvoiceItemAmount,


      //  b.SupplierInvoiceItemAmount,

      b.TaxCode,
      b.SuplrInvcDeliveryCostCndnType,
      b.SupplierInvoiceItemText,
      //      k.GLAccount,
      /* LOCFCHARGE - now summing from aggregated k */
      //  @Semantics.amount.currencyCode: 'DocumentCurrency'
      //  sum(
      //    case
      //      when k.TransactionTypeDetermination = 'FR1' or k.GLAccount = '0000450073'
      //      then k.AmountInTransactionCurrency
      //      else cast(0 as abap.curr(15,2))
      //    end
      //  ) as locfcharge,

      @Semantics.amount.currencyCode: 'DocumentCurrency'
      sum(
        case
          when b.SuplrInvcDeliveryCostCndnType = 'ZFVI' or b.SuplrInvcDeliveryCostCndnType = 'ZIF1'
          then b.SupplierInvoiceItemAmount
          else cast(0 as abap.curr(15,2))
        end
      )                                                           as impfcharge,

      /* PARK CHARGE / ROUND / INS / OTHER / etc — unchanged but using aggregated k where applicable */
      @Semantics.amount.currencyCode: 'DocumentCurrency'
      sum(
        case
          when k.GLAccount = '0000410109'
          then k.AmountInTransactionCurrency
          else cast(0 as abap.curr(15,2))
        end
      )                                                           as parkcharge,

      @Semantics.amount.currencyCode: 'DocumentCurrency'
      sum(
        case
          when k1.GLAccount = '0000450034'
          then k1.AmountInTransactionCurrency
          else cast(0 as abap.curr(15,2))
        end
      )                                                           as round,

      @Semantics.amount.currencyCode: 'DocumentCurrency'
      sum(
        case
          when b.SuplrInvcDeliveryCostCndnType = 'ZIIV'
          then b.SupplierInvoiceItemAmount
          else cast(0 as abap.curr(15,2))
        end
      )                                                           as inscharge,

      @Semantics.amount.currencyCode: 'DocumentCurrency'
      sum(
        case
          when b.SuplrInvcDeliveryCostCndnType = 'ZOTC'
          then b.SupplierInvoiceItemAmount
          else cast(0 as abap.curr(15,2))
        end
      )                                                           as otherexp,

      @Semantics.amount.currencyCode: 'DocumentCurrency'
      sum(
        case
          when b.SuplrInvcDeliveryCostCndnType = 'ZBCD' or b.SuplrInvcDeliveryCostCndnType = 'ZIOT'
          then b.SupplierInvoiceItemAmount
          else cast(0 as abap.curr(15,2))
        end
      )                                                           as custdcharge,

      @Semantics.amount.currencyCode: 'DocumentCurrency'
      sum(
        case
          when b.SuplrInvcDeliveryCostCndnType = 'ZSWC'
          then b.SupplierInvoiceItemAmount
          else cast(0 as abap.curr(15,2))
        end
      )                                                           as swscharge,

      @Semantics.amount.currencyCode: 'DocumentCurrency'
      sum(
        case
          when b.SuplrInvcDeliveryCostCndnType = 'ZCHA' or b.SuplrInvcDeliveryCostCndnType = 'ZTCH'
          or b.SuplrInvcDeliveryCostCndnType = 'ZSTD' or b.SuplrInvcDeliveryCostCndnType = 'ZSLC'
          or b.SuplrInvcDeliveryCostCndnType = 'ZCFS'
          then b.SupplierInvoiceItemAmount
          else cast(0 as abap.curr(15,2))
        end
      )                                                           as chacharge,

      @Semantics.amount.currencyCode: 'DocumentCurrency'
      b.SuplrInvcItmUnplndDelivCost,

      //      cast( A.ExchangeRate as abap.dec(9,5) ) as ExchangeRate,

      e.BPTaxNumber,
      f.CityName,
      f.BPSupplierFullName                                        as fullname,
      h.TaxCodeName,
      i.Name,
      g.ProductType,
      g.PurchaseOrderItemText,

      @Semantics.amount.currencyCode: 'DocumentCurrency'
      sum(b.SupplierInvoiceItemAmount)
      + sum(
          case
            when b.SuplrInvcDeliveryCostCndnType = 'ZLFV' or b.SuplrInvcDeliveryCostCndnType = 'ZLF1' or
            b.SuplrInvcDeliveryCostCndnType = 'ZFVI' or b.SuplrInvcDeliveryCostCndnType = 'ZIF1' or b.SuplrInvcDeliveryCostCndnType = 'ZPG1'
            or b.SuplrInvcDeliveryCostCndnType = 'ZPQ1' or b.SuplrInvcDeliveryCostCndnType = 'ZPV1' or b.SuplrInvcDeliveryCostCndnType = 'ZIIV' or
            b.SuplrInvcDeliveryCostCndnType = 'ZOTC' or b.SuplrInvcDeliveryCostCndnType = 'ZBCD' or b.SuplrInvcDeliveryCostCndnType = 'ZIOT'
            or b.SuplrInvcDeliveryCostCndnType = 'ZSWC' or b.SuplrInvcDeliveryCostCndnType = 'ZCHA' or b.SuplrInvcDeliveryCostCndnType = 'ZTCH'
            or b.SuplrInvcDeliveryCostCndnType = 'ZSTD' or b.SuplrInvcDeliveryCostCndnType = 'ZSLC' or b.SuplrInvcDeliveryCostCndnType = 'ZCFS'
            then b.SupplierInvoiceItemAmount
            else cast(0 as abap.curr(15,2))
          end
        )                                                         as GrandTotalAmount,

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
      end                                                         as plantgstin,

      j.igst_rate                                                 as igstrate,
      j.sgst_rate                                                 as sgstrate,
      j.cgst_rate                                                 as cgstrate,
      j.ugst_rate                                                 as ugstrate,
      j.rcm_igst_rate                                             as rcmigstrate,
      j.rcm_cgst_rate                                             as rcmcgstrate,
      j.rcm_sgst_rate                                             as rcmsgstrate,
      j.rcm_ugst_rate                                             as rcmugstrate,

      /* note: k.AccountingDocument is produced by the aggregated view (MIN) */
      k.AccountingDocument                                        as ad,

      L.BPIdentificationNumber                                    as msme,
      M.BusinessPartnerPanNumber                                  as suppan,
      f.BPAddrStreetName                                          as address,

      @Semantics.amount.currencyCode: 'DocumentCurrency'
      (
      case
      when b.TaxCode = 'R1' or b.TaxCode = 'R2' or b.TaxCode = 'R3' or b.TaxCode = 'R4' or b.TaxCode = 'RA' or
        b.TaxCode = 'RB' or b.TaxCode = 'RC' or b.TaxCode = 'RD'
      then cast( 0 as abap.dec(15,2) )
      //      when k.TransactionTypeDetermination = 'JIC'
      //            then cast( k.AmountInTransactionCurrency as abap.dec(15,2) )
      //      then cast( k_n.CGSTAmount as abap.dec(15,2) )
      //      else cast( 0 as abap.dec(15,2) )
      else cast( k.CGST as abap.dec(15,2) )
      end
      ) * case when n.IsReversed = 'X' then -1 else 1 end         as cgstamt,
      //      sum(
      //      (
      //      case
      //        when b.TaxCode = 'R1' or b.TaxCode = 'R2' or b.TaxCode = 'R3' or b.TaxCode = 'R4' or b.TaxCode = 'RA' or
      //        b.TaxCode = 'RB' or b.TaxCode = 'RC' or b.TaxCode = 'RD'
      //        then cast(0 as abap.curr(15,2))
      //        when k.TransactionTypeDetermination = 'JIC'
      //        then k.AmountInTransactionCurrency
      //        else cast(0 as abap.curr(15,2))
      //      end                ) *
      //case when n.IsReversed = 'X' then -1 else 1 end
      //as cgstamt,

      @Semantics.amount.currencyCode: 'DocumentCurrency'
      (
      case
      when b.TaxCode = 'R1' or  b.TaxCode = 'R2' or  b.TaxCode = 'R3' or  b.TaxCode = 'R4'
      then cast( 0 as abap.dec(15,2) )
      //      when k.TransactionTypeDetermination = 'JIS'
      //            then cast( k.AmountInTransactionCurrency as abap.dec(15,2) )
      //      //      then cast( k_n.SGSTAmount as abap.dec(15,2) )
      //      else cast( 0 as abap.dec(15,2) )
      else cast( k.SGST as abap.dec(15,2) )
      end
      ) * case when n.IsReversed = 'X' then -1 else 1 end         as sgstamt,
      //      sum(
      //      case
      //        when b.TaxCode = 'R1' or  b.TaxCode = 'R2' or  b.TaxCode = 'R3' or  b.TaxCode = 'R4'
      //        then cast(0 as abap.curr(15,2))
      //        when k.TransactionTypeDetermination = 'JIS'
      //        then k.AmountInTransactionCurrency
      //        else cast(0 as abap.curr(15,2))
      //      end                                                                       as sgstamt,

      @Semantics.amount.currencyCode: 'DocumentCurrency'
      (
      case
      when b.TaxCode = 'R5' or b.TaxCode = 'R6' or b.TaxCode = 'R7' or b.TaxCode = 'R8' or b.TaxCode = 'R9'
      then cast( 0 as abap.dec(15,2) )
      //      when k.TransactionTypeDetermination = 'JII'
      //            then cast( k.AmountInTransactionCurrency as abap.dec(15,2) )
      //      //      then cast( k_n.IGSTAmount as abap.dec(15,2) )
      //      else cast( 0 as abap.dec(15,2) )
      else cast( k.IGST as abap.dec(15,2) )
      end
      ) * case when n.IsReversed = 'X' then -1 else 1 end         as igstamt,
      //      sum(
      //      case
      //        when b.TaxCode = 'R5' or b.TaxCode = 'R6' or b.TaxCode = 'R7' or b.TaxCode = 'R8' or b.TaxCode = 'R9'
      //        then cast(0 as abap.curr(15,2))
      //        when k.TransactionTypeDetermination = 'JII'
      //        then k.AmountInTransactionCurrency
      //        else cast(0 as abap.curr(15,2))
      //      end                                                                       as igstamt,

      @Semantics.amount.currencyCode: 'DocumentCurrency'
      (
      case
      when b.TaxCode = 'RA' or b.TaxCode = 'RB' or b.TaxCode = 'RC' or b.TaxCode = 'RD'
      then cast( 0 as abap.dec(15,2) )
      //      when k.TransactionTypeDetermination = 'JIU'
      //      //      then cast( k_n.UGSTAmount as abap.dec(15,2) )
      //            then cast( k.AmountInTransactionCurrency as abap.dec(15,2) )
      //      else cast( 0 as abap.dec(15,2) )
      else cast( k.UGST as abap.dec(15,2) )
      end
      ) * case when n.IsReversed = 'X' then -1 else 1 end         as ugstamt,
      //      sum(
      //      case
      //        when b.TaxCode = 'RA' or b.TaxCode = 'RB' or b.TaxCode = 'RC' or b.TaxCode = 'RD'
      //        then cast(0 as abap.curr(15,2))
      //        when k.TransactionTypeDetermination = 'JIU'
      //        then k.AmountInTransactionCurrency
      //        else cast(0 as abap.curr(15,2))
      //      end                                                                       as ugstamt,

      @Semantics.amount.currencyCode: 'DocumentCurrency'
      //      @Semantics.amount.currencyCode: 'DocumentCurrency'
      sum(
        case
          when k1.TransactionTypeDetermination = 'WIT'
          then abs( cast( k1.AmountInTransactionCurrency as abap.dec(15,2) ) )
          else cast(0 as abap.dec(15,2))
        end
      ) * case when n.IsReversed = 'X' then -1 else 1 end         as tds,
      //      sum(
      //        case
      //          when k1.TransactionTypeDetermination = 'WIT'
      //          then k1.AmountInTransactionCurrency
      //          else cast(0 as abap.curr(15,2))
      //        end
      //      )                                                                         as tds,

      @Semantics.amount.currencyCode: 'DocumentCurrency'
      //      sum(
      //      case
      //      when k.TransactionTypeDetermination = 'JRC'
      //      then cast( b.SupplierInvoiceItemAmount as abap.dec(15,2) )
      //      else cast( 0 as abap.dec(15,2) )
      //      end
      //      )
      k.RMCGST * case when n.IsReversed = 'X' then -1 else 1 end  as rcmcgst,
      //      sum(
      //        case
      //          when k.TransactionTypeDetermination = 'JRC'
      //          then b.SupplierInvoiceItemAmount
      //          else cast(0 as abap.curr(15,2))
      //        end
      //      )                                                                         as rcmcgst,

      @Semantics.amount.currencyCode: 'DocumentCurrency'
      //      sum(
      //      case
      //      when k.TransactionTypeDetermination = 'JRS'
      //      then cast( b.SupplierInvoiceItemAmount as abap.dec(15,2) )
      //      else cast( 0 as abap.dec(15,2) )
      //      end
      //      )
      k.RMSGST * case when n.IsReversed = 'X' then -1 else 1 end  as rcmsgst,
      //      sum(
      //        case
      //          when k.TransactionTypeDetermination = 'JRS'
      //          then b.SupplierInvoiceItemAmount
      //          else cast(0 as abap.curr(15,2))
      //        end
      //      )                                                                         as rcmsgst,

      @Semantics.amount.currencyCode: 'DocumentCurrency'
      //      sum(
      //      case
      //      when k.TransactionTypeDetermination = 'JRI'
      //      then cast( b.SupplierInvoiceItemAmount as abap.dec(15,2) )
      //      else cast( 0 as abap.dec(15,2) )
      //      end
      //      )
      k.RMIGST * case when n.IsReversed = 'X' then -1 else 1 end  as rcmigst,

      //      sum(
      //        case
      //          when k.TransactionTypeDetermination = 'JRI'
      //          then b.SupplierInvoiceItemAmount
      //          else cast(0 as abap.curr(15,2))
      //        end
      //      )                                                                         as rcmigst,

      @Semantics.amount.currencyCode: 'DocumentCurrency'
      //      sum(
      //      case
      //      when k.TransactionTypeDetermination = 'JRU'
      //      then cast( b.SupplierInvoiceItemAmount as abap.dec(15,2) )
      //      else cast( 0 as abap.dec(15,2) )
      //      end
      //      )
      k.RMUGST * case when n.IsReversed = 'X' then -1 else 1 end  as rcmugst,
      //      sum(
      //        case
      //          when k.TransactionTypeDetermination = 'JRU'
      //          then b.SupplierInvoiceItemAmount
      //          else cast(0 as abap.curr(15,2))
      //        end
      //      )                                                                         as rcmugst,

      g.IncotermsClassification,
      //      k.IN_HSNOrSACCode                                           as hsn,    COMMENTED BY SANKET KHAVARE
      @Semantics.amount.currencyCode: 'DocumentCurrency'
      case
      when A.DocumentCurrency = 'INR' then
      (
      cast(
        cast(
          case
              when b.SuplrInvcDeliveryCostCndnType = '' or b.SuplrInvcDeliveryCostCndnType is null
                  then cast(b.SupplierInvoiceItemAmount as abap.dec(15,2))
              else 0
          end as abap.dec(15,2)
        )
        +
        cast(
          case
              when b.SuplrInvcDeliveryCostCndnType = 'ZFVA'
                  then cast(b.SupplierInvoiceItemAmount as abap.dec(15,2))
              else 0
          end as abap.dec(15,2)
        )
        +
        sum(
          cast(
            case
              when k.GLAccount = '0000410109'
              then cast(k.AmountInTransactionCurrency as abap.dec(15,2))
              else 0
            end as abap.dec(15,2))
        )
      as abap.dec(15,2))
      )
      when A.DocumentCurrency = 'USD' then
      (
      (
        cast(
          case
              when b.SuplrInvcDeliveryCostCndnType = '' or b.SuplrInvcDeliveryCostCndnType is null
                  then cast(b.SupplierInvoiceItemAmount as abap.dec(15,2))
              else 0
          end as abap.dec(15,2)
        )
        +
        cast(
          case
              when b.SuplrInvcDeliveryCostCndnType = 'ZFVA'
                  then cast(b.SupplierInvoiceItemAmount as abap.dec(15,2))
              else 0
          end as abap.dec(15,2)
        )
        +
        sum(
          cast(
            case
              when k.GLAccount = '0000410109'
              then cast(k.AmountInTransactionCurrency as abap.dec(15,2))
              else 0
            end as abap.dec(15,2))
        )
      ) * cast(A.ExchangeRate as abap.dec(15,5))
      )
      else 0
      end  * case when n.IsReversed = 'X' then -1 else 1 end      as totaltax,
      //       as totaltax,
      //      case
      //    when A.DocumentCurrency = 'INR' then
      //      (
      //      /* SupplierInvoiceItemAmount logic */
      //        case
      //            when b.SuplrInvcDeliveryCostCndnType = '' or b.SuplrInvcDeliveryCostCndnType is null
      //                then b.SupplierInvoiceItemAmount
      //            else cast(0 as abap.curr(15,2))
      //        end
      //        +
      //      /* locfcharge logic */
      //        case
      //            when b.SuplrInvcDeliveryCostCndnType = 'ZFVA'
      //                then b.SupplierInvoiceItemAmount
      //            else cast(0 as abap.curr(15,2))
      //        end
      //        +
      //      /* parkcharge logic (already a SUM expression) */
      //        sum(
      //          case
      //            when k.GLAccount = '0000410109'
      //            then k.AmountInTransactionCurrency
      //            else cast(0 as abap.curr(15,2))
      //          end
      //        )
      //      )               else cast(0 as abap.curr(15,2))                       end as totaltax,

      @Semantics.amount.currencyCode: 'DocumentCurrency'
      case
      when A.DocumentCurrency = 'USD' then
      (
      case when  b.SuplrInvcDeliveryCostCndnType = '' or b.SuplrInvcDeliveryCostCndnType is null
       then cast(b.SupplierInvoiceItemAmount as abap.dec(15,2)) else cast(0 as abap.dec(15,2)) end
      +
      case when b.SuplrInvcDeliveryCostCndnType = 'ZFVA' then cast(b.SupplierInvoiceItemAmount as abap.dec(15,2)) else cast(0 as abap.dec(15,2)) end
      +
      sum(
        cast(
          case when k.GLAccount = '0000410109' then cast(k.AmountInTransactionCurrency as abap.dec(15,2)) else cast(0 as abap.dec(15,2)) end
        as abap.dec(15,2))
      )
      )
      else cast( 0 as abap.dec(15,2) )
      end * case when n.IsReversed = 'X' then -1 else 1 end       as totaltax1,

      //      case
      //      when A.DocumentCurrency = 'USD' then
      //      (
      //      /* SupplierInvoiceItemAmount logic */
      //        case
      //            when b.SuplrInvcDeliveryCostCndnType = '' or b.SuplrInvcDeliveryCostCndnType is null
      //                then b.SupplierInvoiceItemAmount
      //            else cast(0 as abap.curr(15,2))
      //        end
      //        +
      //      /* locfcharge logic */
      //        case
      //            when b.SuplrInvcDeliveryCostCndnType = 'ZFVA'
      //                then b.SupplierInvoiceItemAmount
      //            else cast(0 as abap.curr(15,2))
      //        end
      //        +
      //      /* parkcharge logic (already a SUM expression) */
      //        sum(
      //          case
      //            when k.GLAccount = '0000410109'
      //            then k.AmountInTransactionCurrency
      //            else cast(0 as abap.curr(15,2))
      //          end
      //        )
      //      )               else cast(0 as abap.curr(15,2))                       end
      //      * case when n.IsReversed = 'X' then -1 else 1 end as totaltax1,
      //      as totaltax1,


      @Semantics.amount.currencyCode: 'DocumentCurrency'
      (
      case
      when b.TaxCode = 'R1' or b.TaxCode = 'R2' or b.TaxCode = 'R3' or b.TaxCode = 'R4' or b.TaxCode = 'RA' or
        b.TaxCode = 'RB' or b.TaxCode = 'RC' or b.TaxCode = 'RD'
      //             or (b.TaxCode = 'R5' or b.TaxCode = 'R6' or b.TaxCode = 'R7' or b.TaxCode = 'R8' or b.TaxCode = 'R9')
      then cast(0 as abap.dec(15,2))
      //      when k.TransactionTypeDetermination = 'JIC' or k.TransactionTypeDetermination = 'JIS' or k.TransactionTypeDetermination = 'JII'
      //      //        or k.TransactionTypeDetermination = 'JIU'
      //      then cast( k.AmountInTransactionCurrency as abap.dec(15,2) )
      //      else cast(0 as abap.dec(15,2))
      else cast( coalesce( k.CGST, 0 ) + coalesce( k.UGST, 0 ) + coalesce( k.IGST, 0 ) + coalesce( k.SGST, 0 ) as abap.dec(15,2) )
      end
      ) * case when n.IsReversed = 'X' then -1 else 1 end         as totaltaxamt
      //      case
      //        when (b.TaxCode = 'R1' or b.TaxCode = 'R2' or b.TaxCode = 'R3' or b.TaxCode = 'R4' or b.TaxCode = 'RA' or
      //        b.TaxCode = 'RB' or b.TaxCode = 'RC' or b.TaxCode = 'RD')
      //             or (b.TaxCode = 'R5' or b.TaxCode = 'R6' or b.TaxCode = 'R7' or b.TaxCode = 'R8' or b.TaxCode = 'R9')
      //          then cast(0 as abap.curr(15,2))
      //        when k.TransactionTypeDetermination = 'JIC' or k.TransactionTypeDetermination = 'JIS' or k.TransactionTypeDetermination = 'JII'
      //        or k.TransactionTypeDetermination = 'JIU'
      //          then k.AmountInTransactionCurrency
      //        else cast(0 as abap.curr(15,2))
      //      end                                                                       as totaltaxamt
      //      (
      //        sum(
      //          case
      //            when k.TransactionTypeDetermination = 'JIC' then k.AmountInTransactionCurrency
      //            else cast(0 as abap.curr(15,2))
      //          end
      //        )
      //        +
      //        sum(
      //          case
      //            when k.TransactionTypeDetermination = 'JIS' then k.AmountInTransactionCurrency
      //            else cast(0 as abap.curr(15,2))
      //          end
      //        )
      //        +
      //        sum(
      //          case
      //            when k.TransactionTypeDetermination = 'JII' then k.AmountInTransactionCurrency
      //            else cast(0 as abap.curr(15,2))
      //          end
      //        )
      //        +
      //        sum(
      //          case
      //            when k.TransactionTypeDetermination = 'JIU' then k.AmountInTransactionCurrency
      //            else cast(0 as abap.curr(15,2))
      //          end
      //        )
      //        +
      //        sum(
      //          case
      //            when k.TransactionTypeDetermination = 'JRI' then b.SupplierInvoiceItemAmount
      //            else cast(0 as abap.curr(15,2))
      //          end
      //        )
      //        +
      //        sum(
      //          case
      //            when k.TransactionTypeDetermination = 'JRC' then b.SupplierInvoiceItemAmount
      //            else cast(0 as abap.curr(15,2))
      //          end
      //        )
      //        +
      //        sum(
      //          case
      //            when k.TransactionTypeDetermination = 'JRS' then b.SupplierInvoiceItemAmount
      //            else cast(0 as abap.curr(15,2))
      //          end
      //        )
      //        +
      //        sum(
      //          case
      //            when k.TransactionTypeDetermination = 'JRU' then b.SupplierInvoiceItemAmount
      //            else cast(0 as abap.curr(15,2))
      //          end
      //        )
      //      )                                       as totaltaxamt


}

group by
  A.InvoicingParty,
  A.FiscalYear,
  A.SupplierInvoiceWthnFiscalYear,
  A.SupplierInvoice,
  b.SupplierInvoiceItem,
  b.PurchaseOrder,
  b.Plant,
  b.PurchaseOrderItem,
  d.Supplier,
  A.DocumentDate,
  A.PostingDate,
  A.SupplierInvoiceIDByInvcgParty,
  d.PurchaseOrderType,
  A.DocumentCurrency,
  A.InvoiceGrossAmount,
  b.PurchaseOrderItemMaterial,
  b.PurchaseOrderQuantityUnit,
  b.QuantityInPurchaseOrderUnit,
  b.SupplierInvoiceItemAmount,
  b.TaxCode,
  b.SuplrInvcDeliveryCostCndnType,
  b.SuplrInvcItmUnplndDelivCost,
  b.SupplierInvoiceItemText,
  A.ExchangeRate,
  e.BPTaxNumber,
  f.CityName,
  f.BPSupplierFullName,
  h.TaxCodeName,
  i.Name,
  g.ProductType,
  g.PurchaseOrderItemText,
  j.igst_rate,
  j.sgst_rate,
  j.cgst_rate,
  j.rcm_igst_rate,
  j.rcm_cgst_rate,
  j.rcm_sgst_rate,
  j.ugst_rate,
  j.rcm_ugst_rate,
  k.AccountingDocument,
  L.BPIdentificationNumber,
  M.BusinessPartnerPanNumber,
  A.CompanyCode,
  A.BusinessPlace,
  f.BPAddrStreetName,
  A.PaymentTerms,
  g.IncotermsClassification,
  k.TaxItemGroup,
  //  k.IN_HSNOrSACCode,    /COMMENTED BY SANKET
  k.GLAccount,
  //  k.TransactionTypeDetermination,   /COMMENTED BY SANKET
  k.AmountInTransactionCurrency,
  k.TaxItemGroup,
  k.IGST, //ADDED BY SANKET
  k.CGST, //ADDED BY SANKET
  k.UGST, //ADDED BY SANKET
  k.SGST, //ADDED BY SANKET
  k.RMCGST,
  k.RMUGST,
  k.RMSGST,
  k.RMIGST,
  //  k.IN_HSNOrSACCode,
  //  k.GLAccount,
  //  k.TransactionTypeDetermination,  /COMMENTED BY SANKET
  //  k_n.CGSTAmount,
  //  k_n.SGSTAmount,
  //  k_n.IGSTAmount,
  //  k_n.UGSTAmount,
  n.IsReversed
//  k.GLAccount
