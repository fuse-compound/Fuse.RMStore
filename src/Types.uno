using Uno;
using Uno.UX;
using Uno.Threading;
using Uno.Collections;
using Uno.Compiler.ExportTargetInterop;
using Fuse;
using Fuse.Triggers;
using Fuse.Controls;
using Fuse.Controls.Native;
using Fuse.Controls.Native.Android;

namespace Fuse.URMStore
{
    [ForeignInclude(Language.ObjC, "RMStore.h")]
    extern(iOS)
    public class SKProductInformation
    {
        ObjC.Object _handle;

        public SKProductInformation(ObjC.Object handle)
        {
            _handle = handle;
        }
        // this is only so we can map over it to make new instances
        public static SKProductInformation Create(ObjC.Object handle)
        {
            return new SKProductInformation(handle);
        }

        // 'Holy shit, why are you returning a price as a string' you may rightly ask
        // the reason is that JS has no sensible number format for this by default and
        // I'd rather be exact textually that inaccurate numerically.
        public string Price { get { return Helpers.FormatDecimalAsPrice(GetPrice(), GetPriceLocale()); } }
        public string PriceLocale { get { return GetPriceLocaleName(); } }
        public string LocalizedDescription { get { return GetLocalizedDescription(); } }
        public string ProductIdentifier { get { return GetProductIdentifier(); } }
        public string LocalizedTitle { get { return GetLocalizedTitle(); } }

        [Foreign(Language.ObjC)]
        ObjC.Object GetPrice()
        @{
            return [@{SKProductInformation:Of(_this)._handle} price];
        @}

        [Foreign(Language.ObjC)]
        string GetPriceLocaleName()
        @{
            return [@{SKProductInformation:Of(_this).GetPriceLocale():Call()} localeIdentifier];
        @}

        [Foreign(Language.ObjC)]
        ObjC.Object GetPriceLocale()
        @{
            return [@{SKProductInformation:Of(_this)._handle} priceLocale];
        @}

        [Foreign(Language.ObjC)]
        string GetLocalizedDescription()
        @{
            return [@{SKProductInformation:Of(_this)._handle} localizedDescription];
        @}

        [Foreign(Language.ObjC)]
        string GetProductIdentifier()
        @{
            return [@{SKProductInformation:Of(_this)._handle} productIdentifier];
        @}

        [Foreign(Language.ObjC)]
        string GetLocalizedTitle()
        @{
            return [@{SKProductInformation:Of(_this)._handle} localizedTitle];
        @}
    }

    [ForeignInclude(Language.ObjC, "RMStore.h")]
    extern(iOS)
    public class SKPaymentInfo
    {
        ObjC.Object _handle;

        public SKPaymentInfo(ObjC.Object handle)
        {
            _handle = handle;
        }

        public string ProductIdentifier { get { return GetProductIdentifier(); } }

        [Foreign(Language.ObjC)]
        string GetProductIdentifier()
        @{
            return [@{SKPaymentInfo:Of(_this)._handle} productIdentifier];
        @}

        public string ApplicationUsername { get { return GetApplicationUsername(); } }

        [Foreign(Language.ObjC)]
        string GetApplicationUsername()
        @{
            return [@{SKPaymentInfo:Of(_this)._handle} applicationUsername];
        @}

        public int Quantity { get { return GetQuantity(); } }

        [Foreign(Language.ObjC)]
        int GetQuantity()
        @{
            return [((SKPayment*)@{SKPaymentInfo:Of(_this)._handle}) quantity];
        @}

        //simulatesAskToBuyInSandbox
    }

    [ForeignInclude(Language.ObjC, "RMStore.h")]
    extern(iOS)
    public class SKPaymentTransactionInfo
    {
        public enum State {
            Purchasing,
            Purchased,
            Failed,
            Restored,
            Deferred,
        }

        public static string StateToString(State x)
        {
            switch (x)
            {
            case State.Purchasing:
                return "Purchasing";
            case State.Purchased:
                return "Purchased";
            case State.Failed:
                return "Failed";
            case State.Restored:
                return "Restored";
            case State.Deferred:
                return "Deferred";
            }
            throw new Exception("Invalid state passed to StateToString");
        }

        ObjC.Object _handle;

        public SKPaymentTransactionInfo(ObjC.Object handle)
        {
            _handle = handle;
        }
        // this is only so we can map over it to make new instances
        public static SKPaymentTransactionInfo Create(ObjC.Object handle)
        {
            return new SKPaymentTransactionInfo(handle);
        }

        public string Error { get { return GetError(); } }

        [Foreign(Language.ObjC)]
        string GetError()
        @{
            NSError* err = [@{SKPaymentTransactionInfo:Of(_this)._handle} error];
            if (err)
                return [err localizedDescription];
            else
                return NULL;
        @}

        public SKPaymentInfo Payment { get { return new SKPaymentInfo(GetPayment()); } }

        [Foreign(Language.ObjC)]
        ObjC.Object GetPayment()
        @{
            return [@{SKPaymentTransactionInfo:Of(_this)._handle} payment];
        @}

        public State TransactionState { get { return GetTransactionState(); } }

        [Foreign(Language.ObjC)]
        State GetTransactionState()
        @{
            return (@{State})[@{SKPaymentTransactionInfo:Of(_this)._handle} transactionState];
        @}

        public string TransactionIdentifier { get { return GetTransactionIdentifier(); } }

        [Foreign(Language.ObjC)]
        string GetTransactionIdentifier()
        @{
            return [@{SKPaymentTransactionInfo:Of(_this)._handle} transactionIdentifier];
        @}

        public string TransactionDate { get { return Helpers.NSDateToUTCISO(GetTransactionDate()); } }

        [Foreign(Language.ObjC)]
        ObjC.Object GetTransactionDate()
        @{
            return [@{SKPaymentTransactionInfo:Of(_this)._handle} transactionDate];
        @}
    }


    [ForeignInclude(Language.ObjC, "RMStore.h")]
    [Require("Source.Include", "RMAppReceipt.h")]
    extern(iOS)
    public class ReceiptTransactionInfo
    {
        [ForeignTypeName("RMAppReceiptIAP*")]
        class RMAppReceiptIAP : ObjC.Object { }

        RMAppReceiptIAP _handle;

        public ReceiptTransactionInfo(ObjC.Object handle)
        {
            _handle = (RMAppReceiptIAP)handle;
        }
        // this is only so we can map over it to make new instances
        public static ReceiptTransactionInfo Create(ObjC.Object handle)
        {
            return new ReceiptTransactionInfo(handle);
        }

        public int Quantity { get { return GetQuantity(); } }

        [Foreign(Language.ObjC)]
        int GetQuantity()
        @{
            return [@{ReceiptTransactionInfo:Of(_this)._handle} quantity];
        @}

        public string ProductIdentifier { get { return GetProductIdentifier(); } }

        [Foreign(Language.ObjC)]
        string GetProductIdentifier()
        @{
            return [@{ReceiptTransactionInfo:Of(_this)._handle} productIdentifier];
        @}

        public string TransactionIdentifier { get { return GetTransactionIdentifier(); } }

        [Foreign(Language.ObjC)]
        string GetTransactionIdentifier()
        @{
            return [@{ReceiptTransactionInfo:Of(_this)._handle} transactionIdentifier];
        @}

        public string OriginalTransactionIdentifier { get { return GetOriginalTransactionIdentifier(); } }

        [Foreign(Language.ObjC)]
        string GetOriginalTransactionIdentifier()
        @{
            return [@{ReceiptTransactionInfo:Of(_this)._handle} originalTransactionIdentifier];
        @}

        public string PurchaseDate { get { return Helpers.NSDateToUTCISO(GetPurchaseDate()); } }

        [Foreign(Language.ObjC)]
        ObjC.Object GetPurchaseDate()
        @{
            return [@{ReceiptTransactionInfo:Of(_this)._handle} purchaseDate];
        @}

        public string OriginalPurchaseDate { get { return Helpers.NSDateToUTCISO(GetOriginalPurchaseDate()); } }

        [Foreign(Language.ObjC)]
        ObjC.Object GetOriginalPurchaseDate()
        @{
            return [@{ReceiptTransactionInfo:Of(_this)._handle} originalPurchaseDate];
        @}

        public string SubscriptionExpirationDate { get { return Helpers.NSDateToUTCISO(GetSubscriptionExpirationDate()); } }

        [Foreign(Language.ObjC)]
        ObjC.Object GetSubscriptionExpirationDate()
        @{
            return [@{ReceiptTransactionInfo:Of(_this)._handle} subscriptionExpirationDate];
        @}

        public string CancellationDate { get { return Helpers.NSDateToUTCISO(GetCancellationDate()); } }

        [Foreign(Language.ObjC)]
        ObjC.Object GetCancellationDate()
        @{
            return [@{ReceiptTransactionInfo:Of(_this)._handle} cancellationDate];
        @}

        public int WebOrderLineItemID { get { return GetWebOrderLineItemID(); } }

        [Foreign(Language.ObjC)]
        int GetWebOrderLineItemID()
        @{
            NSInteger liid = (NSInteger)[@{ReceiptTransactionInfo:Of(_this)._handle} webOrderLineItemID];
            return (@{int})liid;
        @}
    }
}
