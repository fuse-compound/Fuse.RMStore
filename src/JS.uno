using Uno;
using Uno.UX;
using Uno.Threading;
using Uno.Text;
using Uno.Platform;
using Uno.Compiler.ExportTargetInterop;
using Uno.Collections;
using Fuse;
using Fuse.Scripting;
using Fuse.Reactive;

namespace Fuse.URMStore
{
    /**
    */
    [UXGlobalModule]
    public sealed class URMStoreModule : NativeModule
    {
        static readonly URMStoreModule _instance;

        public URMStoreModule()
        {
            if(_instance != null) return;
            Uno.UX.Resource.SetGlobalKey(_instance = this, "RMStore");

            Core.Init();
            if defined(iOS)
            {
                AddMember(new NativeProperty<bool, bool>("canMakePayments", CanMakePayments));

                AddMember(new NativeFunction("getReceiptTransactions", GetReceiptTransactions));

                AddMember(new NativeFunction("getEncryptedReceiptAsBase64", GetEncryptedReceiptAsBase64));

                AddMember(new NativePromise<KeyValuePair<IList<SKProductInformation>, IList<string>>, Scripting.Object>(
                              "requestProducts", RequestProducts, ListOfSKProductInformationToJS));
                AddMember(new NativePromise<SKPaymentTransactionInfo, Scripting.Object>(
                              "addPayment", AddPayment, SKPaymentTransactionInfoToJS));
                AddMember(new NativePromise<IList<SKPaymentTransactionInfo>, Scripting.Array>(
                              "restoreTransactions", RestoreTransactions, ListOfSKPaymentTransactionInfoToJS));
                AddMember(new NativePromise<string, string>("refreshReceipt", RefreshReceipt));
            }
        }

        //----------------------------------------------------------------------

        extern(iOS)
        static bool CanMakePayments()
        {
            return Core.CanMakePayments;
        }

        //----------------------------------------------------------------------

        extern(iOS)
        static string GetEncryptedReceiptAsBase64(Context c, object[] args)
        {
            return Core.GetEncryptedReceiptAsBase64();
        }

        //----------------------------------------------------------------------

        extern(iOS)
        static Future<string> RefreshReceipt(object[] args)
        {
            return Core.RefreshReceipt();
        }

        //----------------------------------------------------------------------

        extern(iOS)
        static Scripting.Array GetReceiptTransactions(Context c, object[] args)
        {
            return Helpers.MapToJS<ReceiptTransactionInfo>(c, ReceiptTransactionInfoToJS, Core.GetReceiptTransactions());
        }

        extern(iOS)
        static Scripting.Object ReceiptTransactionInfoToJS(Context c, ReceiptTransactionInfo rt)
        {
            var res = c.NewObject();
            res["quantity"] = rt.Quantity;
            res["productIdentifier"] = rt.ProductIdentifier;
            res["transactionIdentifier"] = rt.TransactionIdentifier;
            res["originalTransactionIdentifier"] = rt.OriginalTransactionIdentifier;
            res["purchaseDate"] = rt.PurchaseDate;
            res["originalPurchaseDate"] = rt.OriginalPurchaseDate;
            res["subscriptionExpirationDate"] = rt.SubscriptionExpirationDate;
            res["cancellationDate"] = rt.CancellationDate;
            res["webOrderLineItemID"] = rt.WebOrderLineItemID;
            return res;
        }

        //----------------------------------------------------------------------

        extern(iOS)
        static Future<IList<SKPaymentTransactionInfo>> RestoreTransactions(object[] args)
        {
            if (args.Length == 1)
                return Core.RestoreTransactions((string)args[0]);
            else
                return Core.RestoreTransactions();
        }

        extern(iOS)
        public static Scripting.Array ListOfSKPaymentTransactionInfoToJS(Context c, IList<SKPaymentTransactionInfo> results)
        {
            return Helpers.MapToJS<SKPaymentTransactionInfo>(c, SKPaymentTransactionInfoToJS, results);
        }

        //----------------------------------------------------------------------

        extern(iOS)
        static Future<SKPaymentTransactionInfo> AddPayment(object[] args)
        {
            if (args.Length == 2)
                return Core.AddPayment((string)args[0], (string)args[1]);
            else
                return Core.AddPayment((string)args[0]);
        }

        extern(iOS)
        static Scripting.Object SKPaymentTransactionInfoToJS(Context c, SKPaymentTransactionInfo pid)
        {
            var res = c.NewObject();
            res["payment"] = SKPaymentInfoToJS(c, pid.Payment);
            res["transactionState"] = SKPaymentTransactionInfo.StateToString(pid.TransactionState);
            res["transactionIdentifier"] = pid.TransactionIdentifier;
            res["transactionDateUTC"] = pid.TransactionDate;
            res["error"] = pid.Error;
            return res;
        }

        extern(iOS)
        static Scripting.Object SKPaymentInfoToJS(Context c, SKPaymentInfo payment)
        {
            var res = c.NewObject();
            res["productIdentifier"] = payment.ProductIdentifier;
            res["quantity"] = payment.Quantity;
            res["applicationUsername"] = payment.ApplicationUsername;
            return res;
        }

        //-----------------------------------------------------------------------

        extern(iOS)
        static Future<KeyValuePair<IList<SKProductInformation>, IList<string>>> RequestProducts(object[] args)
        {
            var jsIDs = (Scripting.Array)args[0];
            var ids = new List<string>();

            for (var i = 0; i < jsIDs.Length; i++)
                ids.Add((string)jsIDs[i]);

            return Core.RequestProducts(ids);
        }

        extern(iOS)
        public static Scripting.Object ListOfSKProductInformationToJS(Context c, KeyValuePair<IList<SKProductInformation>, IList<string>> result)
        {
            var queryResult = c.NewObject();
            queryResult["valid"] = Helpers.MapToJS<SKProductInformation>(c, SKProductInformationToJS, result.Key);
            queryResult["invalid"] = Helpers.ToJSArr<string>(c, result.Value);
            return queryResult;
        }

        extern(iOS)
        public static Scripting.Object SKProductInformationToJS(Context c, SKProductInformation pid)
        {
            var res = c.NewObject();
            res["price"] = pid.Price;
            res["priceLocale"] = pid.PriceLocale;
            res["localizedDescription"] = pid.LocalizedDescription;
            res["productIdentifier"] = pid.ProductIdentifier;
            res["localizedTitle"] = pid.LocalizedTitle;
            return res;
        }
    }
}
