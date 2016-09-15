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
    [Require("Cocoapods.Podfile.Target", "pod 'RMStore/AppReceiptVerificator'")]
    [ForeignInclude(Language.ObjC, "RMStore.h")]
    [ForeignInclude(Language.ObjC, "RMAppReceipt.h")]
    [ForeignInclude(Language.ObjC, "RMStoreAppReceiptVerificator.h")]
    extern(iOS)
    public class ReceiptVerifier
    {
        static ObjC.Object _delegate;

        static public void Init()
        {
            AttachDelegate();
        }

        [Foreign(Language.ObjC)]
        static void AttachDelegate()
        @{
            @{_delegate:Set([[RMStoreAppReceiptVerificator alloc] init])};
            [RMStore defaultStore].receiptVerificator = @{_delegate};
        @}

        [Foreign(Language.ObjC)]
        static ObjC.Object GetReceipt()
        @{
            return [RMAppReceipt bundleReceipt];
        @}


        [Foreign(Language.ObjC)]
        static ObjC.Object GetReceiptTransactionsInner()
        @{
            return [@{GetReceipt():Call()} inAppPurchases];
        @}

        public static IList<ReceiptTransactionInfo> GetReceiptTransactions()
        {
            return Helpers.MapNSArray<ReceiptTransactionInfo>(ReceiptTransactionInfo.Create, GetReceiptTransactionsInner());
        }
    }
}
