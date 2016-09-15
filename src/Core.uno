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
    extern(!iOS)
    public class Core
    {
        static public void Init() { }
    }

    [Require("Cocoapods.Podfile.Target", "pod 'RMStore', '~> 0.7'")]
    [ForeignInclude(Language.ObjC, "RMStore.h")]
    extern(iOS)
    public class Core
    {
        static public void Init()
        {
            ReceiptVerifier.Init();
        }

        [Foreign(Language.ObjC)]
        public static string GetEncryptedReceiptAsBase64()
        @{
            NSURL* receiptURL = (NSURL*)@{GetReceiptUrl():Call()};
            if (![[NSFileManager defaultManager] fileExistsAtPath:[receiptURL path]])
                return NULL;
            NSData* receiptData = [NSData dataWithContentsOfURL:receiptURL];
            NSString* b64 = [receiptData base64EncodedStringWithOptions:NSDataBase64EncodingEndLineWithCarriageReturn];
            return b64;
        @}

        [Foreign(Language.ObjC)]
        public static ObjC.Object GetReceiptUrl()
        @{
            return [[NSBundle mainBundle] appStoreReceiptURL];
        @}


        static bool GetCanMakePayments()
        @{
            return RMStore.canMakePayments;
        @}

        public static bool CanMakePayments
        {
            // seems redundent to expose like this, but its a tiny bit of work for a
            // slightly more uno friendly api (should anyone care about that in future)
            get { return GetCanMakePayments(); }
        }

        public static IList<ReceiptTransactionInfo> GetReceiptTransactions()
        {
            return ReceiptVerifier.GetReceiptTransactions();
        }

        // Requesting products
        public static Promise<KeyValuePair<IList<SKProductInformation>, IList<string>>> RequestProducts(IEnumerable<string> products)
        {
            return new RequestProducts(products);
        }

        // Add payment
        public static Promise<SKPaymentTransactionInfo> AddPayment(string product)
        {
            return new AddPayment(product);
        }

        public static Promise<SKPaymentTransactionInfo> AddPayment(string product, string applicationUsername)
        {
            return new AddPayment(product, applicationUsername);
        }

        // Restore transactions
        public static Promise<IList<SKPaymentTransactionInfo>> RestoreTransactions()
        {
            return new RestoreTransactions();
        }

        public static Promise<IList<SKPaymentTransactionInfo>> RestoreTransactions(string applicationUsername)
        {
            return new RestoreTransactions(applicationUsername);
        }

        // Refresh receipt
        public static Promise<string> RefreshReceipt()
        {
            return new RefreshReceipt();
        }
    }
}
