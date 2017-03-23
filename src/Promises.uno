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
    //----------------------------------------------------------------------

    [Require("Source.Include", "@{Helpers:Include}")]
    [ForeignInclude(Language.ObjC, "RMStore.h")]
    extern(iOS)
    internal class RequestProducts : Promise<KeyValuePair<IList<SKProductInformation>, IList<string>>>
    {
        [Foreign(Language.ObjC)]
        public RequestProducts(IEnumerable<string> products)
        @{
            NSSet* requestedProducts = @{Helpers.ToNSSet(IEnumerable<string>):Call(products)};

            [[RMStore defaultStore] requestProducts:requestedProducts success:^(NSArray* validProducts, NSArray* invalidProductIdentifiers) {
                @{RequestProducts:Of(_this).Resolve(ObjC.Object, ObjC.Object):Call(validProducts, invalidProductIdentifiers)};
            } failure:^(NSError *error) {
                @{RequestProducts:Of(_this).Reject(string):Call(@"failed")};
            }];
        @}

        void Resolve(ObjC.Object validProducts, ObjC.Object invalidProductIDs)
        {
            Resolve(new KeyValuePair<IList<SKProductInformation>, IList<string>> (
                        Helpers.MapNSArray<SKProductInformation>(SKProductInformation.Create, validProducts),
                        Helpers.MapNSArray<string>(Helpers.NSObjectToString, invalidProductIDs)));
        }

        void Reject(string reason) { Reject(new Exception(reason)); }
    }

    //----------------------------------------------------------------------

    [Require("Source.Include", "@{Helpers:Include}")]
    [ForeignInclude(Language.ObjC, "RMStore.h")]
    extern(iOS)
    internal class AddPayment : Promise<SKPaymentTransactionInfo>
    {
        [Foreign(Language.ObjC)]
        public AddPayment(string product)
        @{
            [[RMStore defaultStore] addPayment:product success:^(SKPaymentTransaction* transaction) {
                @{AddPayment:Of(_this).Resolve(ObjC.Object):Call(transaction)};
            } failure:^(SKPaymentTransaction *transaction, NSError *error) {
                @{AddPayment:Of(_this).Reject(string):Call(@"failed")};
            }];
        @}

        [Foreign(Language.ObjC)]
        public AddPayment(string product, string applicationUsername)
        @{
            [[RMStore defaultStore] addPayment:product user:applicationUsername
             success:^(SKPaymentTransaction* transaction) {
                @{AddPayment:Of(_this).Resolve(ObjC.Object):Call(transaction)};
            } failure:^(SKPaymentTransaction *transaction, NSError *error) {
                @{AddPayment:Of(_this).Reject(string):Call(@"failed")};
            }];
        @}

        void Resolve(ObjC.Object transaction)
        {
            Resolve(new SKPaymentTransactionInfo(transaction));
        }

        void Reject(string reason) { Reject(new Exception(reason)); }
    }

    //----------------------------------------------------------------------

    [Require("Source.Include", "@{Helpers:Include}")]
    [ForeignInclude(Language.ObjC, "RMStore.h")]
    extern(iOS)
    internal class RestoreTransactions : Promise<IList<SKPaymentTransactionInfo>>
    {
        [Foreign(Language.ObjC)]
        public RestoreTransactions()
        @{
            [[RMStore defaultStore] restoreTransactionsOnSuccess:^(NSArray *transactions){
                @{RestoreTransactions:Of(_this).Resolve(ObjC.Object):Call(transactions)};
            } failure:^(NSError *error) {
                @{RestoreTransactions:Of(_this).Reject(string):Call(@"failed")};
            }];
        @}

        [Foreign(Language.ObjC)]
        public RestoreTransactions(string applicationUsername)
        @{
            [[RMStore defaultStore] restoreTransactionsOfUser:applicationUsername
             onSuccess:^(NSArray *transactions){
                @{RestoreTransactions:Of(_this).Resolve(ObjC.Object):Call(transactions)};
            } failure:^(NSError *error) {
                @{RestoreTransactions:Of(_this).Reject(string):Call(@"failed")};
            }];
        @}

        void Resolve(ObjC.Object transactions)
        {
            Resolve(Helpers.MapNSArray<SKPaymentTransactionInfo>(SKPaymentTransactionInfo.Create, transactions));
        }

        void Reject(string reason) { Reject(new Exception(reason)); }
    }

    //----------------------------------------------------------------------

    [Require("Source.Include", "@{Helpers:Include}")]
    [ForeignInclude(Language.ObjC, "RMStore.h")]
    extern(iOS)
    internal class RefreshReceipt : Promise<string>
    {
        [Foreign(Language.ObjC)]
        public RefreshReceipt()
        @{
            [[RMStore defaultStore] refreshReceiptOnSuccess:^{
                @{RefreshReceipt:Of(_this).Resolve():Call()};
            } failure:^(NSError *error) {
                @{RefreshReceipt:Of(_this).Reject(string):Call(@"failed")};
            }];
        @}

        void Resolve()
        {
            Resolve("success");
        }

        void Reject(string reason) { Reject(new Exception(reason)); }
    }

    //----------------------------------------------------------------------
}
